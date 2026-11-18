import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/main.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';
import 'package:veserve_vphone/src/services/storage_manager.dart';

import 'storage_manager_test.dart' show StorageTestPreferences;

class StorageTestPhone extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: []);

  void setPlayingRecording(int id) {
    state = state.copyWith(playingRecordingId: id);
  }

  void setConnectedCall({required bool recording}) {
    final call = CallInfo(
      callId: 1,
      state: 5,
      mediaStatus: 1,
      connectedAt: DateTime.now(),
      remoteUri: 'sip:100@example.com',
    );
    state = state.copyWith(
      calls: {call.callId: call},
      recordingCallIds: recording ? {call.callId} : {},
    );
  }
}

Future<void> pumpPage(WidgetTester tester) async {
  // 主页面有常驻动画，只等当前页面和弹窗完成这一轮刷新。
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  for (final locale in [
    const Locale('zh'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    const Locale('en'),
  ]) {
    testWidgets('${locale.toLanguageTag()} 存储设置自定义、清理确认和独立录音入口', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(950, 720);
      tester.view.devicePixelRatio = 1;
      tester.binding.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final db = CallHistoryDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = StorageTestPreferences();
      final deleted = <String>[];
      final storage = StorageManager(
        db,
        preferences: prefs,
        deleteFile: (path) async {
          deleted.add(path);
        },
      );
      final startedAt = DateTime.now().subtract(const Duration(days: 100));
      final historyId = await db.recordCall(
        callId: 1,
        direction: CallHistoryDirection.inbound,
        status: CallHistoryStatus.missed,
        remoteUri: 'sip:100@example.com',
        phoneNumber: '100',
        startedAt: startedAt,
        endedAt: startedAt,
        recordingSessionKey: 'retained',
      );
      final recordingId = await db.beginCallRecording(
        sessionKey: 'retained',
        callId: 1,
        relativePath: '2026/01/retained.wav',
        startedAt: startedAt,
      );
      await db.finalizeCallRecording(
        id: recordingId,
        status: CallRecordingStatus.completed,
        endedAt: startedAt,
        duration: const Duration(seconds: 3),
        fileSizeBytes: 96044,
      );
      final l10n = await AppLocalizations.delegate.load(locale);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pjsipServiceProvider.overrideWith(StorageTestPhone.new),
            callHistoryDatabaseProvider.overrideWithValue(db),
            storageManagerProvider.overrideWithValue(storage),
          ],
          child: const MyApp(),
        ),
      );
      await pumpPage(tester);
      await tester.tap(find.byIcon(AppIcons.settings));
      await pumpPage(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(l10n.settingsCalls),
        ),
      );
      await pumpPage(tester);
      final viewRecordings = find.text(l10n.storageViewRecordings);
      await tester.ensureVisible(viewRecordings);
      await tester.tap(viewRecordings);
      await pumpPage(tester);
      expect(find.text('retained.wav'), findsOneWidget);
      expect(
        ProviderScope.containerOf(tester.element(find.byType(MyApp)))
            .read(pjsipServiceProvider)
            .localCallRecordingEnabled,
        isFalse,
      );
      await tester.tap(find.byTooltip(l10n.settingsClose).last);
      await pumpPage(tester);
      expect(viewRecordings, findsOneWidget);
      await tester.tap(find.text(l10n.settingsStorage));
      await pumpPage(tester);
      expect(find.text(l10n.storageForever), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('historyDays')));
      await pumpPage(tester);
      await tester.tap(find.text(l10n.storageCustomDays).last);
      await pumpPage(tester);
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.widgetWithText(FilledButton, l10n.commonSave));
      await pumpPage(tester);
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '37');
      await tester.tap(find.widgetWithText(FilledButton, l10n.commonSave));
      await pumpPage(tester);
      expect((await storage.readSettings()).historyDays, 37);
      expect((await storage.readSettings()).recordingDays, 0);

      // 自定义值显示在按钮上，重新打开菜单也会标记为已选中。
      expect(
        tester.getSize(find.byKey(const ValueKey('historyDays'))).width,
        200,
      );
      await tester.tap(find.byKey(const ValueKey('historyDays')));
      await pumpPage(tester);
      final selected = find.widgetWithText(
        MenuItemButton,
        l10n.storageKeepDays(37),
      );
      expect(
        find.descendant(of: selected, matching: find.byIcon(AppIcons.check)),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.storageCustomDays).last);
      await pumpPage(tester);
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).initialValue,
        '37',
      );
      await tester.tap(find.text(l10n.commonCancel));
      await pumpPage(tester);

      // 按应用允许的最小窗口尺寸检查，按钮仍保持紧凑，页面可以滚动。
      tester.view.physicalSize = const Size(920, 620);
      await pumpPage(tester);
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('historyDays'))).width,
        200,
      );
      tester.view.physicalSize = const Size(950, 720);
      await pumpPage(tester);

      // 预览和取消都不能删数据。
      await tester.tap(find.text(l10n.storageCleanNow));
      await pumpPage(tester);
      expect(find.text(l10n.storageCleanConfirm(1, 0)), findsOneWidget);
      await tester.tap(find.text(l10n.commonCancel));
      await pumpPage(tester);
      expect((await db.listRecentPage()).single.id, historyId);
      await tester.tap(find.text(l10n.storageCleanNow));
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(FilledButton, l10n.storageCleanNow));
      await pumpPage(tester);
      expect(await db.listRecentPage(), isEmpty);
      expect(deleted, isEmpty);
      await tester.tap(find.text(l10n.storageViewRecordings));
      await pumpPage(tester);
      expect(find.text('retained.wav'), findsOneWidget);
      expect(find.byTooltip(l10n.historyRecordingPlay), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyApp)),
      );
      (container.read(pjsipServiceProvider.notifier) as StorageTestPhone)
          .setPlayingRecording(recordingId);
      await pumpPage(tester);
      expect(find.byTooltip(l10n.historyRecordingStop), findsOneWidget);
      // 三种退出方式都要停掉试听；重新打开时不能还是“播放中”。
      if (locale.languageCode == 'en') {
        await tester.tapAt(const Offset(8, 8));
      } else if (locale.scriptCode == 'Hant') {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      } else {
        await tester.tap(find.byTooltip(l10n.settingsClose).last);
      }
      await pumpPage(tester);
      expect(container.read(pjsipServiceProvider).playingRecordingId, isNull);
      expect(find.text('retained.wav'), findsNothing);
      await tester.tap(find.text(l10n.storageViewRecordings));
      await pumpPage(tester);
      expect(find.byTooltip(l10n.historyRecordingPlay), findsOneWidget);
      expect(find.byTooltip(l10n.historyRecordingStop), findsNothing);
      final phone =
          container.read(pjsipServiceProvider.notifier) as StorageTestPhone;
      final toggle = find.widgetWithText(
        SwitchListTile,
        l10n.callSettingsLocalRecording,
      );
      await db.deleteRecording(recordingId);
      await pumpPage(tester);
      expect(find.text(l10n.storageNoRecordingsDisabled), findsOneWidget);
      phone.setConnectedCall(recording: false);
      await pumpPage(tester);
      expect(
        find.textContaining(l10n.storageRecordingStartDuringCall),
        findsOneWidget,
      );
      await tester.tap(toggle);
      await pumpPage(tester);
      expect(find.text(l10n.storageNoRecordingsEnabled), findsOneWidget);
      expect(
        find.textContaining(l10n.storageRecordingStopDuringCall),
        findsNothing,
      );
      phone.setConnectedCall(recording: true);
      await pumpPage(tester);
      expect(
        find.textContaining(l10n.storageRecordingStopDuringCall),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip(l10n.settingsClose).last);
      await pumpPage(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(l10n.settingsCalls),
        ),
      );
      await pumpPage(tester);
      await tester.ensureVisible(toggle);
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      await tester.tap(toggle);
      await pumpPage(tester);
      await tester.tap(find.text(l10n.settingsStorage));
      await pumpPage(tester);
      await tester.tap(find.text(l10n.storageViewRecordings));
      await pumpPage(tester);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(find.text(l10n.storageNoRecordingsDisabled), findsOneWidget);
      await tester.tap(find.byTooltip(l10n.settingsClose).last);
      await pumpPage(tester);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
