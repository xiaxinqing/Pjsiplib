import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show FilledButton, SizedBox, TextField;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/main.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

class _TrialPjsipService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(
    logs: [],
    isNetworkAvailable: false,
    accounts: {
      for (final id in [1, 2])
        id: SipAccountInfo(
          accId: id,
          lineName: '试用账号 $id',
          username: '200$id',
          host: 'example.com',
          registrationStatus: 403,
        ),
    },
    activeCallId: 3,
    conferenceCallIds: const {1, 2},
    calls: {
      for (final id in [1, 2, 3])
        id: CallInfo(
          callId: id,
          accountId: id == 2 ? 2 : 1,
          remoteUri: 'sip:1001@example.com',
          state: id == 3 ? 3 : 5,
        ),
    },
  );

  void addFourthIncomingCall() {
    state = state.copyWith(
      calls: {
        ...state.calls,
        4: CallInfo(
          callId: 4,
          accountId: 2,
          remoteUri: 'sip:1001@example.com',
          direction: PjsipCallDirection.inbound,
          state: 2,
        ),
      },
    );
  }
}

void main() {
  testWidgets('试用拨号只受四路容量限制，满四路仍可接听已有来电', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pjsipServiceProvider.overrideWith(_TrialPjsipService.new),
          callHistoryDatabaseProvider.overrideWithValue(database),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    final numberField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == l10n.dialNumberHint,
    );
    await tester.enterText(numberField, '1001');
    await tester.pump();

    // 已有同号会议和未接通外呼，即使注册失败、网络标记离线仍允许提交。
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, l10n.dialCall),
          )
          .onPressed,
      isNotNull,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MyApp)),
    );
    final service =
        container.read(pjsipServiceProvider.notifier) as _TrialPjsipService;
    service.addFourthIncomingCall();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.navDialpad).first);
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, l10n.dialCapacityReached),
          )
          .onPressed,
      isNull,
    );
    final answerButtons = tester.widgetList<FilledButton>(
      find.widgetWithText(FilledButton, l10n.activeCallAnswer),
    );
    expect(answerButtons, isNotEmpty);
    expect(answerButtons.every((button) => button.onPressed != null), isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
