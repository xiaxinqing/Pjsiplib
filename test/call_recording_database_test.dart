import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/call_history_database.dart';

void main() {
  group('call recording metadata', () {
    late CallHistoryDatabase database;

    setUp(() {
      database = CallHistoryDatabase(NativeDatabase.memory());
    });

    tearDown(() => database.close());

    test(
      'links a recording when recording metadata is written first',
      () async {
        final startedAt = DateTime(2026, 8, 14, 9, 30);
        const sessionKey = 'recording-first-7';
        final recordingId = await database.beginCallRecording(
          sessionKey: sessionKey,
          callId: 7,
          relativePath: '2026/08/recording-first-7.partial.wav',
          startedAt: startedAt,
        );

        final historyId = await database.recordCall(
          callId: 7,
          direction: CallHistoryDirection.outbound,
          status: CallHistoryStatus.completed,
          remoteUri: 'sip:10086@pbx.example.com',
          phoneNumber: '10086',
          startedAt: startedAt,
          answeredAt: startedAt.add(const Duration(seconds: 2)),
          endedAt: startedAt.add(const Duration(seconds: 32)),
          recordingSessionKey: sessionKey,
        );
        await database.finalizeCallRecording(
          id: recordingId,
          status: CallRecordingStatus.completed,
          endedAt: startedAt.add(const Duration(seconds: 30)),
          duration: const Duration(seconds: 30),
          fileSizeBytes: 480044,
          relativePath: '2026/08/recording-first-7.wav',
        );

        final recordings = await database.listRecordingsForHistory(historyId);
        final historyIdsWithRecording = await database
            .watchHistoryIdsWithAvailableRecordings()
            .first;
        expect(recordings, hasLength(1));
        expect(recordings.single.id, recordingId);
        expect(recordings.single.historyEntryId, historyId);
        expect(
          recordings.single.status,
          CallRecordingStatus.completed.storageKey,
        );
        expect(recordings.single.durationMs, 30000);
        expect(recordings.single.fileSizeBytes, 480044);
        expect(recordings.single.relativePath, '2026/08/recording-first-7.wav');
        expect(historyIdsWithRecording, contains(historyId));
      },
    );

    test('links a recording when call history is written first', () async {
      final startedAt = DateTime(2026, 8, 14, 10);
      const sessionKey = 'history-first-8';
      final historyId = await database.recordCall(
        callId: 8,
        direction: CallHistoryDirection.inbound,
        status: CallHistoryStatus.completed,
        remoteUri: 'sip:10010@pbx.example.com',
        phoneNumber: '10010',
        startedAt: startedAt,
        answeredAt: startedAt.add(const Duration(seconds: 1)),
        endedAt: startedAt.add(const Duration(seconds: 11)),
        recordingSessionKey: sessionKey,
      );

      final recordingId = await database.beginCallRecording(
        sessionKey: sessionKey,
        callId: 8,
        relativePath: '2026/08/history-first-8.partial.wav',
        startedAt: startedAt.add(const Duration(seconds: 1)),
      );

      final recordings = await database.listRecordingsForHistory(historyId);
      final historyIdsWithRecording = await database
          .watchHistoryIdsWithAvailableRecordings()
          .first;
      expect(recordings, hasLength(1));
      expect(recordings.single.id, recordingId);
      expect(recordings.single.historyEntryId, historyId);
      expect(
        recordings.single.status,
        CallRecordingStatus.recording.storageKey,
      );
      expect(historyIdsWithRecording, isNot(contains(historyId)));
    });

    test('one conference recording links every participant history', () async {
      final startedAt = DateTime(2026, 8, 14, 11);
      const recordingSessionKey = 'call-a';
      const participantBSessionKey = 'call-b';
      final recordingId = await database.beginCallRecording(
        sessionKey: recordingSessionKey,
        participantSessionKey: recordingSessionKey,
        callId: 10,
        relativePath: '2026/08/conference.partial.wav',
        startedAt: startedAt,
      );
      await database.promoteCallRecordingToConference(recordingId);
      await database.addCallRecordingParticipant(
        recordingId: recordingId,
        callSessionKey: participantBSessionKey,
        callId: 11,
        joinedAt: startedAt.add(const Duration(seconds: 20)),
      );
      await database.leaveCallRecordingParticipant(
        recordingId: recordingId,
        callSessionKey: participantBSessionKey,
        leftAt: startedAt.add(const Duration(seconds: 50)),
      );

      final historyA = await database.recordCall(
        callId: 10,
        direction: CallHistoryDirection.outbound,
        status: CallHistoryStatus.completed,
        remoteUri: 'sip:a@pbx.example.com',
        phoneNumber: 'A',
        startedAt: startedAt,
        answeredAt: startedAt,
        endedAt: startedAt.add(const Duration(seconds: 60)),
        recordingSessionKey: recordingSessionKey,
      );
      final historyB = await database.recordCall(
        callId: 11,
        direction: CallHistoryDirection.outbound,
        status: CallHistoryStatus.completed,
        remoteUri: 'sip:b@pbx.example.com',
        phoneNumber: 'B',
        startedAt: startedAt.add(const Duration(seconds: 10)),
        answeredAt: startedAt.add(const Duration(seconds: 10)),
        endedAt: startedAt.add(const Duration(seconds: 50)),
        recordingSessionKey: participantBSessionKey,
      );
      await database.finalizeCallRecording(
        id: recordingId,
        status: CallRecordingStatus.completed,
        endedAt: startedAt.add(const Duration(seconds: 60)),
        duration: const Duration(seconds: 60),
        fileSizeBytes: 960044,
        relativePath: '2026/08/conference.wav',
      );

      final recordingsA = await database.listRecordingsForHistory(historyA);
      final recordingsB = await database.listRecordingsForHistory(historyB);
      final participants = await database.listRecordingParticipants(
        recordingId,
      );
      final historyIds = await database
          .watchHistoryIdsWithAvailableRecordings()
          .first;

      expect(recordingsA.single.id, recordingId);
      expect(recordingsB.single.id, recordingId);
      expect(recordingsA.single.kind, CallRecordingKind.conference.storageKey);
      expect(participants, hasLength(2));
      expect(
        participants
            .singleWhere(
              (participant) =>
                  participant.callSessionKey == participantBSessionKey,
            )
            .leftAt,
        startedAt.add(const Duration(seconds: 50)),
      );
      expect(historyIds, containsAll(<int>{historyA, historyB}));

      expect(await database.unlinkRecordingsFromHistory(historyB), isEmpty);
      expect(await database.listRecordingsForHistory(historyA), hasLength(1));
      expect(
        await database.unlinkRecordingsFromHistory(historyA),
        contains(
          isA<CallRecording>().having((row) => row.id, 'id', recordingId),
        ),
      );
    });
  });

  group('call recording migration', () {
    test('upgrades a version 6 database directly to version 8', () async {
      final database = CallHistoryDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute(
              'CREATE TABLE call_history_entries '
              '(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)',
            );
            raw.execute('PRAGMA user_version = 6');
          },
        ),
      );
      addTearDown(database.close);

      final recordingColumns = await database
          .customSelect('PRAGMA table_info(call_recordings)')
          .get();
      final linkColumns = await database
          .customSelect('PRAGMA table_info(call_recording_links)')
          .get();

      expect(
        recordingColumns.map((row) => row.read<String>('name')),
        contains('kind'),
      );
      expect(linkColumns, isNotEmpty);
    });

    test(
      'resumes the partially completed version 6 recording migration',
      () async {
        final database = CallHistoryDatabase(
          NativeDatabase.memory(
            setup: (raw) {
              // 复现线上状态：ALTER session_key 和 call_recordings 已落盘，
              // 但后续步骤失败，因此 user_version 仍停在 6。
              raw.execute('''
              CREATE TABLE call_history_entries (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                session_key TEXT NULL
              )
            ''');
              raw.execute('''
              CREATE TABLE call_recordings (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                history_entry_id INTEGER NULL,
                session_key TEXT NOT NULL,
                call_id INTEGER NOT NULL,
                relative_path TEXT NOT NULL,
                status TEXT NOT NULL,
                format TEXT NOT NULL DEFAULT 'wav',
                started_at INTEGER NOT NULL,
                ended_at INTEGER NULL,
                duration_ms INTEGER NOT NULL DEFAULT 0,
                file_size_bytes INTEGER NOT NULL DEFAULT 0,
                failure_reason TEXT NULL,
                created_at INTEGER NOT NULL
              )
            ''');
              raw.execute(
                "INSERT INTO call_recordings "
                "(session_key, call_id, relative_path, status, started_at, created_at) "
                "VALUES ('partial-call', 21, 'partial.wav', 'completed', 1, 1)",
              );
              raw.execute('PRAGMA user_version = 6');
            },
          ),
        );
        addTearDown(database.close);

        final recordings = await database.listAllRecordings();
        final links = await database
            .customSelect('SELECT call_session_key FROM call_recording_links')
            .get();
        final version = await database
            .customSelect('PRAGMA user_version')
            .map((row) => row.read<int>('user_version'))
            .getSingle();

        expect(version, 8);
        expect(recordings.single.sessionKey, 'partial-call');
        expect(recordings.single.kind, CallRecordingKind.single.storageKey);
        expect(links.single.read<String>('call_session_key'), 'partial-call');
      },
    );

    test(
      'preserves version 7 recordings when creating participant links',
      () async {
        final database = CallHistoryDatabase(
          NativeDatabase.memory(
            setup: (raw) {
              raw.execute(
                'CREATE TABLE call_history_entries '
                '(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)',
              );
              raw.execute('''
              CREATE TABLE call_recordings (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                history_entry_id INTEGER NULL,
                session_key TEXT NOT NULL,
                call_id INTEGER NOT NULL,
                relative_path TEXT NOT NULL,
                status TEXT NOT NULL,
                format TEXT NOT NULL DEFAULT 'wav',
                started_at INTEGER NOT NULL,
                ended_at INTEGER NULL,
                duration_ms INTEGER NOT NULL DEFAULT 0,
                file_size_bytes INTEGER NOT NULL DEFAULT 0,
                failure_reason TEXT NULL,
                created_at INTEGER NOT NULL
              )
            ''');
              raw.execute(
                "INSERT INTO call_recordings "
                "(session_key, call_id, relative_path, status, started_at, created_at) "
                "VALUES ('legacy-call', 12, 'legacy.wav', 'completed', 1, 1)",
              );
              raw.execute('PRAGMA user_version = 7');
            },
          ),
        );
        addTearDown(database.close);

        final links = await database
            .customSelect('SELECT call_session_key FROM call_recording_links')
            .get();
        final recordings = await database.listAllRecordings();

        expect(links.single.read<String>('call_session_key'), 'legacy-call');
        expect(recordings.single.kind, CallRecordingKind.single.storageKey);
      },
    );
  });
}
