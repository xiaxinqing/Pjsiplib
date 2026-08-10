part of '../pjsip_service.dart';

enum PjsipCallDirection { inbound, outbound }

/// 一路 SIP 通话在 UI 层需要关心的信息。
///
/// PJSIP 自己维护完整的 call object；这里不是复制全部底层数据，而是抽取 UI、
/// 会议、暂停/恢复、计时所需的最小状态。
class CallInfo {
  /// PJSIP 分配的通话 ID。后续接听、挂断、hold、取 conference slot 都靠它。
  final int callId;

  /// PJSIP 邀请会话状态，对应 `pjsip_inv_state`。
  ///
  /// 常见值：2=INCOMING、5=CONFIRMED、6=DISCONNECTED。
  final int state;

  /// 远端 SIP URI，用于展示来电方/对端信息。
  final String remoteUri;

  /// 这通电话归属的 SIP 账号/线路 ID。来电来自 PJSIP 回调 accId，外呼来自默认线路。
  final int? accountId;

  /// 呼叫方向。用于通话记录判断未接来电、呼出取消、呼叫失败等状态。
  final PjsipCallDirection direction;

  /// 通话创建时间。外呼为发起 INVITE 的时刻，来电为收到 INVITE 的时刻。
  final DateTime startedAt;

  /// 通话接通 (进入 CONFIRMED) 的时间戳，用于计时。未接通时为 null。
  final DateTime? connectedAt;

  /// 振铃开始时间。
  ///
  /// 外呼：收到 180/183 后进入 EARLY 的时间，表示“对方开始振铃/早期媒体”。
  /// 来电：本机收到 INVITE 并回 180 的时间，表示“客户已开始等待我们接听”。
  final DateTime? ringingAt;

  /// 媒体真正 ACTIVE 的时间。
  ///
  /// SIP 接通不等于 RTP/SRTP 已可用，这个时间点用于排查“信令通了但没声音”。
  final DateTime? mediaConnectedAt;

  /// 是否由本地发起的暂停 (Hold)
  final bool isOnHold;

  /// 是否由远端发起的暂停 (Remote Hold)
  final bool isRemoteOnHold;

  /// PJSIP 当前默认音频媒体状态。SIP dialog 接通不代表 RTP/SRTP 已经可用，
  /// 这个字段用于 UI 区分“信令通了”和“媒体已建立”。
  final int? mediaStatus;

  /// 当前音频媒体 transport 是否实际堆叠了 SRTP。
  final CallMediaSecurity? mediaSecurity;

  /// 当前这次 Hold 开始的时间。非 Hold 状态为 null。
  final DateTime? holdStartedAt;

  /// 已完成的累计 Hold 时长。正在 Hold 的一段在归档时再补上。
  final Duration totalHoldDuration;

  /// 本地/远端进入 Hold 的次数，用于判断客户等待次数。
  final int holdCount;

  CallInfo({
    required this.callId,
    required this.state,
    required this.remoteUri,
    this.accountId,
    this.direction = PjsipCallDirection.outbound,
    DateTime? startedAt,
    this.connectedAt,
    this.ringingAt,
    this.mediaConnectedAt,
    this.isOnHold = false,
    this.isRemoteOnHold = false,
    this.mediaStatus,
    this.mediaSecurity,
    this.holdStartedAt,
    this.totalHoldDuration = Duration.zero,
    this.holdCount = 0,
  }) : startedAt = startedAt ?? DateTime.now();

