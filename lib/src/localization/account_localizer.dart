import '../../l10n/app_localizations.dart';
import '../services/pjsip_service.dart';

enum AccountLineStatus {
  online,
  disabled,
  enabling,
  disabling,
  connecting,
  restarting,
  restoring,
  failed,
  offline;

  String label(AppLocalizations l10n) => switch (this) {
    online => l10n.accountStatusOnline,
    disabled => l10n.accountStatusDisabled,
    enabling => l10n.accountStatusEnabling,
    disabling => l10n.accountStatusDisabling,
    connecting => l10n.accountStatusConnecting,
    restarting => l10n.accountStatusRestarting,
    restoring => l10n.accountStatusRestoring,
    failed => l10n.accountStatusFailed,
    offline => l10n.accountStatusOffline,
  };
}

/// 线路列表的文案和可用操作由同一注册状态推导。
abstract final class AccountLocalizer {
  static String status(AppLocalizations l10n, SipAccountInfo account) =>
      lineStatus(account).label(l10n);

  static AccountLineStatus lineStatus(SipAccountInfo account) {
    if (account.isRestoringPlaceholder) return AccountLineStatus.restoring;
    if (!account.registrationEnabled) {
      return account.registrationActionInProgress &&
              account.restartPhase == SipAccountRestartPhase.none
          ? AccountLineStatus.disabling
          : AccountLineStatus.disabled;
    }
    if (account.restartPhase != SipAccountRestartPhase.none) {
      return AccountLineStatus.restarting;
    }
    if (account.registrationActionInProgress) {
      // 启用和刷新共用注册请求，服务在发起启用时设置这个本地标记。
      return account.registrationStatusText == '启用中'
          ? AccountLineStatus.enabling
          : AccountLineStatus.connecting;
    }
    if (account.isRegistered) return AccountLineStatus.online;
    final code = account.registrationStatus;
    if (code == null || code < 200) return AccountLineStatus.connecting;
    return code >= 300 ? AccountLineStatus.failed : AccountLineStatus.offline;
  }
}
