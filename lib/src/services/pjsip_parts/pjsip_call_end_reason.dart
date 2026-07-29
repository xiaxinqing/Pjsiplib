part of '../pjsip_service.dart';

/// PJSIP 内部使用的结束原因包装函数。
///
/// 真正的 SIP 状态码业务映射在 [SipCallEndReasonMapper] 中集中维护。
/// 这里保留私有函数，是为了让拆分出来的 PJSIP 调用代码不用感知 UI 文案工具类。
String _formatSipCallEndReason(
  int statusCode, {
  required PjsipCallDirection? direction,
  required bool wasConnected,
  required bool reachedRinging,
  bool includeSipCode = false,
}) {
  return SipCallEndReasonMapper.detailText(
    statusCode,
    direction: _toSipReasonDirection(direction),
    wasConnected: wasConnected,
    reachedRinging: reachedRinging,
    includeSipCode: includeSipCode,
  );
}

SipReasonDirection? _toSipReasonDirection(PjsipCallDirection? direction) =>
    switch (direction) {
      PjsipCallDirection.inbound => SipReasonDirection.inbound,
      PjsipCallDirection.outbound => SipReasonDirection.outbound,
      null => null,
    };
