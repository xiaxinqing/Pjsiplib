part of '../pjsip_service.dart';

/// 通话结束原因的业务化分类。
///
/// SIP 状态码只说明协议结果，同一个状态码在不同服务端配置下可能代表不同业务
/// 含义。这里把“是否已经接通、是否进入过响铃、呼叫方向”合在一起判断，避免
/// Toast 和通话记录直接展示 `Forbidden`、`Decline` 这类容易误导的原始文案。
String _formatSipCallEndReason(
  int statusCode, {
  required PjsipCallDirection? direction,
  required bool wasConnected,
  required bool reachedRinging,
  bool includeSipCode = false,
}) {
  final label = _sipCallEndReasonLabel(
    statusCode,
    direction: direction,
    wasConnected: wasConnected,
    reachedRinging: reachedRinging,
  );
  if (!includeSipCode || statusCode <= 0) return label;
  return '$label（SIP $statusCode）';
}

String _sipCallEndReasonLabel(
  int statusCode, {
  required PjsipCallDirection? direction,
  required bool wasConnected,
  required bool reachedRinging,
}) {
  if (wasConnected) return '通话已结束';

  return switch (statusCode) {
    // 外呼 INVITE 的 401/407 通常只是 Digest 鉴权挑战；如果最后仍停在这里，
    // 才按账号认证问题展示。已接通场景会在上层忽略这类历史快照。
    401 || 407 => '账号认证失败',

    // Asterisk 等服务端可能在对方响铃后返回 403 + Q.850 cause=21 表达拒接；
    // 没有响铃上下文时，403 更像线路策略、权限或服务端拒绝。
    403 when reachedRinging => '对方已拒接',
    403 => '呼叫被拒绝',

    404 || 604 => '号码不存在或无法接通',
    408 || 504 => '呼叫超时',
    480 => '对方暂时无法接通',
    486 => '对方忙线',
    487 => '呼叫已取消',
    488 || 606 => '对方不支持本次通话',

    // 603 Decline 没有统一业务含义：响铃后通常是拒接；未响铃直接 603
    // 更常见于分机未注册、路由策略拒绝或对方不可达。
    603 when reachedRinging => '对方已拒接',
    603 => '对方无法接听',

    500 || 502 || 503 => '电话服务暂时不可用',
    >= 300 && < 400 => '呼叫被转移或重定向',
    >= 400 && < 500 => '呼叫未完成',
    >= 500 && < 600 => '电话服务异常',
    >= 600 => '对方无法接听',
    _ => direction == PjsipCallDirection.inbound ? '来电已结束' : '通话已结束',
  };
}
