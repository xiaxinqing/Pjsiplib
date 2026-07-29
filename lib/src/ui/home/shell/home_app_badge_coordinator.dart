part of '../../../../main.dart';

/// 应用角标协调器：把通话记录中的未读未接来电数量同步到系统 Dock/任务栏角标。
extension _HomeAppBadgeCoordinator on _MyHomePageState {
  /// 订阅未读未接来电数量变化，并通过原生桥接封装更新应用角标。
  void _bindUnreadMissedAppBadge() {
    _unreadMissedBadgeSubscription?.cancel();
    _unreadMissedBadgeSubscription = _watchUnreadMissedCallCount()
        .distinct()
        .listen((count) {
          unawaited(AppBadgeController.instance.setUnreadMissedCount(count));
        }, onError: _handleUnreadMissedAppBadgeError);
  }

  /// 角标同步失败不应该影响主页面，只记录一次轻量日志方便排查。
  void _handleUnreadMissedAppBadgeError(Object error, StackTrace stackTrace) {
    debugPrint('监听未读未接来电角标失败: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
