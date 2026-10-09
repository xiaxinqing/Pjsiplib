import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_identity.dart';

enum LaunchAtStartupStatus { disabled, enabled, requiresApproval, unsupported }

/// 开关只是入口，真正的开机启动项交给系统保存。
/// 所以这里每次都问系统，不再另外存一份“已开启”，免得两边对不上。
class AppLaunchAtStartupController {
  const AppLaunchAtStartupController({SharedPreferencesAsync? preferences})
    : _preferenceOverride = preferences;

  static const autostartArgument = '--autostart';
  static const _minimizedKey = 'minimize_on_autostart';
  static const _legacyHiddenKey = 'hide_to_tray_on_autostart';
  static const _manualRestartKey = 'manual_restart_requested_at';
  static final _preferences = SharedPreferencesAsync();
  final SharedPreferencesAsync? _preferenceOverride;
  SharedPreferencesAsync get _storage => _preferenceOverride ?? _preferences;

  static const _statusChannel = MethodChannel(
    'voip_desk/launch_at_startup_status',
  );

  static bool get isSupported =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static void initialize() {
    if (!isSupported) return;
    _configurePlugin();
    // 这里只告诉插件“启动哪个程序”。用户没打开开关，就不要替他注册。
  }

  static void _configurePlugin({bool legacy = false}) {
    launchAtStartup.setup(
      appName: appDisplayName,
      appPath: executableCommand(
        Platform.resolvedExecutable,
        defaultTargetPlatform,
      ),
      args: legacy ? const [] : const [autostartArgument],
    );
  }

  Future<bool> readStartMinimized() async =>
      // 沿用之前子开关的选择，只把行为改成系统最小化。新安装仍默认关闭。
      await _storage.getBool(_minimizedKey) ??
      await _storage.getBool(_legacyHiddenKey) ??
      false;

  Future<void> setStartMinimized(bool enabled) async {
    if (enabled) {
      if (await readStatus() != LaunchAtStartupStatus.enabled) {
        throw StateError('Enable launch at startup first.');
      }
      // 旧启动项没有 --autostart。用户打开子开关时顺便更新，之后才认得出来源。
      if (await setEnabled(true) != LaunchAtStartupStatus.enabled) {
        throw StateError('Launch at startup is awaiting system approval.');
      }
    }
    await _storage.setBool(_minimizedKey, enabled);
  }

  Future<bool> wasLaunchedAtLogin(List<String> arguments) async {
    if (!isSupported) return false;
    if (arguments.contains(autostartArgument)) return true;
    if (Platform.isMacOS) {
      // macOS 13+ 的系统登录项不接受 args，启动来源由 AppDelegate 保存。
      return await _statusChannel.invokeMethod<bool>('wasLaunchedAtLogin') ??
          false;
    }
    return false;
  }

  Future<bool> shouldStartMinimized(List<String> arguments) async {
    try {
      return await _shouldStartMinimized(
        arguments,
      ).timeout(const Duration(seconds: 3));
    } catch (error) {
      // 来源或偏好拿不准时就正常显示，不要卡住整个应用的启动。
      debugPrint('Could not determine startup visibility: $error');
      return false;
    }
  }

  Future<bool> _shouldStartMinimized(List<String> arguments) async {
    final fromLogin = await wasLaunchedAtLogin(arguments);
    debugPrint('VPhone startup origin: launchedAtLogin=$fromLogin');
    if (!fromLogin) return false;
    final restartTime = await _storage.getInt(_manualRestartKey);
    if (restartTime != null) {
      await _storage.remove(_manualRestartKey);
      final age = DateTime.now().millisecondsSinceEpoch - restartTime;
      // Windows/Linux 的重启插件会原样带回 --autostart，但点“重启”是手动操作。
      // 这个标记只用一次且一分钟后失效，不能影响下一次真正的开机启动。
      if (age >= 0 && age < const Duration(minutes: 1).inMilliseconds) {
        return false;
      }
    }
    return await readStartMinimized() &&
        await readStatus() == LaunchAtStartupStatus.enabled;
  }

  Future<void> prepareForManualRestart() =>
      _storage.setInt(_manualRestartKey, DateTime.now().millisecondsSinceEpoch);

