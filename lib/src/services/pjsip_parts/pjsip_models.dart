part of '../pjsip_service.dart';

enum PjsipNetworkState {
  idle,
  offline,
  waitingForStableNetwork,
  recovering,
  failed,
}

class PjsipLog {
  final String message;
  final DateTime time;

  PjsipLog(this.message) : time = DateTime.now();
}

class CallInfo {
  final int callId;
  final int state; // pjsip_inv_state
  final String remoteUri;

  /// 通话接通 (进入 CONFIRMED) 的时间戳，用于计时。未接通时为 null。
  final DateTime? connectedAt;

  /// 是否由本地发起的暂停 (Hold)
  final bool isOnHold;

  /// 是否由远端发起的暂停 (Remote Hold)
  final bool isRemoteOnHold;

  CallInfo({
    required this.callId,
    required this.state,
    required this.remoteUri,
    this.connectedAt,
    this.isOnHold = false,
    this.isRemoteOnHold = false,
  });

  CallInfo copyWith({
    int? callId,
    int? state,
    String? remoteUri,
    DateTime? connectedAt,
    bool? isOnHold,
    bool? isRemoteOnHold,
  }) {
    return CallInfo(
      callId: callId ?? this.callId,
      state: state ?? this.state,
      remoteUri: remoteUri ?? this.remoteUri,
      connectedAt: connectedAt ?? this.connectedAt,
      isOnHold: isOnHold ?? this.isOnHold,
      isRemoteOnHold: isRemoteOnHold ?? this.isRemoteOnHold,
    );
  }

  bool get isIncoming =>
      state == pjsip_inv_state.PJSIP_INV_STATE_INCOMING.value;

  /// 通话是否已真正接通 (媒体已建立)。
  bool get isConnected =>
      state == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.value;

  /// 已接通时长。未接通返回 Duration.zero。
  Duration get duration => connectedAt == null
      ? Duration.zero
      : DateTime.now().difference(connectedAt!);

  /// 计时文案，形如 "01:23" 或 "1:02:03"。
  String get durationLabel {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  /// 根据 pjsip_inv_state 给出可显示的通话状态文案。
  String get statusLabel {
    if (isOnHold) return '⏸ 通话已暂停';
    if (isRemoteOnHold) return '⏸ 对方已暂停通话';

    switch (state) {
      case 1: // CALLING
        return '📲 正在呼叫…';
      case 2: // INCOMING
        return '🔔 收到来电';
      case 3: // EARLY
        return '📳 对方振铃中…';
      case 4: // CONNECTING
        return '🔗 接通中…';
      case 5: // CONFIRMED
        return '📞 通话中';
      case 6: // DISCONNECTED
        return '🔚 通话已结束';
      default:
        return '通话状态: $state';
    }
  }
}

class PjsipUIState {
  final List<PjsipLog> logs;
  final Map<int, CallInfo> calls;
  final int? activeCallId;
  final Set<int> conferenceCallIds;
  final bool isConferencePaused;
  final int? conferenceInterruptionCallId;
  final bool isNetworkAvailable;
  final PjsipNetworkState networkState;
  final bool isInitialized;
  final int accId;
  final String host;

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
    );
  }

  CallInfo? get activeCall => activeCallId == null ? null : calls[activeCallId];

  /// 两路远端通话加上本机用户，即构成三方通话。
  bool get hasConference => conferenceCallIds.length >= 2;

  bool get isConferenceActive => hasConference && !isConferencePaused;

  bool isInConference(int callId) => conferenceCallIds.contains(callId);
}

const Object _unset = Object();
