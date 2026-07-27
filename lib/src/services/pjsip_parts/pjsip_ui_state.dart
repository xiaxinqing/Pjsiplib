part of '../pjsip_service.dart';

enum SeatEnvironmentState { checking, restoring, ready }

enum PjsipMicrophonePermissionStatus {
  unsupported,
  unknown,
  notDetermined,
  authorized,
  denied,
  restricted,
}

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

  /// 启动时恢复上次坐席环境的阶段，用于给首页显示更明确的 loading/恢复状态。
  final SeatEnvironmentState seatEnvironmentState;

  /// PJSIP 引擎是否已经初始化。
  final bool isInitialized;

  /// 是否正在完整重启电话服务。该流程会临时注销线路、销毁并重新初始化 PJSIP。
  final bool isPhoneServiceRestarting;

  /// PJSIP 账号 ID。注册成功后用于后续账号相关操作。
  final int accId;

  /// 当前注册/连接的 SIP 服务器地址。
  final String host;

  /// 坐席当前已添加的 SIP 线路。key 是 PJSIP accId。
  final Map<int, SipAccountInfo> accounts;

  /// 默认外呼线路。来电仍按 PJSIP 回调中的 accId 归属到具体线路。
  final int? defaultAccountId;

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

  /// 本机不再收听的远端通话集合。
  ///
  /// 这是“只影响当前坐席听感”的单路静音：只断开该通话到本地扬声器的连接，
  /// 不影响会议中其他成员是否能听到这个人。
  final Set<int> remoteMutedCallIds;

  /// 麦克风电平，来自 PJSIP conference bridge signal level。
  final int microphoneLevel;

  /// 扬声器电平，来自 PJSIP conference bridge signal level。
  final int speakerLevel;

  /// 本地麦克风输入音量，范围 0-100。
  final int microphoneVolume;

  /// 本地扬声器输出音量，范围 0-100。
  final int speakerVolume;

  /// 是否正在进行麦克风测试。开启后即使没有通话，也会显示输入电平。
  final bool isMicrophoneTesting;

  /// 是否正在播放扬声器测试音。
  final bool isSpeakerTesting;

  /// 自动/手动音频设备选择模式。
  final PjsipAudioDeviceMode audioDeviceMode;

  /// 当前音频策略的简短状态文案。
  final String audioDeviceStatus;

  /// 当前音频设备异常/降级提示，例如没有麦克风、默认设备不可用。
  ///
  /// 它和 [audioDeviceStatus] 分开保存：status 表达“当前策略”，issue 表达
  /// “需要用户处理的风险”。这样设置页和侧边栏可以用更明显的视觉提示，但不影响
  /// 原有音频策略文案。
  final String? audioDeviceIssueMessage;

  /// 最近一次 PJSIP 音频设备异常码，用于排查 native 侧具体原因。
  final int? audioDeviceIssueStatus;

  /// macOS 麦克风隐私权限状态。
  final PjsipMicrophonePermissionStatus microphonePermissionStatus;

  /// 是否允许通话中检测并自动切换新插入的音频设备。
  final bool allowInCallAudioDeviceSwitch;

  /// 是否播放来电铃声。
  final bool incomingRingtoneEnabled;

  /// 是否播放外呼等待接通时的本地回铃音。
  final bool outgoingRingbackEnabled;

  /// 是否在已接通通话结束时播放轻提示音。
  final bool callEndedSoundEnabled;

  /// 是否在拨号盘输入时播放轻按键音。
  final bool dialpadKeySoundEnabled;

  PjsipUIState({
    required this.logs,
    this.calls = const {},
    this.activeCallId,
    this.conferenceCallIds = const {},
    this.isConferencePaused = false,
    this.conferenceInterruptionCallId,
    this.isNetworkAvailable = true,
    this.networkState = PjsipNetworkState.idle,
    this.seatEnvironmentState = SeatEnvironmentState.checking,
    this.isInitialized = false,
    this.isPhoneServiceRestarting = false,
    this.accId = -1,
    this.host = '',
    this.accounts = const {},
    this.defaultAccountId,
    this.captureDevices = const [],
    this.playbackDevices = const [],
    this.selectedCaptureDeviceId,
    this.selectedPlaybackDeviceId,
    this.isMicrophoneMuted = false,
    this.isSpeakerMuted = false,
    this.remoteMutedCallIds = const {},
    this.microphoneLevel = 0,
    this.speakerLevel = 0,
    this.microphoneVolume = 100,
    this.speakerVolume = 100,
    this.isMicrophoneTesting = false,
    this.isSpeakerTesting = false,
    this.audioDeviceMode = PjsipAudioDeviceMode.automatic,
    this.audioDeviceStatus = '自动选择设备',
    this.audioDeviceIssueMessage,
    this.audioDeviceIssueStatus,
    this.microphonePermissionStatus = PjsipMicrophonePermissionStatus.unknown,
    this.allowInCallAudioDeviceSwitch = true,
    this.incomingRingtoneEnabled = true,
    this.outgoingRingbackEnabled = true,
    this.callEndedSoundEnabled = true,
    this.dialpadKeySoundEnabled = true,
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
    SeatEnvironmentState? seatEnvironmentState,
    bool? isInitialized,
    bool? isPhoneServiceRestarting,
    int? accId,
    String? host,
    Map<int, SipAccountInfo>? accounts,
    Object? defaultAccountId = _unset,
    List<PjsipAudioDevice>? captureDevices,
    List<PjsipAudioDevice>? playbackDevices,
    Object? selectedCaptureDeviceId = _unset,
    Object? selectedPlaybackDeviceId = _unset,
    bool? isMicrophoneMuted,
    bool? isSpeakerMuted,
    Set<int>? remoteMutedCallIds,
    int? microphoneLevel,
    int? speakerLevel,
    int? microphoneVolume,
    int? speakerVolume,
    bool? isMicrophoneTesting,
    bool? isSpeakerTesting,
    PjsipAudioDeviceMode? audioDeviceMode,
    String? audioDeviceStatus,
    Object? audioDeviceIssueMessage = _unset,
    Object? audioDeviceIssueStatus = _unset,
    PjsipMicrophonePermissionStatus? microphonePermissionStatus,
    bool? allowInCallAudioDeviceSwitch,
    bool? incomingRingtoneEnabled,
    bool? outgoingRingbackEnabled,
    bool? callEndedSoundEnabled,
    bool? dialpadKeySoundEnabled,
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
      seatEnvironmentState: seatEnvironmentState ?? this.seatEnvironmentState,
      isInitialized: isInitialized ?? this.isInitialized,
      isPhoneServiceRestarting:
          isPhoneServiceRestarting ?? this.isPhoneServiceRestarting,
      accId: accId ?? this.accId,
      host: host ?? this.host,
      accounts: accounts ?? this.accounts,
      defaultAccountId: identical(defaultAccountId, _unset)
          ? this.defaultAccountId
          : defaultAccountId as int?,
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
      remoteMutedCallIds: remoteMutedCallIds ?? this.remoteMutedCallIds,
      microphoneLevel: microphoneLevel ?? this.microphoneLevel,
      speakerLevel: speakerLevel ?? this.speakerLevel,
      microphoneVolume: microphoneVolume ?? this.microphoneVolume,
      speakerVolume: speakerVolume ?? this.speakerVolume,
      isMicrophoneTesting: isMicrophoneTesting ?? this.isMicrophoneTesting,
      isSpeakerTesting: isSpeakerTesting ?? this.isSpeakerTesting,
      audioDeviceMode: audioDeviceMode ?? this.audioDeviceMode,
      audioDeviceStatus: audioDeviceStatus ?? this.audioDeviceStatus,
      audioDeviceIssueMessage: identical(audioDeviceIssueMessage, _unset)
          ? this.audioDeviceIssueMessage
          : audioDeviceIssueMessage as String?,
      audioDeviceIssueStatus: identical(audioDeviceIssueStatus, _unset)
          ? this.audioDeviceIssueStatus
          : audioDeviceIssueStatus as int?,
      microphonePermissionStatus:
          microphonePermissionStatus ?? this.microphonePermissionStatus,
      allowInCallAudioDeviceSwitch:
          allowInCallAudioDeviceSwitch ?? this.allowInCallAudioDeviceSwitch,
      incomingRingtoneEnabled:
          incomingRingtoneEnabled ?? this.incomingRingtoneEnabled,
      outgoingRingbackEnabled:
          outgoingRingbackEnabled ?? this.outgoingRingbackEnabled,
      callEndedSoundEnabled:
          callEndedSoundEnabled ?? this.callEndedSoundEnabled,
      dialpadKeySoundEnabled:
          dialpadKeySoundEnabled ?? this.dialpadKeySoundEnabled,
    );
  }

  /// 当前主通话对象。没有 activeCallId 或已被移除时返回 null。
  CallInfo? get activeCall => activeCallId == null ? null : calls[activeCallId];

  SipAccountInfo? get defaultAccount =>
      defaultAccountId == null ? null : accounts[defaultAccountId];

  /// 是否存在需要用户注意的音频设备问题。
  bool get hasAudioDeviceIssue =>
      audioDeviceIssueMessage?.trim().isNotEmpty == true;

  Iterable<SipAccountInfo> get registeredAccounts =>
      accounts.values.where((account) => account.isRegistered);

  SipAccountInfo? get bestOutgoingAccount {
    final currentDefault = defaultAccount;
    if (currentDefault?.isRegistered == true) return currentDefault;
    for (final account in registeredAccounts) {
      return account;
    }
    return null;
  }

  bool get hasRegisteredAccount => registeredAccounts.isNotEmpty;

  SipAccountInfo? accountForCall(CallInfo call) =>
      call.accountId == null ? null : accounts[call.accountId];

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
