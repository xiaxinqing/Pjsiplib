import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/localization/locale_controller.dart';

void main() {
  const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  group('系统语言解析', () {
    test('不支持的系统语言回退到英文', () {
      expect(
        resolveAppLocale(const [Locale('ja', 'JP')], supportedLocales),
        const Locale('en'),
      );
    });

    test('系统未返回语言时回退到英文', () {
      expect(resolveAppLocale(null, supportedLocales), const Locale('en'));
    });

    test('中文系统按地区区分简体和繁体', () {
      expect(
        resolveAppLocale(const [Locale('zh', 'CN')], supportedLocales),
        const Locale('zh', 'CN'),
      );
      expect(
        resolveAppLocale(const [Locale('zh', 'HK')], supportedLocales),
        const Locale('zh', 'TW'),
      );
    });

    test('英文地区统一使用英文资源', () {
      expect(
        resolveAppLocale(const [Locale('en', 'US')], supportedLocales),
        const Locale('en'),
      );
    });
  });
}
