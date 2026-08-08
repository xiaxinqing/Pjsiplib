import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:window_manager/window_manager.dart';

import '../../app_identity.dart';
import 'app_dock_menu_controller.dart';
import 'app_window_controller.dart';

class AppTrayController with tray.TrayListener {
  AppTrayController._();

  static final AppTrayController instance = AppTrayController._();

  static const _showWindowKey = 'show_window';
  static const _showCallsKey = 'show_calls';
  static const _showHistoryKey = 'show_history';
  static const _statusKey = 'status';
  static const _incomingRingtoneKey = 'incoming_ringtone';
  static const _disconnectAllKey = 'disconnect_all';
  static const _settingsKey = 'settings';
  static const _aboutKey = 'about';
  static const _restartAppKey = 'restart_app';
  static const _exitAppKey = 'exit_app';

  bool _initialized = false;
  bool _exiting = false;
  String? _menuSignature;
  VoidCallback? _onOpenCalls;
  VoidCallback? _onOpenHistory;
  VoidCallback? _onOpenSettings;
  VoidCallback? _onOpenAbout;
  Future<void> Function()? _onDisconnectAll;
  Future<void> Function()? _onRestartApplication;
  Future<void> Function()? _onExitApplication;
  ValueChanged<bool>? _onIncomingRingtoneChanged;

  void bindActions({
    required VoidCallback onOpenCalls,
    required VoidCallback onOpenHistory,
    required VoidCallback onOpenSettings,
    required VoidCallback onOpenAbout,
    required Future<void> Function() onDisconnectAll,
    required Future<void> Function() onRestartApplication,
    required Future<void> Function() onExitApplication,
    required ValueChanged<bool> onIncomingRingtoneChanged,
  }) {
    _onOpenCalls = onOpenCalls;
    _onOpenHistory = onOpenHistory;
    _onOpenSettings = onOpenSettings;
    _onOpenAbout = onOpenAbout;
    _onDisconnectAll = onDisconnectAll;
    _onRestartApplication = onRestartApplication;
    _onExitApplication = onExitApplication;
    _onIncomingRingtoneChanged = onIncomingRingtoneChanged;
  }

  void clearActions() {
    _onOpenCalls = null;
    _onOpenHistory = null;
    _onOpenSettings = null;
    _onOpenAbout = null;
    _onDisconnectAll = null;
    _onRestartApplication = null;
    _onExitApplication = null;
    _onIncomingRingtoneChanged = null;
  }

  Future<void> initialize() async {
    if (!AppWindowController.isDesktop || _initialized) return;

    tray.trayManager.addListener(this);
    _initialized = true;

    await _safeTrayCall(() async {
      await tray.trayManager.setIcon(
        _trayIconPath,
        isTemplate: Platform.isMacOS,
        iconSize: 18,
      );
      await tray.trayManager.setToolTip(appDisplayName);
      await updateMenu(
        connectedLines: 0,
        totalLines: 0,
        incomingRingtoneEnabled: true,
        canDisconnectAll: false,
        hasActiveCalls: false,
      );
      debugPrint('Tray initialized.');
    });
  }

  String get _trayIconPath {
    if (Platform.isWindows) return 'assets/tray/tray_icon.ico';
    if (Platform.isMacOS) return 'assets/tray/tray_icon_macos_template.png';
    return 'assets/tray/tray_icon.png';
  }

