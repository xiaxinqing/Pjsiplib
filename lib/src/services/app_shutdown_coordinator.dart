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

/// Coordinates process shutdown across native SIP callbacks and local storage.
///
/// The order is intentional: stop PJSIP and other write producers first, wait
/// for accepted database writes, then close Drift before Flutter destroys the
/// Dart isolate. Repeated exit requests share the same future.
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
      await _database.close();
      debugPrint('Call history database closed before application exit.');
    } catch (error, stackTrace) {
      debugPrint('Call history database close before exit failed: $error');
      debugPrint('$stackTrace');
    }

    debugPrint('Application shutdown completed.');
  }
}
