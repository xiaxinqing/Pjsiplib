import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// 缩短页面访问本地化资源时的重复代码。
extension BuildContextLocalization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
