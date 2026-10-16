import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';
import 'package:veserve_vphone/src/services/storage_manager.dart';

class StorageTestPreferences implements SharedPreferencesAsync {
  final values = <String, Object?>{};
  String? get saved => values['saved'] as String?;
  set saved(String? value) => values['saved'] = value;
  bool get failSave => values['failSave'] == true;
  set failSave(bool value) => values['failSave'] = value;
  @override
  Future<String?> getString(String key) async => saved;
  @override
  Future<void> setString(String key, String value) async {
    if (failSave) throw StateError('Save failed');
    saved = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late CallHistoryDatabase db;
  late StorageTestPreferences prefs;
  late StorageManager storage;
  late Directory directory;
  final now = DateTime.utc(2026, 10, 14, 12);
  final oldTime = now.subtract(const Duration(days: 100));

  Future<({int history, int recording, File file})> addCall(
    DateTime time, {
    String key = 'old',
    bool finished = true,
  }) async {
    final file = File('${directory.path}/$key.wav');
    await file.writeAsString('recording test data');
    final recording = await db.beginCallRecording(
      sessionKey: key,
      callId: 1,
      relativePath: '$key.wav',
      startedAt: time,
    );
    final history = await db.recordCall(
      callId: 1,
      direction: CallHistoryDirection.inbound,
      status: CallHistoryStatus.missed,
      remoteUri: 'sip:100@example.com',
      phoneNumber: '100',
      startedAt: time,
      endedAt: time,
      recordingSessionKey: key,
    );
    if (finished) {
      await db.finalizeCallRecording(
        id: recording,
        status: CallRecordingStatus.completed,
        endedAt: time,
        duration: const Duration(seconds: 1),
        fileSizeBytes: 100,
      );
    }
    return (history: history, recording: recording, file: file);
  }

  setUp(() async {
    db = CallHistoryDatabase(NativeDatabase.memory());
    prefs = StorageTestPreferences();
    directory = await Directory.systemTemp.createTemp('storage_test_');
    storage = StorageManager(
      db,
      preferences: prefs,
      deleteFile: (path) async {
        final file = File('${directory.path}/$path');
        if (await file.exists()) await file.delete();
      },
    );
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  test('默认永久保存，重新打开后分别恢复保存期限，写入失败不覆盖旧规则', () async {
    await addCall(oldTime);
    final defaults = await storage.readSettings();
    expect(defaults.historyDays, 0);
    expect(defaults.recordingDays, 0);
    expect((await storage.findExpired(defaults, now: now)).isEmpty, isTrue);
    await storage.saveSettings(
      const StorageSettings(historyDays: 37, recordingDays: 90),
    );
    final reopened = StorageManager(db, preferences: prefs);
    expect((await reopened.readSettings()).historyDays, 37);
    expect((await reopened.readSettings()).recordingDays, 90);
    prefs.failSave = true;
    await expectLater(
      storage.saveSettings(const StorageSettings(historyDays: 1)),
      throwsStateError,
    );
    expect((await reopened.readSettings()).historyDays, 37);
    await expectLater(
      storage.saveSettings(const StorageSettings(recordingDays: -1)),
      throwsArgumentError,
    );
  });

  test('清理历史不删录音，关联解除，独立录音列表和未读角标及时更新', () async {
    final call = await addCall(oldTime);
    expect(await db.watchUnreadMissedCallCount().first, 1);
    final plan = await storage.findExpired(
      const StorageSettings(historyDays: 90),
      now: now,
    );
    final result = await storage.cleanExpired(plan);
    expect(result.historyCount, 1);
    expect(await db.listRecentPage(), isEmpty);
    expect(await call.file.exists(), isTrue);
    final rows = await db.watchLocalRecordings().first;
    expect(rows.single.id, call.recording);
    expect(rows.single.historyEntryId, isNull);
    expect(
      (await db.listRecordingParticipants(
        call.recording,
      )).single.historyEntryId,
      isNull,
    );
    expect(await db.watchUnreadMissedCallCount().first, 0);
  });

  test('仅删过期录音和关联，保留历史；恰好到期限和近期数据不删', () async {
    final old = await addCall(oldTime);
    await addCall(now.subtract(const Duration(days: 90)), key: 'boundary');
    await addCall(now.subtract(const Duration(days: 1)), key: 'new');
    final plan = await storage.findExpired(
      const StorageSettings(recordingDays: 90),
      now: now,
    );
    expect(plan.recordings.map((r) => r.id), [old.recording]);
    final result = await storage.cleanExpired(plan);
    expect(result.recordingCount, 1);
    expect(await old.file.exists(), isFalse);
    expect(await db.listRecentPage(), hasLength(3));
    expect(await db.listRecordingParticipants(old.recording), isEmpty);
    expect(await db.listAllRecordings(), hasLength(2));
  });

  test('录制中、播放中、正在打开的录音都跳过，之后可以重试', () async {
    final playing = await addCall(oldTime, key: 'playing');
    final opening = await addCall(oldTime, key: 'opening');
    final active = await addCall(oldTime, key: 'active', finished: false);
    final plan = await storage.findExpired(
      const StorageSettings(recordingDays: 90),
      now: now,
    );
    expect(plan.recordings, hasLength(2));
    storage.busyRecordingIds.add(opening.recording);
    final result = await storage.cleanExpired(
      plan,
      isPlaying: (id) => id == playing.recording,
    );
    expect(result.recordingCount, 0);
    expect(await db.listAllRecordings(), hasLength(3));
    storage.busyRecordingIds.clear();
    expect((await storage.cleanExpired(plan)).recordingCount, 2);
    expect(await active.file.exists(), isTrue);
  });

  test('文件删除失败保留数据库，其他条目继续清理，缺失文件可以清掉记录', () async {
    final failed = await addCall(oldTime, key: 'failed');
    final missing = await addCall(oldTime, key: 'missing');
    await missing.file.delete();
    final cleaner = StorageManager(
      db,
      preferences: prefs,
      deleteFile: (path) async {
        if (path == 'failed.wav') throw const FileSystemException('locked');
      },
    );
    final plan = await cleaner.findExpired(
      const StorageSettings(recordingDays: 90),
      now: now,
    );
    final result = await cleaner.cleanExpired(plan);
    expect(result.failedCount, 1);
    expect(result.recordingCount, 1);
    expect((await db.listAllRecordings()).single.id, failed.recording);
    expect(await failed.file.exists(), isTrue);
    final retry = await storage.findExpired(
      const StorageSettings(recordingDays: 90),
      now: now,
    );
    expect((await storage.cleanExpired(retry)).recordingCount, 1);
  });

  test('清理中保护文件，重复清理不会同时执行', () async {
    final call = await addCall(oldTime);
    final started = Completer<void>();
    final gate = Completer<void>();
    final cleaner = StorageManager(
      db,
      preferences: prefs,
      deleteFile: (_) async {
        started.complete();
        await gate.future;
      },
    );
    final plan = await cleaner.findExpired(
      const StorageSettings(recordingDays: 90),
      now: now,
    );
    final cleaning = cleaner.cleanExpired(plan);
    await started.future;
    expect(cleaner.busyRecordingIds, contains(call.recording));
    await expectLater(cleaner.cleanExpired(plan), throwsStateError);
    gate.complete();
    await cleaning;
    expect(cleaner.busyRecordingIds, isEmpty);
  });

  test('损坏的设置拒绝清理，不猜测删除期限', () async {
    prefs.saved = '{"historyDays":-1,"recordingDays":30}';
    await expectLater(storage.readSettings(), throwsFormatException);
  });
}
