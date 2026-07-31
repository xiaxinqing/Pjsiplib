import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'app_window_controller.dart';

/// Handles macOS Dock menu commands that need Flutter-side UI, such as opening
/// settings or showing the restart confirmation dialog.
class AppDockMenuController {
  AppDockMenuController._();

  static final AppDockMenuController instance = AppDockMenuController._();

  static const MethodChannel _channel = MethodChannel('voip_desk/dock_menu');

  bool _initialized = false;
  VoidCallback? _onOpenSettings;
  VoidCallback? _onOpenAbout;
  Future<void> Function()? _onRestartApplication;
  Future<void> Function()? _onExitApplication;

  void bindActions({
    required VoidCallback onOpenSettings,
    required VoidCallback onOpenAbout,
    required Future<void> Function() onRestartApplication,
    required Future<void> Function() onExitApplication,
  }) {
    _onOpenSettings = onOpenSettings;
    _onOpenAbout = onOpenAbout;
    _onRestartApplication = onRestartApplication;
    _onExitApplication = onExitApplication;
    _ensureInitialized();
  }

  void clearActions() {
    _onOpenSettings = null;
    _onOpenAbout = null;
    _onRestartApplication = null;
    _onExitApplication = null;
  }

  void _ensureInitialized() {
    if (_initialized || !AppWindowController.isDesktop || !Platform.isMacOS) {
      return;
    }
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Requests the native macOS application lifecycle to terminate the app.
  ///
  /// AppDelegate will call back into `prepareToTerminate` and wait for Flutter
  /// to finish PJSIP/database cleanup before allowing the engine to shut down.
  Future<bool> requestApplicationTermination() async {
    if (!AppWindowController.isDesktop || !Platform.isMacOS) return false;
    _ensureInitialized();
    try {
      await _channel.invokeMethod<void>('requestApplicationTermination');
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'openSettings':
        _onOpenSettings?.call();
        break;
      case 'openAbout':
        _onOpenAbout?.call();
        break;
      case 'restartApplication':
        await _onRestartApplication?.call();
        break;
      case 'prepareToTerminate':
      case 'exitApplication':
        await _onExitApplication?.call();
        break;
      default:
        throw MissingPluginException(
          'Unknown dock menu method: ${call.method}',
        );
    }
  }
}