  Future<void> cancelManualRestart() => _storage.remove(_manualRestartKey);

  /// 安装目录可能带空格，得把路径当成一个完整参数交给系统。
  @visibleForTesting
  static String executableCommand(String path, TargetPlatform platform) {
    if (platform == TargetPlatform.windows) return '"$path"';
    if (platform == TargetPlatform.linux) {
      // .desktop 会先解转义，再解析 Exec；反斜杠需要经过这两层。
      final escaped = path
          .replaceAll(r'\', r'\\\\')
          .replaceAll('"', r'\\"')
          .replaceAll(r'$', r'\\$')
          .replaceAll('`', r'\\`')
          .replaceAll('%', '%%');
      return '"$escaped"';
    }
    return path;
  }

  Future<LaunchAtStartupStatus> readStatus() async {
    if (!isSupported) return LaunchAtStartupStatus.unsupported;
    var enabled = await launchAtStartup.isEnabled();
    if (!enabled && Platform.isWindows) {
      // Windows 插件会比较完整命令。旧版本没带参数，也应该显示为已开启。
      // 这里只查询，不擅自重新开启被用户在任务管理器中禁用的启动项。
      try {
        _configurePlugin(legacy: true);
        enabled = await launchAtStartup.isEnabled();
      } finally {
        _configurePlugin();
      }
    }
    if (Platform.isLinux && enabled) {
      // 有些桌面环境关闭自启动时会保留文件，只在里面写“禁用”。
      // 插件只看文件在不在，我们再看看内容，免得开关显示错了。
      final entry = File(
        '${Platform.environment['HOME']}/.config/autostart/$appDisplayName.desktop',
      );
      if (linuxEntryIsDisabled(await entry.readAsString())) {
        return LaunchAtStartupStatus.disabled;
      }
    }
    if (Platform.isMacOS) {
      final pending = await _statusChannel.invokeMethod<bool>(
        'requiresApproval',
      );
      if (pending == true) return LaunchAtStartupStatus.requiresApproval;
    }
    return enabled
        ? LaunchAtStartupStatus.enabled
        : LaunchAtStartupStatus.disabled;
  }

  @visibleForTesting
  static bool linuxEntryIsDisabled(String contents) {
    var inDesktopEntry = false;
    for (final line in contents.split('\n')) {
      final value = line.trim();
      if (value.startsWith('[')) {
        inDesktopEntry = value == '[Desktop Entry]';
      } else if (inDesktopEntry && !value.startsWith('#')) {
        final separator = value.indexOf('=');
        if (separator < 0) continue;
        final key = value.substring(0, separator).trim();
        final setting = value.substring(separator + 1).trim();
        if ((key == 'Hidden' && setting == 'true') ||
            (key == 'X-GNOME-Autostart-enabled' && setting == 'false')) {
          return true;
        }
      }
    }
    return false;
  }

  Future<LaunchAtStartupStatus> setEnabled(bool enabled) async {
    if (!isSupported) {
      throw UnsupportedError('Launch at startup is unavailable.');
    }
    if (!enabled &&
        Platform.isMacOS &&
        await readStatus() == LaunchAtStartupStatus.requiresApproval) {
      // 插件把“待批准”当成关闭，disable() 会直接跳过。这里补上真正的取消。
      await _statusChannel.invokeMethod<void>('cancelPendingRegistration');
    }
    final succeeded = enabled
        ? await launchAtStartup.enable()
        : await launchAtStartup.disable();
    if (!succeeded) throw StateError('Could not update launch at startup.');

    // 系统可能还在等用户批准。不能因为调用没报错，就直接把开关显示成开启。
    final status = await readStatus();
    if (enabled && status == LaunchAtStartupStatus.requiresApproval) {
      return status;
    }
    if ((status == LaunchAtStartupStatus.enabled) != enabled ||
        status == LaunchAtStartupStatus.requiresApproval) {
      throw StateError(
        'The system did not apply the requested startup setting.',
      );
    }
    return status;
  }

  Future<void> openSystemSettings() async {
    if (!kIsWeb && Platform.isMacOS) {
      await _statusChannel.invokeMethod<void>('openSystemSettings');
    }
  }
}
