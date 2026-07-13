import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/pjsip_bindings.g.dart';

part 'pjsip_parts/pjsip_models.dart';

part 'pjsip_parts/pjsip_callbacks.dart';

part 'pjsip_parts/pjsip_engine.dart';

part 'pjsip_parts/pjsip_calls.dart';

part 'pjsip_parts/pjsip_network.dart';

class PjsipService extends Notifier<PjsipUIState> {
  late PjsipBindings _bindings;
  final Set<int> _mediaConnectedCalls = <int>{};

  // 拆分文件通过这组私有访问器读写 Notifier 状态。这样既不把 state 暴露给
  // 业务层，也不会让 extension 直接访问 Riverpod 的 protected 成员。
  PjsipUIState get _uiState => state;

  set _uiState(PjsipUIState value) => state = value;

  // 通话计时器：接通后每秒触发一次 state 刷新，让 UI 上的时长走动。
  // duration 本身由 CallInfo.connectedAt 实时算出，timer 只负责触发重建。
  Timer? _callTimer;
  Timer? _networkChangeTimer;
  Timer? _ipChangeTimeoutTimer;
  bool _ipChangeInProgress = false;
  bool _ipChangeHadError = false;
  bool _pendingIpChange = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Set<ConnectivityResult>? _lastConnectivityTypes;
  bool _connectivityMonitorStarted = false;
  bool _isDisposed = false;

  // 保持对 Callable 的引用，防止被 GC 回收
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)
  >
  _logCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _regStateCallable;
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.Int, ffi.Pointer<pjsip_rx_data>)
  >
  _incomingCallCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int, ffi.Pointer<pjsip_event>)>
  _callStateCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _callMediaStateCallable;
  late ffi.NativeCallable<
    ffi.Void Function(
      ffi.UnsignedInt,
      ffi.Int,
      ffi.Pointer<pjsua_ip_change_op_info>,
    )
  >
  _ipChangeProgressCallable;

  @override
  PjsipUIState build() {
    final libraryName = Platform.isWindows
        ? 'pjsip.dll'
        : Platform.isLinux
        ? 'libpjsip.so'
        : 'libpjsip.dylib';
    final dylib = ffi.DynamicLibrary.open(libraryName);
    _bindings = PjsipBindings(dylib);
    _setupCallables();
    // Notifier 不会自动调用 dispose()，必须显式注册清理，否则 NativeCallable
    // 永远不会 close()，pjsua 也不会销毁。
    ref.onDispose(_cleanup);
    // build() 返回 state 后再启动异步检测，避免初始化完成前修改 Notifier.state。
    scheduleMicrotask(_startConnectivityMonitoring);
    return PjsipUIState(logs: []);
  }

  void _addLog(String msg) {
    debugPrint('🔔 printLog: ID $msg');
    scheduleMicrotask(() {
      state = state.copyWith(logs: [...state.logs, PjsipLog(msg)]);
    });
  }

  // 每秒重建一次 state，驱动 UI 上的通话时长刷新。connectedAt 不变，因此
  // 只是触发 Riverpod 通知；durationLabel 会算出最新的秒数。
  void _startCallTimer() {
    if (_callTimer != null) return; // 已在计时，避免重复启动
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.calls.values.any((call) => call.isConnected)) {
        _stopCallTimer();
        return;
      }
      // 复制 Map 触发一次通知即可，duration 是实时计算的。
      state = state.copyWith(calls: Map<int, CallInfo>.of(state.calls));
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  void _pjStr(pj_str_t target, ffi.Pointer<Utf8> source) {
    target.ptr = source.cast<ffi.Char>();
    // pj_str_t.slen 需要 UTF-8 字节长度。Utf8Pointer.length 返回 strlen
    // (字节数)，而 toDartString().length 返回的是 UTF-16 码元数，遇到非
    // ASCII 字符会算错并导致字段截断/损坏。
    target.slen = source.length;
  }

  void stop() {
    if (!state.isInitialized) return;
    _stopCallTimer();
    _networkChangeTimer?.cancel();
    _ipChangeTimeoutTimer?.cancel();
    _ipChangeInProgress = false;
    _ipChangeHadError = false;
    _pendingIpChange = false;
    _bindings.pjsua_destroy();
    _mediaConnectedCalls.clear();
    state = state.copyWith(
      isInitialized: false,
      calls: const {},
      activeCallId: null,
      conferenceCallIds: const {},
      isConferencePaused: false,
      conferenceInterruptionCallId: null,
      networkState: PjsipNetworkState.idle,
    );
    _addLog('⏹ 引擎已关闭');
  }

  void _cleanup() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _stopCallTimer();
    _networkChangeTimer?.cancel();
    _ipChangeTimeoutTimer?.cancel();
    _ipChangeInProgress = false;
    _pendingIpChange = false;
    if (state.isInitialized) {
      _bindings.pjsua_destroy();
      _mediaConnectedCalls.clear();
    }
    _logCallable.close();
    _regStateCallable.close();
    _incomingCallCallable.close();
    _callStateCallable.close();
    _callMediaStateCallable.close();
    _ipChangeProgressCallable.close();
  }
}

final pjsipServiceProvider = NotifierProvider<PjsipService, PjsipUIState>(
  PjsipService.new,
);
