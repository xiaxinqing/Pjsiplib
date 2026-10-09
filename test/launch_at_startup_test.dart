import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veserve_vphone/l10n/app_localizations.dart';
import 'package:veserve_vphone/src/services/native_bridge/app_launch_at_startup_controller.dart';
import 'package:veserve_vphone/src/services/native_bridge/app_window_controller.dart';
import 'package:veserve_vphone/src/ui/settings/launch_at_startup_switch.dart';

class MemoryPreferences implements SharedPreferencesAsync {
  MemoryPreferences({this.failWrite = false});
  final values = <String, Object>{};
  final bool failWrite;

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<int?> getInt(String key) async => values[key] as int?;

  @override
  Future<void> setInt(String key, int value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    if (failWrite) throw StateError('Preference write failed');
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStartupController extends AppLaunchAtStartupController {
  FakeStartupController({MemoryPreferences? preferences})
    : super(preferences: preferences ?? MemoryPreferences());

  LaunchAtStartupStatus status = LaunchAtStartupStatus.disabled;
  Completer<LaunchAtStartupStatus>? write;
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;
  int settingsOpened = 0;

  @override
  Future<LaunchAtStartupStatus> readStatus() async {
    if (failRead) throw StateError('Read failed');
    return status;
  }

  @override
  Future<LaunchAtStartupStatus> setEnabled(bool enabled) async {
    writes++;
    if (failWrite) throw StateError('Write failed');
    return status = write != null
        ? await write!.future
        : enabled
        ? LaunchAtStartupStatus.enabled
        : LaunchAtStartupStatus.disabled;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}

Widget host(FakeStartupController controller, {bool showChild = false}) =>
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: LaunchAtStartupSwitch(
            controller: controller,
            layoutBuilder: showChild
                ? (startup, hidden) => Column(
                    children: [
                      startup,
                      if (hidden != null)
                        KeyedSubtree(
                          key: const Key('startMinimized'),
                          child: hidden,
                        ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('子开关只在开启后出现，默认关闭，保存后重开弹窗仍有效', (tester) async {
    final controller = FakeStartupController();
    await tester.pumpWidget(host(controller, showChild: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startMinimized')), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final child = find.descendant(
      of: find.byKey(const Key('startMinimized')),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(child).value, isFalse);
    await tester.tap(child);
    await tester.pumpAndSettle();
    expect(await controller.readStartMinimized(), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(controller, showChild: true));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(child).value, isTrue);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startMinimized')), findsNothing);
  });

  testWidgets('偏好保存失败不会显示为开启，待批准时也不显示子开关', (tester) async {
    final preferences = MemoryPreferences(failWrite: true);
    final controller = FakeStartupController(preferences: preferences)
      ..status = LaunchAtStartupStatus.enabled;
    await tester.pumpWidget(host(controller, showChild: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch).last).value, isFalse);
    controller.status = LaunchAtStartupStatus.requiresApproval;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startMinimized')), findsNothing);
  });

  test('只有自启动、已注册、子开关开启三个条件同时成立才最小化', () async {
    final controller = FakeStartupController()
      ..status = LaunchAtStartupStatus.enabled;
    expect(await controller.shouldStartMinimized(['--autostart']), isFalse);
    await controller.setStartMinimized(true);
    expect(await controller.shouldStartMinimized(['--autostart']), isTrue);
    await controller.prepareForManualRestart();
    expect(await controller.shouldStartMinimized(['--autostart']), isFalse);
    expect(await controller.shouldStartMinimized(['--autostart']), isTrue);
    // 在 macOS 上，无标记启动会查询原生通道；测试未注册通道也应该正常显示。
    expect(await controller.shouldStartMinimized([]), isFalse);
    controller.status = LaunchAtStartupStatus.disabled;
    expect(await controller.shouldStartMinimized(['--autostart']), isFalse);
    await expectLater(controller.setStartMinimized(true), throwsStateError);
    controller.failRead = true;
    expect(await controller.shouldStartMinimized(['--autostart']), isFalse);
  });

  test('沿用旧子开关偏好，新开关保存后优先使用新值', () async {
    final preferences = MemoryPreferences();
    preferences.values['hide_to_tray_on_autostart'] = true;
    final controller = FakeStartupController(preferences: preferences);
    expect(await controller.readStartMinimized(), isTrue);
    await controller.setStartMinimized(false);
    expect(await controller.readStartMinimized(), isFalse);
  });

  testWidgets('先完成页面初始化和首帧再最小化，手动启动不最小化', (tester) async {
    const channel = MethodChannel('window_manager');
    final events = <String>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      events.add(call.method);
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final startup = AppWindowController.completeStartup(startMinimized: true);
    expect(events, isEmpty);
    await tester.pumpWidget(
      Builder(
        builder: (_) {
          events.add('page-built');
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => events.add('first-frame'),
          );
          return const SizedBox();
        },
      ),
    );
    await startup;
    expect(events, ['page-built', 'first-frame', 'minimize']);
    events.clear();
    await AppWindowController.completeStartup(startMinimized: false);
    expect(events, isEmpty);
  });

  testWidgets('最小化失败不会抛出异常，也不会把窗口隐藏掉', (tester) async {
    const channel = MethodChannel('window_manager');
    final calls = <String>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      throw PlatformException(code: 'minimize_failed');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final startup = AppWindowController.completeStartup(startMinimized: true);
    await tester.pump();
    await startup;
    expect(calls, ['minimize']);
  });

  test('Linux 桌面禁用了文件时，不能只凭文件存在判断已开启', () {
    expect(
      AppLaunchAtStartupController.linuxEntryIsDisabled(
        '[Desktop Entry]\nHidden=true\n',
      ),
      isTrue,
    );
    expect(
      AppLaunchAtStartupController.linuxEntryIsDisabled(
        '[Desktop Entry]\nX-GNOME-Autostart-enabled=false\n',
      ),
      isTrue,
    );
    expect(
      AppLaunchAtStartupController.linuxEntryIsDisabled(
        '[Desktop Entry]\n# Hidden=true\nHidden=false\n[Other]\nHidden=true\n',
      ),
      isFalse,
    );
  });

  test('启动路径带空格也只作为一个参数，Linux 的百分号不会变成字段代码', () {
    expect(
      AppLaunchAtStartupController.executableCommand(
        r'C:\Users\Test User\VPhone.exe',
        TargetPlatform.windows,
      ),
      r'"C:\Users\Test User\VPhone.exe"',
    );
    expect(
      AppLaunchAtStartupController.executableCommand(
        '/opt/My Phone/100%/VPhone',
        TargetPlatform.linux,
      ),
      '"/opt/My Phone/100%%/VPhone"',
    );
    expect(
      AppLaunchAtStartupController.executableCommand(
        r'/opt/a$b`c"d\e',
        TargetPlatform.linux,
      ),
      r'"/opt/a\\$b\\`c\\"d\\\\e"',
    );
  });

  testWidgets('读取状态不会偷偷注册，操作期间不能重复点击', (tester) async {
    final controller = FakeStartupController();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(controller.writes, 0);
    controller.write = Completer<LaunchAtStartupStatus>();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(controller.writes, 1);
    controller.write!.complete(LaunchAtStartupStatus.enabled);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('修改失败后显示实际状态和错误，可以重试', (tester) async {
    final controller = FakeStartupController()..failWrite = true;
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text('Retry'), findsOneWidget);
    controller.failWrite = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('查询失败不显示假开关，重试可以恢复', (tester) async {
    final controller = FakeStartupController()..failRead = true;
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsNothing);
    controller.failRead = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('待批准时显示系统设置入口，也能取消注册', (tester) async {
    final controller = FakeStartupController()
      ..status = LaunchAtStartupStatus.requiresApproval;
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsNothing);
    await tester.tap(find.text('Open System Settings'));
    expect(controller.settingsOpened, 1);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('从系统设置回来后重新读取，不覆盖系统中的关闭操作', (tester) async {
    final controller = FakeStartupController()
      ..status = LaunchAtStartupStatus.enabled;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    controller.status = LaunchAtStartupStatus.disabled;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(controller.writes, 0);
  });

  testWidgets('关闭弹窗后异步返回，不访问已经销毁的界面', (tester) async {
    final controller = FakeStartupController()
      ..write = Completer<LaunchAtStartupStatus>();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpWidget(const SizedBox());
    controller.write!.complete(LaunchAtStartupStatus.enabled);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // 用假的系统通道验证插件连接；测试不会修改电脑上的真实登录项。
  group('macOS plugin bridge', () {
    const pluginChannel = MethodChannel('launch_at_startup');
    const statusChannel = MethodChannel('voip_desk/launch_at_startup_status');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var enabled = false;
    var pending = false;
    var applyWrite = true;
    final writes = <bool>[];
    var cancellations = 0;
    setUp(() {
      enabled = false;
      pending = false;
      applyWrite = true;
      writes.clear();
      cancellations = 0;
      AppLaunchAtStartupController.initialize();
      messenger.setMockMethodCallHandler(pluginChannel, (call) async {
        if (call.method == 'launchAtStartupIsEnabled') return enabled;
        final requested = (call.arguments as Map)['setEnabledValue'] as bool;
        writes.add(requested);
        if (applyWrite) enabled = requested;
        return null;
      });
      messenger.setMockMethodCallHandler(statusChannel, (call) async {
        if (call.method == 'requiresApproval') return pending;
        if (call.method == 'cancelPendingRegistration') {
          cancellations++;
          pending = false;
        }
        return null;
      });
    });
    tearDown(() {
      messenger.setMockMethodCallHandler(pluginChannel, null);
      messenger.setMockMethodCallHandler(statusChannel, null);
    });
    test('初始化不注册，启用与关闭都重新确认系统状态', () async {
      const controller = AppLaunchAtStartupController();
      expect(writes, isEmpty);
      expect(await controller.setEnabled(true), LaunchAtStartupStatus.enabled);
      expect(
        await controller.setEnabled(false),
        LaunchAtStartupStatus.disabled,
      );
      expect(writes, [true, false]);
    });
    test('系统没生效时不能报告成功', () async {
      applyWrite = false;
      expect(
        const AppLaunchAtStartupController().setEnabled(true),
        throwsStateError,
      );
    });
    test('补上官方插件在待批准时跳过的取消操作', () async {
      pending = true;
      expect(
        await const AppLaunchAtStartupController().readStatus(),
        LaunchAtStartupStatus.requiresApproval,
      );
      expect(
        await const AppLaunchAtStartupController().setEnabled(false),
        LaunchAtStartupStatus.disabled,
      );
      expect(cancellations, 1);
    });
  }, skip: !Platform.isMacOS);
}
