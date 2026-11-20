#include "vphone_dial_worker.h"

#include <pjlib.h>
#include <condition_variable>
#include <mutex>
#include <new>
#include <queue>
#include <string>
#include <utility>

struct DialRequest {
  int64_t id;
  int account_id;
  std::string uri;
  bool is_tls;
};

struct vphone_dial_worker {
  pj_pool_t *pool = nullptr;
  pj_thread_t *thread = nullptr;
  vphone_dial_result callback;
  std::mutex mutex;
  std::condition_variable ready;
  std::queue<DialRequest> requests;
  bool stopping = false;
};

static int run_worker(void *arg) {
  auto *worker = static_cast<vphone_dial_worker *>(arg);
  for (;;) {
    DialRequest request;
    bool cancel;
    {
      std::unique_lock<std::mutex> lock(worker->mutex);
      worker->ready.wait(lock, [&] {
        return worker->stopping || !worker->requests.empty();
      });
      if (worker->requests.empty()) return 0;
      request = std::move(worker->requests.front());
      worker->requests.pop();
      cancel = worker->stopping;
    }

    pjsua_call_id call_id = PJSUA_INVALID_ID;
    pj_status_t status = PJ_ECANCELLED;
    if (!cancel) {
      status = PJ_EINVAL;
      if (pjsua_acc_is_valid(request.account_id)) {
        pjsua_call_setting settings;
        pjsua_call_setting_default(&settings);
        settings.aud_cnt = 1;
        settings.vid_cnt = 0;
        settings.txt_cnt = 0;
        if (request.is_tls) settings.req_keyframe_method = 0;
        pj_str_t uri = pj_str(&request.uri[0]);
        status = pjsua_call_make_call(request.account_id, &uri, &settings,
                                      nullptr, nullptr, &call_id);
      }
    }
    worker->callback(request.id, status,
                     status == PJ_SUCCESS ? call_id : PJSUA_INVALID_ID);
  }
}

int vphone_dial_worker_create(vphone_dial_result callback,
                              vphone_dial_worker **out_worker) {
  if (!out_worker || !callback) return PJ_EINVAL;
  *out_worker = nullptr;
  vphone_dial_worker *worker;
  try {
    worker = new vphone_dial_worker;
  } catch (const std::bad_alloc &) {
    return PJ_ENOMEM;
  }
  worker->callback = callback;
  worker->pool = pjsua_pool_create("dial_worker", 2048, 2048);
  if (!worker->pool) {
    delete worker;
    return PJ_ENOMEM;
  }
  const pj_status_t status = pj_thread_create(
      worker->pool, "vphone.dial", run_worker, worker, 512 * 1024, 0,
      &worker->thread);
  if (status != PJ_SUCCESS) {
    pj_pool_release(worker->pool);
    delete worker;
    return status;
  }
  *out_worker = worker;
  return PJ_SUCCESS;
}

int vphone_dial_worker_submit(vphone_dial_worker *worker, int64_t request_id,
                              int account_id, const char *destination_uri,
                              int is_tls) {
  if (!worker || !destination_uri || !*destination_uri) return PJ_EINVAL;
  try {
    std::lock_guard<std::mutex> lock(worker->mutex);
    if (worker->stopping) return PJ_ECANCELLED;
    worker->requests.push({request_id, account_id, destination_uri, is_tls != 0});
  } catch (const std::bad_alloc &) {
    return PJ_ENOMEM;
  }
  worker->ready.notify_one();
  return PJ_SUCCESS;
}

void vphone_dial_worker_destroy(vphone_dial_worker *worker) {
  if (!worker) return;
  {
    std::lock_guard<std::mutex> lock(worker->mutex);
    worker->stopping = true;
  }
  worker->ready.notify_one();
  pj_thread_join(worker->thread);
  pj_thread_destroy(worker->thread);
  pj_pool_release(worker->pool);
  delete worker;
}
