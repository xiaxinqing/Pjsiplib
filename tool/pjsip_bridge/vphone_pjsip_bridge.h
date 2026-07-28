#ifndef VPHONE_PJSIP_BRIDGE_H
#define VPHONE_PJSIP_BRIDGE_H

#include <stdint.h>

#include <pjsua-lib/pjsua.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define VPHONE_PJSIP_EXPORT __declspec(dllexport)
#else
#define VPHONE_PJSIP_EXPORT __attribute__((visibility("default")))
#endif

/*
 * VPhone 自己维护的通话结束原因快照。
 *
 * 注意：这不是实时 pjsua_call_info，也不会保存 PJSIP 的原生指针。
 * on_call_tsx_state 回调里的 pjsip_transaction / pjsip_event 生命周期很短，
 * Dart 侧异步读取会有 EXC_BAD_ACCESS 风险，所以这里只把需要展示/记录的
 * 普通字段同步复制到固定数组里，供 Dart 在 call_info 已释放时兜底查询。
 */
typedef struct vphone_call_info_snapshot {
  int valid;
  int call_id;
  int status_code;
  int role_code;
  int transaction_state_code;
  int event_type_code;
  int64_t updated_at_ms;
  char method[16];
  char role[16];
  char transaction_state[24];
  char event_type[24];
  char status_text[128];
} vphone_call_info_snapshot;

/*
 * 把安全的 on_call_tsx_state 快照回调挂到 pjsua_config 上。
 *
 * 必须在 pjsua_init() 之前调用。这个函数只设置 VPhone wrapper 自己的回调，
 * 不会覆盖 Dart 已注册的 on_call_state / on_incoming_call 等其它回调。
 */
VPHONE_PJSIP_EXPORT void vphone_apply_call_snapshot_callbacks(
    pjsua_config *cfg);

/*
 * 查询某路通话最近一次 SIP transaction 快照。
 *
 * 返回 1 表示 out_snapshot 已填充，返回 0 表示没有可用快照。Dart 只应该读
 * 这里复制出来的普通值，不能再直接读取 pjsip_transaction / pjsip_event。
 */
VPHONE_PJSIP_EXPORT int vphone_get_call_info_snapshot(
    int call_id,
    vphone_call_info_snapshot *out_snapshot);

/*
 * 清理某路通话快照，避免 PJSIP 复用 call_id 后读到旧数据。
 */
VPHONE_PJSIP_EXPORT void vphone_clear_call_info_snapshot(int call_id);

/*
 * 引擎销毁或重新初始化前清空全部快照。
 */
VPHONE_PJSIP_EXPORT void vphone_clear_all_call_info_snapshots(void);

#ifdef __cplusplus
}
#endif

#endif
