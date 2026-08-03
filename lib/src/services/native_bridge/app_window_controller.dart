import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class AppWindowController with WindowListener {
  AppWindowController();

  static const Size minimumSize = Size(920, 620);
  static const _attentionChannel = MethodChannel('voip_desk/window_attention');

  Timer? _attentionResetTimer;
  bool _closeToTrayAttached = false;

  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  static Future<void> initializeMainWindow() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    // macOS keeps the native traffic-light buttons when the title bar is
    // hidden, while Windows/Linux hide the system window controls as well.
    final titleBarStyle = Platform.isMacOS
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal;
    final initialSize = Platform.isMacOS
        ? const Size(1180, 740)
        : const Size(1080, 700);

    final options = WindowOptions(
      size: initialSize,
      minimumSize: minimumSize,
      center: true,
      title: 'VPhone',
      titleBarStyle: titleBarStyle,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> attachCloseToTrayBehavior() async {
    if (!isDesktop || _closeToTrayAttached) return;

    _closeToTrayAttached = true;
    windowManager.addListener(this);
    await _safeWindowCall(() => windowManager.setPreventClose(true));
    debugPrint('Window close-to-tray behavior attached.');
  }

  void detachCloseToTrayBehavior() {
    if (!isDesktop || !_closeToTrayAttached) return;

    _closeToTrayAttached = false;
    windowManager.removeListener(this);
  }

  @override
  void onWindowClose() {
    debugPrint(
      'Window close requested; hiding to tray if prevent-close is on.',
    );
    unawaited(_hideWindowInsteadOfClosing());
  }

  Future<void> notifyIncomingCall() async {
    if (!isDesktop) return;

    await _restoreAndFocus();
    if (Platform.isMacOS) {
      // window_manager can restore and focus a window in the current Space,
      // but it cannot reliably bring a window across macOS Spaces. Let AppKit
      // perform that final presentation step for incoming calls.
      await _safePlatformCall('presentIncomingCallWindow');
    }
    await _requestUserAttention();
    await _pulseAlwaysOnTop();
  }

  Future<void> clearIncomingCallAttention() async {
    if (!isDesktop) return;

    _attentionResetTimer?.cancel();
    _attentionResetTimer = null;
    await _safeWindowCall(() => windowManager.setAlwaysOnTop(false));
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

  Future<void> _hideWindowInsteadOfClosing() async {
    if (!isDesktop) return;

    await _safeWindowCall(() async {
      final preventClose = await windowManager.isPreventClose();
      debugPrint('Window hide-to-tray preventClose=$preventClose');
      if (!preventClose) return;
      await windowManager.setAlwaysOnTop(false);
      await windowManager.hide();
      debugPrint('Window hidden to tray.');
    });
  }

  Future<void> _requestUserAttention() async {
    await _safePlatformCall('requestAttention');
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
