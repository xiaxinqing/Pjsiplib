part of '../pjsip_service.dart';

/// PJSIP 页面/服务暴露给 Flutter UI 的完整状态。
///
/// 这个项目用 Riverpod `Notifier` 管理状态。服务层每次调用 `copyWith` 生成一个
/// 新的 `PjsipUIState`，UI 就会收到通知并重建对应区域。
///
/// 这里故意只放“UI 需要观察的状态”。PJSIP 句柄、timer、设备轮询缓存这类运行时
/// 对象不放进来，它们留在 service/runtime 内部。
class PjsipUIState {
  /// 页面日志列表。
  final List<PjsipLog> logs;

  /// 当前还在 UI 中展示/管理的通话。key 是 PJSIP callId。
  final Map<int, CallInfo> calls;

  /// 当前主操作通话。多路通话时，接听、挂断、静音桥接通常优先作用于它。
  final int? activeCallId;

  /// 参与本地会议的 callId 集合。两路远端 + 本机用户即构成三方通话。
  final Set<int> conferenceCallIds;

  /// 会议是否被整体暂停。
  final bool isConferencePaused;

  /// 会议中被新来电打断时，记录这个中断通话的 callId。
  final int? conferenceInterruptionCallId;

  /// 系统层网络是否可用。
  final bool isNetworkAvailable;

  /// PJSIP 网络恢复流程状态，比 `isNetworkAvailable` 更细。
  final PjsipNetworkState networkState;

  /// PJSIP 引擎是否已经初始化。
  final bool isInitialized;

  /// PJSIP 账号 ID。注册成功后用于后续账号相关操作。
  final int accId;

  /// 当前注册/连接的 SIP 服务器地址。
  final String host;

  /// UI 可选的输入设备列表，已经过滤掉明显不适合通话的设备。
  final List<PjsipAudioDevice> captureDevices;

  /// UI 可选的输出设备列表，已经过滤掉明显不适合通话的设备。
  final List<PjsipAudioDevice> playbackDevices;

  /// 当前 PJSIP 使用的输入设备 ID。
  final int? selectedCaptureDeviceId;

  /// 当前 PJSIP 使用的输出设备 ID。
  final int? selectedPlaybackDeviceId;

  /// 本地麦克风静音状态。
  final bool isMicrophoneMuted;

  /// 本地扬声器静音状态。
  final bool isSpeakerMuted;

  /// 麦克风电平，来自 PJSIP conference bridge signal level。
  final int microphoneLevel;

  /// 扬声器电平，来自 PJSIP conference bridge signal level。
  final int speakerLevel;

  /// 是否正在进行麦克风测试。开启后即使没有通话，也会显示输入电平。
  final bool isMicrophoneTesting;

  /// 是否正在播放扬声器测试音。
  final bool isSpeakerTesting;

  /// 自动/手动音频设备选择模式。
  final PjsipAudioDeviceMode audioDeviceMode;

  /// 当前音频策略的简短状态文案。
  final String audioDeviceStatus;

  /// 是否允许通话中检测并自动切换新插入的音频设备。
  final bool allowInCallAudioDeviceSwitch;

  PjsipUIState({
    required this.logs,
    this.calls = const {},
    this.activeCallId,
    this.conferenceCallIds = const {},
    this.isConferencePaused = false,
    this.conferenceInterruptionCallId,
    this.isNetworkAvailable = true,
    this.networkState = PjsipNetworkState.idle,
    this.isInitialized = false,
    this.accId = -1,
    this.host = '',
    this.captureDevices = const [],
    this.playbackDevices = const [],
    this.selectedCaptureDeviceId,
    this.selectedPlaybackDeviceId,
    this.isMicrophoneMuted = false,
    this.isSpeakerMuted = false,
    this.microphoneLevel = 0,
    this.speakerLevel = 0,
    this.isMicrophoneTesting = false,
    this.isSpeakerTesting = false,
    this.audioDeviceMode = PjsipAudioDeviceMode.automatic,
    this.audioDeviceStatus = '自动选择设备',
    this.allowInCallAudioDeviceSwitch = false,
  });

