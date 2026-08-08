import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/localization/account_localizer.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

void main() {
  group('线路状态统一文案转换', () {
    SipAccountInfo account({
      int accId = 1,
      int? status,
      bool enabled = true,
      bool updating = false,
    }) {
      return SipAccountInfo(
        accId: accId,
        username: '101',
        host: 'sip.example.com',
        registrationStatus: status,
        registrationEnabled: enabled,
        registrationActionInProgress: updating,
      );
    }

    test('英文覆盖线路的主要运行状态', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(AccountLocalizer.status(en, account(status: 200)), 'Online');
      expect(AccountLocalizer.status(en, account(status: 100)), 'Connecting');
      expect(AccountLocalizer.status(en, account(status: 401)), 'Failed');
      expect(AccountLocalizer.status(en, account(status: 202)), 'Offline');
      expect(AccountLocalizer.status(en, account(enabled: false)), 'Disabled');
      expect(AccountLocalizer.status(en, account(updating: true)), 'Updating');
      expect(AccountLocalizer.status(en, account(accId: -1)), 'Restoring');
    });

    test('简繁中文不依赖底层英文 SIP 状态', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      final zhHant = await AppLocalizations.delegate.load(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );

      expect(AccountLocalizer.status(zh, account(status: 401)), '连接失败');
      expect(AccountLocalizer.status(zhHant, account(status: 401)), '連線失敗');
    });
  });
}
