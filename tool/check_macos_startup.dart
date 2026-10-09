// 原生启动回归检查：使用真实 macOS Runner，不连接 SIP，也不改登录项或偏好。
// flutter run -d macos -t tool/check_macos_startup.dart
// flutter run -d macos -t tool/check_macos_startup.dart --dart-define=STARTUP_PROBE_MINIMIZED=true
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:veserve_vphone/src/services/native_bridge/app_launch_at_startup_controller.dart';
import 'package:veserve_vphone/src/services/native_bridge/app_window_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  stdout.writeln(
    'STARTUP_PROBE: running a test window, not the VPhone main entrypoint.',
  );
  const minimized = bool.fromEnvironment('STARTUP_PROBE_MINIMIZED');
  final watchdog = Timer(const Duration(seconds: 15), () {
    stderr.writeln('STARTUP_PROBE_FAILED: timed out');
    exit(1);
  });
  final fromLogin = await const AppLaunchAtStartupController()
      .wasLaunchedAtLogin([]);
  await AppWindowController.initializeMainWindow();
  await windowManager.setTitle('VPhone — 启动回归检查');
  final initiallyVisible = await windowManager.isVisible();
  final initialized = Completer<void>();
  runApp(_StartupProbe(onInitialized: initialized.complete));
  await AppWindowController.completeStartup(startMinimized: minimized);
  await initialized.future;
  // 系统最小化带动画，等真实状态变化，再检查能否像点任务栏一样恢复。
  var actuallyMinimized = await windowManager.isMinimized();
  for (var i = 0; i < 30 && actuallyMinimized != minimized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    actuallyMinimized = await windowManager.isMinimized();
  }
  if (!initiallyVisible || actuallyMinimized != minimized || fromLogin) {
    stderr.writeln(
      'STARTUP_PROBE_FAILED: initiallyVisible=$initiallyVisible minimized=$actuallyMinimized login=$fromLogin',
    );
    exit(1);
  }
  // 最小化以后 Dart 仍在执行，恢复也应正常。
  await Future<void>.delayed(const Duration(milliseconds: 200));
  if (minimized) {
    await AppWindowController.showMainWindow();
    if (await windowManager.isMinimized() || !await windowManager.isVisible()) {
      stderr.writeln('STARTUP_PROBE_FAILED: could not restore');
      exit(1);
    }
  }
  watchdog.cancel();
  stdout.writeln(
    'STARTUP_PROBE_PASSED: initiallyVisible=$initiallyVisible minimized=$actuallyMinimized widgetInitialized=true restored=true',
  );
  exit(0);
}

class _StartupProbe extends StatefulWidget {
  const _StartupProbe({required this.onInitialized});
  final VoidCallback onInitialized;

  @override
  State<_StartupProbe> createState() => _StartupProbeState();
}

class _StartupProbeState extends State<_StartupProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInitialized();
  }

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(body: Center(child: Text('Startup regression check'))),
  );
}
