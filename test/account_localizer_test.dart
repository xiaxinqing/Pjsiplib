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
      expect(
        AccountLocalizer.status(en, account(updating: true)),
        'Connecting',
      );
      expect(
        AccountLocalizer.status(
          en,
          account(
            updating: true,
          ).copyWith(restartPhase: SipAccountRestartPhase.preparing),
        ),
        'Restarting',
      );
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

    test('普通注册和等待注册结果统一显示连接中', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      for (final updating in [false, true]) {
        for (final status in [null, 0, 100]) {
          expect(
            AccountLocalizer.status(
              zh,
              account(status: status, updating: updating),
            ),
            '连接中',
          );
        }
      }
    });

    test('重启跨越注销和临时响应，直到新注册成功才显示在线', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      var restarting = account(
        updating: true,
      ).copyWith(restartPhase: SipAccountRestartPhase.preparing);
      expect(AccountLocalizer.status(zh, restarting), '重启中');

      restarting = restarting.withRegistrationResult(
        status: 200,
        statusText: 'OK',
        expires: 0,
      );
      expect(AccountLocalizer.status(zh, restarting), '重启中');
      expect(restarting.registrationActionInProgress, isTrue);

      restarting = restarting.copyWith(
        restartPhase: SipAccountRestartPhase.registering,
      );
      for (final response in [(100, 0), (200, 0)]) {
        restarting = restarting.withRegistrationResult(
          status: response.$1,
          statusText: '',
          expires: response.$2,
        );
        expect(AccountLocalizer.status(zh, restarting), '重启中');
        expect(restarting.registrationActionInProgress, isTrue);
      }

      final connected = restarting.withRegistrationResult(
        status: 200,
        statusText: 'OK',
        expires: 300,
      );
      expect(AccountLocalizer.status(zh, connected), '在线');
      expect(connected.registrationActionInProgress, isFalse);
      expect(connected.restartPhase, SipAccountRestartPhase.none);
    });

    test('重新注册失败结束重启，停用和恢复仍显示原有状态', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      final restarting = account(
        updating: true,
      ).copyWith(restartPhase: SipAccountRestartPhase.registering);
      final failed = restarting.withRegistrationResult(
        status: 403,
        statusText: 'Forbidden',
        expires: 0,
      );
      expect(AccountLocalizer.status(zh, failed), '连接失败');
      expect(failed.registrationActionInProgress, isFalse);
      expect(failed.restartPhase, SipAccountRestartPhase.none);
      expect(
        AccountLocalizer.status(
          zh,
          restarting.copyWith(registrationEnabled: false),
        ),
        '已停用',
      );
      expect(
        AccountLocalizer.status(zh, restarting.copyWith(accId: -1)),
        '恢复中',
      );
      final paused = account(
        enabled: false,
        updating: true,
      ).withRegistrationResult(status: 200, statusText: 'OK', expires: 300);
      expect(AccountLocalizer.status(zh, paused), '已停用');
      expect(paused.registrationExpires, 0);
      expect(paused.registrationActionInProgress, isFalse);
    });
  });
}
