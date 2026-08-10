#include "vphone_pjsip_bridge.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

#define VPHONE_MAX_CALL_SNAPSHOTS 32

static vphone_call_info_snapshot
    g_call_snapshots[VPHONE_MAX_CALL_SNAPSHOTS];
static void (*g_original_on_call_state)(pjsua_call_id call_id,
                                        pjsip_event *event) = NULL;

static int vphone_valid_call_id(int call_id) {
  return call_id >= 0 && call_id < VPHONE_MAX_CALL_SNAPSHOTS;
}

static int64_t vphone_now_ms(void) {
  return (int64_t)time(NULL) * 1000;
}

static void vphone_copy_text(char *dst, size_t dst_size, const char *src) {
  if (dst == NULL || dst_size == 0) return;
  dst[0] = '\0';
  if (src == NULL) return;
  snprintf(dst, dst_size, "%s", src);
}

static void vphone_copy_pj_str(char *dst, size_t dst_size, const pj_str_t *src) {
  size_t len;

  if (dst == NULL || dst_size == 0) return;
  dst[0] = '\0';
  if (src == NULL || src->ptr == NULL || src->slen <= 0) return;

  len = (size_t)src->slen;
  if (len >= dst_size) len = dst_size - 1;
  memcpy(dst, src->ptr, len);
  dst[len] = '\0';
}

static const char *vphone_role_label(int role) {
  switch (role) {
    case PJSIP_ROLE_UAC:
      return "UAC";
    case PJSIP_ROLE_UAS:
      return "UAS";
    default:
      return "UNKNOWN";
  }
}

static const char *vphone_tsx_state_label(int state) {
  switch (state) {
    case PJSIP_TSX_STATE_NULL:
      return "NULL";
    case PJSIP_TSX_STATE_CALLING:
      return "CALLING";
    case PJSIP_TSX_STATE_TRYING:
      return "TRYING";
    case PJSIP_TSX_STATE_PROCEEDING:
      return "PROCEEDING";
    case PJSIP_TSX_STATE_COMPLETED:
      return "COMPLETED";
    case PJSIP_TSX_STATE_CONFIRMED:
      return "CONFIRMED";
    case PJSIP_TSX_STATE_TERMINATED:
      return "TERMINATED";
    case PJSIP_TSX_STATE_DESTROYED:
      return "DESTROYED";
    default:
      return "UNKNOWN";
  }
}

static const char *vphone_event_type_label(int type) {
  switch (type) {
    case PJSIP_EVENT_UNKNOWN:
      return "UNKNOWN";
    case PJSIP_EVENT_TIMER:
      return "TIMER";
    case PJSIP_EVENT_TX_MSG:
      return "TX_MSG";
    case PJSIP_EVENT_RX_MSG:
      return "RX_MSG";
    case PJSIP_EVENT_TRANSPORT_ERROR:
      return "TRANSPORT_ERROR";
    case PJSIP_EVENT_TSX_STATE:
      return "TSX_STATE";
    case PJSIP_EVENT_USER:
      return "USER";
    default:
      return "UNKNOWN";
  }
}

static const char *vphone_inv_state_label(int state) {
  switch (state) {
    case PJSIP_INV_STATE_NULL:
      return "NULL";
    case PJSIP_INV_STATE_CALLING:
      return "CALLING";
    case PJSIP_INV_STATE_INCOMING:
      return "INCOMING";
    case PJSIP_INV_STATE_EARLY:
      return "EARLY";
    case PJSIP_INV_STATE_CONNECTING:
      return "CONNECTING";
    case PJSIP_INV_STATE_CONFIRMED:
      return "CONFIRMED";
    case PJSIP_INV_STATE_DISCONNECTED:
      return "DISCONNECTED";
    default:
      return "UNKNOWN";
  }
}

static int vphone_should_keep_method(const char *method) {
  if (method == NULL) return 0;
  return strcmp(method, "INVITE") == 0 || strcmp(method, "CANCEL") == 0 ||
         strcmp(method, "BYE") == 0 || strcmp(method, "REFER") == 0;
}

