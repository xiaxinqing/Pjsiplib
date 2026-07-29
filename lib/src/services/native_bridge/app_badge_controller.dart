import 'package:app_badge_control_flutter/app_badge_control_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 统一管理应用图标角标。
///
/// 1. 角标显示“通话记录中的未读未接来电数量 + 当前响铃来电数量”。
/// 2. 两者都为 0 时，清除系统角标。
///
/// 系统角标表达的是待处理总数；窗口跳动/置顶这类强提醒仍只由当前响铃来电触发。
class AppBadgeController {
  AppBadgeController._();

  static final AppBadgeController instance = AppBadgeController._();

  bool? _isSupported;
  int _incomingCallCount = 0;
  int _unreadMissedCount = 0;
  int? _lastAppliedCount;
  int _applyRevision = 0;
  bool _hasLoggedFailure = false;

  /// 记录当前正在响铃的来电数量，会和历史未读未接来电数量一起计入系统角标。
  Future<void> setIncomingCallCount(int count) {
    _incomingCallCount = _normalizeCount(count);
    return _applyPreferredBadgeCount();
  }

  /// 记录通话记录中未读未接来电数量。
  Future<void> setUnreadMissedCount(int count) {
    _unreadMissedCount = _normalizeCount(count);
    return _applyPreferredBadgeCount();
  }

  /// 主动清除全部角标状态，用于退出前或测试场景兜底。
  Future<void> clearAll() {
    _incomingCallCount = 0;
    _unreadMissedCount = 0;
    return _applyPreferredBadgeCount();
  }

  int _normalizeCount(int count) => count < 0 ? 0 : count;

  int get _preferredBadgeCount => _incomingCallCount + _unreadMissedCount;

  Future<void> _applyPreferredBadgeCount() async {
    final nextCount = _preferredBadgeCount;
    if (_lastAppliedCount == nextCount) return;

    final revision = ++_applyRevision;

    final supported = await _checkSupported();
    if (!supported) return;

    // 异步检查支持期间可能又来了新状态，只允许最新一次状态落到系统角标。
    if (revision != _applyRevision) return;

    try {
      if (nextCount == 0) {
        await AppBadgeControlFlutter.removeBadge();
      } else {
        await AppBadgeControlFlutter.updateBadgeCount(nextCount);
      }
      _lastAppliedCount = nextCount;
      _hasLoggedFailure = false;
    } on MissingPluginException {
      // 测试环境或暂不支持的平台可能没有注册插件，角标失败不影响主流程。
      _isSupported = false;
    } on PlatformException catch (error) {
      _logOnce('同步应用角标失败: ${error.message ?? error.code}');
    } catch (error, stackTrace) {
      _logOnce('同步应用角标异常: $error', stackTrace: stackTrace);
    }
  }

  Future<bool> _checkSupported() async {
    final cached = _isSupported;
    if (cached != null) return cached;

    try {
      final supported = await AppBadgeControlFlutter.isAppBadgeSupported();
      _isSupported = supported;
      return supported;
    } on MissingPluginException {
      _isSupported = false;
      return false;
    } on PlatformException catch (error) {
      _logOnce('检查应用角标支持失败: ${error.message ?? error.code}');
      _isSupported = false;
      return false;
    } catch (error, stackTrace) {
      _logOnce('检查应用角标支持异常: $error', stackTrace: stackTrace);
      _isSupported = false;
      return false;
    }
  }

  void _logOnce(String message, {StackTrace? stackTrace}) {
    if (_hasLoggedFailure) return;
    _hasLoggedFailure = true;
    debugPrint(message);
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
