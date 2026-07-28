part of '../pjsip_service.dart';

typedef _VphoneApplyCallSnapshotCallbacksC =
    ffi.Void Function(ffi.Pointer<pjsua_config>);
typedef _VphoneApplyCallSnapshotCallbacksDart =
    void Function(ffi.Pointer<pjsua_config>);
typedef _VphoneGetCallInfoSnapshotC =
    ffi.Int Function(ffi.Int, ffi.Pointer<_VphoneCallInfoSnapshotNative>);
typedef _VphoneGetCallInfoSnapshotDart =
    int Function(int, ffi.Pointer<_VphoneCallInfoSnapshotNative>);
typedef _VphoneClearCallInfoSnapshotC = ffi.Void Function(ffi.Int);
typedef _VphoneClearCallInfoSnapshotDart = void Function(int);
typedef _VphoneClearAllCallInfoSnapshotsC = ffi.Void Function();
typedef _VphoneClearAllCallInfoSnapshotsDart = void Function();

/// 和 `tool/pjsip_bridge/vphone_pjsip_bridge.h` 保持字段顺序一致。
///
/// 这里不能增删字段或调整顺序；如果以后改 C 结构体，Dart 侧也要同步修改。
/// 结构体只包含 int / int64 / 固定长度 char 数组，避免跨 FFI 持有原生指针。
final class _VphoneCallInfoSnapshotNative extends ffi.Struct {
  @ffi.Int()
  external int valid;

  @ffi.Int()
  external int callId;

  @ffi.Int()
  external int statusCode;

  @ffi.Int()
  external int roleCode;

  @ffi.Int()
  external int transactionStateCode;

  @ffi.Int()
  external int eventTypeCode;

  @ffi.Int64()
  external int updatedAtMs;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Char> method;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Char> role;

  @ffi.Array.multi([24])
  external ffi.Array<ffi.Char> transactionState;

  @ffi.Array.multi([24])
  external ffi.Array<ffi.Char> eventType;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Char> statusText;
}

/// PJSIP wrapper 暴露的安全通话状态快照。
///
/// 背景：`on_call_tsx_state` 原生回调能拿到更准确的 SIP 状态码，但其中的
/// `pjsip_transaction*` / `pjsip_event*` 生命周期很短。Dart listener 是异步
/// 投递，直接读这些指针会偶发崩溃。现在由 dylib wrapper 同步复制字段，
/// Dart 只查询这份快照。
class _PjsipCallSnapshotRuntime {
  _VphoneApplyCallSnapshotCallbacksDart? _applyCallbacks;
  _VphoneGetCallInfoSnapshotDart? _getSnapshot;
  _VphoneClearCallInfoSnapshotDart? _clearSnapshot;
  _VphoneClearAllCallInfoSnapshotsDart? _clearAllSnapshots;

  /// 查找 dylib wrapper 的导出函数。
  ///
  /// 兼容旧 dylib：如果当前本地库还没重新打包，符号不存在时保持 no-op，
  /// 应用仍可启动，只是拿不到 call_info 释放后的 SIP 结束原因。
  void setup(ffi.DynamicLibrary dylib) {
    try {
      _applyCallbacks = dylib
          .lookupFunction<
            _VphoneApplyCallSnapshotCallbacksC,
            _VphoneApplyCallSnapshotCallbacksDart
          >('vphone_apply_call_snapshot_callbacks');
      _getSnapshot = dylib
          .lookupFunction<
            _VphoneGetCallInfoSnapshotC,
            _VphoneGetCallInfoSnapshotDart
          >('vphone_get_call_info_snapshot');
      _clearSnapshot = dylib
          .lookupFunction<
            _VphoneClearCallInfoSnapshotC,
            _VphoneClearCallInfoSnapshotDart
          >('vphone_clear_call_info_snapshot');
      _clearAllSnapshots = dylib
          .lookupFunction<
            _VphoneClearAllCallInfoSnapshotsC,
            _VphoneClearAllCallInfoSnapshotsDart
          >('vphone_clear_all_call_info_snapshots');
    } on ArgumentError {
      _applyCallbacks = null;
      _getSnapshot = null;
      _clearSnapshot = null;
      _clearAllSnapshots = null;
    }
  }

  /// 在 `pjsua_init()` 前把 C 层安全快照回调挂到配置上。
  void applyCallbacks(ffi.Pointer<pjsua_config> config) {
    _applyCallbacks?.call(config);
  }

  /// 读取指定 callId 最近一次 SIP transaction 快照。
  ///
  /// 返回 null 表示当前 dylib 不支持、callId 无效，或还没有可用快照。
  CallSipTransactionSnapshot? getLast(int callId) {
    final getSnapshot = _getSnapshot;
    if (getSnapshot == null) return null;

    final snapshot = calloc<_VphoneCallInfoSnapshotNative>();
    try {
      final ok = getSnapshot(callId, snapshot);
      if (ok == 0 || snapshot.ref.valid == 0) return null;

      return CallSipTransactionSnapshot(
        callId: snapshot.ref.callId,
        method: _nativeCharArrayToString(snapshot.ref.method, 16),
        role: _nativeCharArrayToString(snapshot.ref.role, 16),
        transactionState: _nativeCharArrayToString(
          snapshot.ref.transactionState,
          24,
        ),
        eventType: _nativeCharArrayToString(snapshot.ref.eventType, 24),
        statusCode: snapshot.ref.statusCode,
        statusText: _nativeCharArrayToString(snapshot.ref.statusText, 128),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          snapshot.ref.updatedAtMs,
        ),
      );
    } finally {
      calloc.free(snapshot);
    }
  }

  /// 清理单路通话快照，避免 PJSIP 复用 callId 后读到上一通的原因。
  void clear(int callId) {
    _clearSnapshot?.call(callId);
  }

  /// 引擎停止/销毁前清空全部快照。
  void clearAll() {
    _clearAllSnapshots?.call();
  }
}

/// 读取 C 固定长度 char 数组，遇到 `\0` 就停止。
String _nativeCharArrayToString(ffi.Array<ffi.Char> chars, int maxLength) {
  final bytes = <int>[];
  for (var i = 0; i < maxLength; i++) {
    final value = chars[i];
    if (value == 0) break;
    bytes.add(value & 0xff);
  }
  return utf8.decode(bytes, allowMalformed: true);
}
