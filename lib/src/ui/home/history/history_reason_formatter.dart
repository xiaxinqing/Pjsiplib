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
    final l10n = context.l10n;
    return switch (item.status) {
      CallHistoryStatus.completed => CallHistoryLocalizer.status(
        l10n,
        CallHistoryStatus.completed,
      ),
      CallHistoryStatus.missed => CallHistoryLocalizer.status(
        l10n,
        CallHistoryStatus.missed,
      ),
      CallHistoryStatus.rejected => CallHistoryLocalizer.rejectedStatus(
        l10n,
        item.direction,
      ),
      CallHistoryStatus.canceled => CallHistoryLocalizer.status(
        l10n,
        CallHistoryStatus.canceled,
      ),
      CallHistoryStatus.failed => _historyFailedReasonLabel(item),
      null => item.statusLabel,
    };
  }

  /// SIP 失败码在列表中归类成稳定短文案。
  String _historyFailedReasonLabel(_HistoryItem item) {
    return CallHistoryLocalizer.shortReason(
      context.l10n,
      SipCallEndReasonMapper.shortReason(
        statusCode: item.sipStatusCode,
        fallbackReason: item.hangupReason,
        reachedRinging: _historyReachedRinging(item),
      ),
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
      if (item.direction == CallHistoryDirection.inbound) {
        return CallHistoryLocalizer.status(
          context.l10n,
          CallHistoryStatus.rejected,
        );
      }
      return item.sipStatusCode == null
          ? context.l10n.historyReasonRemoteRejected
          : CallHistoryLocalizer.detailReasonWithSipCode(
              context.l10n,
              SipCallEndReasonMapper.detailReason(
                item.sipStatusCode!,
                direction: direction,
                wasConnected: false,
                reachedRinging: _historyReachedRinging(item),
              ),
              item.sipStatusCode!,
            );
    }

    final sipStatusCode = item.sipStatusCode;
    if (sipStatusCode != null) {
      return CallHistoryLocalizer.detailReasonWithSipCode(
        context.l10n,
        SipCallEndReasonMapper.detailReason(
          sipStatusCode,
          direction: direction,
          wasConnected:
              item.status == CallHistoryStatus.completed ||
              item.answeredAt != null,
          reachedRinging: _historyReachedRinging(item),
        ),
        sipStatusCode,
      );
    }

    final reason = item.hangupReason?.trim();
    if (reason == null || reason.isEmpty) return null;
    final fallbackReason = SipCallEndReasonMapper.reasonFromFallback(reason);
    if (fallbackReason != SipCallEndReason.notConnected) {
      return CallHistoryLocalizer.detailReason(context.l10n, fallbackReason);
    }
    return switch (item.status) {
      CallHistoryStatus.completed => CallHistoryLocalizer.detailReason(
        context.l10n,
        SipCallEndReason.callEnded,
      ),
      CallHistoryStatus.missed => CallHistoryLocalizer.detailReason(
        context.l10n,
        SipCallEndReason.noAnswer,
      ),
      CallHistoryStatus.rejected => CallHistoryLocalizer.detailReason(
        context.l10n,
        SipCallEndReason.remoteRejected,
      ),
      CallHistoryStatus.canceled => CallHistoryLocalizer.detailReason(
        context.l10n,
        SipCallEndReason.canceled,
      ),
      CallHistoryStatus.failed || null => CallHistoryLocalizer.detailReason(
        context.l10n,
        SipCallEndReason.notConnected,
      ),
    };
  }

  /// 是否已经进入响铃阶段。
  ///
  /// 403/603 这类状态码在不同阶段含义不同：响铃后更像拒接/未接，
  /// 未响铃时更像线路、权限或服务端策略导致的无法接通。
  bool _historyReachedRinging(_HistoryItem item) {
    return item.ringingAt != null || item.timeToRingingMs != null;
  }
}
