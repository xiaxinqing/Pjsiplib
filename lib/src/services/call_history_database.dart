import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_identity.dart';

part 'call_history_database.g.dart';

enum CallHistoryDirection {
  inbound('inbound', '来电'),
  outbound('outbound', '呼出');

  const CallHistoryDirection(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static CallHistoryDirection fromStorage(String value) {
    return values.firstWhere(
      (direction) => direction.storageKey == value,
      orElse: () => CallHistoryDirection.outbound,
    );
  }
}

enum CallHistoryStatus {
  completed('completed', '已接通'),
  missed('missed', '未接来电'),
  rejected('rejected', '已拒接'),
  failed('failed', '呼叫失败'),
  canceled('canceled', '已取消');

  const CallHistoryStatus(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static CallHistoryStatus fromStorage(String value) {
    return values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () => CallHistoryStatus.completed,
    );
  }
}

enum CallRecordingStatus {
  recording('recording'),
  completed('completed'),
  interrupted('interrupted'),
  failed('failed');

  const CallRecordingStatus(this.storageKey);

  final String storageKey;

  static CallRecordingStatus fromStorage(String value) {
    return values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () => CallRecordingStatus.failed,
    );
  }
}

enum CallRecordingKind {
  single('single'),
  conference('conference');

  const CallRecordingKind(this.storageKey);

  final String storageKey;
}

class CallHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get callId => integer()();
  TextColumn get sessionKey => text().nullable()();
  TextColumn get direction => text()();
  TextColumn get status => text()();
  TextColumn get remoteUri => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get contactId => text().nullable()();
  IntColumn get accountId => integer().nullable()();
  TextColumn get accountLabel => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get ringingAt => dateTime().nullable()();
  DateTimeColumn get answeredAt => dateTime().nullable()();
  DateTimeColumn get mediaConnectedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get ringSeconds => integer().withDefault(const Constant(0))();
  IntColumn get timeToRingingMs => integer().nullable()();
  IntColumn get ringingToAnswerMs => integer().nullable()();
  IntColumn get answerToMediaMs => integer().nullable()();
  IntColumn get holdCount => integer().withDefault(const Constant(0))();
  IntColumn get holdSeconds => integer().withDefault(const Constant(0))();
  IntColumn get sipStatusCode => integer().nullable()();
  TextColumn get hangupReason => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get missedReadAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 本地录音独立于通话记录保存，允许一条通话记录关联多个录音片段。