  Future<void> updateMenu({
    required int connectedLines,
    required int totalLines,
    required bool incomingRingtoneEnabled,
    required bool canDisconnectAll,
    required bool hasActiveCalls,
  }) async {
    if (!AppWindowController.isDesktop || !_initialized) return;

    final signature = [
      connectedLines,
      totalLines,
      incomingRingtoneEnabled,
      canDisconnectAll,
      hasActiveCalls,
    ].join('|');
    if (_menuSignature == signature) return;
    _menuSignature = signature;

    await _safeTrayCall(() {
      return tray.trayManager.setContextMenu(
        tray.Menu(
          items: [
            tray.MenuItem(key: _showWindowKey, label: '打开 $appDisplayName'),
            tray.MenuItem(
              key: _showCallsKey,
              label: '当前通话',
              disabled: !hasActiveCalls,
            ),
            tray.MenuItem(key: _showHistoryKey, label: '通话记录'),
            tray.MenuItem.separator(),
            tray.MenuItem(
              key: _statusKey,
              label: '当前状态：已连接 $connectedLines/$totalLines 线路',
              disabled: true,
            ),
            tray.MenuItem.checkbox(
              key: _incomingRingtoneKey,
              label: '来电铃声',
              checked: incomingRingtoneEnabled,
            ),
            tray.MenuItem(
              key: _disconnectAllKey,
              label: '断开全部线路',
              disabled: !canDisconnectAll,
            ),
            tray.MenuItem.separator(),
            tray.MenuItem(key: _settingsKey, label: '设置'),
            tray.MenuItem(key: _aboutKey, label: '关于 $appDisplayName'),
            tray.MenuItem(key: _restartAppKey, label: '重启应用...'),
            tray.MenuItem.separator(),
            tray.MenuItem(key: _exitAppKey, label: '退出 $appDisplayName'),
          ],
        ),
      );
    });
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(_showTrayMenu());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(_showTrayMenu());
  }

  @override
  void onTrayMenuItemClick(tray.MenuItem menuItem) {
    switch (menuItem.key) {
      case _showWindowKey:
        unawaited(_showMainWindow());
        break;
      case _showCallsKey:
        unawaited(_handleOpenCalls());
        break;
      case _showHistoryKey:
        unawaited(_handleOpenHistory());
        break;
      case _incomingRingtoneKey:
        final nextValue = !(menuItem.checked ?? false);
        _onIncomingRingtoneChanged?.call(nextValue);
        break;
      case _disconnectAllKey:
        unawaited(_handleDisconnectAll());
        break;
      case _settingsKey:
        unawaited(_handleOpenSettings());
        break;
      case _aboutKey:
        unawaited(_handleOpenAbout());
        break;
      case _restartAppKey:
        unawaited(_handleRestartApplication());
        break;
      case _exitAppKey:
        unawaited(_exitApplication());
        break;
    }
  }

  Future<void> _showMainWindow() async {
    if (!AppWindowController.isDesktop) return;

    await _safeWindowCall(() async {
      debugPrint('Tray requested main window restore.');
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
      debugPrint('Main window restored from tray.');
    });
  }

  Future<void> _showTrayMenu() async {
    await _safeTrayCall(() => tray.trayManager.popUpContextMenu());
  }

  Future<void> _handleOpenSettings() async {
    await _showMainWindow();
    _onOpenSettings?.call();
  }

  Future<void> _handleOpenAbout() async {
    await _showMainWindow();
    _onOpenAbout?.call();
  }

  Future<void> _handleOpenCalls() async {
    await _showMainWindow();
    _onOpenCalls?.call();
  }

  Future<void> _handleOpenHistory() async {
    await _showMainWindow();
    _onOpenHistory?.call();
  }

  Future<void> _handleDisconnectAll() async {
    await _showMainWindow();
    await _onDisconnectAll?.call();
  }

  Future<void> _handleRestartApplication() async {
    await _showMainWindow();
    await _onRestartApplication?.call();
  }

  /// Exits through Flutter first so app-level resources can be closed before
  /// the Flutter engine starts shutting down Dart isolates.
  Future<void> exitApplication() async {
    await _exitApplication();
  }

  Future<void> _exitApplication() async {
    if (!AppWindowController.isDesktop) return;
    if (_exiting) return;
    _exiting = true;

    if (Platform.isMacOS) {
      final requested = await AppDockMenuController.instance
          .requestApplicationTermination();
      if (requested) {
        // 请求已交给 AppDelegate，但退出可能被系统取消或超时。macOS 原生状态机
        // 会合并重复请求；这里解锁后，用户仍可再次从托盘发起退出。
        _exiting = false;
        return;
      }
    }

    // Other desktop platforms do not currently expose an AppDelegate-style
    // terminate-later handshake, so prepare resources before destroying the
    // desktop window.
    await _onExitApplication?.call();
    await _safeWindowCall(() => windowManager.setPreventClose(false));
    await _safeTrayCall(() => tray.trayManager.destroy());
    await _safeWindowCall(() => windowManager.destroy());
  }

  Future<void> _safeTrayCall(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      // Widget tests and unsupported desktop shells may not register the tray.
    } on PlatformException catch (error) {
      debugPrint('Tray manager call failed: ${error.message}');
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
