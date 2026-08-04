import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException, rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_identity.dart';
import '../generated/pjsip_bindings.g.dart';
import 'call_history_database.dart';
import 'contact_service.dart';
import 'diagnostic_log_exporter.dart';
import 'native_bridge/audio_device_change_controller.dart';
import 'sip_call_end_reason_mapper.dart';
import '../../utils/toast_util.dart';

part 'pjsip_parts/pjsip_log_model.dart';

part 'pjsip_parts/pjsip_network_models.dart';

part 'pjsip_parts/pjsip_audio_models.dart';

part 'pjsip_parts/pjsip_account_models.dart';

part 'pjsip_parts/pjsip_call_models.dart';

part 'pjsip_parts/pjsip_call_transaction_snapshot.dart';

part 'pjsip_parts/pjsip_call_end_reason.dart';

part 'pjsip_parts/pjsip_ui_state.dart';

part 'pjsip_parts/pjsip_callbacks.dart';

part 'pjsip_parts/pjsip_engine.dart';

part 'pjsip_parts/pjsip_calls.dart';

part 'pjsip_parts/pjsip_audio_devices.dart';

part 'pjsip_parts/pjsip_audio_errors.dart';

part 'native_bridge/pjsip_audio_permissions.dart';

part 'native_bridge/pjsip_call_snapshot_bridge.dart';

part 'native_bridge/pjsip_windows_audio_devices.dart';

part 'pjsip_parts/pjsip_network.dart';

part 'pjsip_parts/pjsip_persistence.dart';

class PjsipService extends Notifier<PjsipUIState> {
  static const int _maxUiLogEntries = 300;
  static const Duration _logFlushInterval = Duration(milliseconds: 80);

  late PjsipBindings _bindings;
  final _PjsipAudioRuntime _audio = _PjsipAudioRuntime();
  final AudioDeviceChangeController _audioDeviceChangeController =
      AudioDeviceChangeController();
  final _PjsipCallSnapshotRuntime _callSnapshots = _PjsipCallSnapshotRuntime();
  final Set<int> _mediaConnectedCalls = <int>{};
  final Set<int> _locallyEndedCallIds = <int>{};
  final Set<int> _blindTransferAutoReleaseCallIds = <int>{};
  final Set<int> _hangupSoundPlayedCallIds = <int>{};
  final Set<int> _backgroundHoldScheduledCallIds = <int>{};
  final Set<int> _locallyReleasedCallIds = <int>{};
  final Set<int> _knownIncomingCallIds = <int>{};
  // 外呼进入 EARLY 时立即缓存响铃时间。未接通快速断开时，PJSIP 可能已释放
  // call_info，归档只能拿到旧 CallInfo；这个缓存用于补齐“拨号到响铃”统计。
  final Map<int, DateTime> _outboundRingingAtByCallId = <int, DateTime>{};
  final Map<int, DateTime> _lastCallControlOperationAt = <int, DateTime>{};
  final Map<int, Timer> _delayedHangupTimers = <int, Timer>{};
  final Map<int, Timer> _hangupCleanupTimers = <int, Timer>{};
  final Map<int, String> _blindTransferTargets = <int, String>{};
  final Map<int, String> _callNotes = <int, String>{};
  final Map<int, String> _sharedConferenceNotes = <int, String>{};
  final Map<SipTransport, int> _sipTransportIds = <SipTransport, int>{};
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 拆分文件通过这组私有访问器读写 Notifier 状态。这样既不把 state 暴露给
  // 业务层，也不会让 extension 直接访问 Riverpod 的 protected 成员。
  PjsipUIState get _uiState => state;

  set _uiState(PjsipUIState value) => state = value;

  CallHistoryDatabase get _callHistoryDatabase =>
      ref.read(callHistoryDatabaseProvider);

  List<ContactEntry> get _contacts => ref.read(contactBookProvider).contacts;

