import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veserve_vphone/src/generated/pjsip_bindings.g.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

// 使用真实 PjsipService 和动态库，只模拟异步系统查询。无账号，不打开音频设备。
// VPHONE_RUN_NATIVE_AUDIO_TESTS=1 flutter test --no-pub
//   test/native_audio_route_startup_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final enabled =
      Platform.isMacOS &&
      Platform.environment['VPHONE_RUN_NATIVE_AUDIO_TESTS'] == '1';
  const channel = MethodChannel('voip_desk/audio_device_changes');
  const route = {
    'input': {'id': 'BuiltInMicrophone', 'name': 'MacBook Pro麦克风'},
    'output': {'id': 'BuiltInSpeaker', 'name': 'MacBook Pro扬声器'},
  };

  for (final disposeWhileWaiting in [false, true]) {
    test(
      disposeWhileWaiting
          ? '系统路由查询期间退出，不再初始化原生引擎或更新已销毁状态'
          : '系统路由延迟返回时，启动和拨号预热不会误报设备缺失',
      () async {
        final dylib = ffi.DynamicLibrary.open(
          '${Directory.current.path}/macos/Frameworks/libpjsip.dylib',
        );
        final bindings = PjsipBindings(dylib);
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final pendingRoute = Completer<Object?>();
        final routeRequested = Completer<void>();
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getCurrentAudioRoute') {
            if (!routeRequested.isCompleted) routeRequested.complete();
            return pendingRoute.future;
          }
          return false;
        });
        const permission = MethodChannel('voip_desk/audio_permission');
        messenger.setMockMethodCallHandler(
          permission,
          (_) async => 'authorized',
        );
        const secure = MethodChannel(
          'plugins.it_nomads.com/flutter_secure_storage',
        );
        messenger.setMockMethodCallHandler(secure, (_) async => null);
        SharedPreferences.setMockInitialValues({});
        final database = CallHistoryDatabase(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [callHistoryDatabaseProvider.overrideWithValue(database)],
        );
        var disposed = false;
        final readyRoutes = <String?>[];
        container.listen(pjsipServiceProvider, (_, state) {
          if (state.isInitialized) {
            readyRoutes.add(state.systemAudioRoute?.output?.name);
          }
        });
        final service = container.read(pjsipServiceProvider.notifier);
        try {
          final firstInit = service.init();
          await routeRequested.future;
          final secondInit = service.init();
          // 复现日志中的顺序：路由通道仍在等待，拨号页先请求预热。
          service.prepareDialpadKeySound();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(container.read(pjsipServiceProvider).isInitialized, isFalse);
          expect(
            container.read(pjsipServiceProvider).audioDeviceIssueStatus,
            isNull,
          );
          expect(readyRoutes, isEmpty);

          if (disposeWhileWaiting) {
            await service.shutdownForApplicationExit();
            container.dispose();
            disposed = true;
          }
          pendingRoute.complete(route);
          await Future.wait([firstInit, secondInit]);
          if (!disposed) {
            final state = container.read(pjsipServiceProvider);
            expect(state.isInitialized, isTrue);
            expect(state.audioDeviceIssueStatus, isNull);
            expect(readyRoutes, isNotEmpty);
            expect(readyRoutes, everyElement('MacBook Pro扬声器'));
            expect(bindings.pjsua_snd_is_active(), 0);
            expect(state.accounts, isEmpty);
          }
        } finally {
          if (!pendingRoute.isCompleted) pendingRoute.complete(route);
          if (!disposed) {
            await service.shutdownForApplicationExit();
            container.dispose();
          }
          await database.close();
          // 排空服务清理过程中已经发出的通道请求。
          await Future<void>.delayed(const Duration(milliseconds: 100));
          messenger.setMockMethodCallHandler(channel, null);
          messenger.setMockMethodCallHandler(permission, null);
          messenger.setMockMethodCallHandler(secure, null);
        }
      },
      skip: !enabled,
    );
  }
}
