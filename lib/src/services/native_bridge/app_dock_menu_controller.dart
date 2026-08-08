import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../app_identity.dart';
import 'app_window_controller.dart';

class AppDockMenuLabels {
  const AppDockMenuLabels({
    required this.openApp,
    required this.settings,
    required this.aboutApp,
    required this.restartApp,
    required this.exitApp,
  });

  factory AppDockMenuLabels.localized(AppLocalizations l10n) {
    return AppDockMenuLabels(
      openApp: l10n.trayOpenApp(appDisplayName),
      settings: l10n.traySettings,
      aboutApp: l10n.trayAboutApp(appDisplayName),
      restartApp: l10n.trayRestartApp,
      exitApp: l10n.trayExitApp(appDisplayName),
    );
  }

  final String openApp;
  final String settings;
  final String aboutApp;
  final String restartApp;
  final String exitApp;

  String get signature => '$openApp|$settings|$aboutApp|$restartApp|$exitApp';

  Map<String, String> toMap() => {
    'openApp': openApp,
    'settings': settings,
    'aboutApp': aboutApp,
    'restartApp': restartApp,
    'exitApp': exitApp,
  };
}

/// Handles macOS Dock menu commands that need Flutter-side UI, such as opening
/// settings or showing the restart confirmation dialog.
class AppDockMenuController {
  AppDockMenuController._();

  static final AppDockMenuController instance = AppDockMenuController._();

  static const MethodChannel _channel = MethodChannel('voip_desk/dock_menu');

  bool _initialized = false;
  String? _labelsSignature;
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

  Future<void> updateMenuLabels(AppDockMenuLabels labels) async {
    if (!AppWindowController.isDesktop || !Platform.isMacOS) return;
    _ensureInitialized();
    if (_labelsSignature == labels.signature) return;
    try {
      await _channel.invokeMethod<void>('updateMenuLabels', labels.toMap());
      _labelsSignature = labels.signature;
    } on MissingPluginException {
      // 测试环境或旧版原生壳未注册菜单通道，不影响主界面。
    } on PlatformException {
      // Dock 菜单同步失败时保留原生默认文案。
    }
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
        try {
          await _onExitApplication?.call();
        } finally {
          // 不只依赖原生 invokeMethod 的结果回调。清理完成后再主动通知
          // AppDelegate，避免 macOS 永久停在 terminateLater。
          unawaited(_notifyApplicationTerminationReady());
        }
        break;
      case 'exitApplication':
        await _onExitApplication?.call();
        break;
      default:
        throw MissingPluginException(
          'Unknown dock menu method: ${call.method}',
        );
    }
  }

  Future<void> _notifyApplicationTerminationReady() async {
    try {
      await _channel.invokeMethod<void>('applicationTerminationReady');
    } on MissingPluginException {
      // 原生 invokeMethod 的结果回调仍可完成退出。
    } on PlatformException {
      // 原生 invokeMethod 的结果回调仍可完成退出。
    }
  }
}