  // 通话计时器：接通后每秒触发一次 state 刷新，让 UI 上的时长走动。
  // duration 本身由 CallInfo.connectedAt 实时算出，timer 只负责触发重建。
  Timer? _callTimer;
  Timer? _logFlushTimer;
  Timer? _startupWarmupTimer;
  Timer? _networkChangeTimer;
  Timer? _automaticRegistrationRecoveryTimer;
  Timer? _ipChangeTimeoutTimer;
  Timer? _outgoingMediaRecoveryTimer;
  AppLifecycleListener? _appLifecycleListener;
  final Map<int, DateTime> _lastAutomaticRegistrationAttemptAt =
      <int, DateTime>{};
  final List<PjsipLog> _pendingLogs = <PjsipLog>[];
  bool _ipChangeInProgress = false;
  bool _ipChangeHadError = false;
  bool _pendingIpChange = false;
  bool _seatRestoreInProgress = false;
  bool _loggedMacOsFallbackRead = false;
  bool _loggedMacOsFallbackWrite = false;
  String? _preferredDefaultLineKey;
  Future<void> _seatPersistQueue = Future<void>.value();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Set<ConnectivityResult>? _lastConnectivityTypes;
  bool _connectivityMonitorStarted = false;
  bool _isDisposed = false;
  bool _cleanupCompleted = false;
  bool _nativeCallablesClosed = false;
  Future<void>? _applicationShutdownFuture;
  DateTime? _outgoingMediaRecoveryUntil;
  String? _outgoingMediaRecoveryReason;
  DateTime? _lastAudioDeviceIssueToastAt;
  bool _audioDeviceSpeakerOnlyFallbackActive = false;
  DateTime? _lastSipIpChangeAt;
  late final String _nativeLogDirectoryPath = Platform.isWindows
      ? '${Platform.environment['APPDATA'] ?? Directory.systemTemp.path}\\$appStorageDirectoryName'
      : Platform.isLinux
      ? '${Platform.environment['HOME'] ?? Directory.systemTemp.path}/.local/state/$appStorageDirectoryName'
      : '${Platform.environment['HOME'] ?? Directory.systemTemp.path}/Library/Logs/$appStorageDirectoryName';
  late final String _nativeLogFilePath = Platform.isWindows
      ? '$_nativeLogDirectoryPath\\vphone_native.log'
      : '$_nativeLogDirectoryPath/vphone_native.log';

