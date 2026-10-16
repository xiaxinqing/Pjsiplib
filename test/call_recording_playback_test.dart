import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';
import 'package:veserve_vphone/src/services/storage_manager.dart';

import 'storage_manager_test.dart' show StorageTestPreferences;

class PlaybackTestPhone extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: [], isInitialized: true);

  void setEngineStopped() {
    // 测试不加载原生电话引擎，停止时也不需要真的操作声卡。
    state = state.copyWith(isInitialized: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('文件还在读取时停止试听，旧请求不能继续打开播放器', () async {
    final directory = await Directory.systemTemp.createTemp('playback_cancel_');
    addTearDown(() => directory.delete(recursive: true));
    final db = CallHistoryDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final storage = StorageManager(db, preferences: StorageTestPreferences());
    final container = ProviderContainer(
      overrides: [
        callHistoryDatabaseProvider.overrideWithValue(db),
        storageManagerProvider.overrideWithValue(storage),
        pjsipServiceProvider.overrideWith(PlaybackTestPhone.new),
      ],
    );
    addTearDown(container.dispose);
    final started = Completer<void>();
    final directoryResult = Completer<String>();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationSupportDirectory') {
        started.complete();
        return directoryResult.future;
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final now = DateTime.now();
    await db.beginCallRecording(
      sessionKey: 'cancel-test',
      callId: 1,
      relativePath: 'cancel.wav',
      startedAt: now,
    );
    final recording = (await db.listAllRecordings()).single;
    final phone =
        container.read(pjsipServiceProvider.notifier) as PlaybackTestPhone;
    final pending = phone.toggleCallRecordingPlayback(recording);
    await started.future;
    phone.setEngineStopped();
    phone.stopCallRecordingPlayback();
    directoryResult.complete(directory.path);

    // 如果旧请求没有作废，这里会报文件缺失，或尝试打开原生播放器。
    expect(await pending, CallRecordingPlaybackResult.stopped);
    expect(container.read(pjsipServiceProvider).playingRecordingId, isNull);
    expect(storage.busyRecordingIds, isEmpty);
  });
}
