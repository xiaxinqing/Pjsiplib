import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter/material.dart'
    show
        CompositedTransformTarget,
        Dialog,
        FilledButton,
        SegmentedButton,
        SizedBox,
        TextField;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/main.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/contact_service.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

class FakePjsipService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: []);
}

class FakeActiveCallPjsipService extends PjsipService {
  @override
  PjsipUIState build() {
    final connectedAt = DateTime.now().subtract(const Duration(seconds: 20));
    return PjsipUIState(
      logs: [],
      isInitialized: true,
      calls: {
        1: CallInfo(
          callId: 1,
          state: 5,
          remoteUri: 'sip:6545@example.com',
          connectedAt: connectedAt,
          mediaConnectedAt: connectedAt,
        ),
      },
    );
  }
}

void main() {
  test('网络恢复状态可以独立记录', () {
    final offline = PjsipUIState(logs: []).copyWith(
      isNetworkAvailable: false,
      networkState: PjsipNetworkState.offline,
    );

    expect(offline.isNetworkAvailable, isFalse);
    expect(offline.networkState, PjsipNetworkState.offline);
  });

  test('会议暂停时保留原会议成员和中断通话', () {
    final state = PjsipUIState(
      logs: [],
      conferenceCallIds: const {1, 2},
      isConferencePaused: true,
      conferenceInterruptionCallId: 3,
      activeCallId: 3,
    );

    expect(state.hasConference, isTrue);
    expect(state.isConferenceActive, isFalse);
    expect(state.isInConference(1), isTrue);
    expect(state.conferenceInterruptionCallId, 3);
  });

  test('单路麦克风静音不影响其他通话或全局设置', () {
    final state = PjsipUIState(logs: [], microphoneMutedCallIds: const {1});

    expect(state.isMicrophoneMuted, isFalse);
    expect(state.isMicrophoneMutedForCall(1), isTrue);
    expect(state.isMicrophoneMutedForCall(2), isFalse);
  });

  test('会议麦克风状态要求全部成员静音且服从全局静音', () {
    final partiallyMuted = PjsipUIState(
      logs: [],
      conferenceCallIds: const {1, 2},
      microphoneMutedCallIds: const {1},
    );
    final fullyMuted = partiallyMuted.copyWith(
      microphoneMutedCallIds: const {1, 2},
    );
    final globallyMuted = partiallyMuted.copyWith(isMicrophoneMuted: true);

    expect(partiallyMuted.isConferenceMicrophoneMuted, isFalse);
    expect(fullyMuted.isConferenceMicrophoneMuted, isTrue);
    expect(globallyMuted.isConferenceMicrophoneMuted, isTrue);
  });

  test('断开连接时账号状态应回到未登录', () {
    final disconnected = PjsipUIState(
      logs: [],
      isInitialized: true,
      accId: 0,
      host: '139.59.100.15',
    ).copyWith(isInitialized: false, accId: -1, host: '');

    expect(disconnected.isInitialized, isFalse);
    expect(disconnected.accId, -1);
    expect(disconnected.host, isEmpty);
  });

  test('多线路状态可以记录默认外呼线路', () {
    final account6523 = SipAccountInfo(
      accId: 0,
      username: '6523',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
    );
    final account6529 = SipAccountInfo(
      accId: 1,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {0: account6523, 1: account6529},
      defaultAccountId: 1,
      accId: 1,
      host: account6529.host,
    );

    expect(state.accounts.length, 2);
    expect(state.defaultAccount?.username, '6529');
    expect(state.hasRegisteredAccount, isTrue);
  });

  test('注册失败线路不能被当成在线或外呼默认线路', () {
    final failedAccount = SipAccountInfo(
      accId: 1,
      username: '65299',
      host: '139.59.100.15',
      registrationStatus: 401,
      registrationStatusText: 'Unauthorized',
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {1: failedAccount},
      defaultAccountId: 1,
      accId: 1,
      host: failedAccount.host,
    );

    expect(state.hasRegisteredAccount, isFalse);
    expect(state.bestOutgoingAccount, isNull);
  });

  test('默认线路失败时优先选择已注册线路外呼', () {
    final failedAccount = SipAccountInfo(
      accId: 1,
      username: '65299',
      host: '139.59.100.15',
      registrationStatus: 401,
      registrationStatusText: 'Unauthorized',
    );
    final registeredAccount = SipAccountInfo(
      accId: 2,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {1: failedAccount, 2: registeredAccount},
      defaultAccountId: 1,
    );

    expect(state.bestOutgoingAccount?.username, '6529');
    expect(state.hasRegisteredAccount, isTrue);
  });

  test('注销成功的线路即使返回 200 也不应算在线', () {
    final pausedAccount = SipAccountInfo(
      accId: 1,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
      registrationExpires: 0,
      registrationEnabled: false,
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {1: pausedAccount},
      defaultAccountId: 1,
    );

    expect(pausedAccount.isRegistered, isFalse);
    expect(state.bestOutgoingAccount, isNull);
    expect(state.hasRegisteredAccount, isFalse);
  });

  test('暂停确认中的线路不能因为旧 expires 被当成在线', () {
    final pausingAccount = SipAccountInfo(
      accId: 1,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
      registrationExpires: 299,
      registrationEnabled: false,
      registrationActionInProgress: true,
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {1: pausingAccount},
      defaultAccountId: 1,
    );

    expect(pausingAccount.isRegistered, isFalse);
    expect(state.bestOutgoingAccount, isNull);
    expect(state.hasRegisteredAccount, isFalse);
  });

  test('注册操作中线路不应被当成在线', () {
    final registeringAccount = SipAccountInfo(
      accId: 1,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: null,
      registrationStatusText: '注册中',
      registrationActionInProgress: true,
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {1: registeringAccount},
      defaultAccountId: 1,
    );

    expect(registeringAccount.isRegistered, isFalse);
    expect(state.bestOutgoingAccount, isNull);
    expect(state.hasRegisteredAccount, isFalse);
  });

  test('通话可以关联到具体线路', () {
    final account = SipAccountInfo(
      accId: 7,
      username: '售后',
      host: 'pbx.example.com',
    );
    final call = CallInfo(
      callId: 3,
      state: 2,
      remoteUri: 'sip:10086@pbx.example.com',
      accountId: 7,
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {7: account},
      calls: {3: call},
    );

    expect(state.accountForCall(call)?.username, '售后');
  });

  test('联系人备用号码可以被识别为重复号码', () {
    final existing = ContactEntry(
      id: 'contact-a',
      name: '客户 A',
      number: '10086',
      phones: const [
        ContactPhoneEntry(label: '默认', number: '10086', isPrimary: true),
        ContactPhoneEntry(label: '备用', number: '20086'),
      ],
    );
    final state = ContactBookState(contacts: [existing]);

    final conflict = state.findPhoneConflict(const [
      ContactPhoneEntry(label: '手机', number: '20086'),
    ]);

    expect(conflict?.contact.id, 'contact-a');
    expect(conflict?.phone.label, '备用');
  });

  test('保存联系人后会自动关联已有通话记录', () async {
    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final startedAt = DateTime(2026, 7, 23, 10);
    await database.recordCall(
      callId: 88,
      direction: CallHistoryDirection.outbound,
      status: CallHistoryStatus.completed,
      remoteUri: 'sip:10086@pbx.example.com',
      phoneNumber: '10086',
      startedAt: startedAt,
      answeredAt: startedAt.add(const Duration(seconds: 2)),
      endedAt: startedAt.add(const Duration(seconds: 32)),
    );
    await database.recordCall(
      callId: 89,
      direction: CallHistoryDirection.inbound,
      status: CallHistoryStatus.missed,
      remoteUri: 'sip:20086@pbx.example.com',
      phoneNumber: '20086',
      startedAt: startedAt.add(const Duration(minutes: 1)),
      endedAt: startedAt.add(const Duration(minutes: 1, seconds: 8)),
    );

    await database.upsertContact(
      StoredContactRow(
        id: 'contact-10086',
        name: '移动客服',
        number: '10086',
        phones: const [
          StoredContactPhoneRow(label: '热线', number: '10086', isPrimary: true),
          StoredContactPhoneRow(label: '备用', number: '20086', isPrimary: false),
        ],
        company: '客户中心',
        department: '热线',
        remark: '',
        isFavorite: true,
        createdAt: startedAt,
        updatedAt: startedAt,
      ),
    );

    final contact = await database.findContactByPhoneNumber('10086');
    final backupContact = await database.findContactByPhoneNumber('20086');
    final entries = await database
        .watchRecentForContact(
          contactId: 'contact-10086',
          phoneNumber: '10086',
          phoneNumbers: const ['10086', '20086'],
        )
        .first;

    expect(contact?.name, '移动客服');
    expect(backupContact?.id, 'contact-10086');
    expect(contact?.phones, hasLength(2));
    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.contactId).toSet(), {'contact-10086'});
    expect(entries.map((entry) => entry.displayName).toSet(), {'移动客服'});
  });

  test('通话备注会保存到通话记录', () async {
    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final startedAt = DateTime(2026, 7, 24, 9);
    await database.recordCall(
      callId: 90,
      direction: CallHistoryDirection.outbound,
      status: CallHistoryStatus.completed,
      remoteUri: 'sip:10010@pbx.example.com',
      phoneNumber: '10010',
      startedAt: startedAt,
      answeredAt: startedAt.add(const Duration(seconds: 3)),
      endedAt: startedAt.add(const Duration(seconds: 63)),
      note: '客户要求下午回访',
    );

    final entries = await database.watchRecent(keyword: '回访', limit: 1).first;

    expect(entries, hasLength(1));
    expect(entries.single.note, '客户要求下午回访');

    await database.updateEntryNote(entries.single.id, '客户已确认明天回访');
    final updated = await database.watchRecent(keyword: '明天', limit: 1).first;
    expect(updated.single.note, '客户已确认明天回访');

    await database.updateEntryNote(entries.single.id, '');
    final cleared = await database.watchRecent(limit: 1).first;
    expect(cleared.single.note, isNull);
  });

  test('数据库关闭会等待已接受的写入并拒绝新写入', () async {
    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final startedAt = DateTime(2026, 7, 31, 10);

    final writes = List<Future<void>>.generate(
      20,
      (index) => database.recordCall(
        callId: index,
        direction: CallHistoryDirection.outbound,
        status: CallHistoryStatus.canceled,
        remoteUri: 'sip:$index@pbx.example.com',
        phoneNumber: '$index',
        startedAt: startedAt.add(Duration(seconds: index)),
        endedAt: startedAt.add(Duration(seconds: index + 1)),
      ),
    );

    final closeFuture = database.close();
    await Future.wait(writes);
    await closeFuture;

    await expectLater(database.clearAll(), throwsA(isA<StateError>()));
  });

  test('进程退出准备会等待写入但不主动关闭数据库连接', () async {
    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final startedAt = DateTime(2026, 8, 3, 10);

    final write = database.recordCall(
      callId: 101,
      direction: CallHistoryDirection.outbound,
      status: CallHistoryStatus.canceled,
      remoteUri: 'sip:101@pbx.example.com',
      phoneNumber: '101',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(seconds: 1)),
    );

    await database.prepareForProcessExit();
    await write;

    final rows = await database.listRecentPage(limit: 10);
    expect(rows, hasLength(1));
    await expectLater(database.clearAll(), throwsA(isA<StateError>()));
  });

  testWidgets('VoIP 主界面可以正常构建', (WidgetTester tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [
      Locale('zh', 'CN'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pjsipServiceProvider.overrideWith(FakePjsipService.new)],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('VPhone'), findsOneWidget);
    expect(find.text('拨号'), findsWidgets);
    expect(find.byIcon(AppIcons.settings), findsOneWidget);
  });

  for (final locale in const [
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('en'),
  ]) {
    testWidgets('设置页使用 ${locale.toLanguageTag()} 文案且布局正常', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      tester.binding.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final l10n = await AppLocalizations.delegate.load(locale);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [pjsipServiceProvider.overrideWith(FakePjsipService.new)],
          child: const MyApp(),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(AppIcons.settings));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text(l10n.accountSettingsEmpty), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.accountSettingsAddLine).last,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text(l10n.accountDialogUsername), findsOneWidget);
      expect(find.text(l10n.accountDialogServer), findsOneWidget);
      await tester.tap(find.text(l10n.commonCancel).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      final settingsDialog = find.byType(Dialog);
      final callsNavigation = find.descendant(
        of: settingsDialog,
        matching: find.text(l10n.settingsCalls),
      );
      await tester.tap(callsNavigation);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text(l10n.callSettingsControls), findsOneWidget);
      expect(find.text(l10n.callSettingsAutoHold), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: settingsDialog,
          matching: find.text(l10n.settingsDiagnostics),
        ),
      );
      await tester.pump();
      expect(find.text(l10n.diagnosticsShowLogs), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: settingsDialog,
          matching: find.text(l10n.settingsAbout),
        ),
      );
      await tester.pump();
      expect(find.text(l10n.aboutTagline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('英文通话记录窄宽度使用方向下拉且宽屏恢复分段按钮', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 740);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pjsipServiceProvider.overrideWith(FakePjsipService.new),
          callHistoryDatabaseProvider.overrideWithValue(database),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.navCallHistory).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == l10n.historySearchPlaceholder,
    );
    final segmentedFilter = find.byWidgetPredicate(
      (widget) => widget is SegmentedButton,
    );
    expect(searchField, findsOneWidget);
    expect(segmentedFilter, findsNothing);
    expect(tester.getSize(searchField).width, greaterThanOrEqualTo(100));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(l10n.historyFilterAll).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final outboundMenuItem = find.text(l10n.historyFilterOutbound);
    expect(outboundMenuItem, findsOneWidget);
    await tester.tap(outboundMenuItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.historyFilterOutbound), findsOneWidget);

    tester.view.physicalSize = const Size(1454, 740);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(segmentedFilter, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('双栏历史列表变窄时隐藏时长列且详情保留时长', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1079, 710);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    final database = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final startedAt = DateTime.now().subtract(const Duration(minutes: 2));
    await database.recordCall(
      callId: 101,
      direction: CallHistoryDirection.outbound,
      status: CallHistoryStatus.completed,
      remoteUri: 'sip:6545@pbx.example.com',
      phoneNumber: '6545',
      displayName: '风清扬',
      accountLabel: '6543@143.198.197.101:5061',
      startedAt: startedAt,
      answeredAt: startedAt.add(const Duration(seconds: 2)),
      endedAt: startedAt.add(const Duration(seconds: 32)),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pjsipServiceProvider.overrideWith(FakePjsipService.new),
          callHistoryDatabaseProvider.overrideWithValue(database),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.navCallHistory).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(l10n.historyColumnDuration), findsNothing);
    expect(find.text(l10n.historyFieldDuration), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1454, 710);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.historyColumnDuration), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('通话中键盘以浮层显示且不推动主舞台操作区', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 740);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pjsipServiceProvider.overrideWith(FakeActiveCallPjsipService.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.navCurrentCalls).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final hangUpLabel = find.text(l10n.activeCallHangUp).first;
    final hangUpPosition = tester.getTopLeft(hangUpLabel);
    final keypadControl = find.ancestor(
      of: find.text(l10n.activeCallKeypad),
      matching: find.byType(CompositedTransformTarget),
    );
    await tester.tap(
      find.descendant(
        of: keypadControl,
        matching: find.byIcon(AppIcons.dialpad),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));

    expect(find.text(l10n.activeCallDtmfTitle), findsOneWidget);
    expect(tester.getTopLeft(hangUpLabel), hangUpPosition);
    final popoverRect = tester.getRect(find.text(l10n.activeCallDtmfTitle));
    expect(popoverRect.top, greaterThanOrEqualTo(64));
    expect(popoverRect.right, lessThanOrEqualTo(1200));
    expect(popoverRect.bottom, lessThan(tester.getRect(keypadControl).top));

    await tester.tap(find.text(l10n.activeCallPanelCurrentCalls).last);
    await tester.pump();
    expect(find.text(l10n.activeCallDtmfTitle), findsNothing);

    await tester.tap(
      find.descendant(
        of: keypadControl,
        matching: find.byIcon(AppIcons.dialpad),
      ),
    );
    await tester.pump();
    expect(find.text(l10n.activeCallDtmfTitle), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text(l10n.activeCallDtmfTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('VoIP 主界面在矮窗口下可以滚动布局', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 620);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pjsipServiceProvider.overrideWith(FakePjsipService.new)],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('VPhone'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
