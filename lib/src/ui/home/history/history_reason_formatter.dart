part of '../../../../main.dart';

/// 通话记录原因文案：统一列表短标签、详情结束原因和 tooltip 的展示规则。
///
/// SIP 原始码到业务含义的基础映射放在 [SipCallEndReasonMapper]；这里再结合
/// 通话记录状态、方向和是否响铃，把它转换成历史页需要的 UI 文案。
extension _HistoryReasonFormatter on _MyHomePageState {
  /// 通话记录列表只展示客服能快速理解的短原因。
  ///
  /// 例如来电被本机拒绝显示“已拒接”，外呼被对方拒绝显示“对方拒接”。
  /// 完整 SIP 原因保留给右侧详情，避免列表被协议细节干扰。
  String _historyListStatusLabel(_HistoryItem item) {
    if (item.isLive) return item.statusLabel;
    return switch (item.status) {
      CallHistoryStatus.completed => item.statusLabel,
      CallHistoryStatus.missed => item.statusLabel,
      CallHistoryStatus.rejected =>
        item.direction == CallHistoryDirection.inbound ? '已拒接' : '对方拒接',
      CallHistoryStatus.canceled => item.statusLabel,
      CallHistoryStatus.failed => _historyFailedReasonLabel(item),
      null => item.statusLabel,
    };
  }

  /// SIP 失败码在列表中归类成稳定短文案。
  String _historyFailedReasonLabel(_HistoryItem item) {
    return SipCallEndReasonMapper.shortLabel(
      statusCode: item.sipStatusCode,
      fallbackReason: item.hangupReason,
      reachedRinging: _historyReachedRinging(item),
    );
  }

  /// 右侧详情使用的结束原因。
  ///
  /// 旧版本可能已经把不准确的业务文案写入 hangupReason，例如本机拒接来电
  /// 被存成“对方忙线”。详情展示时优先用结构化状态重新归类，避免列表短标签
  /// 和详情原因互相打架；没有 SIP 码时才回退到已保存的原始文案。
  String? _historyEndReasonText(_HistoryItem item) {
    final direction = item.direction == CallHistoryDirection.inbound
        ? SipReasonDirection.inbound
        : SipReasonDirection.outbound;

    if (item.status == CallHistoryStatus.rejected) {
      if (item.direction == CallHistoryDirection.inbound) return '已拒接';
      return item.sipStatusCode == null
          ? '对方已拒接'
          : SipCallEndReasonMapper.detailText(
              item.sipStatusCode!,
              direction: direction,
              wasConnected: false,
              reachedRinging: _historyReachedRinging(item),
              includeSipCode: true,
            );
    }

    final sipStatusCode = item.sipStatusCode;
    if (sipStatusCode != null) {
      return SipCallEndReasonMapper.detailText(
        sipStatusCode,
        direction: direction,
        wasConnected:
            item.status == CallHistoryStatus.completed ||
            item.answeredAt != null,
        reachedRinging: _historyReachedRinging(item),
        includeSipCode: true,
      );
    }

    final reason = item.hangupReason?.trim();
    return reason == null || reason.isEmpty ? null : reason;
  }

  /// 是否已经进入响铃阶段。
  ///
  /// 403/603 这类状态码在不同阶段含义不同：响铃后更像拒接/未接，
  /// 未响铃时更像线路、权限或服务端策略导致的无法接通。
  bool _historyReachedRinging(_HistoryItem item) {
    return item.ringingAt != null || item.timeToRingingMs != null;
  }
}
