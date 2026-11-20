"""Exercise the packaged library on the GitHub runner without a SIP account."""

import ctypes as c
from pathlib import Path
import sys
import threading


def check(library_path):
    lib = c.CDLL(str(Path(library_path).resolve()))
    callback_type = c.CFUNCTYPE(None, c.c_int64, c.c_int, c.c_int)
    worker = c.c_void_p()
    lib.vphone_dial_worker_create.argtypes = [callback_type, c.POINTER(c.c_void_p)]
    lib.vphone_dial_worker_submit.argtypes = [
        c.c_void_p, c.c_int64, c.c_int, c.c_char_p, c.c_int
    ]
    lib.vphone_dial_worker_destroy.argtypes = [c.c_void_p]
    lib.vphone_dial_worker_destroy.restype = None
    done = threading.Event()
    results = []
    caller = threading.get_ident()
    request_id = 1 << 40

    @callback_type
    def completed(token, status, call_id):
        results.append((token, status, call_id, threading.get_ident()))
        done.set()

    assert lib.pjsua_create() == 0
    try:
        assert lib.vphone_dial_worker_create(completed, c.byref(worker)) == 0
        # No accounts exist. Expect one asynchronous failure on the worker.
        assert lib.vphone_dial_worker_submit(
            worker, request_id, 0, b"sip:test@127.0.0.1", 0
        ) == 0
        assert done.wait(10), "Missing dial completion"
    finally:
        lib.vphone_dial_worker_destroy(worker)
        lib.pjsua_destroy()
    (token, status, call_id, thread), = results
    assert token == request_id and status != 0 and call_id == -1
    assert thread != caller, "Dial completion ran on the submitting thread"


if __name__ == "__main__":
    check(sys.argv[1])
