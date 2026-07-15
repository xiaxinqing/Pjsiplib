import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class AppWindowController {
  AppWindowController();

  static const Size minimumSize = Size(980, 640);
  static const _attentionChannel = MethodChannel('voip_desk/window_attention');

  Timer? _attentionResetTimer;

  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static Future<void> initializeMainWindow() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: Size(1280, 780),
      minimumSize: minimumSize,
      center: true,
      title: 'Thruv',
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> notifyIncomingCall({required int incomingCallCount}) async {
    if (!isDesktop) return;

    await _restoreAndFocus();
    await _requestUserAttention();
    await _setBadge(incomingCallCount);
    await _pulseAlwaysOnTop();
  }

  Future<void> clearIncomingCallAttention() async {
    if (!isDesktop) return;

    _attentionResetTimer?.cancel();
    _attentionResetTimer = null;
    await _safeWindowCall(() => windowManager.setAlwaysOnTop(false));
    await _safeWindowCall(() => windowManager.setBadgeLabel());
    await _safePlatformCall('clearAttention');
  }

  Future<void> _restoreAndFocus() async {
    await _safeWindowCall(() async {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> _requestUserAttention() async {
    await _safePlatformCall('requestAttention');
  }

  Future<void> _setBadge(int incomingCallCount) async {
    if (!Platform.isMacOS) return;
    await _safeWindowCall(
      () => windowManager.setBadgeLabel(incomingCallCount.toString()),
    );
  }

  Future<void> _pulseAlwaysOnTop() async {
    await _safeWindowCall(() => windowManager.setAlwaysOnTop(true));
    _attentionResetTimer?.cancel();
    _attentionResetTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_safeWindowCall(() => windowManager.setAlwaysOnTop(false)));
    });
  }

  Future<void> _safePlatformCall(String method) async {
    try {
      await _attentionChannel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Linux currently relies on focus/restore only.
    } on PlatformException catch (error) {
      debugPrint('Window attention "$method" failed: ${error.message}');
    }
  }

  Future<void> _safeWindowCall(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      // Widget tests and unsupported desktop shells may not register the plugin.
    } on PlatformException catch (error) {
      debugPrint('Window manager call failed: ${error.message}');
    }
  }
}