///
/// [sessionKey] 在一次 PJSIP 通话实例内稳定，不能只使用会被复用的 callId。
/// 文件路径保存为相对录音根目录的路径，避免应用目录迁移后绝对路径失效。
class CallRecordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get historyEntryId => integer().nullable().references(
    CallHistoryEntries,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get sessionKey => text()();
  IntColumn get callId => integer()();
  TextColumn get kind => text().withDefault(const Constant('single'))();
  TextColumn get relativePath => text()();
  TextColumn get status => text()();
  TextColumn get format => text().withDefault(const Constant('wav'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get failureReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 一段物理录音与参与过该录音的 SIP 通话实例之间的多对多关联。
///
/// 会议成员可以中途加入或退出；[callSessionKey] 使用通话开始时间和 callId
/// 组成，避免 PJSIP 复用 callId 后把录音关联到错误的历史记录。
class CallRecordingLinks extends Table {
  IntColumn get recordingId =>
      integer().references(CallRecordings, #id, onDelete: KeyAction.cascade)();
  TextColumn get callSessionKey => text()();
  IntColumn get callId => integer()();
  IntColumn get historyEntryId => integer().nullable().references(
    CallHistoryEntries,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get joinedAt => dateTime()();
  DateTimeColumn get leftAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {recordingId, callSessionKey};
}

class DbContacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get number => text()();
  TextColumn get normalizedNumber => text()();
  TextColumn get company => text().withDefault(const Constant(''))();
  TextColumn get department => text().withDefault(const Constant(''))();
  TextColumn get remark => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DbContactPhones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().references(DbContacts, #id)();
  TextColumn get label => text().withDefault(const Constant('默认'))();
  TextColumn get number => text()();
  TextColumn get normalizedNumber => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

class StoredContactRow {
  const StoredContactRow({
    required this.id,
    required this.name,
    required this.number,
    this.phones = const [],
    required this.company,
    required this.department,
    required this.remark,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String number;
  final List<StoredContactPhoneRow> phones;
  final String company;
  final String department;
  final String remark;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

class StoredContactPhoneRow {
  const StoredContactPhoneRow({
    required this.label,
    required this.number,
    required this.isPrimary,
  });

  final String label;
  final String number;
  final bool isPrimary;
}

@DriftDatabase(
  tables: [
    CallHistoryEntries,
    CallRecordings,
    CallRecordingLinks,
    DbContacts,
    DbContactPhones,
  ],
)
class CallHistoryDatabase extends _$CallHistoryDatabase {
  CallHistoryDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  final Set<Future<void>> _pendingWrites = <Future<void>>{};
  Future<void>? _closeFuture;
  Future<void>? _processExitPreparationFuture;
  bool _acceptingWrites = true;

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
      await _createRecordingIndexes();
      await _createRecordingLinkIndexes();
      await _createContactIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _createIndexes();
      }
      if (from < 3) {
        await migrator.createTable(dbContacts);
        await migrator.createTable(dbContactPhones);
        await _createContactIndexes();
      }
      if (from < 4) {
        await migrator.addColumn(callHistoryEntries, callHistoryEntries.note);
      }
      if (from < 5) {
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.ringingAt,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.mediaConnectedAt,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.timeToRingingMs,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.ringingToAnswerMs,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.answerToMediaMs,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.holdCount,
        );
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.holdSeconds,
        );
      }
      if (from < 6) {
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.missedReadAt,
        );
      }
      if (from < 7) {
        await migrator.addColumn(
          callHistoryEntries,
          callHistoryEntries.sessionKey,
        );
        await migrator.createTable(callRecordings);
        await _createRecordingIndexes();
      }
      if (from == 7) {
        await migrator.addColumn(callRecordings, callRecordings.kind);
      }
      if (from < 8) {
        await migrator.createTable(callRecordingLinks);
        await customStatement(
          'INSERT OR IGNORE INTO call_recording_links '
          '(recording_id, call_session_key, call_id, history_entry_id, joined_at, left_at) '
          'SELECT id, session_key, call_id, history_entry_id, started_at, ended_at '
          'FROM call_recordings',
        );
        await _createRecordingLinkIndexes();
      }
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_history_started_at '
      'ON call_history_entries (started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_history_direction_started_at '
      'ON call_history_entries (direction, started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_history_phone_number '
      'ON call_history_entries (phone_number)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_history_contact_id '
      'ON call_history_entries (contact_id)',
    );
  }

  Future<void> _createContactIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contacts_favorite_name '
      'ON db_contacts (is_favorite DESC, name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contacts_normalized_number '
      'ON db_contacts (normalized_number)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_phones_contact_id '
      'ON db_contact_phones (contact_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_phones_normalized_number '
      'ON db_contact_phones (normalized_number)',
    );
  }

  Future<void> _createRecordingIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_recordings_history_entry '
      'ON call_recordings (history_entry_id, started_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_recordings_session_key '
      'ON call_recordings (session_key)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_recordings_status '
      'ON call_recordings (status)',
    );
  }

  Future<void> _createRecordingLinkIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_recording_links_history '
      'ON call_recording_links (history_entry_id, recording_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_call_recording_links_session '
      'ON call_recording_links (call_session_key)',
    );
  }

  Future<void> warmUp() async {
    await (select(callHistoryEntries)..limit(1)).get();
  }

  Stream<List<CallHistoryEntry>> watchRecent({
    String keyword = '',
    CallHistoryDirection? direction,
    bool missedOnly = false,
    DateTime? startedFrom,
    DateTime? startedBefore,
    int limit = 100,
  }) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final query = select(callHistoryEntries)
      ..orderBy([
        (table) => OrderingTerm.desc(table.startedAt),
        (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(limit);

    if (direction != null) {
      query.where((table) => table.direction.equals(direction.storageKey));
    }
    if (missedOnly) {
      // 未接提醒只统计“别人打进来且本机没有接通”的记录，不包含呼出失败。
      query.where(
        (table) =>
            table.direction.equals(CallHistoryDirection.inbound.storageKey) &
            table.status.equals(CallHistoryStatus.missed.storageKey) &
            table.answeredAt.isNull(),
      );
    }
    if (startedFrom != null) {
      query.where((table) => table.startedAt.isBiggerOrEqualValue(startedFrom));
    }
    if (startedBefore != null) {
      query.where((table) => table.startedAt.isSmallerThanValue(startedBefore));
    }
    if (normalizedKeyword.isNotEmpty) {
      query.where(
        (table) =>
            table.phoneNumber.lower().contains(normalizedKeyword) |
            table.remoteUri.lower().contains(normalizedKeyword) |
            table.displayName.lower().contains(normalizedKeyword) |
            table.accountLabel.lower().contains(normalizedKeyword) |
            table.note.lower().contains(normalizedKeyword),
      );
    }
    return query.watch();
  }

  Future<List<CallHistoryEntry>> listRecentPage({
    String keyword = '',
    CallHistoryDirection? direction,
    bool missedOnly = false,
    DateTime? startedFrom,
    DateTime? startedBefore,
    DateTime? cursorStartedAt,
    int? cursorId,
    int limit = 100,
  }) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final query = select(callHistoryEntries)
      ..orderBy([
        (table) => OrderingTerm.desc(table.startedAt),
        (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(limit);

    if (direction != null) {
      query.where((table) => table.direction.equals(direction.storageKey));
    }
    if (missedOnly) {
      // 未接分页也只取“别人打进来且本机没有接通”的记录，和未读统计保持一致。
      query.where(
        (table) =>
            table.direction.equals(CallHistoryDirection.inbound.storageKey) &
            table.status.equals(CallHistoryStatus.missed.storageKey) &
            table.answeredAt.isNull(),
      );
    }
    if (startedFrom != null) {
      query.where((table) => table.startedAt.isBiggerOrEqualValue(startedFrom));
    }
    if (startedBefore != null) {
      query.where((table) => table.startedAt.isSmallerThanValue(startedBefore));
    }
    if (cursorStartedAt != null && cursorId != null) {
      // 游标分页按 started_at desc, id desc 排序，避免新通话插入顶部后 offset 错位。
      query.where(
        (table) =>
            table.startedAt.isSmallerThanValue(cursorStartedAt) |
            (table.startedAt.equals(cursorStartedAt) &
                table.id.isSmallerThanValue(cursorId)),
      );
    }
    if (normalizedKeyword.isNotEmpty) {
      query.where(
        (table) =>
            table.phoneNumber.lower().contains(normalizedKeyword) |
            table.remoteUri.lower().contains(normalizedKeyword) |
            table.displayName.lower().contains(normalizedKeyword) |
            table.accountLabel.lower().contains(normalizedKeyword) |
            table.note.lower().contains(normalizedKeyword),
      );
    }
    return query.get();
  }

  Stream<int> watchUnreadMissedCallCount() {
    final countExpression = callHistoryEntries.id.count();
    final query = selectOnly(callHistoryEntries)
      ..addColumns([countExpression])
      ..where(
        callHistoryEntries.direction.equals(
              CallHistoryDirection.inbound.storageKey,
            ) &
            callHistoryEntries.status.equals(
              CallHistoryStatus.missed.storageKey,
            ) &
            callHistoryEntries.answeredAt.isNull() &
            callHistoryEntries.missedReadAt.isNull(),
      );
    // watchSingle   持续监听，返回 Stream<int>
    return query.map((row) => row.read(countExpression) ?? 0).watchSingle();
  }

  Stream<List<CallHistoryEntry>> watchRecentForContact({
    required String contactId,
    required String phoneNumber,
    Iterable<String> phoneNumbers = const [],
    int limit = 5,
  }) {
    final normalizedNumbers = {
      _normalizePhoneNumber(phoneNumber),
      ...phoneNumbers.map(_normalizePhoneNumber),
    }.where((number) => number.isNotEmpty).toSet();
    final query = select(callHistoryEntries)
      ..orderBy([(table) => OrderingTerm.desc(table.startedAt)])
      ..limit(limit);

    if (normalizedNumbers.isEmpty) {
      query.where((table) => table.contactId.equals(contactId));
    } else {
      query.where(
        (table) =>
            table.contactId.equals(contactId) |
            table.phoneNumber.isIn(normalizedNumbers),
      );
    }
    return query.watch();
  }

  Future<void> addEntry(CallHistoryEntriesCompanion entry) {
    return _trackWrite(
      'addEntry',
      () => into(callHistoryEntries).insert(entry).then((_) {}),
    );
  }

  Future<int> recordCall({
    required int callId,
    required CallHistoryDirection direction,
    required CallHistoryStatus status,
    required String remoteUri,
    required String phoneNumber,
    required DateTime startedAt,
    required DateTime endedAt,
    DateTime? ringingAt,
    DateTime? answeredAt,
    DateTime? mediaConnectedAt,
    String? displayName,
    String? contactId,
    int? accountId,
    String? accountLabel,
    int holdCount = 0,
    Duration holdDuration = Duration.zero,
    int? sipStatusCode,
    String? hangupReason,
    String? note,
    String? recordingSessionKey,
  }) {
    final durationSeconds = answeredAt == null
        ? 0
        : endedAt.difference(answeredAt).inSeconds.clamp(0, 1 << 31).toInt();
    final ringSeconds = endedAt
        .difference(startedAt)
        .inSeconds
        .clamp(0, 1 << 31)
        .toInt();
    final timeToRingingMs = _positiveMilliseconds(startedAt, ringingAt);
    // 同一个字段记录“响铃阶段耗时”：已接通时是响铃到接听，未接通时是响铃到结束。
    // 这样通话记录详情不需要为未接通外呼额外维护一套统计字段。
    final ringingEndAt = answeredAt ?? endedAt;
    final ringingToAnswerMs = _positiveMilliseconds(ringingAt, ringingEndAt);
    final answerToMediaMs = _positiveMilliseconds(answeredAt, mediaConnectedAt);
    return _trackWrite('recordCall', () async {
      final historyId = await into(callHistoryEntries).insert(
        CallHistoryEntriesCompanion.insert(
          callId: callId,
          sessionKey: Value(recordingSessionKey),
          direction: direction.storageKey,
          status: status.storageKey,
          remoteUri: remoteUri,
          phoneNumber: phoneNumber,
          displayName: Value(displayName),
          contactId: Value(contactId),
          accountId: Value(accountId),
          accountLabel: Value(accountLabel),
          startedAt: startedAt,
          ringingAt: Value(ringingAt),
          answeredAt: Value(answeredAt),
          mediaConnectedAt: Value(mediaConnectedAt),
          endedAt: endedAt,
          durationSeconds: Value(durationSeconds),
          ringSeconds: Value(ringSeconds),
          timeToRingingMs: Value(timeToRingingMs),
          ringingToAnswerMs: Value(ringingToAnswerMs),
          answerToMediaMs: Value(answerToMediaMs),
          holdCount: Value(holdCount.clamp(0, 1 << 31).toInt()),
          holdSeconds: Value(holdDuration.inSeconds.clamp(0, 1 << 31).toInt()),
          sipStatusCode: Value(sipStatusCode),
          hangupReason: Value(hangupReason),
          note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
          createdAt: DateTime.now(),
        ),
      );
      if (recordingSessionKey != null && recordingSessionKey.isNotEmpty) {
        await (update(callRecordings)
              ..where((table) => table.sessionKey.equals(recordingSessionKey)))
            .write(CallRecordingsCompanion(historyEntryId: Value(historyId)));
        await (update(callRecordingLinks)..where(
              (table) => table.callSessionKey.equals(recordingSessionKey),
            ))
            .write(
              CallRecordingLinksCompanion(historyEntryId: Value(historyId)),
            );
      }
      return historyId;
    });
  }

  Future<int> beginCallRecording({
    required String sessionKey,
    required int callId,
    required String relativePath,
    required DateTime startedAt,
    String? participantSessionKey,
  }) {
    return _trackWrite('beginCallRecording', () async {
      final effectiveParticipantSessionKey =
          participantSessionKey ?? sessionKey;
      final recordingId = await into(callRecordings).insert(
        CallRecordingsCompanion.insert(
          sessionKey: sessionKey,
          callId: callId,
          relativePath: relativePath,
          status: CallRecordingStatus.recording.storageKey,
          startedAt: startedAt,
          createdAt: DateTime.now(),
        ),
      );
      final history =
          await (select(callHistoryEntries)
                ..where(
                  (table) =>
                      table.sessionKey.equals(effectiveParticipantSessionKey),
                )
                ..limit(1))
              .getSingleOrNull();
      await into(callRecordingLinks).insert(
        CallRecordingLinksCompanion.insert(
          recordingId: recordingId,
          callSessionKey: effectiveParticipantSessionKey,
          callId: callId,
          historyEntryId: Value(history?.id),
          joinedAt: startedAt,
        ),
      );
      if (history != null) {
        await (update(callRecordings)
              ..where((table) => table.id.equals(recordingId)))
            .write(CallRecordingsCompanion(historyEntryId: Value(history.id)));
      }
      return recordingId;
    });
  }

  Future<void> promoteCallRecordingToConference(int recordingId) {
    return _trackWrite(
      'promoteCallRecordingToConference',
      () =>
          (update(
            callRecordings,
          )..where((table) => table.id.equals(recordingId))).write(
            CallRecordingsCompanion(
              kind: Value(CallRecordingKind.conference.storageKey),
            ),
          ),
    );
  }

  Future<void> addCallRecordingParticipant({
    required int recordingId,
    required String callSessionKey,
    required int callId,
    required DateTime joinedAt,
  }) {
    return _trackWrite('addCallRecordingParticipant', () async {
      final history =
          await (select(callHistoryEntries)
                ..where((table) => table.sessionKey.equals(callSessionKey))
                ..limit(1))
              .getSingleOrNull();
      await into(callRecordingLinks).insertOnConflictUpdate(
        CallRecordingLinksCompanion.insert(
          recordingId: recordingId,
          callSessionKey: callSessionKey,
          callId: callId,
          historyEntryId: Value(history?.id),
          joinedAt: joinedAt,
          leftAt: const Value(null),
        ),
      );
    });
  }

  Future<void> leaveCallRecordingParticipant({
    required int recordingId,
    required String callSessionKey,
    required DateTime leftAt,
  }) {
    return _trackWrite(
      'leaveCallRecordingParticipant',
      () =>
          (update(callRecordingLinks)..where(
                (table) =>
                    table.recordingId.equals(recordingId) &
                    table.callSessionKey.equals(callSessionKey),
              ))
              .write(CallRecordingLinksCompanion(leftAt: Value(leftAt))),
    );
  }

  Future<void> finalizeCallRecording({
    required int id,
    required CallRecordingStatus status,
    required DateTime endedAt,
    required Duration duration,
    required int fileSizeBytes,
    String? relativePath,
    String? failureReason,
  }) {
    return _trackWrite('finalizeCallRecording', () async {
      await (update(
        callRecordings,
      )..where((table) => table.id.equals(id))).write(
        CallRecordingsCompanion(
          status: Value(status.storageKey),
          endedAt: Value(endedAt),
          durationMs: Value(duration.inMilliseconds.clamp(0, 1 << 31).toInt()),
          fileSizeBytes: Value(
            fileSizeBytes.clamp(0, 0x7fffffffffffffff).toInt(),
          ),
          relativePath: relativePath == null
              ? const Value.absent()
              : Value(relativePath),
          failureReason: Value(failureReason),
        ),
      );
      await (update(callRecordingLinks)..where(
            (table) => table.recordingId.equals(id) & table.leftAt.isNull(),
          ))
          .write(CallRecordingLinksCompanion(leftAt: Value(endedAt)));
    });
  }

  Stream<List<CallRecording>> watchRecordingsForHistory(int historyEntryId) {
    final query =
        select(callRecordings).join([
            innerJoin(
              callRecordingLinks,
              callRecordingLinks.recordingId.equalsExp(callRecordings.id),
            ),
          ])
          ..where(callRecordingLinks.historyEntryId.equals(historyEntryId))
          ..orderBy([OrderingTerm.asc(callRecordings.startedAt)]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.readTable(callRecordings).id: row.readTable(callRecordings),
      }.values.toList(),
    );
  }

  /// 一次性监听所有“已有可播放录音”的通话记录 ID。
  ///
  /// 列表页用一条响应式查询生成 Set，避免每一行单独查询录音。
  /// 正在录制、失败或只有 WAV 头的文件不显示“有录音”标识。
  Stream<Set<int>> watchHistoryIdsWithAvailableRecordings() {
    final historyId = callRecordingLinks.historyEntryId;
    final query =
        selectOnly(callRecordingLinks, distinct: true).join([
            innerJoin(
              callRecordings,
              callRecordings.id.equalsExp(callRecordingLinks.recordingId),
            ),
          ])
          ..addColumns([historyId])
          ..where(
            historyId.isNotNull() &
                callRecordings.status.isIn([
                  CallRecordingStatus.completed.storageKey,
                  CallRecordingStatus.interrupted.storageKey,
                ]) &
                callRecordings.fileSizeBytes.isBiggerThanValue(44),
          );
    return query
        .map((row) => row.read(historyId))
        .watch()
        .map((ids) => ids.whereType<int>().toSet());
  }

  Future<List<CallRecording>> listRecordingsForHistory(int historyEntryId) {
    final query =
        select(callRecordings).join([
            innerJoin(
              callRecordingLinks,
              callRecordingLinks.recordingId.equalsExp(callRecordings.id),
            ),
          ])
          ..where(callRecordingLinks.historyEntryId.equals(historyEntryId))
          ..orderBy([OrderingTerm.asc(callRecordings.startedAt)]);
    return query.get().then(
      (rows) => {
        for (final row in rows)
          row.readTable(callRecordings).id: row.readTable(callRecordings),
      }.values.toList(),
    );
  }

  Future<List<CallRecordingLink>> listRecordingParticipants(int recordingId) {
    return (select(callRecordingLinks)
          ..where((table) => table.recordingId.equals(recordingId))
          ..orderBy([(table) => OrderingTerm.asc(table.joinedAt)]))
        .get();
  }

  /// 从一条历史记录解除录音关联。只有它是最后一个历史关联时才返回录音，
  /// 调用方据此删除物理文件，避免删除会议中某一成员记录时误删共享录音。
  Future<List<CallRecording>> unlinkRecordingsFromHistory(int historyEntryId) {
    return _trackWrite('unlinkRecordingsFromHistory', () async {
      final linked = await listRecordingsForHistory(historyEntryId);
      await (update(
        callRecordingLinks,
      )..where((table) => table.historyEntryId.equals(historyEntryId))).write(
        const CallRecordingLinksCompanion(historyEntryId: Value(null)),
      );
      final orphaned = <CallRecording>[];
      for (final recording in linked) {
        final remaining =
            await (selectOnly(callRecordingLinks)
                  ..addColumns([callRecordingLinks.recordingId.count()])
                  ..where(
                    callRecordingLinks.recordingId.equals(recording.id) &
                        callRecordingLinks.historyEntryId.isNotNull(),
                  ))
                .map(
                  (row) =>
                      row.read(callRecordingLinks.recordingId.count()) ?? 0,
                )
                .getSingle();
        if (remaining == 0) orphaned.add(recording);
      }
      return orphaned;
    });
  }

  Future<List<CallRecording>> listAllRecordings() {
    return (select(
      callRecordings,
    )..orderBy([(table) => OrderingTerm.desc(table.startedAt)])).get();
  }

  Future<List<CallRecording>> listUnfinishedRecordings() {
    return (select(callRecordings)..where(
          (table) =>
              table.status.equals(CallRecordingStatus.recording.storageKey),
        ))
        .get();
  }

  Future<void> deleteRecording(int id) {
    return _trackWrite(
      'deleteRecording',
      () => (delete(
        callRecordings,
      )..where((table) => table.id.equals(id))).go().then((_) {}),
    );
  }

  int? _positiveMilliseconds(DateTime? from, DateTime? to) {
    if (from == null || to == null) return null;
    final milliseconds = to.difference(from).inMilliseconds;
    if (milliseconds < 0) return 0;
    return milliseconds.clamp(0, 1 << 31).toInt();
  }

  Future<void> deleteEntry(int id) {
    return _trackWrite(
      'deleteEntry',
      () => (delete(
        callHistoryEntries,
      )..where((table) => table.id.equals(id))).go().then((_) {}),
    );
  }

  Future<void> updateEntryNote(int id, String note) {
    final value = note.trim();
    return _trackWrite(
      'updateEntryNote',
      () => (update(callHistoryEntries)..where((table) => table.id.equals(id)))
          .write(
            CallHistoryEntriesCompanion(
              note: Value(value.isEmpty ? null : value),
            ),
          ),
    );
  }

  Future<void> markMissedCallRead(int id) {
    return _trackWrite(
      'markMissedCallRead',
      () => (update(callHistoryEntries)..where((table) => table.id.equals(id)))
          .write(
            CallHistoryEntriesCompanion(missedReadAt: Value(DateTime.now())),
          ),
    );
  }

  Future<void> markAllMissedCallsRead() {
    return _trackWrite(
      'markAllMissedCallsRead',
      () =>
          (update(callHistoryEntries)..where(
                (table) =>
                    table.direction.equals(
                      CallHistoryDirection.inbound.storageKey,
                    ) &
                    table.status.equals(CallHistoryStatus.missed.storageKey) &
                    table.answeredAt.isNull() &
                    table.missedReadAt.isNull(),
              ))
              .write(
                CallHistoryEntriesCompanion(
                  missedReadAt: Value(DateTime.now()),
                ),
              ),
    );
  }

  Future<void> clearAll() {
    return _trackWrite(
      'clearAll',
      () => delete(callHistoryEntries).go().then((_) {}),
    );
  }

  Future<List<StoredContactRow>> listContacts() async {
    final rows =
        await (select(dbContacts)
              ..where((table) => table.deletedAt.isNull())
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.isFavorite,
                  mode: OrderingMode.desc,
                ),
                (table) => OrderingTerm.asc(table.name),
              ]))
            .get();
    final phones =
        await (select(dbContactPhones)..orderBy([
              (table) => OrderingTerm(
                expression: table.isPrimary,
                mode: OrderingMode.desc,
              ),
              (table) => OrderingTerm.asc(table.id),
            ]))
            .get();
    final phonesByContact = <String, List<DbContactPhone>>{};
    for (final phone in phones) {
      phonesByContact.putIfAbsent(phone.contactId, () => []).add(phone);
    }
    return rows
        .map((row) => _storedContactFromRow(row, phonesByContact[row.id]))
        .toList();
  }

  Future<StoredContactRow?> findContactByPhoneNumber(String phoneNumber) async {
    final normalized = _normalizePhoneNumber(phoneNumber);
    if (normalized.isEmpty) return null;

    final query =
        select(dbContacts).join([
            innerJoin(
              dbContactPhones,
              dbContactPhones.contactId.equalsExp(dbContacts.id),
            ),
          ])
          ..where(
            dbContacts.deletedAt.isNull() &
                dbContactPhones.normalizedNumber.equals(normalized),
          )
          ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final contact = row.readTable(dbContacts);
    final phones =
        await (select(dbContactPhones)
              ..where((table) => table.contactId.equals(contact.id))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.isPrimary,
                  mode: OrderingMode.desc,
                ),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return _storedContactFromRow(contact, phones);
  }

  Future<int> contactCount() {
    final countExpression = dbContacts.id.count();
    final query = selectOnly(dbContacts)
      ..addColumns([countExpression])
      ..where(dbContacts.deletedAt.isNull());
    return query.map((row) => row.read(countExpression) ?? 0).getSingle();
  }

  Future<void> replaceContacts(List<StoredContactRow> contacts) {
    return _trackWrite('replaceContacts', () async {
      await transaction(() async {
        await delete(dbContactPhones).go();
        await delete(dbContacts).go();
        for (final contact in contacts) {
          await _upsertContactRow(contact);
        }
      });
    });
  }

  Future<void> upsertContact(StoredContactRow contact) {
    return _trackWrite('upsertContact', () async {
      await transaction(() async {
        await _upsertContactRow(contact);
      });
    });
  }

  Future<void> _upsertContactRow(StoredContactRow contact) async {
    final phones = _normalizedStoredPhones(contact);
    final primaryPhone = phones.first;
    final normalized = _normalizePhoneNumber(primaryPhone.number);
    await into(dbContacts).insertOnConflictUpdate(
      DbContactsCompanion.insert(
        id: contact.id,
        name: contact.name,
        number: primaryPhone.number,
        normalizedNumber: normalized,
        company: Value(contact.company),
        department: Value(contact.department),
        remark: Value(contact.remark),
        isFavorite: Value(contact.isFavorite),
        createdAt: contact.createdAt,
        updatedAt: Value(contact.updatedAt),
        deletedAt: const Value(null),
      ),
    );
    await (delete(
      dbContactPhones,
    )..where((table) => table.contactId.equals(contact.id))).go();
    for (final phone in phones) {
      await into(dbContactPhones).insert(
        DbContactPhonesCompanion.insert(
          contactId: contact.id,
          label: Value(phone.label),
          number: phone.number,
          normalizedNumber: _normalizePhoneNumber(phone.number),
          isPrimary: Value(phone.isPrimary),
          createdAt: contact.createdAt,
        ),
      );
    }
    await _syncCallHistoryContactSnapshot(
      contact,
      phones.map((phone) => _normalizePhoneNumber(phone.number)).toSet(),
    );
  }

  Future<void> _syncCallHistoryContactSnapshot(
    StoredContactRow contact,
    Set<String> normalizedNumbers,
  ) async {
    final effectiveNumbers = normalizedNumbers
        .where((number) => number.isNotEmpty)
        .toSet();
    final updater = update(callHistoryEntries)
      ..where(
        (table) => effectiveNumbers.isEmpty
            ? table.contactId.equals(contact.id)
            : table.contactId.equals(contact.id) |
                  table.phoneNumber.isIn(effectiveNumbers),
      );
    await updater.write(
      CallHistoryEntriesCompanion(
        displayName: Value(contact.name),
        contactId: Value(contact.id),
      ),
    );
  }

  Future<void> deleteContact(String id) {
    return _trackWrite('deleteContact', () async {
      await transaction(() async {
        await (delete(
          dbContactPhones,
        )..where((table) => table.contactId.equals(id))).go();
        await (delete(dbContacts)..where((table) => table.id.equals(id))).go();
      });
    });
  }

  Future<void> deleteContacts(Set<String> ids) {
    if (ids.isEmpty) return Future<void>.value();
    return _trackWrite('deleteContacts', () async {
      await transaction(() async {
        await (delete(
          dbContactPhones,
        )..where((table) => table.contactId.isIn(ids))).go();
        await (delete(dbContacts)..where((table) => table.id.isIn(ids))).go();
      });
    });
  }

  /// Registers one database mutation so app shutdown can wait for every write
  /// that was accepted before the database starts closing.
  Future<T> _trackWrite<T>(String operation, Future<T> Function() action) {
    if (!_acceptingWrites) {
      return Future<T>.error(
        StateError('Database is closing; rejected write: $operation'),
      );
    }

    final completion = Completer<void>();
    final token = completion.future;
    _pendingWrites.add(token);

    late final Future<T> result;
    try {
      result = Future<T>.sync(action);
    } catch (error, stackTrace) {
      _pendingWrites.remove(token);
      completion.complete();
      return Future<T>.error(error, stackTrace);
    }

    unawaited(
      result.then<void>(
        (_) {
          _pendingWrites.remove(token);
          if (!completion.isCompleted) completion.complete();
        },
        onError: (Object _, StackTrace _) {
          _pendingWrites.remove(token);
          if (!completion.isCompleted) completion.complete();
        },
      ),
    );
    return result;
  }

  /// Waits until all writes accepted before shutdown have reached SQLite.
  Future<void> waitForPendingWrites() async {
    while (_pendingWrites.isNotEmpty) {
      await Future.wait<void>(List<Future<void>>.of(_pendingWrites));
    }
  }

  /// 为进程退出准备数据库，但不主动关闭 SQLite 原生连接。
  ///
  /// 退出时 Flutter engine 与 Drift 后台 isolate 会同时进入销毁阶段。在 macOS
  /// 上显式调用 [close] 可能让 `sqlite3_close` 与 isolate/native finalizer 竞态，
  /// 进而触发 EXC_BAD_ACCESS。这里先拒绝新写入并等待已接收事务完成，数据已经
  /// 按 SQLite 事务语义落盘；随后由操作系统随进程统一回收连接资源。
  Future<void> prepareForProcessExit() {
    return _processExitPreparationFuture ??= _prepareForProcessExit();
  }

  Future<void> _prepareForProcessExit() async {
    _acceptingWrites = false;
    await waitForPendingWrites();
  }

  @override
  Future<void> close() {
    return _closeFuture ??= _closeGracefully();
  }

  Future<void> _closeGracefully() async {
    await prepareForProcessExit();
    await super.close();
  }

  List<StoredContactPhoneRow> _normalizedStoredPhones(
    StoredContactRow contact,
  ) {
    final phones = <StoredContactPhoneRow>[];
    for (final phone in contact.phones) {
      final number = phone.number.trim();
      if (number.isEmpty) continue;
      phones.add(
        StoredContactPhoneRow(
          label: phone.label.trim().isEmpty ? '默认' : phone.label.trim(),
          number: number,
          isPrimary: phone.isPrimary,
        ),
      );
    }
    final primaryNumber = contact.number.trim();
    if (primaryNumber.isNotEmpty &&
        !phones.any((phone) => phone.number == primaryNumber)) {
      phones.insert(
        0,
        StoredContactPhoneRow(
          label: '默认',
          number: primaryNumber,
          isPrimary: true,
        ),
      );
    }
    if (phones.isEmpty) {
      phones.add(
        const StoredContactPhoneRow(label: '默认', number: '', isPrimary: true),
      );
    }
    final primaryIndex = phones.indexWhere((phone) => phone.isPrimary);
    return [
      for (var index = 0; index < phones.length; index++)
        StoredContactPhoneRow(
          label: phones[index].label,
          number: phones[index].number,
          isPrimary: primaryIndex == -1 ? index == 0 : index == primaryIndex,
        ),
    ]..sort((a, b) {
      if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
      return 0;
    });
  }

  StoredContactRow _storedContactFromRow(
    DbContact row, [
    List<DbContactPhone>? phones,
  ]) {
    return StoredContactRow(
      id: row.id,
      name: row.name,
      number: row.number,
      phones: (phones == null || phones.isEmpty)
          ? [
              StoredContactPhoneRow(
                label: '默认',
                number: row.number,
                isPrimary: true,
              ),
            ]
          : phones
                .map(
                  (phone) => StoredContactPhoneRow(
                    label: phone.label,
                    number: phone.number,
                    isPrimary: phone.isPrimary,
                  ),
                )
                .toList(),
      company: row.company,
      department: row.department,
      remark: row.remark,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

String _normalizePhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+*#]'), '');
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final appDirectory = Directory(
      p.join(directory.path, appStorageDirectoryName),
    );
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    final file = File(p.join(appDirectory.path, 'call_history.sqlite'));

    // Drift 默认会缓存 sqlite3_stmt 以复用相同 SQL。macOS 上存在低频的
    // sqlite3_finalize / EXC_BAD_ACCESS 上游问题，且发生在线程和调用栈与本项目
    // 收集到的崩溃一致：https://github.com/simolus3/drift/issues/3771
    //
    // 在官方明确修复前，仅对 macOS 关闭 prepared statement 缓存，缩短 native
    // statement 的持有和复用周期；后台数据库 isolate 仍然保留，Windows/Linux
    // 也继续使用 Drift 默认缓存，避免扩大此次规避措施的影响范围。
    return NativeDatabase.createInBackground(
      file,
      cachePreparedStatements: !Platform.isMacOS,
    );
  });
}

final callHistoryDatabaseProvider = Provider<CallHistoryDatabase>((ref) {
  final database = CallHistoryDatabase();
  // 这是应用级数据库单例，整个进程只创建一次。
  //
  // 不把 close 绑定到 Provider dispose，是为了避免页面/ProviderScope 生命周期
  // 干扰正在执行的通话记录写入。真正退出应用时，由
  // AppShutdownCoordinator 只等待已接收写入完成，不在进程退出阶段显式
  // sqlite3_close。macOS 上后台 Drift isolate 与 Flutter engine 同时销毁时，
  // 主动关闭原生连接存在低频竞态；进程退出后由系统统一回收资源更可靠。
  return database;
});
