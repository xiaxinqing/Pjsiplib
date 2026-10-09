import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:window_manager/window_manager.dart';

import '../../app_identity.dart';
import '../../../l10n/app_localizations.dart';
import 'app_dock_menu_controller.dart';
import 'app_window_controller.dart';

class AppTrayMenuLabels {
  const AppTrayMenuLabels({
    required this.openApp,
    required this.currentCalls,
    required this.callHistory,
    required this.connectionStatus,
    required this.incomingRingtone,
    required this.disconnectAll,
    required this.settings,
    required this.aboutApp,
    required this.restartApp,
    required this.exitApp,
  });

  factory AppTrayMenuLabels.localized(AppLocalizations l10n) {
    return AppTrayMenuLabels(
      openApp: l10n.trayOpenApp(appDisplayName),
      currentCalls: l10n.trayCurrentCalls,
      callHistory: l10n.trayCallHistory,
      connectionStatus: l10n.trayConnectionStatus,
      incomingRingtone: l10n.trayIncomingRingtone,
      disconnectAll: l10n.trayDisconnectAll,
      settings: l10n.traySettings,
      aboutApp: l10n.trayAboutApp(appDisplayName),
      restartApp: l10n.trayRestartApp,
      exitApp: l10n.trayExitApp(appDisplayName),
    );
  }

  static const simplifiedChinese = AppTrayMenuLabels(
    openApp: '打开 VPhone',
    currentCalls: '当前通话',
    callHistory: '通话记录',
    connectionStatus: _fallbackConnectionStatus,
    incomingRingtone: '来电铃声',
    disconnectAll: '断开全部线路',
    settings: '设置',
    aboutApp: '关于 VPhone',
    restartApp: '重启应用…',
    exitApp: '退出 VPhone',
  );

  static String _fallbackConnectionStatus(int connected, int total) =>
      '已连接 $connected/$total 条线路';

  final String openApp;
  final String currentCalls;
  final String callHistory;
  final String Function(int connected, int total) connectionStatus;
  final String incomingRingtone;
  final String disconnectAll;
  final String settings;
  final String aboutApp;
  final String restartApp;
  final String exitApp;

  String get signature => [
    openApp,
    currentCalls,
    callHistory,
    incomingRingtone,
    disconnectAll,
    settings,
    aboutApp,
    restartApp,
    exitApp,
  ].join('|');
}

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
  Future<bool>? _initialization;
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

  Future<bool> initialize() => _initialization ??= _initialize();

  Future<bool> _initialize() async {
    if (!AppWindowController.isDesktop) return false;

    tray.trayManager.addListener(this);
    _initialized = true;

    final ready = await _safeTrayCall(() async {
      await tray.trayManager.setIcon(
        _trayIconPath,
        isTemplate: Platform.isMacOS,
        iconSize: 18,
      );
      // 提示文字失败不影响托盘入口，图标和菜单则必须真的创建成功。
      await _safeTrayCall(() => tray.trayManager.setToolTip(appDisplayName));
      final menuReady = await updateMenu(
        connectedLines: 0,
        totalLines: 0,
        incomingRingtoneEnabled: true,
        canDisconnectAll: false,
        hasActiveCalls: false,
        labels: AppTrayMenuLabels.simplifiedChinese,
      );
      if (!menuReady) throw StateError('Tray menu is unavailable.');
      debugPrint('Tray initialized.');
    });
    if (!ready) {
      _initialized = false;
      tray.trayManager.removeListener(this);
    }
    return ready;
  }

  String get _trayIconPath {
    if (Platform.isWindows) return 'assets/tray/tray_icon.ico';
    if (Platform.isMacOS) return 'assets/tray/tray_icon_macos_template.png';
    return 'assets/tray/tray_icon.png';
  }

  Future<bool> updateMenu({
    required int connectedLines,
    required int totalLines,
    required bool incomingRingtoneEnabled,
    required bool canDisconnectAll,
    required bool hasActiveCalls,
    required AppTrayMenuLabels labels,
  }) async {
    if (!AppWindowController.isDesktop || !_initialized) return false;

    final signature = [
      connectedLines,
      totalLines,
      incomingRingtoneEnabled,
      canDisconnectAll,
      hasActiveCalls,
      labels.signature,
    ].join('|');
    if (_menuSignature == signature) return true;

    final ready = await _safeTrayCall(() {
      return tray.trayManager.setContextMenu(
        tray.Menu(
          items: [
            tray.MenuItem(key: _showWindowKey, label: labels.openApp),
            tray.MenuItem(
              key: _showCallsKey,
              label: labels.currentCalls,
              disabled: !hasActiveCalls,
            ),
            tray.MenuItem(key: _showHistoryKey, label: labels.callHistory),
            tray.MenuItem.separator(),
            tray.MenuItem(
              key: _statusKey,
              label: labels.connectionStatus(connectedLines, totalLines),
              disabled: true,
            ),
            tray.MenuItem.checkbox(
              key: _incomingRingtoneKey,
              label: labels.incomingRingtone,
              checked: incomingRingtoneEnabled,
            ),
            tray.MenuItem(
              key: _disconnectAllKey,
              label: labels.disconnectAll,
              disabled: !canDisconnectAll,
            ),
            tray.MenuItem.separator(),
            tray.MenuItem(key: _settingsKey, label: labels.settings),
            tray.MenuItem(key: _aboutKey, label: labels.aboutApp),
            tray.MenuItem(key: _restartAppKey, label: labels.restartApp),
            tray.MenuItem.separator(),
            tray.MenuItem(key: _exitAppKey, label: labels.exitApp),
          ],
        ),
      );
    });
    if (ready) _menuSignature = signature;
    return ready;
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

  Future<bool> _safeTrayCall(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on MissingPluginException {
      // Widget tests and unsupported desktop shells may not register the tray.
    } on PlatformException catch (error) {
      debugPrint('Tray manager call failed: ${error.message}');
    } catch (error) {
      debugPrint('Tray initialization or update failed: $error');
    }
    return false;
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