static int vphone_snapshot_has_status(
    const vphone_call_info_snapshot *snapshot) {
  return snapshot != NULL &&
         (snapshot->status_code > 0 || snapshot->status_text[0] != '\0');
}

static int vphone_snapshot_score(const vphone_call_info_snapshot *snapshot) {
  int code;

  if (!vphone_snapshot_has_status(snapshot)) return 0;

  code = snapshot->status_code;
  if (code >= 300) return 4000 + code;
  if (code >= 200) return 3000 + code;
  if (code >= 100) return 1000 + code;
  return 500;
}

static int vphone_should_replace_snapshot(
    const vphone_call_info_snapshot *previous,
    const vphone_call_info_snapshot *next_snapshot) {
  int previous_score;
  int next_score;

  if (next_snapshot == NULL || !next_snapshot->valid) return 0;
  if (previous == NULL || !previous->valid) return 1;

  previous_score = vphone_snapshot_score(previous);
  next_score = vphone_snapshot_score(next_snapshot);

  /*
   * 结束原因优先级：最终失败码(3xx-6xx) > 成功终态(2xx) > 临时状态(1xx)。
   * 这样 100 Trying 不会覆盖 487/486/603 等真正该给用户看的原因。
   */
  return next_score >= previous_score;
}

static void vphone_on_call_tsx_state(
    pjsua_call_id call_id,
    pjsip_transaction *tsx,
    pjsip_event *event) {
  vphone_call_info_snapshot next_snapshot;
  const vphone_call_info_snapshot *previous;
  const char *event_type;

  if (!vphone_valid_call_id(call_id) || tsx == NULL) return;

  memset(&next_snapshot, 0, sizeof(next_snapshot));
  next_snapshot.call_id = call_id;
  next_snapshot.status_code = tsx->status_code;
  next_snapshot.role_code = (int)tsx->role;
  next_snapshot.transaction_state_code = (int)tsx->state;
  next_snapshot.updated_at_ms = vphone_now_ms();
  vphone_copy_pj_str(
      next_snapshot.method,
      sizeof(next_snapshot.method),
      &tsx->method.name);
  if (!vphone_should_keep_method(next_snapshot.method)) return;

  /*
   * 只复制当前回调参数里的普通字段，不调用 pjsua_call_get_info()。
   * 这个回调可能处在 PJSIP 锁内，调用更高层 PJSUA API 有死锁风险。
   */
  vphone_copy_text(
      next_snapshot.role,
      sizeof(next_snapshot.role),
      vphone_role_label(next_snapshot.role_code));
  vphone_copy_text(
      next_snapshot.transaction_state,
      sizeof(next_snapshot.transaction_state),
      vphone_tsx_state_label(next_snapshot.transaction_state_code));
  vphone_copy_pj_str(
      next_snapshot.status_text,
      sizeof(next_snapshot.status_text),
      &tsx->status_text);

  if (event == NULL) {
    next_snapshot.event_type_code = PJSIP_EVENT_UNKNOWN;
    event_type = "UNKNOWN";
  } else if (event->type == PJSIP_EVENT_TSX_STATE) {
    next_snapshot.event_type_code = (int)event->body.tsx_state.type;
    event_type = vphone_event_type_label(next_snapshot.event_type_code);
  } else {
    next_snapshot.event_type_code = (int)event->type;
    event_type = vphone_event_type_label(next_snapshot.event_type_code);
  }
  vphone_copy_text(
      next_snapshot.event_type,
      sizeof(next_snapshot.event_type),
      event_type);

  next_snapshot.valid = 1;
  previous = &g_call_snapshots[call_id];
  if (vphone_should_replace_snapshot(previous, &next_snapshot)) {
    g_call_snapshots[call_id] = next_snapshot;
  }
}

