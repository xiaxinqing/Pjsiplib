import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/services/native_bridge/app_dock_menu_controller.dart';

void main() {
  test('Dock 菜单使用当前界面语言和精简文案', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));

    final english = AppDockMenuLabels.localized(en);
    final simplifiedChinese = AppDockMenuLabels.localized(zh);

    expect(english.openApp, 'Open VPhone');
    expect(english.restartApp, 'Restart app…');
    expect(english.exitApp, 'Quit VPhone');
    expect(simplifiedChinese.settings, '设置');
    expect(simplifiedChinese.aboutApp, '关于 VPhone');
  });
}
