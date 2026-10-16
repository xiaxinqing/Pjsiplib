import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/services/native_bridge/app_badge_controller.dart';
import 'package:veserve_vphone/src/ui/settings/app_badge_switch.dart';

class BadgePreferences implements SharedPreferencesAsync {
  BadgePreferences({this.readGate});

  final values = <String, bool>{};
  final failures = <String>{};
  final Completer<void>? readGate;

  @override
  Future<bool?> getBool(String key) async {
    await readGate?.future;
    if (failures.contains('read')) throw StateError('Read failed');
    return values[key];
  }

  @override
  Future<void> setBool(String key, bool value) async {
    if (failures.contains('write')) throw StateError('Write failed');
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host(AppBadgeController controller) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(child: AppBadgeSwitch(controller: controller)),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_app_badge_control');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late BadgePreferences preferences;
  late AppBadgeController controller;
  final applied = <int>[];
  var supported = true;
  var failSupport = false;
  var failApply = false;
  Completer<void>? updateGate;
  Completer<void>? updateStarted;

  setUp(() {
    preferences = BadgePreferences();
    controller = AppBadgeController(preferences: preferences);
    applied.clear();
    supported = true;
    failSupport = false;
    failApply = false;
    updateGate = null;
    updateStarted = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isAppBadgeSupported') {
        if (failSupport) throw PlatformException(code: 'support_failed');
        return supported;
      }
      if (failApply) throw PlatformException(code: 'apply_failed');
      if (call.method == 'updateBadgeCount') {
        updateStarted?.complete();
        updateStarted = null;
        await updateGate?.future;
        applied.add(call.arguments as int);
      } else if (call.method == 'removeBadge') {
        applied.add(0);
      }
      return null;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('默认开启，响铃和未读相加，归零时移除', () async {
    expect((await controller.readSettings()).enabled, isTrue);
    await controller.setUnreadMissedCount(3);
    await controller.setIncomingCallCount(2);
    await controller.setIncomingCallCount(0);
    await controller.setUnreadMissedCount(0);
    expect(applied, [0, 3, 5, 3, 0]);
  });

  test('关闭立即清除，继续记录变化，重开立即显示最新总数', () async {
    await controller.setUnreadMissedCount(3);
    await controller.setIncomingCallCount(1);
    await controller.setEnabled(false);
    await controller.setUnreadMissedCount(5);
    await controller.setIncomingCallCount(2);
    expect(applied, [3, 4, 0]);
    await controller.setEnabled(true);
    expect(applied.last, 7);
  });

  test('保存关闭后创建新控制器仍关闭，等待偏好期间也不闪出角标', () async {
    await controller.setEnabled(false);
    final gate = Completer<void>();
    final restoredStore = BadgePreferences(readGate: gate)
      ..values.addAll(preferences.values);
    final restored = AppBadgeController(preferences: restoredStore);
    applied.clear();
    final syncing = restored.setUnreadMissedCount(8);
    await Future<void>.delayed(Duration.zero);
    expect(applied, isEmpty);
    gate.complete();
    await syncing;
    expect(applied, [0]);
    expect((await restored.readSettings()).enabled, isFalse);
    await restored.setEnabled(true);
    expect(applied.last, 8);
  });

  test('旧的异步更新完成后再清除，最终不会把关闭的角标写回来', () async {
    updateGate = Completer<void>();
    updateStarted = Completer<void>();
    final started = updateStarted!.future;
    final oldUpdate = controller.setIncomingCallCount(1);
    await started;
    final disabling = controller.setEnabled(false);
    final newerCount = controller.setUnreadMissedCount(6);
    updateGate!.complete();
    await Future.wait([oldUpdate, disabling, newerCount]);
    expect(applied.last, 0);
    await controller.setEnabled(true);
    expect(applied.last, 7);
  });

  test('保存失败保留旧开关和数量，失败不会堵住后续操作', () async {
    await controller.setUnreadMissedCount(4);
    preferences.failures.add('write');
    await expectLater(controller.setEnabled(false), throwsStateError);
    expect(controller.enabled, isTrue);
    expect(applied, [4]);
    preferences.failures.clear();
    await controller.setEnabled(false);
    expect(applied.last, 0);
  });

  test('读取失败不猜测已开启，重试恢复后才同步', () async {
    preferences.failures.add('read');
    await controller.setUnreadMissedCount(3);
    expect(applied, isEmpty);
    preferences.failures.clear();
    expect((await controller.readSettings()).enabled, isTrue);
    expect(applied, [3]);
  });

  testWidgets('开关可关闭并在重新打开设置后恢复，保存失败提供重试', (tester) async {
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    preferences.failures.add('write');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(find.text('Retry'), findsOneWidget);
    preferences.failures.clear();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(AppBadgeController(preferences: preferences)));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('不支持的平台显示说明而不是可操作开关', (tester) async {
    supported = false;
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(find.text('Not supported on this system'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(applied, isEmpty);
  });

  testWidgets('临时查询失败可重试，不缓存成永久不支持', (tester) async {
    failSupport = true;
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    failSupport = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('已保存但系统更新失败，显示保存值并允许重新同步', (tester) async {
    await controller.setUnreadMissedCount(4);
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    failApply = true;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text('Retry'), findsOneWidget);
    failApply = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(applied.last, 0);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('关闭弹窗后异步返回不会访问已经销毁的界面', (tester) async {
    final gate = Completer<void>();
    final slow = AppBadgeController(
      preferences: BadgePreferences(readGate: gate),
    );
    await tester.pumpWidget(host(slow));
    await tester.pumpWidget(const SizedBox());
    gate.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
