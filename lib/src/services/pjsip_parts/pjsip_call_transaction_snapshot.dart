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

  /// 是否有可用于排查的状态信息。
  bool get hasStatus => statusCode > 0 || statusText.trim().isNotEmpty;

  /// 是否已经进入最终 SIP 状态。
  ///
  /// 100 Trying、180 Ringing、183 Session Progress 只是临时状态，不能当作
  /// 客户看到的挂断原因。只有 2xx 及以上才适合保存为结束状态。
  bool get hasFinalStatus => statusCode >= 200;

  /// 给客户看的通话结束原因。为空时由上层继续使用更粗粒度兜底文案。
  String? get customerEndReason {
    if (!hasFinalStatus) return null;
    return _customerSipStatusLabel(statusCode);
  }

  /// 原始快照诊断文案，仅用于日志排查，不直接展示给客户。
  String? get diagnosticReason {
    if (!hasStatus) return null;
    final text = statusText.trim();
    final status = statusCode > 0 ? 'SIP $statusCode' : method;
    final reason = text.isEmpty ? status : '$status $text';
    return '$reason · $method/$role/$eventType';
  }
}

/// call_info 被 PJSIP 提前释放时，挂断流程能使用的兜底结束信息。
///
/// 正常情况下我们直接读取 `pjsua_call_info.last_status`；但远端挂断、未接通
/// 很快结束时，Dart 收到回调再查 call_info 可能已经失败。这个对象把 C 层
/// 事务快照中的状态码和格式化原因合在一起，供记录、提示和日志使用。
class CallReleasedInfo {
  const CallReleasedInfo({
    required this.reason,
    this.sipStatusCode,
    this.fromTransactionSnapshot = false,
  });

  /// 用于通话记录和用户提示的结束原因。
  final String reason;

  /// 最近一次 SIP 状态码；null 表示原生层没有返回明确状态码。
  final int? sipStatusCode;

  /// 是否来自 C 层 `on_call_tsx_state` 安全快照。
  final bool fromTransactionSnapshot;
}

/// 把常见 SIP 状态码转换为客服和客户都能理解的中文文案。
///
/// 文案刻意不暴露 transaction/method 细节；底层细节保留在日志中的
/// [CallSipTransactionSnapshot.diagnosticReason]，方便开发排查。
String _customerSipStatusLabel(int statusCode) {
  final label = switch (statusCode) {
    200 => '通话已结束',
    400 => '呼叫请求异常',
    401 || 407 => '账号认证失败',
    403 => '没有呼叫权限',
    404 || 604 => '号码不存在或无法接通',
    408 || 504 => '呼叫超时',
    480 => '对方暂时不可用',
    486 => '对方忙线',
    487 => '呼叫已取消',
    488 || 606 => '对方不支持本次通话',
    500 => '电话服务异常',
    502 => '网关异常',
    503 => '电话服务暂不可用',
    603 => '对方已拒接',
    >= 300 && < 400 => '呼叫被转移或重定向',
    >= 400 && < 500 => '呼叫未完成',
    >= 500 && < 600 => '电话服务异常',
    >= 600 => '对方无法接听',
    _ => '通话已结束',
  };
  return '$label（SIP $statusCode）';
}
