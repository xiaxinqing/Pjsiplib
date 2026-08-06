import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户选择的应用显示语言。
///
/// `system` 不强制指定 Locale，由 Flutter 根据操作系统语言自动匹配。
enum AppLocalePreference {
  system,
  simplifiedChinese,
  traditionalChinese,
  english,
}

extension AppLocalePreferenceValue on AppLocalePreference {
  Locale? get locale => switch (this) {
    AppLocalePreference.system => null,
    AppLocalePreference.simplifiedChinese => const Locale('zh', 'CN'),
    AppLocalePreference.traditionalChinese => const Locale('zh', 'TW'),
    AppLocalePreference.english => const Locale('en'),
  };

  String get storageValue => switch (this) {
    AppLocalePreference.system => 'system',
    AppLocalePreference.simplifiedChinese => 'zh_CN',
    AppLocalePreference.traditionalChinese => 'zh_TW',
    AppLocalePreference.english => 'en',
  };

  static AppLocalePreference fromStorage(String? value) => switch (value) {
    'zh_CN' => AppLocalePreference.simplifiedChinese,
    'zh_TW' => AppLocalePreference.traditionalChinese,
    'en' => AppLocalePreference.english,
    _ => AppLocalePreference.system,
  };
}

/// 读取、切换并持久化应用显示语言。
class LocaleController extends Notifier<AppLocalePreference> {
  static const _storageKey = 'app_locale_preference';
  static final _storage = SharedPreferencesAsync();

  bool _changedByUser = false;

  @override
  AppLocalePreference build() {
    unawaited(_restore());
    return AppLocalePreference.system;
  }

  /// 保存用户选择；跟随系统时删除显式配置，避免保存无意义的默认值。
  Future<void> setPreference(AppLocalePreference preference) async {
    _changedByUser = true;
    state = preference;
    try {
      if (preference == AppLocalePreference.system) {
        await _storage.remove(_storageKey);
        return;
      }
      await _storage.setString(_storageKey, preference.storageValue);
    } catch (_) {
      // 语言已经即时切换。普通偏好写入失败时不向 UI 抛出异常，避免影响使用。
    }
  }

  Future<void> _restore() async {
    try {
      final stored = await _storage.getString(_storageKey);
      if (!_changedByUser) {
        state = AppLocalePreferenceValue.fromStorage(stored);
      }
    } catch (_) {
      // 语言偏好读取失败不应影响电话服务启动，继续跟随系统语言。
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, AppLocalePreference>(
      LocaleController.new,
    );

/// 将系统 Locale 收敛到应用实际支持的语言。
///
/// Flutter 默认只按语言代码匹配时，香港、澳门等繁体中文系统可能命中
/// 简体中文资源，因此这里显式识别繁体脚本和常见繁体地区；系统语言不在
/// 支持列表中，或系统未返回语言时，统一回退到英文。
Locale resolveAppLocale(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  final preferred = preferredLocales != null && preferredLocales.isNotEmpty
      ? preferredLocales.first
      : null;
  Locale resolvedLocale;
  if (preferred?.languageCode == 'zh') {
    final usesTraditionalChinese =
        preferred?.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(preferred?.countryCode);
    resolvedLocale = usesTraditionalChinese
        ? const Locale('zh', 'TW')
        : const Locale('zh', 'CN');
  } else if (preferred?.languageCode == 'en') {
    resolvedLocale = const Locale('en');
  } else {
    resolvedLocale = const Locale('en');
  }

  return supportedLocales.contains(resolvedLocale)
      ? resolvedLocale
      : supportedLocales.first;
}
