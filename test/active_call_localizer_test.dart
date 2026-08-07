import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/localization/active_call_localizer.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

void main() {
  group('实时通话统一文案转换', () {
    test('EARLY 状态根据通话方向区分来电等待和对方振铃', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final inbound = _call(state: 3, direction: PjsipCallDirection.inbound);
      final outbound = _call(state: 3);

      expect(ActiveCallLocalizer.status(en, inbound), 'Awaiting answer');
      expect(ActiveCallLocalizer.status(en, outbound), 'Ringing');
    });

    test('本地与远端保持优先于底层邀请会话状态', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(
        ActiveCallLocalizer.status(zh, _call(state: 5, isOnHold: true)),
        '保持中',
      );
      expect(
        ActiveCallLocalizer.status(zh, _call(state: 5, isRemoteOnHold: true)),
        '对方保持',
      );
    });

    test('媒体状态使用相同语言资源并保留未知状态值', () async {
      final traditionalChinese = await AppLocalizations.delegate.load(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );

      expect(
        ActiveCallLocalizer.mediaStatus(
          traditionalChinese,
          _call(state: 5, mediaStatus: 1),
        ),
        '媒體已連線',
      );
      expect(
        ActiveCallLocalizer.mediaStatus(
          traditionalChinese,
          _call(state: 5, mediaStatus: 99),
        ),
        '媒體狀態 99',
      );
    });
  });
}

CallInfo _call({
  required int state,
  PjsipCallDirection direction = PjsipCallDirection.outbound,
  bool isOnHold = false,
  bool isRemoteOnHold = false,
  int? mediaStatus,
}) {
  return CallInfo(
    callId: 1,
    state: state,
    remoteUri: 'sip:1001@example.com',
    direction: direction,
    isOnHold: isOnHold,
    isRemoteOnHold: isRemoteOnHold,
    mediaStatus: mediaStatus,
  );
}
