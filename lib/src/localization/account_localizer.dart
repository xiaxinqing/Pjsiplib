import '../../l10n/app_localizations.dart';
import '../services/pjsip_service.dart';

/// 统一把线路运行状态转换为当前界面语言。
abstract final class AccountLocalizer {
  static String status(AppLocalizations l10n, SipAccountInfo account) {
    if (account.isRestoringPlaceholder) return l10n.accountStatusRestoring;
    if (!account.registrationEnabled) return l10n.accountStatusDisabled;
    if (account.registrationActionInProgress) {
      return l10n.accountStatusUpdating;
    }
    if (account.isRegistered) return l10n.accountStatusOnline;
    final status = account.registrationStatus;
    if (status == null || status < 200) return l10n.accountStatusConnecting;
    if (status >= 300) return l10n.accountStatusFailed;
    return l10n.accountStatusOffline;
  }
}
