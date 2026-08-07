import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/localization/locale_controller.dart';

void main() {
  const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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

    test('中文系统解析为简体或繁体书写体系', () {
      expect(
        resolveAppLocale(const [Locale('zh', 'CN')], supportedLocales),
        const Locale('zh'),
      );
      expect(
        resolveAppLocale(const [Locale('zh', 'HK')], supportedLocales),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );
      expect(
        resolveAppLocale(const [
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ], supportedLocales),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );
    });

    test('英文地区统一使用英文资源', () {
      expect(
        resolveAppLocale(const [Locale('en', 'US')], supportedLocales),
        const Locale('en'),
      );
    });
  });

  group('语言偏好持久化', () {
    test('读取当前简繁体存储值', () {
      expect(
        AppLocalePreferenceValue.fromStorage('zh'),
        AppLocalePreference.simplifiedChinese,
      );
      expect(
        AppLocalePreferenceValue.fromStorage('zh_Hant'),
        AppLocalePreference.traditionalChinese,
      );
    });

    test('兼容旧版地区存储值', () {
      expect(
        AppLocalePreferenceValue.fromStorage('zh_Hans'),
        AppLocalePreference.simplifiedChinese,
      );
      expect(
        AppLocalePreferenceValue.fromStorage('zh_CN'),
        AppLocalePreference.simplifiedChinese,
      );
      expect(
        AppLocalePreferenceValue.fromStorage('zh_TW'),
        AppLocalePreference.traditionalChinese,
      );
    });
  });
}
