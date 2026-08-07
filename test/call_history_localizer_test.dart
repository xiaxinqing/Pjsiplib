import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/localization/call_history_localizer.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/sip_call_end_reason_mapper.dart';

void main() {
  group('通话记录统一文案转换', () {
    test('基础方向和状态按当前语言转换', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(
        CallHistoryLocalizer.direction(en, CallHistoryDirection.outbound),
        'Outgoing',
      );
      expect(
        CallHistoryLocalizer.status(en, CallHistoryStatus.completed),
        'Connected',
      );
      expect(
        CallHistoryLocalizer.direction(zh, CallHistoryDirection.inbound),
        '来电',
      );
      expect(CallHistoryLocalizer.status(zh, CallHistoryStatus.missed), '未接来电');
    });

    test('拒接状态结合通话方向转换', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        CallHistoryLocalizer.rejectedStatus(en, CallHistoryDirection.inbound),
        'Rejected',
      );
      expect(
        CallHistoryLocalizer.rejectedStatus(en, CallHistoryDirection.outbound),
        'Declined',
      );
    });

    test('短原因和详情原因使用同一套语言资源', () async {
      final traditionalChinese = await AppLocalizations.delegate.load(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );

      expect(
        CallHistoryLocalizer.shortReason(
          traditionalChinese,
          SipCallEndReason.authenticationFailed,
        ),
        '認證失敗',
      );
      expect(
        CallHistoryLocalizer.detailReason(
          traditionalChinese,
          SipCallEndReason.authenticationFailed,
        ),
        '帳戶認證失敗',
      );
      expect(
        CallHistoryLocalizer.detailReasonWithSipCode(
          traditionalChinese,
          SipCallEndReason.remoteBusy,
          486,
        ),
        '對方忙線（SIP 486）',
      );
    });
  });
}
