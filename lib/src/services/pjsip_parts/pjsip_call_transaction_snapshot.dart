part of '../pjsip_service.dart';

/// 单路通话最近一次关键 SIP transaction 快照。
///
/// `on_call_tsx_state` 回调给到的是 PJSIP 原生指针，生命周期很短，不能
/// 跨异步保存。这个模型只保存同步复制出来的 Dart 值，用于 call_info 已
/// 被释放时兜底判断通话结束原因；它不参与 UI 状态驱动，也不触发日志。
class CallSipTransactionSnapshot {
  const CallSipTransactionSnapshot({
    required this.callId,
    required this.method,
    required this.role,
    required this.transactionState,
    required this.eventType,
    required this.statusCode,
    required this.statusText,
    required this.updatedAt,
  });

  /// PJSIP 通话 ID。
  final int callId;

  /// SIP 方法名，例如 INVITE、CANCEL、BYE、REFER。
  final String method;

  /// transaction 角色，UAC 代表本机发起，UAS 代表本机接收。
  final String role;

  /// PJSIP transaction 状态，例如 PROCEEDING、COMPLETED、TERMINATED。
  final String transactionState;

  /// 触发 transaction 状态变化的事件类型，例如 RX_MSG、TX_MSG、TIMER。
  final String eventType;

  /// 最近一次 transaction 状态码。0 表示当前 transaction 尚未形成 SIP 状态。
  final int statusCode;

  /// 最近一次状态原因文本。
  final String statusText;

  /// 快照更新时间。
  final DateTime updatedAt;

  /// 是否有可用于用户提示或通话记录的状态信息。
  bool get hasStatus => statusCode > 0 || statusText.trim().isNotEmpty;

  /// 格式化为通话结束原因。为空时由上层继续使用更粗粒度兜底文案。
  String? get endReason {
    if (!hasStatus) return null;
    final text = statusText.trim();
    final status = statusCode > 0 ? 'SIP $statusCode' : method;
    final reason = text.isEmpty ? status : '$status $text';
    return '$reason · $method/$role/$eventType';
  }
}
