import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'call_history_database.dart';
import 'call_recording_storage.dart';

/// 0 就是永久保存，其他数字就是保留多少天。
class StorageSettings {
  const StorageSettings({this.historyDays = 0, this.recordingDays = 0});

  final int historyDays;
  final int recordingDays;

  static bool validDays(int days) => days >= 0 && days <= 36500;
}

/// 先把要删的内容列出来，手动清理时就能告诉用户会删多少。
class StorageCleanupPlan {
  const StorageCleanupPlan(this.historyIds, this.recordings);

  final List<int> historyIds;
  final List<CallRecording> recordings;
  bool get isEmpty => historyIds.isEmpty && recordings.isEmpty;
}

class StorageCleanupResult {
  const StorageCleanupResult(
    this.historyCount,
    this.recordingCount,
    this.failedCount,
  );

  final int historyCount;
  final int recordingCount;
  final int failedCount;
}

/// 保存期限、找过期数据、清理数据，都从这里走。
class StorageManager {
  StorageManager(
    this.database, {
    SharedPreferencesAsync? preferences,
    Future<void> Function(String)? deleteFile,
  }) : _preferences = preferences ?? SharedPreferencesAsync(),
       _deleteFile = deleteFile ?? CallRecordingStorage.delete;

  final CallHistoryDatabase database;
  final SharedPreferencesAsync _preferences;
  final Future<void> Function(String) _deleteFile;
  static const settingsKey = 'storage_save_days';
  bool _cleaning = false;

  // 播放器正在打开文件时也要占个位置，免得刚点播放就被后台清理了。
  final Set<int> busyRecordingIds = {};

  Future<StorageSettings> readSettings() async {
    final saved = await _preferences.getString(settingsKey);
    if (saved == null) return const StorageSettings();
    final data = jsonDecode(saved) as Map<String, dynamic>;
    final history = data['historyDays'];
    final recording = data['recordingDays'];
    if (history is! int ||
        recording is! int ||
        !StorageSettings.validDays(history) ||
        !StorageSettings.validDays(recording)) {
      throw const FormatException('Invalid storage days');
    }
    return StorageSettings(historyDays: history, recordingDays: recording);
  }

  Future<void> saveSettings(StorageSettings settings) async {
    if (!StorageSettings.validDays(settings.historyDays) ||
        !StorageSettings.validDays(settings.recordingDays)) {
      throw ArgumentError('Days must be between 0 and 36500');
    }
    // 两个值一起保存，避免只存成功一半。
    await _preferences.setString(
      settingsKey,
      jsonEncode({
        'historyDays': settings.historyDays,
        'recordingDays': settings.recordingDays,
      }),
    );
  }

  Future<StorageCleanupPlan> findExpired(
    StorageSettings settings, {
    DateTime? now,
  }) async {
    final time = now ?? DateTime.now();
    final history = settings.historyDays == 0
        ? <int>[]
        : await database.findOldHistoryIds(
            time.subtract(Duration(days: settings.historyDays)),
          );
    final recordings = settings.recordingDays == 0
        ? <CallRecording>[]
        : await database.findOldRecordings(
            time.subtract(Duration(days: settings.recordingDays)),
          );
    return StorageCleanupPlan(history, recordings);
  }

  Future<StorageCleanupResult> cleanExpired(
    StorageCleanupPlan plan, {
    bool Function(int)? isPlaying,
  }) async {
    if (_cleaning) throw StateError('Storage cleanup is already running');
    _cleaning = true;
    var historyCount = 0;
    var recordingCount = 0;
    var failedCount = 0;
    try {
      for (final recording in plan.recordings) {
        if (recording.status == CallRecordingStatus.recording.storageKey ||
            (isPlaying?.call(recording.id) ?? false) ||
            !busyRecordingIds.add(recording.id)) {
          continue;
        }
        try {
          // 文件先删，数据库后删。文件删不掉就留下记录，下次还能重试。
          // 文件已经不存在也没关系，顺手把数据库里的旧记录收拾掉。
          await _deleteFile(recording.relativePath);
          await database.deleteRecording(recording.id);
          recordingCount++;
        } catch (_) {
          failedCount++;
        } finally {
          busyRecordingIds.remove(recording.id);
        }
      }
      for (final id in plan.historyIds) {
        try {
          // 不走手动“连录音一起删”的入口，录音有自己的保存期限。
          await database.deleteOldHistoryEntry(id);
          historyCount++;
        } catch (_) {
          failedCount++;
        }
      }
      return StorageCleanupResult(historyCount, recordingCount, failedCount);
    } finally {
      _cleaning = false;
    }
  }
}

final storageManagerProvider = Provider<StorageManager>((ref) {
  return StorageManager(ref.read(callHistoryDatabaseProvider));
});