static void vphone_store_call_state_snapshot(pjsua_call_id call_id) {
  pjsua_call_info info;
  vphone_call_info_snapshot next_snapshot;
  const vphone_call_info_snapshot *previous;

  if (!vphone_valid_call_id(call_id)) return;

  /*
   * 这个函数运行在 PJSIP 同步 on_call_state 回调里，此时 call_info 通常还没
   * 被释放。Dart 的 NativeCallable.listener 是异步的，等 Dart 再查就可能
   * 已释放，所以这里提前复制 last_status/last_status_text。
   */
  if (pjsua_call_get_info(call_id, &info) != PJ_SUCCESS) return;

  memset(&next_snapshot, 0, sizeof(next_snapshot));
  next_snapshot.valid = 1;
  next_snapshot.call_id = call_id;
  next_snapshot.status_code = info.last_status;
  next_snapshot.updated_at_ms = vphone_now_ms();
  vphone_copy_text(next_snapshot.method, sizeof(next_snapshot.method), "CALL");
  vphone_copy_text(next_snapshot.role, sizeof(next_snapshot.role), "PJSUA");
  vphone_copy_text(
      next_snapshot.transaction_state,
      sizeof(next_snapshot.transaction_state),
      vphone_inv_state_label((int)info.state));
  vphone_copy_text(next_snapshot.event_type, sizeof(next_snapshot.event_type),
                   "CALL_STATE");
  vphone_copy_pj_str(next_snapshot.status_text, sizeof(next_snapshot.status_text),
                     &info.last_status_text);

  previous = &g_call_snapshots[call_id];
  if (vphone_should_replace_snapshot(previous, &next_snapshot)) {
    g_call_snapshots[call_id] = next_snapshot;
  }
}

static void vphone_on_call_state(pjsua_call_id call_id, pjsip_event *event) {
  vphone_store_call_state_snapshot(call_id);

  if (g_original_on_call_state != NULL) {
    (*g_original_on_call_state)(call_id, event);
  }
}

VPHONE_PJSIP_EXPORT void vphone_apply_call_snapshot_callbacks(
    pjsua_config *cfg) {
  if (cfg == NULL) return;
  g_original_on_call_state = cfg->cb.on_call_state;
  cfg->cb.on_call_state = &vphone_on_call_state;
  cfg->cb.on_call_tsx_state = &vphone_on_call_tsx_state;
}

VPHONE_PJSIP_EXPORT int vphone_get_call_info_snapshot(
    int call_id,
    vphone_call_info_snapshot *out_snapshot) {
  if (!vphone_valid_call_id(call_id) || out_snapshot == NULL) return 0;
  if (!g_call_snapshots[call_id].valid) return 0;

  *out_snapshot = g_call_snapshots[call_id];
  return 1;
}

VPHONE_PJSIP_EXPORT void vphone_clear_call_info_snapshot(int call_id) {
  if (!vphone_valid_call_id(call_id)) return;
  memset(&g_call_snapshots[call_id], 0, sizeof(g_call_snapshots[call_id]));
}

VPHONE_PJSIP_EXPORT void vphone_clear_all_call_info_snapshots(void) {
  memset(g_call_snapshots, 0, sizeof(g_call_snapshots));
}

VPHONE_PJSIP_EXPORT int vphone_get_call_media_security(
    int call_id,
    unsigned media_index,
    vphone_media_security_snapshot *out_snapshot) {
  pjmedia_transport_info transport_info;
  pj_status_t status;
  unsigned index;

  if (out_snapshot == NULL) return 0;
  memset(out_snapshot, 0, sizeof(*out_snapshot));

  status = pjsua_call_get_med_transport_info(
      (pjsua_call_id)call_id,
      media_index,
      &transport_info);
  if (status != PJ_SUCCESS) return 0;

  out_snapshot->valid = 1;
  for (index = 0; index < transport_info.specific_info_cnt; ++index) {
    pjmedia_transport_specific_info *specific_info =
        &transport_info.spc_info[index];

    if (specific_info->type == PJMEDIA_TRANSPORT_TYPE_SRTP) {
      pjmedia_srtp_info *srtp_info =
          (pjmedia_srtp_info *)specific_info->buffer;
      out_snapshot->has_srtp_transport = 1;
      out_snapshot->srtp_active = srtp_info->active ? 1 : 0;
    } else if (specific_info->type == PJMEDIA_TRANSPORT_TYPE_ICE) {
      out_snapshot->has_ice_transport = 1;
    }
  }

  return 1;
}
