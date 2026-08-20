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
    // Drift/riverpod 的异步堆栈可能包含 package:stack_trace 插入的
    // "asynchronous gap" 标记，debugPrintStack 在部分 Flutter 版本会因无法
    // 解析该标记再次抛断言。错误处理器必须保持不抛异常，直接打印原始堆栈。
    debugPrint('$stackTrace');
  }
}
