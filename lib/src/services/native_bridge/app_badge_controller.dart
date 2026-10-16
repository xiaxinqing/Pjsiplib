import 'package:app_badge_control_flutter/app_badge_control_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBadgeSettings {
  const AppBadgeSettings({required this.enabled, required this.supported});

  final bool enabled;
  final bool supported;
}

/// 角标只负责提示待处理数量，和铃声、来电弹窗、页面里的未读标记各管各的。
class AppBadgeController {
  AppBadgeController({this.preferences});

  static final AppBadgeController instance = AppBadgeController();
  static const _enabledKey = 'show_app_badge';

  final SharedPreferencesAsync? preferences;
  SharedPreferencesAsync? _defaultPreferences;
  bool? _isSupported;
  bool? _enabled;
  int _incomingCallCount = 0;
  int _unreadMissedCount = 0;
  int? _lastAppliedCount;
  bool _hasLoggedFailure = false;
  Future<void>? _pending;

  // 设置界面操作失败时也能显示真实状态，不把“保存失败”画成保存成功。
  bool? get enabled => _enabled;
  bool? get isSupported => _isSupported;

  SharedPreferencesAsync get _storage =>
      preferences ?? (_defaultPreferences ??= SharedPreferencesAsync());

  /// 启动时先读取偏好，再碰系统角标，避免已经关闭了却闪出一次数字。
  Future<void> initialize() => _syncSafely();

  Future<AppBadgeSettings> readSettings() => _enqueue(() async {
    await _prepare();
    await _applyBadge();
    return _settings;
  });

  Future<AppBadgeSettings> setEnabled(bool value) => _enqueue(() async {
    await _prepare();
    if (_isSupported != true) {
      throw UnsupportedError('App badges are unavailable on this platform.');
    }
    // 先保存，成功后再改当前状态；保存失败时原来的开关和角标都保留。
    await _storage.setBool(_enabledKey, value);
    _enabled = value;
    // 这里只控制显示，千万别 clearAll，否则重新打开时未读数量就丢了。
    await _applyBadge();
    return _settings;
  });

  AppBadgeSettings get _settings => AppBadgeSettings(
    enabled: _enabled ?? true,
    supported: _isSupported == true,
  );

  Future<void> setIncomingCallCount(int count) {
    _incomingCallCount = count < 0 ? 0 : count;
    return _syncSafely();
  }

  Future<void> setUnreadMissedCount(int count) {
    _unreadMissedCount = count < 0 ? 0 : count;
    return _syncSafely();
  }

  /// 只用于确实需要清空内存计数的场景，设置开关不要走这里。
  Future<void> clearAll() {
    _incomingCallCount = 0;
    _unreadMissedCount = 0;
    return _syncSafely();
  }

  Future<void> _prepare() async {
    if (_isSupported == null) {
      try {
        _isSupported = await AppBadgeControlFlutter.isAppBadgeSupported();
      } on MissingPluginException {
        // 例如当前插件没有 Linux 实现，界面直接说明不支持。
        _isSupported = false;
      }
      // 其他查询错误交给界面重试，不能把暂时失败永久记成“不支持”。
    }
    if (_isSupported == true && _enabled == null) {
      _enabled = await _storage.getBool(_enabledKey) ?? true;
    }
  }

  Future<void> _applyBadge() async {
    if (_isSupported != true || _enabled == null) return;
    final count = _enabled! ? _incomingCallCount + _unreadMissedCount : 0;
    if (_lastAppliedCount == count) return;
    if (count == 0) {
      await AppBadgeControlFlutter.removeBadge();
    } else {
      await AppBadgeControlFlutter.updateBadgeCount(count);
    }
    _lastAppliedCount = count;
    _hasLoggedFailure = false;
  }

  Future<void> _syncSafely() async {
    try {
      await _enqueue(() async {
        await _prepare();
        await _applyBadge();
      });
    } catch (error, stackTrace) {
      // 来电和数据库的订阅不能被角标异常打断；下一次变化还会再尝试。
      if (!_hasLoggedFailure) {
        _hasLoggedFailure = true;
        debugPrint('同步应用角标失败: $error\n$stackTrace');
      }
    }
  }

  /// 系统调用排队执行，免得关闭开关后，较慢的旧更新又把数字写回来。
  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = (_pending ?? Future<void>.value()).then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
