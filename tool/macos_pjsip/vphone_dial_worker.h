#ifndef VPHONE_DIAL_WORKER_H
#define VPHONE_DIAL_WORKER_H

#include <stdint.h>
#include "vphone_pjsip_bridge.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct vphone_dial_worker vphone_dial_worker;
typedef void (*vphone_dial_result)(int64_t request_id, int status, int call_id);

/* Create after PJSUA initialization. The callback runs on the worker thread;
 * a Dart caller must use NativeCallable.listener and keep it alive through
 * shutdown and delivery of outstanding results. */
VPHONE_PJSIP_EXPORT int vphone_dial_worker_create(
    vphone_dial_result callback, vphone_dial_worker **out_worker);

/* Copies the URI before returning. PJ_SUCCESS means queued: exactly one
 * callback follows with the result of dialing. Errors returned here do not
 * generate callbacks. Keep the selected account valid until completion. */
VPHONE_PJSIP_EXPORT int vphone_dial_worker_submit(
    vphone_dial_worker *worker, int64_t request_id, int account_id,
    const char *destination_uri, int is_tls);

/* Stop submitting first. Cancels queued requests and waits for any in-flight
 * call before freeing the worker. Call before pjsua_destroy, never from the
 * worker's callback. The owner serializes submit and destroy. */
VPHONE_PJSIP_EXPORT void vphone_dial_worker_destroy(vphone_dial_worker *worker);

#ifdef __cplusplus
}
#endif
#endif