  PjsipUIState copyWith({
    List<PjsipLog>? logs,
    Map<int, CallInfo>? calls,
    Object? activeCallId = _unset,
    Set<int>? conferenceCallIds,
    bool? isConferencePaused,
    Object? conferenceInterruptionCallId = _unset,
    bool? isNetworkAvailable,
    PjsipNetworkState? networkState,
    bool? isInitialized,
    int? accId,
    String? host,
    List<PjsipAudioDevice>? captureDevices,
    List<PjsipAudioDevice>? playbackDevices,
    Object? selectedCaptureDeviceId = _unset,
    Object? selectedPlaybackDeviceId = _unset,
    bool? isMicrophoneMuted,
    bool? isSpeakerMuted,
    int? microphoneLevel,
    int? speakerLevel,
    bool? isMicrophoneTesting,
    bool? isSpeakerTesting,
    PjsipAudioDeviceMode? audioDeviceMode,
    String? audioDeviceStatus,
    bool? allowInCallAudioDeviceSwitch,
  }) {
    return PjsipUIState(
      logs: logs ?? this.logs,
      calls: calls ?? this.calls,
      activeCallId: identical(activeCallId, _unset)
          ? this.activeCallId
          : activeCallId as int?,
      conferenceCallIds: conferenceCallIds ?? this.conferenceCallIds,
      isConferencePaused: isConferencePaused ?? this.isConferencePaused,
      conferenceInterruptionCallId:
          identical(conferenceInterruptionCallId, _unset)
          ? this.conferenceInterruptionCallId
          : conferenceInterruptionCallId as int?,
      isNetworkAvailable: isNetworkAvailable ?? this.isNetworkAvailable,
      networkState: networkState ?? this.networkState,
      isInitialized: isInitialized ?? this.isInitialized,
      accId: accId ?? this.accId,
      host: host ?? this.host,
      captureDevices: captureDevices ?? this.captureDevices,
      playbackDevices: playbackDevices ?? this.playbackDevices,
      selectedCaptureDeviceId: identical(selectedCaptureDeviceId, _unset)
          ? this.selectedCaptureDeviceId
          : selectedCaptureDeviceId as int?,
      selectedPlaybackDeviceId: identical(selectedPlaybackDeviceId, _unset)
          ? this.selectedPlaybackDeviceId
          : selectedPlaybackDeviceId as int?,
      isMicrophoneMuted: isMicrophoneMuted ?? this.isMicrophoneMuted,
      isSpeakerMuted: isSpeakerMuted ?? this.isSpeakerMuted,
      microphoneLevel: microphoneLevel ?? this.microphoneLevel,
      speakerLevel: speakerLevel ?? this.speakerLevel,
      isMicrophoneTesting: isMicrophoneTesting ?? this.isMicrophoneTesting,
      isSpeakerTesting: isSpeakerTesting ?? this.isSpeakerTesting,
      audioDeviceMode: audioDeviceMode ?? this.audioDeviceMode,
      audioDeviceStatus: audioDeviceStatus ?? this.audioDeviceStatus,
      allowInCallAudioDeviceSwitch:
          allowInCallAudioDeviceSwitch ?? this.allowInCallAudioDeviceSwitch,
    );
  }

  /// 当前主通话对象。没有 activeCallId 或已被移除时返回 null。
  CallInfo? get activeCall => activeCallId == null ? null : calls[activeCallId];

  /// 两路远端通话加上本机用户，即构成三方通话。
  bool get hasConference => conferenceCallIds.length >= 2;

  bool get isConferenceActive => hasConference && !isConferencePaused;

  /// 某一路通话是否已经加入会议。
  bool isInConference(int callId) => conferenceCallIds.contains(callId);
}

/// copyWith 里需要区分“参数没传”和“参数显式传 null”。
///
/// 例如 activeCallId 可能需要被清空为 null，如果普通 `int?` 参数默认 null，
/// 就无法判断调用方是没传，还是想清空。`_unset` 就是这个哨兵值。
const Object _unset = Object();
