part of '../pjsip_service.dart';

typedef _VphoneGetCallMediaSecurityNative =
    ffi.Int Function(
      ffi.Int,
      ffi.UnsignedInt,
      ffi.Pointer<_VphoneMediaSecuritySnapshotNative>,
    );
typedef _VphoneGetCallMediaSecurityDart =
    int Function(int, int, ffi.Pointer<_VphoneMediaSecuritySnapshotNative>);

/// 与 `tool/pjsip_bridge/vphone_pjsip_bridge.h` 保持一致。
///
/// 只使用固定宽度整数，避免 `pj_sock_t` 在 Windows x64 与 Unix x64 上的
/// ABI 差异导致后续字段错位。
final class _VphoneMediaSecuritySnapshotNative extends ffi.Struct {
  @ffi.Int32()
  external int valid;

  @ffi.Int32()
  external int hasSrtpTransport;

  @ffi.Int32()
  external int srtpActive;

  @ffi.Int32()
  external int hasIceTransport;
}

class _NativeCallMediaSecurity {
  const _NativeCallMediaSecurity({
    required this.hasSrtpTransport,
    required this.srtpActive,
    required this.hasIceTransport,
  });

  final bool hasSrtpTransport;
  final bool srtpActive;
  final bool hasIceTransport;
}

/// 跨平台媒体安全桥。
///
/// Dart 在 PJSUA 现有 `on_call_media_state` 后查询真正状态；DTLS 尚未完成时
/// 由上层做有限确认。快照只使用固定宽度字段，避免 Windows FFI 布局错误。
class _PjsipMediaSecurityRuntime {
  _VphoneGetCallMediaSecurityDart? _getSecurity;

  bool get isAvailable => _getSecurity != null;

  String get debugStatus => 'get=${_getSecurity != null}';

  void setup(ffi.DynamicLibrary dylib) {
    try {
      _getSecurity = dylib
          .lookupFunction<
            _VphoneGetCallMediaSecurityNative,
            _VphoneGetCallMediaSecurityDart
          >('vphone_get_call_media_security');
    } on ArgumentError {
      _getSecurity = null;
    }
  }

  _NativeCallMediaSecurity? get(int callId, int mediaIndex) {
    final getSecurity = _getSecurity;
    if (getSecurity == null) return null;

    final snapshot = calloc<_VphoneMediaSecuritySnapshotNative>();
    try {
      final ok = getSecurity(callId, mediaIndex, snapshot);
      if (ok == 0 || snapshot.ref.valid == 0) return null;
      return _NativeCallMediaSecurity(
        hasSrtpTransport: snapshot.ref.hasSrtpTransport != 0,
        srtpActive: snapshot.ref.srtpActive != 0,
        hasIceTransport: snapshot.ref.hasIceTransport != 0,
      );
    } finally {
      calloc.free(snapshot);
    }
  }
}
