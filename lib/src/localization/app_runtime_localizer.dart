import '../../l10n/app_localizations.dart';
import '../../utils/toast_util.dart';

/// 为没有 BuildContext 的异步服务回调提供当前窗口语言。
///
/// 服务层仍保存中文诊断状态并打印中文日志；只有面向用户的 Toast 在显示时转换。
abstract final class AppRuntimeLocalizer {
  static AppLocalizations? get current {
    final context = ToastUtil.navigatorKey.currentContext;
    return context == null ? null : AppLocalizations.of(context);
  }

  static String resolve(
    String Function(AppLocalizations l10n) localized,
    String fallback,
  ) {
    final l10n = current;
    return l10n == null ? fallback : localized(l10n);
  }
}
