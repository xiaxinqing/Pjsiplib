import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'call_history_database.dart';
import 'pjsip_service.dart';

final appShutdownCoordinatorProvider = Provider<AppShutdownCoordinator>((ref) {
  return AppShutdownCoordinator(
    pjsipService: ref.read(pjsipServiceProvider.notifier),
    database: ref.read(callHistoryDatabaseProvider),
  );
});

/// 协调 PJSIP 回调和本地数据库的应用退出流程。
///
/// 顺序不能颠倒：先停止可能产生通话记录的 PJSIP，再等待数据库已接收的写入。
/// 退出进程时不显式关闭 Drift 原生连接，避免 macOS 上 sqlite3_close 与后台
/// isolate 销毁竞态。重复退出请求会复用同一个 Future。
class AppShutdownCoordinator {
  AppShutdownCoordinator({
    required this._pjsipService,
    required this._database,
  });

  final PjsipService _pjsipService;
  final CallHistoryDatabase _database;

  Future<void>? _shutdownFuture;

  Future<void> shutdown() {
    return _shutdownFuture ??= _performShutdown();
  }

  Future<void> _performShutdown() async {
    debugPrint('Application shutdown started.');

    try {
      await _pjsipService.shutdownForApplicationExit();
    } catch (error, stackTrace) {
      // Database cleanup must still run even if a native engine reports an
      // error while stopping.
      debugPrint('PJSIP shutdown failed: $error');
      debugPrint('$stackTrace');
    }

    try {
      await _database.prepareForProcessExit();
      debugPrint(
        'Call history database writes drained before application exit.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Wait for call history database writes before exit failed: $error',
      );
      debugPrint('$stackTrace');
    }

    debugPrint('Application shutdown completed.');
  }
}
