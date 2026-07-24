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

  /// 是否由本地发起的暂停 (Hold)
  final bool isOnHold;

  /// 是否由远端发起的暂停 (Remote Hold)
  final bool isRemoteOnHold;

  CallInfo({
    required this.callId,
    required this.state,
    required this.remoteUri,
    this.accountId,
    this.direction = PjsipCallDirection.outbound,
    DateTime? startedAt,
    this.connectedAt,
    this.isOnHold = false,
    this.isRemoteOnHold = false,
  }) : startedAt = startedAt ?? DateTime.now();

  CallInfo copyWith({
    int? callId,
    int? state,
    String? remoteUri,
    Object? accountId = _unset,
    PjsipCallDirection? direction,
    DateTime? startedAt,
    DateTime? connectedAt,
    bool? isOnHold,
    bool? isRemoteOnHold,
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
      connectedAt: connectedAt ?? this.connectedAt,
      isOnHold: isOnHold ?? this.isOnHold,
      isRemoteOnHold: isRemoteOnHold ?? this.isRemoteOnHold,
    );
  }

  /// 是否是来电状态。
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
