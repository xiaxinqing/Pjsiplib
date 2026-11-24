import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

typedef _DialCallback = ffi.Void Function(ffi.Int64, ffi.Int, ffi.Int);
typedef _CallbackPointer = ffi.Pointer<ffi.NativeFunction<_DialCallback>>;
typedef _Handle = ffi.Pointer<ffi.Void>;
typedef DialResult = ({int status, int callId});

/// One worker per PJSUA engine. The native submit function copies the URI
/// before returning. Only integers cross back to Dart on its listener port.
class PjsipDialWorker {
  PjsipDialWorker(ffi.DynamicLibrary library) {
    final create = library
        .lookupFunction<
          ffi.Int Function(_CallbackPointer, ffi.Pointer<_Handle>),
          int Function(_CallbackPointer, ffi.Pointer<_Handle>)
        >('vphone_dial_worker_create');
    _submit = library
        .lookupFunction<
          ffi.Int Function(
            _Handle,
            ffi.Int64,
            ffi.Int,
            ffi.Pointer<Utf8>,
            ffi.Int,
          ),
          int Function(_Handle, int, int, ffi.Pointer<Utf8>, int)
        >('vphone_dial_worker_submit');
    _destroy = library
        .lookupFunction<ffi.Void Function(_Handle), void Function(_Handle)>(
          'vphone_dial_worker_destroy',
        );
    _callback = ffi.NativeCallable<_DialCallback>.listener(_onResult);
    using((arena) {
      final out = arena<_Handle>();
      final status = create(_callback.nativeFunction, out);
      if (status != 0) {
        _callback.close();
        throw StateError('vphone_dial_worker_create: pj_status=$status');
      }
      _handle = out.value;
    });
  }

  late final int Function(_Handle, int, int, ffi.Pointer<Utf8>, int) _submit;
  late final void Function(_Handle) _destroy;
  late final ffi.NativeCallable<_DialCallback> _callback;
  late _Handle _handle;
  int _nextId = 0;
  final _pending = <int, Completer<DialResult>>{};

  Future<DialResult> dial(int accountId, String uri, {required bool tls}) {
    if (_handle == ffi.nullptr) throw StateError('Dial worker closed');
    final id = ++_nextId;
    final result = Completer<DialResult>();
    final status = using(
      (arena) => _submit(
        _handle,
        id,
        accountId,
        uri.toNativeUtf8(allocator: arena),
        tls ? 1 : 0,
      ),
    );
    if (status != 0) return Future.value((status: status, callId: -1));
    // NativeCallable.listener is delivered on this isolate after submit returns.
    _pending[id] = result;
    return result.future;
  }

  void _onResult(int id, int status, int callId) {
    _pending.remove(id)?.complete((status: status, callId: callId));
    if (_handle == ffi.nullptr && _pending.isEmpty) _callback.close();
  }

  void close() {
    if (_handle == ffi.nullptr) return;
    _destroy(_handle);
    _handle = ffi.nullptr;
    // destroy joins the worker. Results it already posted must still be drained.
    if (_pending.isEmpty) _callback.close();
  }
}