  // 保持对 Callable 的引用，防止被 GC 回收
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _regStateCallable;
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.Int, ffi.Pointer<pjsip_rx_data>)
  >
  _incomingCallCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int, ffi.Pointer<pjsip_event>)>
  _callStateCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _callMediaStateCallable;
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.UnsignedInt, ffi.Pointer<pjmedia_event>)
  >
  _callMediaEventCallable;
  late ffi.NativeCallable<
    ffi.Void Function(
      ffi.Int,
      ffi.Pointer<pjmedia_sdp_session>,
      ffi.Pointer<pj_pool_t>,
      ffi.Pointer<pjmedia_sdp_session>,
    )
  >
  _callSdpCreatedCallable;
  late ffi.NativeCallable<
    ffi.Void Function(
      ffi.Int,
      ffi.Int,
      ffi.Pointer<pj_str_t>,
      ffi.Int,
      ffi.Pointer<ffi.Int>,
    )
  >
  _callTransferStatusCallable;
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
    _setupAudioRuntime(dylib);
    _callSnapshots.setup(dylib);
    debugPrint(
      '📌 PJSIP call snapshot bridge: '
      '${_callSnapshots.isAvailable ? 'available' : 'unavailable'} '
      '(${_callSnapshots.debugStatus})',
    );
    _setupCallables();
    // Notifier 不会自动调用 dispose()，必须显式注册清理，否则 NativeCallable
    // 永远不会 close()，pjsua 也不会销毁。
    ref.onDispose(_cleanup);
    // build() 返回 state 后再启动异步检测，避免初始化完成前修改 Notifier.state。
    scheduleMicrotask(_loadAudioPreferences);
    scheduleMicrotask(_startConnectivityMonitoring);
    scheduleMicrotask(_startAppLifecycleMonitoring);
    _scheduleStartupWarmup();
    return PjsipUIState(logs: []);
  }

  void _scheduleStartupWarmup() {
    _startupWarmupTimer?.cancel();
    // 让首帧和基础布局先出来，再预热 PJSIP。这样首次添加线路时不用把
    // create/init/start、transport 创建、codec 精简和音频设备枚举都压在点击事件里。
    _startupWarmupTimer = Timer(const Duration(milliseconds: 250), () {
      _startupWarmupTimer = null;
      unawaited(_warmUpAfterStartup());
    });
  }

  Future<void> _warmUpAfterStartup() async {
    if (_isDisposed) return;
    await init();
    if (_isDisposed) return;
    await _loadCachedAgent();
  }

  void _addLog(String msg) {
    debugPrint('🔔 printLog: ID $msg');
    if (_isDisposed) return;

    // PJSIP 注册、ICE/DTLS 协商、音频设备枚举会在很短时间内产生成批日志。
    // 如果每条日志都立即 copy 一次完整 logs 列表并通知 Riverpod，设置页和拨号页
    // 会被迫连续重建，用户看到的就是首次启动/添加账号时明显卡顿。
    _pendingLogs.add(PjsipLog(msg));
    _logFlushTimer ??= Timer(_logFlushInterval, _flushPendingLogs);
  }

  void _flushPendingLogs() {
    _logFlushTimer = null;
    if (_isDisposed || _pendingLogs.isEmpty) return;

    final pending = List<PjsipLog>.of(_pendingLogs);
    _pendingLogs.clear();
    final merged = <PjsipLog>[...state.logs, ...pending];
    final logs = merged.length <= _maxUiLogEntries
        ? merged
        : merged.sublist(merged.length - _maxUiLogEntries);
    state = state.copyWith(logs: logs);
  }

  void clearLogs() {
    _logFlushTimer?.cancel();
    _logFlushTimer = null;
    _pendingLogs.clear();
    state = state.copyWith(logs: const []);
  }

  /// 导出当前诊断信息，并返回用户选择的保存路径。
  ///
  /// 导出前立即合并尚未刷入 UI 的日志，避免最后几十毫秒发生的注册或通话事件
  /// 丢失。原生日志由导出器直接读取，不会停止或重启 PJSIP 日志写入。
  Future<String?> exportDiagnosticLogs() async {
    _logFlushTimer?.cancel();
    _logFlushTimer = null;
    _flushPendingLogs();

    final snapshot = state;
    final uiLogLines = snapshot.logs
        .map((log) => '[${log.time.toIso8601String()}] ${log.message}')
        .toList(growable: false);
    return DiagnosticLogExporter.export(
      uiLogLines: uiLogLines,
      nativeLogFilePath: _nativeLogFilePath,
      runtimeSummary: <String, String>{
        '电话服务': snapshot.isInitialized ? '已启动' : '未启动',
        '网络': snapshot.isNetworkAvailable ? '可用' : '不可用',
        '网络恢复状态': snapshot.networkState.name,
        '线路数量': '${snapshot.accounts.length}',
        '活动通话数量': '${snapshot.calls.length}',
        '音频模式': snapshot.audioDeviceMode.name,
        '音频状态': snapshot.audioDeviceStatus,
        '音频异常': snapshot.audioDeviceIssueMessage ?? '无',
        '输入设备 ID': '${snapshot.selectedCaptureDeviceId ?? '未选择'}',
        '输出设备 ID': '${snapshot.selectedPlaybackDeviceId ?? '未选择'}',
      },
    );
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

  void stop({bool keepRestarting = false}) {
    if (!state.isInitialized) {
      if (!keepRestarting && state.isPhoneServiceRestarting) {
        state = state.copyWith(isPhoneServiceRestarting: false);
      }
      return;
    }
    final stopWatch = Stopwatch()..start();
    _stopCallTimer();
    _stopMicrophoneTestRecorder();
    _stopSpeakerTestPlayer();
    _stopIncomingRingtone();
    _stopOutgoingRingback();
    _stopHangupSound();
    _stopDialpadKeySound();
    _cancelScheduledSoundDeviceRelease();
    _stopAudioLevelTimer();
    _stopAudioDeviceMonitoring();
    _cancelPendingAudioBridgeReconnects();
    _networkChangeTimer?.cancel();
    _cancelAutomaticRegistrationRecovery();
    _ipChangeTimeoutTimer?.cancel();
    _outgoingMediaRecoveryTimer?.cancel();
    _ipChangeInProgress = false;
    _ipChangeHadError = false;
    _pendingIpChange = false;
    _audioDeviceSpeakerOnlyFallbackActive = false;

    final destroyWatch = Stopwatch()..start();
    _bindings.pjsua_destroy();
    final destroyMs = destroyWatch.elapsedMilliseconds;

    _mediaConnectedCalls.clear();
    _locallyEndedCallIds.clear();
    _hangupSoundPlayedCallIds.clear();
    _backgroundHoldScheduledCallIds.clear();
    _locallyReleasedCallIds.clear();
    _knownIncomingCallIds.clear();
    _outboundRingingAtByCallId.clear();
    _callSnapshots.clearAll();
    _lastCallControlOperationAt.clear();
    for (final timer in _delayedHangupTimers.values) {
      timer.cancel();
    }
    _delayedHangupTimers.clear();
    for (final timer in _hangupCleanupTimers.values) {
      timer.cancel();
    }
    _hangupCleanupTimers.clear();
    _sipTransportIds.clear();
    state = state.copyWith(
      isInitialized: false,
      calls: const {},
      activeCallId: null,
      conferenceCallIds: const {},
      isConferencePaused: false,
      conferenceInterruptionCallId: null,
      networkState: PjsipNetworkState.idle,
      isPhoneServiceRestarting: keepRestarting
          ? state.isPhoneServiceRestarting
          : false,
      accId: -1,
      host: '',
      accounts: const {},
      defaultAccountId: null,
      captureDevices: const [],
      playbackDevices: const [],
      selectedCaptureDeviceId: null,
      selectedPlaybackDeviceId: null,
      isMicrophoneMuted: false,
      isSpeakerMuted: false,
      remoteMutedCallIds: const {},
      microphoneLevel: 0,
      speakerLevel: 0,
      isMicrophoneTesting: false,
      isSpeakerTesting: false,
      audioDeviceMode: PjsipAudioDeviceMode.automatic,
      audioDeviceStatus: '设备监控已停止',
      audioDeviceIssueMessage: null,
      audioDeviceIssueStatus: null,
      microphonePermissionStatus: PjsipMicrophonePermissionStatus.unknown,
      allowInCallAudioDeviceSwitch: true,
    );
    _addLog(
      '⏱ 断开全部耗时: total=${stopWatch.elapsedMilliseconds}ms, pjsua_destroy=${destroyMs}ms',
    );
    _addLog('⏹ 引擎已关闭');
  }

  /// Stops every PJSIP producer before the app closes its local database.
  ///
  /// `pjsua_destroy()` can enqueue final call-state callbacks from a native
  /// worker thread. The short event-loop grace period lets those callbacks
  /// archive their final call records before the database rejects new writes.
  Future<void> shutdownForApplicationExit() {
    return _applicationShutdownFuture ??= _shutdownForApplicationExit();
  }

  Future<void> _shutdownForApplicationExit() async {
    _startupWarmupTimer?.cancel();
    _startupWarmupTimer = null;
    _networkChangeTimer?.cancel();
    _networkChangeTimer = null;
    _cancelAutomaticRegistrationRecovery();
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
    _connectivityMonitorStarted = false;
    try {
      await _connectivitySubscription?.cancel();
    } catch (error) {
      debugPrint(
        'Cancel connectivity monitoring during shutdown failed: $error',
      );
    }
    _connectivitySubscription = null;

    if (state.isInitialized) {
      stop();
    }

    // NativeCallable.listener delivers native callbacks asynchronously. Once
    // pjsua_destroy() has returned, this delay only drains callbacks that were
    // already queued; it does not keep the SIP engine alive.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      await _seatPersistQueue;
    } catch (error) {
      debugPrint('Wait for account persistence during shutdown failed: $error');
    }

    _isDisposed = true;
    _closeNativeCallablesOnce();
  }

  void _closeNativeCallablesOnce() {
    if (_nativeCallablesClosed) return;
    _nativeCallablesClosed = true;
    _regStateCallable.close();
    _incomingCallCallable.close();
    _callStateCallable.close();
    _callMediaStateCallable.close();
    _callMediaEventCallable.close();
    _callSdpCreatedCallable.close();
    _callTransferStatusCallable.close();
    _ipChangeProgressCallable.close();
  }

  void _cleanup() {
    if (_cleanupCompleted) return;
    _cleanupCompleted = true;
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _startupWarmupTimer?.cancel();
    _startupWarmupTimer = null;
    _audio.audioPreferencesDebounceTimer?.cancel();
    _audio.audioPreferencesDebounceTimer = null;
    _logFlushTimer?.cancel();
    _logFlushTimer = null;
    _pendingLogs.clear();
    _stopCallTimer();
    _stopMicrophoneTestRecorder();
    _stopSpeakerTestPlayer();
    _stopIncomingRingtone();
    _stopOutgoingRingback();
    _stopHangupSound();
    _stopDialpadKeySound();
    _cancelScheduledSoundDeviceRelease();
    _stopAudioLevelTimer();
    _stopAudioDeviceMonitoring();
    _cancelPendingAudioBridgeReconnects();
    _networkChangeTimer?.cancel();
    _cancelAutomaticRegistrationRecovery();
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
    _ipChangeTimeoutTimer?.cancel();
    _outgoingMediaRecoveryTimer?.cancel();
    _ipChangeInProgress = false;
    _pendingIpChange = false;
    if (state.isInitialized) {
      _bindings.pjsua_destroy();
      _mediaConnectedCalls.clear();
      _hangupSoundPlayedCallIds.clear();
      _backgroundHoldScheduledCallIds.clear();
      _locallyReleasedCallIds.clear();
      _knownIncomingCallIds.clear();
      _outboundRingingAtByCallId.clear();
      _callSnapshots.clearAll();
      _lastCallControlOperationAt.clear();
      for (final timer in _delayedHangupTimers.values) {
        timer.cancel();
      }
      _delayedHangupTimers.clear();
      for (final timer in _hangupCleanupTimers.values) {
        timer.cancel();
      }
      _hangupCleanupTimers.clear();
      _sipTransportIds.clear();
    }
    _closeNativeCallablesOnce();
  }
}

final pjsipServiceProvider = NotifierProvider<PjsipService, PjsipUIState>(
  PjsipService.new,
);