  CallInfo copyWith({
    int? callId,
    int? state,
    String? remoteUri,
    Object? accountId = _unset,
    PjsipCallDirection? direction,
    DateTime? startedAt,
    Object? connectedAt = _unset,
    Object? ringingAt = _unset,
    Object? mediaConnectedAt = _unset,
    bool? isOnHold,
    bool? isRemoteOnHold,
    Object? mediaStatus = _unset,
    Object? mediaSecurity = _unset,
    Object? holdStartedAt = _unset,
    Duration? totalHoldDuration,
    int? holdCount,
  }) {
    return CallInfo(
      callId: callId ?? this.callId,
      state: state ?? this.state,
      remoteUri: remoteUri ?? this.remoteUri,
      accountId: identical(accountId, _unset)
          ? this.accountId
          : accountId as int?,
      direction: direction ?? this.direction,
      startedAt: startedAt ?? this.startedAt,
      connectedAt: identical(connectedAt, _unset)
          ? this.connectedAt
          : connectedAt as DateTime?,
      ringingAt: identical(ringingAt, _unset)
          ? this.ringingAt
          : ringingAt as DateTime?,
      mediaConnectedAt: identical(mediaConnectedAt, _unset)
          ? this.mediaConnectedAt
          : mediaConnectedAt as DateTime?,
      isOnHold: isOnHold ?? this.isOnHold,
      isRemoteOnHold: isRemoteOnHold ?? this.isRemoteOnHold,
      mediaStatus: identical(mediaStatus, _unset)
          ? this.mediaStatus
          : mediaStatus as int?,
      mediaSecurity: identical(mediaSecurity, _unset)
          ? this.mediaSecurity
          : mediaSecurity as CallMediaSecurity?,
      holdStartedAt: identical(holdStartedAt, _unset)
          ? this.holdStartedAt
          : holdStartedAt as DateTime?,
      totalHoldDuration: totalHoldDuration ?? this.totalHoldDuration,
      holdCount: holdCount ?? this.holdCount,
    );
  }

  Duration? get timeToRinging => ringingAt == null
      ? null
      : _positiveDuration(ringingAt!.difference(startedAt));

  Duration? get ringingToAnswer {
    final ringing = ringingAt;
    final answered = connectedAt;
    if (ringing == null || answered == null) return null;
    return _positiveDuration(answered.difference(ringing));
  }

  Duration? get answerToMedia {
    final answered = connectedAt;
    final media = mediaConnectedAt;
    if (answered == null || media == null) return null;
    return _positiveDuration(media.difference(answered));
  }

  /// 归档时把“当前还在 Hold 的片段”也算进去。
  Duration effectiveHoldDuration(DateTime endedAt) {
    final activeHold = holdStartedAt == null
        ? Duration.zero
        : _positiveDuration(endedAt.difference(holdStartedAt!));
    return totalHoldDuration + activeHold;
  }

  /// 是否是等待本机处理的来电。
  ///
  /// 注意：收到 INVITE 后我们会主动回 `180 Ringing`，PJSIP 可能把来电从
  /// INCOMING 推进到 EARLY。这个 EARLY 仍然是“别人打给我，等待我接听”，
  /// 不能当成外呼的“对方振铃中”。
  bool get isIncoming {
    if (direction != PjsipCallDirection.inbound) return false;
    return state == pjsip_inv_state.PJSIP_INV_STATE_INCOMING.value ||
        state == pjsip_inv_state.PJSIP_INV_STATE_EARLY.value;
  }

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
        return direction == PjsipCallDirection.inbound
            ? '🔔 等待接听'
            : '📳 对方振铃中…';
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

Duration _positiveDuration(Duration duration) {
  return duration.isNegative ? Duration.zero : duration;
}

enum CallMediaKeyingMethod {
  dtls('DTLS'),
  sdes('SDES');

  const CallMediaKeyingMethod(this.label);

  final String label;
}

class CallMediaSecurity {
  const CallMediaSecurity({
    required this.hasSrtpTransport,
    required this.srtpActive,
    this.transportStack = const [],
    this.keyingMethod,
  });

  /// 媒体栈是否包含 SRTP 适配层；存在不代表密钥已经协商完成。
  final bool hasSrtpTransport;

  /// SRTP 会话是否已经真正激活，可用于面向用户确认“通话已加密”。
  final bool srtpActive;

  final List<String> transportStack;
  final CallMediaKeyingMethod? keyingMethod;
}
