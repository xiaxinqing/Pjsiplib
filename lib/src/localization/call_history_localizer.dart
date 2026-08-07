import '../../l10n/app_localizations.dart';
import '../services/call_history_database.dart';
import '../services/sip_call_end_reason_mapper.dart';

/// 通话记录领域文案的统一转换入口。
///
/// 上层负责选择基础状态、短原因或详情原因；此类只负责把稳定的业务语义
/// 转换成当前 [AppLocalizations] 对应的显示文案，不依赖 BuildContext。
abstract final class CallHistoryLocalizer {
  static String direction(
    AppLocalizations l10n,
    CallHistoryDirection direction,
  ) => switch (direction) {
    CallHistoryDirection.inbound => l10n.callDirectionInbound,
    CallHistoryDirection.outbound => l10n.callDirectionOutbound,
  };

  static String status(AppLocalizations l10n, CallHistoryStatus status) =>
      switch (status) {
        CallHistoryStatus.completed => l10n.callStatusCompleted,
        CallHistoryStatus.missed => l10n.callStatusMissed,
        CallHistoryStatus.rejected => l10n.callStatusRejected,
        CallHistoryStatus.failed => l10n.callStatusFailed,
        CallHistoryStatus.canceled => l10n.callStatusCanceled,
      };

  /// 拒接状态需要结合方向区分“本机拒接”和“对方拒接”。
  static String rejectedStatus(
    AppLocalizations l10n,
    CallHistoryDirection direction,
  ) => direction == CallHistoryDirection.inbound
      ? status(l10n, CallHistoryStatus.rejected)
      : l10n.historyStatusPeerRejected;

  static String shortReason(
    AppLocalizations l10n,
    SipCallEndReason reason,
  ) => switch (reason) {
    SipCallEndReason.authenticationFailed =>
      l10n.historyReasonShortAuthenticationFailed,
    SipCallEndReason.remoteRejected => l10n.historyReasonShortRemoteRejected,
    SipCallEndReason.invalidNumber => l10n.historyReasonShortInvalidNumber,
    SipCallEndReason.noAnswer ||
    SipCallEndReason.timeout => l10n.historyReasonNoAnswer,
    SipCallEndReason.ringingUnanswered => l10n.historyReasonRingingUnanswered,
    SipCallEndReason.remoteBusy => l10n.historyReasonRemoteBusy,
    SipCallEndReason.canceled => l10n.callStatusCanceled,
    SipCallEndReason.unsupportedMedia ||
    SipCallEndReason.mediaFailed => l10n.historyReasonShortMediaFailed,
    SipCallEndReason.serviceUnavailable ||
    SipCallEndReason.serviceError => l10n.historyReasonShortServiceError,
    SipCallEndReason.redirected => l10n.historyReasonShortRedirected,
    SipCallEndReason.blindTransfer => l10n.historyReasonShortBlindTransfer,
    SipCallEndReason.callEnded => l10n.callStatusCompleted,
    SipCallEndReason.incomingEnded => l10n.historyReasonIncomingEnded,
    SipCallEndReason.callRejected ||
    SipCallEndReason.remoteUnavailable ||
    SipCallEndReason.callIncomplete ||
    SipCallEndReason.remoteCannotAnswer ||
    SipCallEndReason.notConnected => l10n.historyReasonNotConnected,
  };

  static String detailReason(
    AppLocalizations l10n,
    SipCallEndReason reason,
  ) => switch (reason) {
    SipCallEndReason.callEnded => l10n.historyReasonCallEnded,
    SipCallEndReason.incomingEnded => l10n.historyReasonIncomingEnded,
    SipCallEndReason.authenticationFailed =>
      l10n.historyReasonAuthenticationFailed,
    SipCallEndReason.remoteRejected => l10n.historyReasonRemoteRejected,
    SipCallEndReason.callRejected => l10n.historyReasonCallRejected,
    SipCallEndReason.invalidNumber => l10n.historyReasonInvalidNumber,
    SipCallEndReason.noAnswer => l10n.historyReasonNoAnswer,
    SipCallEndReason.timeout => l10n.historyReasonTimeout,
    SipCallEndReason.remoteUnavailable => l10n.historyReasonRemoteUnavailable,
    SipCallEndReason.ringingUnanswered => l10n.historyReasonRingingUnanswered,
    SipCallEndReason.remoteBusy => l10n.historyReasonRemoteBusy,
    SipCallEndReason.canceled => l10n.historyReasonCanceled,
    SipCallEndReason.unsupportedMedia => l10n.historyReasonUnsupportedMedia,
    SipCallEndReason.serviceUnavailable => l10n.historyReasonServiceUnavailable,
    SipCallEndReason.redirected => l10n.historyReasonRedirected,
    SipCallEndReason.callIncomplete => l10n.historyReasonCallIncomplete,
    SipCallEndReason.serviceError => l10n.historyReasonServiceError,
    SipCallEndReason.remoteCannotAnswer => l10n.historyReasonRemoteCannotAnswer,
    SipCallEndReason.notConnected => l10n.historyReasonNotConnected,
    SipCallEndReason.mediaFailed => l10n.historyReasonMediaFailed,
    SipCallEndReason.blindTransfer => l10n.historyReasonBlindTransfer,
  };

  static String detailReasonWithSipCode(
    AppLocalizations l10n,
    SipCallEndReason reason,
    int code,
  ) => l10n.historyReasonWithSipCode(detailReason(l10n, reason), code);
}
