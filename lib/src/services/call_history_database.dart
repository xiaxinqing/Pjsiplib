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

class CallHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get callId => integer()();
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

@DriftDatabase(tables: [CallHistoryEntries, DbContacts, DbContactPhones])
class CallHistoryDatabase extends _$CallHistoryDatabase {
  CallHistoryDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
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
    return into(callHistoryEntries).insert(entry).then((_) {});
  }

  Future<void> recordCall({
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
    return addEntry(
      CallHistoryEntriesCompanion.insert(
        callId: callId,
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
  }

  int? _positiveMilliseconds(DateTime? from, DateTime? to) {
    if (from == null || to == null) return null;
    final milliseconds = to.difference(from).inMilliseconds;
    if (milliseconds < 0) return 0;
    return milliseconds.clamp(0, 1 << 31).toInt();
  }

  Future<void> deleteEntry(int id) {
    return (delete(
      callHistoryEntries,
    )..where((table) => table.id.equals(id))).go().then((_) {});
  }

  Future<void> updateEntryNote(int id, String note) {
    final value = note.trim();
    return (update(
      callHistoryEntries,
    )..where((table) => table.id.equals(id))).write(
      CallHistoryEntriesCompanion(note: Value(value.isEmpty ? null : value)),
    );
  }

  Future<void> markMissedCallRead(int id) {
    return (update(
      callHistoryEntries,
    )..where((table) => table.id.equals(id))).write(
      CallHistoryEntriesCompanion(missedReadAt: Value(DateTime.now())),
    );
  }

  Future<void> markAllMissedCallsRead() {
    return (update(callHistoryEntries)..where(
          (table) =>
              table.direction.equals(CallHistoryDirection.inbound.storageKey) &
              table.status.equals(CallHistoryStatus.missed.storageKey) &
              table.answeredAt.isNull() &
              table.missedReadAt.isNull(),
        ))
        .write(
          CallHistoryEntriesCompanion(missedReadAt: Value(DateTime.now())),
        );
  }

  Future<void> clearAll() {
    return delete(callHistoryEntries).go().then((_) {});
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

  Future<void> replaceContacts(List<StoredContactRow> contacts) async {
    await transaction(() async {
      await delete(dbContactPhones).go();
      await delete(dbContacts).go();
      for (final contact in contacts) {
        await _upsertContactRow(contact);
      }
    });
  }

  Future<void> upsertContact(StoredContactRow contact) async {
    await transaction(() async {
      await _upsertContactRow(contact);
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

  Future<void> deleteContact(String id) async {
    await transaction(() async {
      await (delete(
        dbContactPhones,
      )..where((table) => table.contactId.equals(id))).go();
      await (delete(dbContacts)..where((table) => table.id.equals(id))).go();
    });
  }

  Future<void> deleteContacts(Set<String> ids) async {
    if (ids.isEmpty) return;
    await transaction(() async {
      await (delete(
        dbContactPhones,
      )..where((table) => table.contactId.isIn(ids))).go();
      await (delete(dbContacts)..where((table) => table.id.isIn(ids))).go();
    });
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
    return NativeDatabase.createInBackground(file);
  });
}

final callHistoryDatabaseProvider = Provider<CallHistoryDatabase>((ref) {
  final database = CallHistoryDatabase();
  ref.onDispose(database.close);
  return database;
});
