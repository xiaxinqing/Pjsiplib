import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/localization/audio_settings_localizer.dart';

void main() {
  group('音频设置统一文案转换', () {
    test('设备异常按错误码使用当前语言', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(
        AudioSettingsLocalizer.deviceIssue(
          en,
          AudioSettingsLocalizer.noConcreteCaptureDevice,
        ),
        'No microphone detected. Connect a headset or input device',
      );
      expect(
        AudioSettingsLocalizer.deviceIssue(zh, AudioSettingsLocalizer.notReady),
        '音频设备暂未就绪，请稍后重试',
      );
    });

    test('繁体中文可转换权限和未知错误', () async {
      final traditionalChinese = await AppLocalizations.delegate.load(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );

      expect(
        AudioSettingsLocalizer.deviceIssue(
          traditionalChinese,
          AudioSettingsLocalizer.microphonePermissionDenied,
        ),
        '請在系統設定中允許 VPhone 使用麥克風',
      );
      expect(
        AudioSettingsLocalizer.deviceIssue(traditionalChinese, 999999),
        '音訊裝置暫時不可用（錯誤碼 999999），請重新連接裝置後再試',
      );
    });

    test('仅扬声器降级优先使用明确说明', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        AudioSettingsLocalizer.deviceIssue(
          en,
          AudioSettingsLocalizer.noDevice,
          diagnosticMessage: '麦克风不可用，已切到仅扬声器模式',
        ),
        'The microphone is temporarily unavailable. Speaker-only audio is active; check the input device',
      );
    });

    test('仅转换应用补入的系统默认设备名称', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        AudioSettingsLocalizer.deviceName(en, id: -1, name: '跟随系统输入'),
        'System default input',
      );
      expect(
        AudioSettingsLocalizer.deviceName(en, id: -2, name: '跟随系统输出'),
        'System default output',
      );
      expect(
        AudioSettingsLocalizer.deviceName(en, id: 7, name: 'AirPods Pro'),
        'AirPods Pro',
      );
    });
  });
}
