// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_history_database.dart';

// ignore_for_file: type=lint
class $CallHistoryEntriesTable extends CallHistoryEntries
    with TableInfo<$CallHistoryEntriesTable, CallHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<int> callId = GeneratedColumn<int>(
    'call_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionKeyMeta = const VerificationMeta(
    'sessionKey',
  );
  @override
  late final GeneratedColumn<String> sessionKey = GeneratedColumn<String>(
    'session_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUriMeta = const VerificationMeta(
    'remoteUri',
  );
  @override
  late final GeneratedColumn<String> remoteUri = GeneratedColumn<String>(
    'remote_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountLabelMeta = const VerificationMeta(
    'accountLabel',
  );
  @override
  late final GeneratedColumn<String> accountLabel = GeneratedColumn<String>(
    'account_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ringingAtMeta = const VerificationMeta(
    'ringingAt',
  );
  @override
  late final GeneratedColumn<DateTime> ringingAt = GeneratedColumn<DateTime>(
    'ringing_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaConnectedAtMeta = const VerificationMeta(
    'mediaConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> mediaConnectedAt =
      GeneratedColumn<DateTime>(
        'media_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ringSecondsMeta = const VerificationMeta(
    'ringSeconds',
  );
  @override
  late final GeneratedColumn<int> ringSeconds = GeneratedColumn<int>(
    'ring_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timeToRingingMsMeta = const VerificationMeta(
    'timeToRingingMs',
  );
  @override
  late final GeneratedColumn<int> timeToRingingMs = GeneratedColumn<int>(
    'time_to_ringing_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ringingToAnswerMsMeta = const VerificationMeta(
    'ringingToAnswerMs',
  );
  @override
  late final GeneratedColumn<int> ringingToAnswerMs = GeneratedColumn<int>(
    'ringing_to_answer_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerToMediaMsMeta = const VerificationMeta(
    'answerToMediaMs',
  );
  @override
  late final GeneratedColumn<int> answerToMediaMs = GeneratedColumn<int>(
    'answer_to_media_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdCountMeta = const VerificationMeta(
    'holdCount',
  );
  @override
  late final GeneratedColumn<int> holdCount = GeneratedColumn<int>(
    'hold_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _holdSecondsMeta = const VerificationMeta(
    'holdSeconds',
  );
  @override
  late final GeneratedColumn<int> holdSeconds = GeneratedColumn<int>(
    'hold_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sipStatusCodeMeta = const VerificationMeta(
    'sipStatusCode',
  );
  @override
  late final GeneratedColumn<int> sipStatusCode = GeneratedColumn<int>(
    'sip_status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hangupReasonMeta = const VerificationMeta(
    'hangupReason',
  );
  @override
  late final GeneratedColumn<String> hangupReason = GeneratedColumn<String>(
    'hangup_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _missedReadAtMeta = const VerificationMeta(
    'missedReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> missedReadAt = GeneratedColumn<DateTime>(
    'missed_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callId,
    sessionKey,
    direction,
    status,
    remoteUri,
    phoneNumber,
    displayName,
    contactId,
    accountId,
    accountLabel,
    startedAt,
    ringingAt,
    answeredAt,
    mediaConnectedAt,
    endedAt,
    durationSeconds,
    ringSeconds,
    timeToRingingMs,
    ringingToAnswerMs,
    answerToMediaMs,
    holdCount,
    holdSeconds,
    sipStatusCode,
    hangupReason,
    note,
    missedReadAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('call_id')) {
      context.handle(
        _callIdMeta,
        callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('session_key')) {
      context.handle(
        _sessionKeyMeta,
        sessionKey.isAcceptableOrUnknown(data['session_key']!, _sessionKeyMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('remote_uri')) {
      context.handle(
        _remoteUriMeta,
        remoteUri.isAcceptableOrUnknown(data['remote_uri']!, _remoteUriMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteUriMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('account_label')) {
      context.handle(
        _accountLabelMeta,
        accountLabel.isAcceptableOrUnknown(
          data['account_label']!,
          _accountLabelMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ringing_at')) {
      context.handle(
        _ringingAtMeta,
        ringingAt.isAcceptableOrUnknown(data['ringing_at']!, _ringingAtMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    if (data.containsKey('media_connected_at')) {
      context.handle(
        _mediaConnectedAtMeta,
        mediaConnectedAt.isAcceptableOrUnknown(
          data['media_connected_at']!,
          _mediaConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('ring_seconds')) {
      context.handle(
        _ringSecondsMeta,
        ringSeconds.isAcceptableOrUnknown(
          data['ring_seconds']!,
          _ringSecondsMeta,
        ),
      );
    }
    if (data.containsKey('time_to_ringing_ms')) {
      context.handle(
        _timeToRingingMsMeta,
        timeToRingingMs.isAcceptableOrUnknown(
          data['time_to_ringing_ms']!,
          _timeToRingingMsMeta,
        ),
      );
    }
    if (data.containsKey('ringing_to_answer_ms')) {
      context.handle(
        _ringingToAnswerMsMeta,
        ringingToAnswerMs.isAcceptableOrUnknown(
          data['ringing_to_answer_ms']!,
          _ringingToAnswerMsMeta,
        ),
      );
    }
    if (data.containsKey('answer_to_media_ms')) {
      context.handle(
        _answerToMediaMsMeta,
        answerToMediaMs.isAcceptableOrUnknown(
          data['answer_to_media_ms']!,
          _answerToMediaMsMeta,
        ),
      );
    }
    if (data.containsKey('hold_count')) {
      context.handle(
        _holdCountMeta,
        holdCount.isAcceptableOrUnknown(data['hold_count']!, _holdCountMeta),
      );
    }
    if (data.containsKey('hold_seconds')) {
      context.handle(
        _holdSecondsMeta,
        holdSeconds.isAcceptableOrUnknown(
          data['hold_seconds']!,
          _holdSecondsMeta,
        ),
      );
    }
    if (data.containsKey('sip_status_code')) {
      context.handle(
        _sipStatusCodeMeta,
        sipStatusCode.isAcceptableOrUnknown(
          data['sip_status_code']!,
          _sipStatusCodeMeta,
        ),
      );
    }
    if (data.containsKey('hangup_reason')) {
      context.handle(
        _hangupReasonMeta,
        hangupReason.isAcceptableOrUnknown(
          data['hangup_reason']!,
          _hangupReasonMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('missed_read_at')) {
      context.handle(
        _missedReadAtMeta,
        missedReadAt.isAcceptableOrUnknown(
          data['missed_read_at']!,
          _missedReadAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      callId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_id'],
      )!,
      sessionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_key'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      remoteUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_uri'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      accountLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_label'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      ringingAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ringing_at'],
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
      mediaConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}media_connected_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      ringSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ring_seconds'],
      )!,
      timeToRingingMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_to_ringing_ms'],
      ),
      ringingToAnswerMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ringing_to_answer_ms'],
      ),
      answerToMediaMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answer_to_media_ms'],
      ),
      holdCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_count'],
      )!,
      holdSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_seconds'],
      )!,
      sipStatusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sip_status_code'],
      ),
      hangupReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hangup_reason'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      missedReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}missed_read_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CallHistoryEntriesTable createAlias(String alias) {
    return $CallHistoryEntriesTable(attachedDatabase, alias);
  }
}

class CallHistoryEntry extends DataClass
    implements Insertable<CallHistoryEntry> {
  final int id;
  final int callId;
  final String? sessionKey;
  final String direction;
  final String status;
  final String remoteUri;
  final String phoneNumber;
  final String? displayName;
  final String? contactId;
  final int? accountId;
  final String? accountLabel;
  final DateTime startedAt;
  final DateTime? ringingAt;
  final DateTime? answeredAt;
  final DateTime? mediaConnectedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int ringSeconds;
  final int? timeToRingingMs;
  final int? ringingToAnswerMs;
  final int? answerToMediaMs;
  final int holdCount;
  final int holdSeconds;
  final int? sipStatusCode;
  final String? hangupReason;
  final String? note;
  final DateTime? missedReadAt;
  final DateTime createdAt;
  const CallHistoryEntry({
    required this.id,
    required this.callId,
    this.sessionKey,
    required this.direction,
    required this.status,
    required this.remoteUri,
    required this.phoneNumber,
    this.displayName,
    this.contactId,
    this.accountId,
    this.accountLabel,
    required this.startedAt,
    this.ringingAt,
    this.answeredAt,
    this.mediaConnectedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.ringSeconds,
    this.timeToRingingMs,
    this.ringingToAnswerMs,
    this.answerToMediaMs,
    required this.holdCount,
    required this.holdSeconds,
    this.sipStatusCode,
    this.hangupReason,
    this.note,
    this.missedReadAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['call_id'] = Variable<int>(callId);
    if (!nullToAbsent || sessionKey != null) {
      map['session_key'] = Variable<String>(sessionKey);
    }
    map['direction'] = Variable<String>(direction);
    map['status'] = Variable<String>(status);
    map['remote_uri'] = Variable<String>(remoteUri);
    map['phone_number'] = Variable<String>(phoneNumber);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<String>(contactId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || accountLabel != null) {
      map['account_label'] = Variable<String>(accountLabel);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || ringingAt != null) {
      map['ringing_at'] = Variable<DateTime>(ringingAt);
    }
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    if (!nullToAbsent || mediaConnectedAt != null) {
      map['media_connected_at'] = Variable<DateTime>(mediaConnectedAt);
    }
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['ring_seconds'] = Variable<int>(ringSeconds);
    if (!nullToAbsent || timeToRingingMs != null) {
      map['time_to_ringing_ms'] = Variable<int>(timeToRingingMs);
    }
    if (!nullToAbsent || ringingToAnswerMs != null) {
      map['ringing_to_answer_ms'] = Variable<int>(ringingToAnswerMs);
    }
    if (!nullToAbsent || answerToMediaMs != null) {
      map['answer_to_media_ms'] = Variable<int>(answerToMediaMs);
    }
    map['hold_count'] = Variable<int>(holdCount);
    map['hold_seconds'] = Variable<int>(holdSeconds);
    if (!nullToAbsent || sipStatusCode != null) {
      map['sip_status_code'] = Variable<int>(sipStatusCode);
    }
    if (!nullToAbsent || hangupReason != null) {
      map['hangup_reason'] = Variable<String>(hangupReason);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || missedReadAt != null) {
      map['missed_read_at'] = Variable<DateTime>(missedReadAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CallHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return CallHistoryEntriesCompanion(
      id: Value(id),
      callId: Value(callId),
      sessionKey: sessionKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionKey),
      direction: Value(direction),
      status: Value(status),
      remoteUri: Value(remoteUri),
      phoneNumber: Value(phoneNumber),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      accountLabel: accountLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(accountLabel),
      startedAt: Value(startedAt),
      ringingAt: ringingAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ringingAt),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
      mediaConnectedAt: mediaConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaConnectedAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      ringSeconds: Value(ringSeconds),
      timeToRingingMs: timeToRingingMs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeToRingingMs),
      ringingToAnswerMs: ringingToAnswerMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ringingToAnswerMs),
      answerToMediaMs: answerToMediaMs == null && nullToAbsent
          ? const Value.absent()
          : Value(answerToMediaMs),
      holdCount: Value(holdCount),
      holdSeconds: Value(holdSeconds),
      sipStatusCode: sipStatusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(sipStatusCode),
      hangupReason: hangupReason == null && nullToAbsent
          ? const Value.absent()
          : Value(hangupReason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      missedReadAt: missedReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(missedReadAt),
      createdAt: Value(createdAt),
    );
  }

  factory CallHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      callId: serializer.fromJson<int>(json['callId']),
      sessionKey: serializer.fromJson<String?>(json['sessionKey']),
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String>(json['status']),
      remoteUri: serializer.fromJson<String>(json['remoteUri']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      accountLabel: serializer.fromJson<String?>(json['accountLabel']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      ringingAt: serializer.fromJson<DateTime?>(json['ringingAt']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
      mediaConnectedAt: serializer.fromJson<DateTime?>(
        json['mediaConnectedAt'],
      ),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      ringSeconds: serializer.fromJson<int>(json['ringSeconds']),
      timeToRingingMs: serializer.fromJson<int?>(json['timeToRingingMs']),
      ringingToAnswerMs: serializer.fromJson<int?>(json['ringingToAnswerMs']),
      answerToMediaMs: serializer.fromJson<int?>(json['answerToMediaMs']),
      holdCount: serializer.fromJson<int>(json['holdCount']),
      holdSeconds: serializer.fromJson<int>(json['holdSeconds']),
      sipStatusCode: serializer.fromJson<int?>(json['sipStatusCode']),
      hangupReason: serializer.fromJson<String?>(json['hangupReason']),
      note: serializer.fromJson<String?>(json['note']),
      missedReadAt: serializer.fromJson<DateTime?>(json['missedReadAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'callId': serializer.toJson<int>(callId),
      'sessionKey': serializer.toJson<String?>(sessionKey),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String>(status),
      'remoteUri': serializer.toJson<String>(remoteUri),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'displayName': serializer.toJson<String?>(displayName),
      'contactId': serializer.toJson<String?>(contactId),
      'accountId': serializer.toJson<int?>(accountId),
      'accountLabel': serializer.toJson<String?>(accountLabel),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'ringingAt': serializer.toJson<DateTime?>(ringingAt),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
      'mediaConnectedAt': serializer.toJson<DateTime?>(mediaConnectedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'ringSeconds': serializer.toJson<int>(ringSeconds),
      'timeToRingingMs': serializer.toJson<int?>(timeToRingingMs),
      'ringingToAnswerMs': serializer.toJson<int?>(ringingToAnswerMs),
      'answerToMediaMs': serializer.toJson<int?>(answerToMediaMs),
      'holdCount': serializer.toJson<int>(holdCount),
      'holdSeconds': serializer.toJson<int>(holdSeconds),
      'sipStatusCode': serializer.toJson<int?>(sipStatusCode),
      'hangupReason': serializer.toJson<String?>(hangupReason),
      'note': serializer.toJson<String?>(note),
      'missedReadAt': serializer.toJson<DateTime?>(missedReadAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CallHistoryEntry copyWith({
    int? id,
    int? callId,
    Value<String?> sessionKey = const Value.absent(),
    String? direction,
    String? status,
    String? remoteUri,
    String? phoneNumber,
    Value<String?> displayName = const Value.absent(),
    Value<String?> contactId = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    Value<String?> accountLabel = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> ringingAt = const Value.absent(),
    Value<DateTime?> answeredAt = const Value.absent(),
    Value<DateTime?> mediaConnectedAt = const Value.absent(),
    DateTime? endedAt,
    int? durationSeconds,
    int? ringSeconds,
    Value<int?> timeToRingingMs = const Value.absent(),
    Value<int?> ringingToAnswerMs = const Value.absent(),
    Value<int?> answerToMediaMs = const Value.absent(),
    int? holdCount,
    int? holdSeconds,
    Value<int?> sipStatusCode = const Value.absent(),
    Value<String?> hangupReason = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<DateTime?> missedReadAt = const Value.absent(),
    DateTime? createdAt,
  }) => CallHistoryEntry(
    id: id ?? this.id,
    callId: callId ?? this.callId,
    sessionKey: sessionKey.present ? sessionKey.value : this.sessionKey,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    remoteUri: remoteUri ?? this.remoteUri,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    displayName: displayName.present ? displayName.value : this.displayName,
    contactId: contactId.present ? contactId.value : this.contactId,
    accountId: accountId.present ? accountId.value : this.accountId,
    accountLabel: accountLabel.present ? accountLabel.value : this.accountLabel,
    startedAt: startedAt ?? this.startedAt,
    ringingAt: ringingAt.present ? ringingAt.value : this.ringingAt,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
    mediaConnectedAt: mediaConnectedAt.present
        ? mediaConnectedAt.value
        : this.mediaConnectedAt,
    endedAt: endedAt ?? this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    ringSeconds: ringSeconds ?? this.ringSeconds,
    timeToRingingMs: timeToRingingMs.present
        ? timeToRingingMs.value
        : this.timeToRingingMs,
    ringingToAnswerMs: ringingToAnswerMs.present
        ? ringingToAnswerMs.value
        : this.ringingToAnswerMs,
    answerToMediaMs: answerToMediaMs.present
        ? answerToMediaMs.value
        : this.answerToMediaMs,
    holdCount: holdCount ?? this.holdCount,
    holdSeconds: holdSeconds ?? this.holdSeconds,
    sipStatusCode: sipStatusCode.present
        ? sipStatusCode.value
        : this.sipStatusCode,
    hangupReason: hangupReason.present ? hangupReason.value : this.hangupReason,
    note: note.present ? note.value : this.note,
    missedReadAt: missedReadAt.present ? missedReadAt.value : this.missedReadAt,
    createdAt: createdAt ?? this.createdAt,
  );
  CallHistoryEntry copyWithCompanion(CallHistoryEntriesCompanion data) {
    return CallHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      callId: data.callId.present ? data.callId.value : this.callId,
      sessionKey: data.sessionKey.present
          ? data.sessionKey.value
          : this.sessionKey,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      remoteUri: data.remoteUri.present ? data.remoteUri.value : this.remoteUri,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountLabel: data.accountLabel.present
          ? data.accountLabel.value
          : this.accountLabel,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      ringingAt: data.ringingAt.present ? data.ringingAt.value : this.ringingAt,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      mediaConnectedAt: data.mediaConnectedAt.present
          ? data.mediaConnectedAt.value
          : this.mediaConnectedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      ringSeconds: data.ringSeconds.present
          ? data.ringSeconds.value
          : this.ringSeconds,
      timeToRingingMs: data.timeToRingingMs.present
          ? data.timeToRingingMs.value
          : this.timeToRingingMs,
      ringingToAnswerMs: data.ringingToAnswerMs.present
          ? data.ringingToAnswerMs.value
          : this.ringingToAnswerMs,
      answerToMediaMs: data.answerToMediaMs.present
          ? data.answerToMediaMs.value
          : this.answerToMediaMs,
      holdCount: data.holdCount.present ? data.holdCount.value : this.holdCount,
      holdSeconds: data.holdSeconds.present
          ? data.holdSeconds.value
          : this.holdSeconds,
      sipStatusCode: data.sipStatusCode.present
          ? data.sipStatusCode.value
          : this.sipStatusCode,
      hangupReason: data.hangupReason.present
          ? data.hangupReason.value
          : this.hangupReason,
      note: data.note.present ? data.note.value : this.note,
      missedReadAt: data.missedReadAt.present
          ? data.missedReadAt.value
          : this.missedReadAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryEntry(')
          ..write('id: $id, ')
          ..write('callId: $callId, ')
          ..write('sessionKey: $sessionKey, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('remoteUri: $remoteUri, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('contactId: $contactId, ')
          ..write('accountId: $accountId, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('startedAt: $startedAt, ')
          ..write('ringingAt: $ringingAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('mediaConnectedAt: $mediaConnectedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('ringSeconds: $ringSeconds, ')
          ..write('timeToRingingMs: $timeToRingingMs, ')
          ..write('ringingToAnswerMs: $ringingToAnswerMs, ')
          ..write('answerToMediaMs: $answerToMediaMs, ')
          ..write('holdCount: $holdCount, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('sipStatusCode: $sipStatusCode, ')
          ..write('hangupReason: $hangupReason, ')
          ..write('note: $note, ')
          ..write('missedReadAt: $missedReadAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    callId,
    sessionKey,
    direction,
    status,
    remoteUri,
    phoneNumber,
    displayName,
    contactId,
    accountId,
    accountLabel,
    startedAt,
    ringingAt,
    answeredAt,
    mediaConnectedAt,
    endedAt,
    durationSeconds,
    ringSeconds,
    timeToRingingMs,
    ringingToAnswerMs,
    answerToMediaMs,
    holdCount,
    holdSeconds,
    sipStatusCode,
    hangupReason,
    note,
    missedReadAt,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallHistoryEntry &&
          other.id == this.id &&
          other.callId == this.callId &&
          other.sessionKey == this.sessionKey &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.remoteUri == this.remoteUri &&
          other.phoneNumber == this.phoneNumber &&
          other.displayName == this.displayName &&
          other.contactId == this.contactId &&
          other.accountId == this.accountId &&
          other.accountLabel == this.accountLabel &&
          other.startedAt == this.startedAt &&
          other.ringingAt == this.ringingAt &&
          other.answeredAt == this.answeredAt &&
          other.mediaConnectedAt == this.mediaConnectedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.ringSeconds == this.ringSeconds &&
          other.timeToRingingMs == this.timeToRingingMs &&
          other.ringingToAnswerMs == this.ringingToAnswerMs &&
          other.answerToMediaMs == this.answerToMediaMs &&
          other.holdCount == this.holdCount &&
          other.holdSeconds == this.holdSeconds &&
          other.sipStatusCode == this.sipStatusCode &&
          other.hangupReason == this.hangupReason &&
          other.note == this.note &&
          other.missedReadAt == this.missedReadAt &&
          other.createdAt == this.createdAt);
}

class CallHistoryEntriesCompanion extends UpdateCompanion<CallHistoryEntry> {
  final Value<int> id;
  final Value<int> callId;
  final Value<String?> sessionKey;
  final Value<String> direction;
  final Value<String> status;
  final Value<String> remoteUri;
  final Value<String> phoneNumber;
  final Value<String?> displayName;
  final Value<String?> contactId;
  final Value<int?> accountId;
  final Value<String?> accountLabel;
  final Value<DateTime> startedAt;
  final Value<DateTime?> ringingAt;
  final Value<DateTime?> answeredAt;
  final Value<DateTime?> mediaConnectedAt;
  final Value<DateTime> endedAt;
  final Value<int> durationSeconds;
  final Value<int> ringSeconds;
  final Value<int?> timeToRingingMs;
  final Value<int?> ringingToAnswerMs;
  final Value<int?> answerToMediaMs;
  final Value<int> holdCount;
  final Value<int> holdSeconds;
  final Value<int?> sipStatusCode;
  final Value<String?> hangupReason;
  final Value<String?> note;
  final Value<DateTime?> missedReadAt;
  final Value<DateTime> createdAt;
  const CallHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.callId = const Value.absent(),
    this.sessionKey = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.remoteUri = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.displayName = const Value.absent(),
    this.contactId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountLabel = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.ringingAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.mediaConnectedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.ringSeconds = const Value.absent(),
    this.timeToRingingMs = const Value.absent(),
    this.ringingToAnswerMs = const Value.absent(),
    this.answerToMediaMs = const Value.absent(),
    this.holdCount = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.sipStatusCode = const Value.absent(),
    this.hangupReason = const Value.absent(),
    this.note = const Value.absent(),
    this.missedReadAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CallHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int callId,
    this.sessionKey = const Value.absent(),
    required String direction,
    required String status,
    required String remoteUri,
    required String phoneNumber,
    this.displayName = const Value.absent(),
    this.contactId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountLabel = const Value.absent(),
    required DateTime startedAt,
    this.ringingAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.mediaConnectedAt = const Value.absent(),
    required DateTime endedAt,
    this.durationSeconds = const Value.absent(),
    this.ringSeconds = const Value.absent(),
    this.timeToRingingMs = const Value.absent(),
    this.ringingToAnswerMs = const Value.absent(),
    this.answerToMediaMs = const Value.absent(),
    this.holdCount = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.sipStatusCode = const Value.absent(),
    this.hangupReason = const Value.absent(),
    this.note = const Value.absent(),
    this.missedReadAt = const Value.absent(),
    required DateTime createdAt,
  }) : callId = Value(callId),
       direction = Value(direction),
       status = Value(status),
       remoteUri = Value(remoteUri),
       phoneNumber = Value(phoneNumber),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       createdAt = Value(createdAt);
  static Insertable<CallHistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? callId,
    Expression<String>? sessionKey,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<String>? remoteUri,
    Expression<String>? phoneNumber,
    Expression<String>? displayName,
    Expression<String>? contactId,
    Expression<int>? accountId,
    Expression<String>? accountLabel,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? ringingAt,
    Expression<DateTime>? answeredAt,
    Expression<DateTime>? mediaConnectedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<int>? ringSeconds,
    Expression<int>? timeToRingingMs,
    Expression<int>? ringingToAnswerMs,
    Expression<int>? answerToMediaMs,
    Expression<int>? holdCount,
    Expression<int>? holdSeconds,
    Expression<int>? sipStatusCode,
    Expression<String>? hangupReason,
    Expression<String>? note,
    Expression<DateTime>? missedReadAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callId != null) 'call_id': callId,
      if (sessionKey != null) 'session_key': sessionKey,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (remoteUri != null) 'remote_uri': remoteUri,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (displayName != null) 'display_name': displayName,
      if (contactId != null) 'contact_id': contactId,
      if (accountId != null) 'account_id': accountId,
      if (accountLabel != null) 'account_label': accountLabel,
      if (startedAt != null) 'started_at': startedAt,
      if (ringingAt != null) 'ringing_at': ringingAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (mediaConnectedAt != null) 'media_connected_at': mediaConnectedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (ringSeconds != null) 'ring_seconds': ringSeconds,
      if (timeToRingingMs != null) 'time_to_ringing_ms': timeToRingingMs,
      if (ringingToAnswerMs != null) 'ringing_to_answer_ms': ringingToAnswerMs,
      if (answerToMediaMs != null) 'answer_to_media_ms': answerToMediaMs,
      if (holdCount != null) 'hold_count': holdCount,
      if (holdSeconds != null) 'hold_seconds': holdSeconds,
      if (sipStatusCode != null) 'sip_status_code': sipStatusCode,
      if (hangupReason != null) 'hangup_reason': hangupReason,
      if (note != null) 'note': note,
      if (missedReadAt != null) 'missed_read_at': missedReadAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CallHistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? callId,
    Value<String?>? sessionKey,
    Value<String>? direction,
    Value<String>? status,
    Value<String>? remoteUri,
    Value<String>? phoneNumber,
    Value<String?>? displayName,
    Value<String?>? contactId,
    Value<int?>? accountId,
    Value<String?>? accountLabel,
    Value<DateTime>? startedAt,
    Value<DateTime?>? ringingAt,
    Value<DateTime?>? answeredAt,
    Value<DateTime?>? mediaConnectedAt,
    Value<DateTime>? endedAt,
    Value<int>? durationSeconds,
    Value<int>? ringSeconds,
    Value<int?>? timeToRingingMs,
    Value<int?>? ringingToAnswerMs,
    Value<int?>? answerToMediaMs,
    Value<int>? holdCount,
    Value<int>? holdSeconds,
    Value<int?>? sipStatusCode,
    Value<String?>? hangupReason,
    Value<String?>? note,
    Value<DateTime?>? missedReadAt,
    Value<DateTime>? createdAt,
  }) {
    return CallHistoryEntriesCompanion(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      sessionKey: sessionKey ?? this.sessionKey,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      remoteUri: remoteUri ?? this.remoteUri,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      contactId: contactId ?? this.contactId,
      accountId: accountId ?? this.accountId,
      accountLabel: accountLabel ?? this.accountLabel,
      startedAt: startedAt ?? this.startedAt,
      ringingAt: ringingAt ?? this.ringingAt,
      answeredAt: answeredAt ?? this.answeredAt,
      mediaConnectedAt: mediaConnectedAt ?? this.mediaConnectedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      ringSeconds: ringSeconds ?? this.ringSeconds,
      timeToRingingMs: timeToRingingMs ?? this.timeToRingingMs,
      ringingToAnswerMs: ringingToAnswerMs ?? this.ringingToAnswerMs,
      answerToMediaMs: answerToMediaMs ?? this.answerToMediaMs,
      holdCount: holdCount ?? this.holdCount,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      sipStatusCode: sipStatusCode ?? this.sipStatusCode,
      hangupReason: hangupReason ?? this.hangupReason,
      note: note ?? this.note,
      missedReadAt: missedReadAt ?? this.missedReadAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<int>(callId.value);
    }
    if (sessionKey.present) {
      map['session_key'] = Variable<String>(sessionKey.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (remoteUri.present) {
      map['remote_uri'] = Variable<String>(remoteUri.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (accountLabel.present) {
      map['account_label'] = Variable<String>(accountLabel.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (ringingAt.present) {
      map['ringing_at'] = Variable<DateTime>(ringingAt.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (mediaConnectedAt.present) {
      map['media_connected_at'] = Variable<DateTime>(mediaConnectedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (ringSeconds.present) {
      map['ring_seconds'] = Variable<int>(ringSeconds.value);
    }
    if (timeToRingingMs.present) {
      map['time_to_ringing_ms'] = Variable<int>(timeToRingingMs.value);
    }
    if (ringingToAnswerMs.present) {
      map['ringing_to_answer_ms'] = Variable<int>(ringingToAnswerMs.value);
    }
    if (answerToMediaMs.present) {
      map['answer_to_media_ms'] = Variable<int>(answerToMediaMs.value);
    }
    if (holdCount.present) {
      map['hold_count'] = Variable<int>(holdCount.value);
    }
    if (holdSeconds.present) {
      map['hold_seconds'] = Variable<int>(holdSeconds.value);
    }
    if (sipStatusCode.present) {
      map['sip_status_code'] = Variable<int>(sipStatusCode.value);
    }
    if (hangupReason.present) {
      map['hangup_reason'] = Variable<String>(hangupReason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (missedReadAt.present) {
      map['missed_read_at'] = Variable<DateTime>(missedReadAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('callId: $callId, ')
          ..write('sessionKey: $sessionKey, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('remoteUri: $remoteUri, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('contactId: $contactId, ')
          ..write('accountId: $accountId, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('startedAt: $startedAt, ')
          ..write('ringingAt: $ringingAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('mediaConnectedAt: $mediaConnectedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('ringSeconds: $ringSeconds, ')
          ..write('timeToRingingMs: $timeToRingingMs, ')
          ..write('ringingToAnswerMs: $ringingToAnswerMs, ')
          ..write('answerToMediaMs: $answerToMediaMs, ')
          ..write('holdCount: $holdCount, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('sipStatusCode: $sipStatusCode, ')
          ..write('hangupReason: $hangupReason, ')
          ..write('note: $note, ')
          ..write('missedReadAt: $missedReadAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CallRecordingsTable extends CallRecordings
    with TableInfo<$CallRecordingsTable, CallRecording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallRecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _historyEntryIdMeta = const VerificationMeta(
    'historyEntryId',
  );
  @override
  late final GeneratedColumn<int> historyEntryId = GeneratedColumn<int>(
    'history_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES call_history_entries (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sessionKeyMeta = const VerificationMeta(
    'sessionKey',
  );
  @override
  late final GeneratedColumn<String> sessionKey = GeneratedColumn<String>(
    'session_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<int> callId = GeneratedColumn<int>(
    'call_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single'),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wav'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    historyEntryId,
    sessionKey,
    callId,
    kind,
    relativePath,
    status,
    format,
    startedAt,
    endedAt,
    durationMs,
    fileSizeBytes,
    failureReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallRecording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('history_entry_id')) {
      context.handle(
        _historyEntryIdMeta,
        historyEntryId.isAcceptableOrUnknown(
          data['history_entry_id']!,
          _historyEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('session_key')) {
      context.handle(
        _sessionKeyMeta,
        sessionKey.isAcceptableOrUnknown(data['session_key']!, _sessionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionKeyMeta);
    }
    if (data.containsKey('call_id')) {
      context.handle(
        _callIdMeta,
        callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallRecording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallRecording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      historyEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_entry_id'],
      ),
      sessionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_key'],
      )!,
      callId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CallRecordingsTable createAlias(String alias) {
    return $CallRecordingsTable(attachedDatabase, alias);
  }
}

class CallRecording extends DataClass implements Insertable<CallRecording> {
  final int id;
  final int? historyEntryId;
  final String sessionKey;
  final int callId;
  final String kind;
  final String relativePath;
  final String status;
  final String format;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMs;
  final int fileSizeBytes;
  final String? failureReason;
  final DateTime createdAt;
  const CallRecording({
    required this.id,
    this.historyEntryId,
    required this.sessionKey,
    required this.callId,
    required this.kind,
    required this.relativePath,
    required this.status,
    required this.format,
    required this.startedAt,
    this.endedAt,
    required this.durationMs,
    required this.fileSizeBytes,
    this.failureReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || historyEntryId != null) {
      map['history_entry_id'] = Variable<int>(historyEntryId);
    }
    map['session_key'] = Variable<String>(sessionKey);
    map['call_id'] = Variable<int>(callId);
    map['kind'] = Variable<String>(kind);
    map['relative_path'] = Variable<String>(relativePath);
    map['status'] = Variable<String>(status);
    map['format'] = Variable<String>(format);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CallRecordingsCompanion toCompanion(bool nullToAbsent) {
    return CallRecordingsCompanion(
      id: Value(id),
      historyEntryId: historyEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(historyEntryId),
      sessionKey: Value(sessionKey),
      callId: Value(callId),
      kind: Value(kind),
      relativePath: Value(relativePath),
      status: Value(status),
      format: Value(format),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: Value(durationMs),
      fileSizeBytes: Value(fileSizeBytes),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
    );
  }

  factory CallRecording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallRecording(
      id: serializer.fromJson<int>(json['id']),
      historyEntryId: serializer.fromJson<int?>(json['historyEntryId']),
      sessionKey: serializer.fromJson<String>(json['sessionKey']),
      callId: serializer.fromJson<int>(json['callId']),
      kind: serializer.fromJson<String>(json['kind']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      status: serializer.fromJson<String>(json['status']),
      format: serializer.fromJson<String>(json['format']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'historyEntryId': serializer.toJson<int?>(historyEntryId),
      'sessionKey': serializer.toJson<String>(sessionKey),
      'callId': serializer.toJson<int>(callId),
      'kind': serializer.toJson<String>(kind),
      'relativePath': serializer.toJson<String>(relativePath),
      'status': serializer.toJson<String>(status),
      'format': serializer.toJson<String>(format),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CallRecording copyWith({
    int? id,
    Value<int?> historyEntryId = const Value.absent(),
    String? sessionKey,
    int? callId,
    String? kind,
    String? relativePath,
    String? status,
    String? format,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationMs,
    int? fileSizeBytes,
    Value<String?> failureReason = const Value.absent(),
    DateTime? createdAt,
  }) => CallRecording(
    id: id ?? this.id,
    historyEntryId: historyEntryId.present
        ? historyEntryId.value
        : this.historyEntryId,
    sessionKey: sessionKey ?? this.sessionKey,
    callId: callId ?? this.callId,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    status: status ?? this.status,
    format: format ?? this.format,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs ?? this.durationMs,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
  );
  CallRecording copyWithCompanion(CallRecordingsCompanion data) {
    return CallRecording(
      id: data.id.present ? data.id.value : this.id,
      historyEntryId: data.historyEntryId.present
          ? data.historyEntryId.value
          : this.historyEntryId,
      sessionKey: data.sessionKey.present
          ? data.sessionKey.value
          : this.sessionKey,
      callId: data.callId.present ? data.callId.value : this.callId,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      status: data.status.present ? data.status.value : this.status,
      format: data.format.present ? data.format.value : this.format,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallRecording(')
          ..write('id: $id, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('sessionKey: $sessionKey, ')
          ..write('callId: $callId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('status: $status, ')
          ..write('format: $format, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    historyEntryId,
    sessionKey,
    callId,
    kind,
    relativePath,
    status,
    format,
    startedAt,
    endedAt,
    durationMs,
    fileSizeBytes,
    failureReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallRecording &&
          other.id == this.id &&
          other.historyEntryId == this.historyEntryId &&
          other.sessionKey == this.sessionKey &&
          other.callId == this.callId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.status == this.status &&
          other.format == this.format &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt);
}

class CallRecordingsCompanion extends UpdateCompanion<CallRecording> {
  final Value<int> id;
  final Value<int?> historyEntryId;
  final Value<String> sessionKey;
  final Value<int> callId;
  final Value<String> kind;
  final Value<String> relativePath;
  final Value<String> status;
  final Value<String> format;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationMs;
  final Value<int> fileSizeBytes;
  final Value<String?> failureReason;
  final Value<DateTime> createdAt;
  const CallRecordingsCompanion({
    this.id = const Value.absent(),
    this.historyEntryId = const Value.absent(),
    this.sessionKey = const Value.absent(),
    this.callId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.status = const Value.absent(),
    this.format = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CallRecordingsCompanion.insert({
    this.id = const Value.absent(),
    this.historyEntryId = const Value.absent(),
    required String sessionKey,
    required int callId,
    this.kind = const Value.absent(),
    required String relativePath,
    required String status,
    this.format = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.failureReason = const Value.absent(),
    required DateTime createdAt,
  }) : sessionKey = Value(sessionKey),
       callId = Value(callId),
       relativePath = Value(relativePath),
       status = Value(status),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt);
  static Insertable<CallRecording> custom({
    Expression<int>? id,
    Expression<int>? historyEntryId,
    Expression<String>? sessionKey,
    Expression<int>? callId,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<String>? status,
    Expression<String>? format,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMs,
    Expression<int>? fileSizeBytes,
    Expression<String>? failureReason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (historyEntryId != null) 'history_entry_id': historyEntryId,
      if (sessionKey != null) 'session_key': sessionKey,
      if (callId != null) 'call_id': callId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (status != null) 'status': status,
      if (format != null) 'format': format,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CallRecordingsCompanion copyWith({
    Value<int>? id,
    Value<int?>? historyEntryId,
    Value<String>? sessionKey,
    Value<int>? callId,
    Value<String>? kind,
    Value<String>? relativePath,
    Value<String>? status,
    Value<String>? format,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationMs,
    Value<int>? fileSizeBytes,
    Value<String?>? failureReason,
    Value<DateTime>? createdAt,
  }) {
    return CallRecordingsCompanion(
      id: id ?? this.id,
      historyEntryId: historyEntryId ?? this.historyEntryId,
      sessionKey: sessionKey ?? this.sessionKey,
      callId: callId ?? this.callId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      status: status ?? this.status,
      format: format ?? this.format,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (historyEntryId.present) {
      map['history_entry_id'] = Variable<int>(historyEntryId.value);
    }
    if (sessionKey.present) {
      map['session_key'] = Variable<String>(sessionKey.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<int>(callId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallRecordingsCompanion(')
          ..write('id: $id, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('sessionKey: $sessionKey, ')
          ..write('callId: $callId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('status: $status, ')
          ..write('format: $format, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CallRecordingLinksTable extends CallRecordingLinks
    with TableInfo<$CallRecordingLinksTable, CallRecordingLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallRecordingLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<int> recordingId = GeneratedColumn<int>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES call_recordings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _callSessionKeyMeta = const VerificationMeta(
    'callSessionKey',
  );
  @override
  late final GeneratedColumn<String> callSessionKey = GeneratedColumn<String>(
    'call_session_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<int> callId = GeneratedColumn<int>(
    'call_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _historyEntryIdMeta = const VerificationMeta(
    'historyEntryId',
  );
  @override
  late final GeneratedColumn<int> historyEntryId = GeneratedColumn<int>(
    'history_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES call_history_entries (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leftAtMeta = const VerificationMeta('leftAt');
  @override
  late final GeneratedColumn<DateTime> leftAt = GeneratedColumn<DateTime>(
    'left_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recordingId,
    callSessionKey,
    callId,
    historyEntryId,
    joinedAt,
    leftAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_recording_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallRecordingLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('call_session_key')) {
      context.handle(
        _callSessionKeyMeta,
        callSessionKey.isAcceptableOrUnknown(
          data['call_session_key']!,
          _callSessionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_callSessionKeyMeta);
    }
    if (data.containsKey('call_id')) {
      context.handle(
        _callIdMeta,
        callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('history_entry_id')) {
      context.handle(
        _historyEntryIdMeta,
        historyEntryId.isAcceptableOrUnknown(
          data['history_entry_id']!,
          _historyEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('left_at')) {
      context.handle(
        _leftAtMeta,
        leftAt.isAcceptableOrUnknown(data['left_at']!, _leftAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recordingId, callSessionKey};
  @override
  CallRecordingLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallRecordingLink(
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recording_id'],
      )!,
      callSessionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_session_key'],
      )!,
      callId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_id'],
      )!,
      historyEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_entry_id'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      leftAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}left_at'],
      ),
    );
  }

  @override
  $CallRecordingLinksTable createAlias(String alias) {
    return $CallRecordingLinksTable(attachedDatabase, alias);
  }
}

class CallRecordingLink extends DataClass
    implements Insertable<CallRecordingLink> {
  final int recordingId;
  final String callSessionKey;
  final int callId;
  final int? historyEntryId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  const CallRecordingLink({
    required this.recordingId,
    required this.callSessionKey,
    required this.callId,
    this.historyEntryId,
    required this.joinedAt,
    this.leftAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recording_id'] = Variable<int>(recordingId);
    map['call_session_key'] = Variable<String>(callSessionKey);
    map['call_id'] = Variable<int>(callId);
    if (!nullToAbsent || historyEntryId != null) {
      map['history_entry_id'] = Variable<int>(historyEntryId);
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    if (!nullToAbsent || leftAt != null) {
      map['left_at'] = Variable<DateTime>(leftAt);
    }
    return map;
  }

  CallRecordingLinksCompanion toCompanion(bool nullToAbsent) {
    return CallRecordingLinksCompanion(
      recordingId: Value(recordingId),
      callSessionKey: Value(callSessionKey),
      callId: Value(callId),
      historyEntryId: historyEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(historyEntryId),
      joinedAt: Value(joinedAt),
      leftAt: leftAt == null && nullToAbsent
          ? const Value.absent()
          : Value(leftAt),
    );
  }

  factory CallRecordingLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallRecordingLink(
      recordingId: serializer.fromJson<int>(json['recordingId']),
      callSessionKey: serializer.fromJson<String>(json['callSessionKey']),
      callId: serializer.fromJson<int>(json['callId']),
      historyEntryId: serializer.fromJson<int?>(json['historyEntryId']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      leftAt: serializer.fromJson<DateTime?>(json['leftAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recordingId': serializer.toJson<int>(recordingId),
      'callSessionKey': serializer.toJson<String>(callSessionKey),
      'callId': serializer.toJson<int>(callId),
      'historyEntryId': serializer.toJson<int?>(historyEntryId),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'leftAt': serializer.toJson<DateTime?>(leftAt),
    };
  }

  CallRecordingLink copyWith({
    int? recordingId,
    String? callSessionKey,
    int? callId,
    Value<int?> historyEntryId = const Value.absent(),
    DateTime? joinedAt,
    Value<DateTime?> leftAt = const Value.absent(),
  }) => CallRecordingLink(
    recordingId: recordingId ?? this.recordingId,
    callSessionKey: callSessionKey ?? this.callSessionKey,
    callId: callId ?? this.callId,
    historyEntryId: historyEntryId.present
        ? historyEntryId.value
        : this.historyEntryId,
    joinedAt: joinedAt ?? this.joinedAt,
    leftAt: leftAt.present ? leftAt.value : this.leftAt,
  );
  CallRecordingLink copyWithCompanion(CallRecordingLinksCompanion data) {
    return CallRecordingLink(
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      callSessionKey: data.callSessionKey.present
          ? data.callSessionKey.value
          : this.callSessionKey,
      callId: data.callId.present ? data.callId.value : this.callId,
      historyEntryId: data.historyEntryId.present
          ? data.historyEntryId.value
          : this.historyEntryId,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      leftAt: data.leftAt.present ? data.leftAt.value : this.leftAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallRecordingLink(')
          ..write('recordingId: $recordingId, ')
          ..write('callSessionKey: $callSessionKey, ')
          ..write('callId: $callId, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recordingId,
    callSessionKey,
    callId,
    historyEntryId,
    joinedAt,
    leftAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallRecordingLink &&
          other.recordingId == this.recordingId &&
          other.callSessionKey == this.callSessionKey &&
          other.callId == this.callId &&
          other.historyEntryId == this.historyEntryId &&
          other.joinedAt == this.joinedAt &&
          other.leftAt == this.leftAt);
}

class CallRecordingLinksCompanion extends UpdateCompanion<CallRecordingLink> {
  final Value<int> recordingId;
  final Value<String> callSessionKey;
  final Value<int> callId;
  final Value<int?> historyEntryId;
  final Value<DateTime> joinedAt;
  final Value<DateTime?> leftAt;
  final Value<int> rowid;
  const CallRecordingLinksCompanion({
    this.recordingId = const Value.absent(),
    this.callSessionKey = const Value.absent(),
    this.callId = const Value.absent(),
    this.historyEntryId = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.leftAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallRecordingLinksCompanion.insert({
    required int recordingId,
    required String callSessionKey,
    required int callId,
    this.historyEntryId = const Value.absent(),
    required DateTime joinedAt,
    this.leftAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recordingId = Value(recordingId),
       callSessionKey = Value(callSessionKey),
       callId = Value(callId),
       joinedAt = Value(joinedAt);
  static Insertable<CallRecordingLink> custom({
    Expression<int>? recordingId,
    Expression<String>? callSessionKey,
    Expression<int>? callId,
    Expression<int>? historyEntryId,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? leftAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recordingId != null) 'recording_id': recordingId,
      if (callSessionKey != null) 'call_session_key': callSessionKey,
      if (callId != null) 'call_id': callId,
      if (historyEntryId != null) 'history_entry_id': historyEntryId,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (leftAt != null) 'left_at': leftAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallRecordingLinksCompanion copyWith({
    Value<int>? recordingId,
    Value<String>? callSessionKey,
    Value<int>? callId,
    Value<int?>? historyEntryId,
    Value<DateTime>? joinedAt,
    Value<DateTime?>? leftAt,
    Value<int>? rowid,
  }) {
    return CallRecordingLinksCompanion(
      recordingId: recordingId ?? this.recordingId,
      callSessionKey: callSessionKey ?? this.callSessionKey,
      callId: callId ?? this.callId,
      historyEntryId: historyEntryId ?? this.historyEntryId,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recordingId.present) {
      map['recording_id'] = Variable<int>(recordingId.value);
    }
    if (callSessionKey.present) {
      map['call_session_key'] = Variable<String>(callSessionKey.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<int>(callId.value);
    }
    if (historyEntryId.present) {
      map['history_entry_id'] = Variable<int>(historyEntryId.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (leftAt.present) {
      map['left_at'] = Variable<DateTime>(leftAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallRecordingLinksCompanion(')
          ..write('recordingId: $recordingId, ')
          ..write('callSessionKey: $callSessionKey, ')
          ..write('callId: $callId, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbContactsTable extends DbContacts
    with TableInfo<$DbContactsTable, DbContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNumberMeta = const VerificationMeta(
    'normalizedNumber',
  );
  @override
  late final GeneratedColumn<String> normalizedNumber = GeneratedColumn<String>(
    'normalized_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    number,
    normalizedNumber,
    company,
    department,
    remark,
    isFavorite,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('normalized_number')) {
      context.handle(
        _normalizedNumberMeta,
        normalizedNumber.isAcceptableOrUnknown(
          data['normalized_number']!,
          _normalizedNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNumberMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      normalizedNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_number'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DbContactsTable createAlias(String alias) {
    return $DbContactsTable(attachedDatabase, alias);
  }
}

class DbContact extends DataClass implements Insertable<DbContact> {
  final String id;
  final String name;
  final String number;
  final String normalizedNumber;
  final String company;
  final String department;
  final String remark;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const DbContact({
    required this.id,
    required this.name,
    required this.number,
    required this.normalizedNumber,
    required this.company,
    required this.department,
    required this.remark,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['number'] = Variable<String>(number);
    map['normalized_number'] = Variable<String>(normalizedNumber);
    map['company'] = Variable<String>(company);
    map['department'] = Variable<String>(department);
    map['remark'] = Variable<String>(remark);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DbContactsCompanion toCompanion(bool nullToAbsent) {
    return DbContactsCompanion(
      id: Value(id),
      name: Value(name),
      number: Value(number),
      normalizedNumber: Value(normalizedNumber),
      company: Value(company),
      department: Value(department),
      remark: Value(remark),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DbContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbContact(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<String>(json['number']),
      normalizedNumber: serializer.fromJson<String>(json['normalizedNumber']),
      company: serializer.fromJson<String>(json['company']),
      department: serializer.fromJson<String>(json['department']),
      remark: serializer.fromJson<String>(json['remark']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<String>(number),
      'normalizedNumber': serializer.toJson<String>(normalizedNumber),
      'company': serializer.toJson<String>(company),
      'department': serializer.toJson<String>(department),
      'remark': serializer.toJson<String>(remark),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DbContact copyWith({
    String? id,
    String? name,
    String? number,
    String? normalizedNumber,
    String? company,
    String? department,
    String? remark,
    bool? isFavorite,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DbContact(
    id: id ?? this.id,
    name: name ?? this.name,
    number: number ?? this.number,
    normalizedNumber: normalizedNumber ?? this.normalizedNumber,
    company: company ?? this.company,
    department: department ?? this.department,
    remark: remark ?? this.remark,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DbContact copyWithCompanion(DbContactsCompanion data) {
    return DbContact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      normalizedNumber: data.normalizedNumber.present
          ? data.normalizedNumber.value
          : this.normalizedNumber,
      company: data.company.present ? data.company.value : this.company,
      department: data.department.present
          ? data.department.value
          : this.department,
      remark: data.remark.present ? data.remark.value : this.remark,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbContact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('company: $company, ')
          ..write('department: $department, ')
          ..write('remark: $remark, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    number,
    normalizedNumber,
    company,
    department,
    remark,
    isFavorite,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbContact &&
          other.id == this.id &&
          other.name == this.name &&
          other.number == this.number &&
          other.normalizedNumber == this.normalizedNumber &&
          other.company == this.company &&
          other.department == this.department &&
          other.remark == this.remark &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DbContactsCompanion extends UpdateCompanion<DbContact> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> number;
  final Value<String> normalizedNumber;
  final Value<String> company;
  final Value<String> department;
  final Value<String> remark;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DbContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.normalizedNumber = const Value.absent(),
    this.company = const Value.absent(),
    this.department = const Value.absent(),
    this.remark = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbContactsCompanion.insert({
    required String id,
    required String name,
    required String number,
    required String normalizedNumber,
    this.company = const Value.absent(),
    this.department = const Value.absent(),
    this.remark = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       number = Value(number),
       normalizedNumber = Value(normalizedNumber),
       createdAt = Value(createdAt);
  static Insertable<DbContact> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? number,
    Expression<String>? normalizedNumber,
    Expression<String>? company,
    Expression<String>? department,
    Expression<String>? remark,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (normalizedNumber != null) 'normalized_number': normalizedNumber,
      if (company != null) 'company': company,
      if (department != null) 'department': department,
      if (remark != null) 'remark': remark,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? number,
    Value<String>? normalizedNumber,
    Value<String>? company,
    Value<String>? department,
    Value<String>? remark,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DbContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      normalizedNumber: normalizedNumber ?? this.normalizedNumber,
      company: company ?? this.company,
      department: department ?? this.department,
      remark: remark ?? this.remark,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (normalizedNumber.present) {
      map['normalized_number'] = Variable<String>(normalizedNumber.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('company: $company, ')
          ..write('department: $department, ')
          ..write('remark: $remark, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbContactPhonesTable extends DbContactPhones
    with TableInfo<$DbContactPhonesTable, DbContactPhone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbContactPhonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_contacts (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('默认'),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNumberMeta = const VerificationMeta(
    'normalizedNumber',
  );
  @override
  late final GeneratedColumn<String> normalizedNumber = GeneratedColumn<String>(
    'normalized_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    label,
    number,
    normalizedNumber,
    isPrimary,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_contact_phones';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbContactPhone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('normalized_number')) {
      context.handle(
        _normalizedNumberMeta,
        normalizedNumber.isAcceptableOrUnknown(
          data['normalized_number']!,
          _normalizedNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNumberMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbContactPhone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbContactPhone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      normalizedNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_number'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DbContactPhonesTable createAlias(String alias) {
    return $DbContactPhonesTable(attachedDatabase, alias);
  }
}

class DbContactPhone extends DataClass implements Insertable<DbContactPhone> {
  final int id;
  final String contactId;
  final String label;
  final String number;
  final String normalizedNumber;
  final bool isPrimary;
  final DateTime createdAt;
  const DbContactPhone({
    required this.id,
    required this.contactId,
    required this.label,
    required this.number,
    required this.normalizedNumber,
    required this.isPrimary,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['label'] = Variable<String>(label);
    map['number'] = Variable<String>(number);
    map['normalized_number'] = Variable<String>(normalizedNumber);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DbContactPhonesCompanion toCompanion(bool nullToAbsent) {
    return DbContactPhonesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      label: Value(label),
      number: Value(number),
      normalizedNumber: Value(normalizedNumber),
      isPrimary: Value(isPrimary),
      createdAt: Value(createdAt),
    );
  }

  factory DbContactPhone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbContactPhone(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      label: serializer.fromJson<String>(json['label']),
      number: serializer.fromJson<String>(json['number']),
      normalizedNumber: serializer.fromJson<String>(json['normalizedNumber']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<String>(contactId),
      'label': serializer.toJson<String>(label),
      'number': serializer.toJson<String>(number),
      'normalizedNumber': serializer.toJson<String>(normalizedNumber),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbContactPhone copyWith({
    int? id,
    String? contactId,
    String? label,
    String? number,
    String? normalizedNumber,
    bool? isPrimary,
    DateTime? createdAt,
  }) => DbContactPhone(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    label: label ?? this.label,
    number: number ?? this.number,
    normalizedNumber: normalizedNumber ?? this.normalizedNumber,
    isPrimary: isPrimary ?? this.isPrimary,
    createdAt: createdAt ?? this.createdAt,
  );
  DbContactPhone copyWithCompanion(DbContactPhonesCompanion data) {
    return DbContactPhone(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      label: data.label.present ? data.label.value : this.label,
      number: data.number.present ? data.number.value : this.number,
      normalizedNumber: data.normalizedNumber.present
          ? data.normalizedNumber.value
          : this.normalizedNumber,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbContactPhone(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('label: $label, ')
          ..write('number: $number, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    label,
    number,
    normalizedNumber,
    isPrimary,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbContactPhone &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.label == this.label &&
          other.number == this.number &&
          other.normalizedNumber == this.normalizedNumber &&
          other.isPrimary == this.isPrimary &&
          other.createdAt == this.createdAt);
}

class DbContactPhonesCompanion extends UpdateCompanion<DbContactPhone> {
  final Value<int> id;
  final Value<String> contactId;
  final Value<String> label;
  final Value<String> number;
  final Value<String> normalizedNumber;
  final Value<bool> isPrimary;
  final Value<DateTime> createdAt;
  const DbContactPhonesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.label = const Value.absent(),
    this.number = const Value.absent(),
    this.normalizedNumber = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DbContactPhonesCompanion.insert({
    this.id = const Value.absent(),
    required String contactId,
    this.label = const Value.absent(),
    required String number,
    required String normalizedNumber,
    this.isPrimary = const Value.absent(),
    required DateTime createdAt,
  }) : contactId = Value(contactId),
       number = Value(number),
       normalizedNumber = Value(normalizedNumber),
       createdAt = Value(createdAt);
  static Insertable<DbContactPhone> custom({
    Expression<int>? id,
    Expression<String>? contactId,
    Expression<String>? label,
    Expression<String>? number,
    Expression<String>? normalizedNumber,
    Expression<bool>? isPrimary,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (label != null) 'label': label,
      if (number != null) 'number': number,
      if (normalizedNumber != null) 'normalized_number': normalizedNumber,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DbContactPhonesCompanion copyWith({
    Value<int>? id,
    Value<String>? contactId,
    Value<String>? label,
    Value<String>? number,
    Value<String>? normalizedNumber,
    Value<bool>? isPrimary,
    Value<DateTime>? createdAt,
  }) {
    return DbContactPhonesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      label: label ?? this.label,
      number: number ?? this.number,
      normalizedNumber: normalizedNumber ?? this.normalizedNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (normalizedNumber.present) {
      map['normalized_number'] = Variable<String>(normalizedNumber.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbContactPhonesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('label: $label, ')
          ..write('number: $number, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$CallHistoryDatabase extends GeneratedDatabase {
  _$CallHistoryDatabase(QueryExecutor e) : super(e);
  $CallHistoryDatabaseManager get managers => $CallHistoryDatabaseManager(this);
  late final $CallHistoryEntriesTable callHistoryEntries =
      $CallHistoryEntriesTable(this);
  late final $CallRecordingsTable callRecordings = $CallRecordingsTable(this);
  late final $CallRecordingLinksTable callRecordingLinks =
      $CallRecordingLinksTable(this);
  late final $DbContactsTable dbContacts = $DbContactsTable(this);
  late final $DbContactPhonesTable dbContactPhones = $DbContactPhonesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    callHistoryEntries,
    callRecordings,
    callRecordingLinks,
    dbContacts,
    dbContactPhones,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'call_history_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('call_recordings', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'call_recordings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('call_recording_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'call_history_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('call_recording_links', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$CallHistoryEntriesTableCreateCompanionBuilder =
    CallHistoryEntriesCompanion Function({
      Value<int> id,
      required int callId,
      Value<String?> sessionKey,
      required String direction,
      required String status,
      required String remoteUri,
      required String phoneNumber,
      Value<String?> displayName,
      Value<String?> contactId,
      Value<int?> accountId,
      Value<String?> accountLabel,
      required DateTime startedAt,
      Value<DateTime?> ringingAt,
      Value<DateTime?> answeredAt,
      Value<DateTime?> mediaConnectedAt,
      required DateTime endedAt,
      Value<int> durationSeconds,
      Value<int> ringSeconds,
      Value<int?> timeToRingingMs,
      Value<int?> ringingToAnswerMs,
      Value<int?> answerToMediaMs,
      Value<int> holdCount,
      Value<int> holdSeconds,
      Value<int?> sipStatusCode,
      Value<String?> hangupReason,
      Value<String?> note,
      Value<DateTime?> missedReadAt,
      required DateTime createdAt,
    });
typedef $$CallHistoryEntriesTableUpdateCompanionBuilder =
    CallHistoryEntriesCompanion Function({
      Value<int> id,
      Value<int> callId,
      Value<String?> sessionKey,
      Value<String> direction,
      Value<String> status,
      Value<String> remoteUri,
      Value<String> phoneNumber,
      Value<String?> displayName,
      Value<String?> contactId,
      Value<int?> accountId,
      Value<String?> accountLabel,
      Value<DateTime> startedAt,
      Value<DateTime?> ringingAt,
      Value<DateTime?> answeredAt,
      Value<DateTime?> mediaConnectedAt,
      Value<DateTime> endedAt,
      Value<int> durationSeconds,
      Value<int> ringSeconds,
      Value<int?> timeToRingingMs,
      Value<int?> ringingToAnswerMs,
      Value<int?> answerToMediaMs,
      Value<int> holdCount,
      Value<int> holdSeconds,
      Value<int?> sipStatusCode,
      Value<String?> hangupReason,
      Value<String?> note,
      Value<DateTime?> missedReadAt,
      Value<DateTime> createdAt,
    });

final class $$CallHistoryEntriesTableReferences
    extends
        BaseReferences<
          _$CallHistoryDatabase,
          $CallHistoryEntriesTable,
          CallHistoryEntry
        > {
  $$CallHistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CallRecordingsTable, List<CallRecording>>
  _callRecordingsRefsTable(_$CallHistoryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.callRecordings,
        aliasName:
            'call_history_entries__id__call_recordings__history_entry_id',
      );

  $$CallRecordingsTableProcessedTableManager get callRecordingsRefs {
    final manager = $$CallRecordingsTableTableManager(
      $_db,
      $_db.callRecordings,
    ).filter((f) => f.historyEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_callRecordingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CallRecordingLinksTable, List<CallRecordingLink>>
  _callRecordingLinksRefsTable(_$CallHistoryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.callRecordingLinks,
        aliasName:
            'call_history_entries__id__call_recording_links__history_entry_id',
      );

  $$CallRecordingLinksTableProcessedTableManager get callRecordingLinksRefs {
    final manager = $$CallRecordingLinksTableTableManager(
      $_db,
      $_db.callRecordingLinks,
    ).filter((f) => f.historyEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _callRecordingLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CallHistoryEntriesTableFilterComposer
    extends Composer<_$CallHistoryDatabase, $CallHistoryEntriesTable> {
  $$CallHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUri => $composableBuilder(
    column: $table.remoteUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ringingAt => $composableBuilder(
    column: $table.ringingAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get mediaConnectedAt => $composableBuilder(
    column: $table.mediaConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ringSeconds => $composableBuilder(
    column: $table.ringSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeToRingingMs => $composableBuilder(
    column: $table.timeToRingingMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ringingToAnswerMs => $composableBuilder(
    column: $table.ringingToAnswerMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answerToMediaMs => $composableBuilder(
    column: $table.answerToMediaMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdCount => $composableBuilder(
    column: $table.holdCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get missedReadAt => $composableBuilder(
    column: $table.missedReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> callRecordingsRefs(
    Expression<bool> Function($$CallRecordingsTableFilterComposer f) f,
  ) {
    final $$CallRecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callRecordings,
      getReferencedColumn: (t) => t.historyEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingsTableFilterComposer(
            $db: $db,
            $table: $db.callRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> callRecordingLinksRefs(
    Expression<bool> Function($$CallRecordingLinksTableFilterComposer f) f,
  ) {
    final $$CallRecordingLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callRecordingLinks,
      getReferencedColumn: (t) => t.historyEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingLinksTableFilterComposer(
            $db: $db,
            $table: $db.callRecordingLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CallHistoryEntriesTableOrderingComposer
    extends Composer<_$CallHistoryDatabase, $CallHistoryEntriesTable> {
  $$CallHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUri => $composableBuilder(
    column: $table.remoteUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ringingAt => $composableBuilder(
    column: $table.ringingAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get mediaConnectedAt => $composableBuilder(
    column: $table.mediaConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ringSeconds => $composableBuilder(
    column: $table.ringSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeToRingingMs => $composableBuilder(
    column: $table.timeToRingingMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ringingToAnswerMs => $composableBuilder(
    column: $table.ringingToAnswerMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answerToMediaMs => $composableBuilder(
    column: $table.answerToMediaMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdCount => $composableBuilder(
    column: $table.holdCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get missedReadAt => $composableBuilder(
    column: $table.missedReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallHistoryEntriesTableAnnotationComposer
    extends Composer<_$CallHistoryDatabase, $CallHistoryEntriesTable> {
  $$CallHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  GeneratedColumn<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get remoteUri =>
      $composableBuilder(column: $table.remoteUri, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ringingAt =>
      $composableBuilder(column: $table.ringingAt, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get mediaConnectedAt => $composableBuilder(
    column: $table.mediaConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ringSeconds => $composableBuilder(
    column: $table.ringSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeToRingingMs => $composableBuilder(
    column: $table.timeToRingingMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ringingToAnswerMs => $composableBuilder(
    column: $table.ringingToAnswerMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answerToMediaMs => $composableBuilder(
    column: $table.answerToMediaMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get holdCount =>
      $composableBuilder(column: $table.holdCount, builder: (column) => column);

  GeneratedColumn<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get missedReadAt => $composableBuilder(
    column: $table.missedReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> callRecordingsRefs<T extends Object>(
    Expression<T> Function($$CallRecordingsTableAnnotationComposer a) f,
  ) {
    final $$CallRecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callRecordings,
      getReferencedColumn: (t) => t.historyEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> callRecordingLinksRefs<T extends Object>(
    Expression<T> Function($$CallRecordingLinksTableAnnotationComposer a) f,
  ) {
    final $$CallRecordingLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.callRecordingLinks,
          getReferencedColumn: (t) => t.historyEntryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CallRecordingLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.callRecordingLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CallHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$CallHistoryDatabase,
          $CallHistoryEntriesTable,
          CallHistoryEntry,
          $$CallHistoryEntriesTableFilterComposer,
          $$CallHistoryEntriesTableOrderingComposer,
          $$CallHistoryEntriesTableAnnotationComposer,
          $$CallHistoryEntriesTableCreateCompanionBuilder,
          $$CallHistoryEntriesTableUpdateCompanionBuilder,
          (CallHistoryEntry, $$CallHistoryEntriesTableReferences),
          CallHistoryEntry,
          PrefetchHooks Function({
            bool callRecordingsRefs,
            bool callRecordingLinksRefs,
          })
        > {
  $$CallHistoryEntriesTableTableManager(
    _$CallHistoryDatabase db,
    $CallHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallHistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> callId = const Value.absent(),
                Value<String?> sessionKey = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> remoteUri = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> accountLabel = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> ringingAt = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<DateTime?> mediaConnectedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> ringSeconds = const Value.absent(),
                Value<int?> timeToRingingMs = const Value.absent(),
                Value<int?> ringingToAnswerMs = const Value.absent(),
                Value<int?> answerToMediaMs = const Value.absent(),
                Value<int> holdCount = const Value.absent(),
                Value<int> holdSeconds = const Value.absent(),
                Value<int?> sipStatusCode = const Value.absent(),
                Value<String?> hangupReason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> missedReadAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CallHistoryEntriesCompanion(
                id: id,
                callId: callId,
                sessionKey: sessionKey,
                direction: direction,
                status: status,
                remoteUri: remoteUri,
                phoneNumber: phoneNumber,
                displayName: displayName,
                contactId: contactId,
                accountId: accountId,
                accountLabel: accountLabel,
                startedAt: startedAt,
                ringingAt: ringingAt,
                answeredAt: answeredAt,
                mediaConnectedAt: mediaConnectedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                ringSeconds: ringSeconds,
                timeToRingingMs: timeToRingingMs,
                ringingToAnswerMs: ringingToAnswerMs,
                answerToMediaMs: answerToMediaMs,
                holdCount: holdCount,
                holdSeconds: holdSeconds,
                sipStatusCode: sipStatusCode,
                hangupReason: hangupReason,
                note: note,
                missedReadAt: missedReadAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int callId,
                Value<String?> sessionKey = const Value.absent(),
                required String direction,
                required String status,
                required String remoteUri,
                required String phoneNumber,
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> accountLabel = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> ringingAt = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<DateTime?> mediaConnectedAt = const Value.absent(),
                required DateTime endedAt,
                Value<int> durationSeconds = const Value.absent(),
                Value<int> ringSeconds = const Value.absent(),
                Value<int?> timeToRingingMs = const Value.absent(),
                Value<int?> ringingToAnswerMs = const Value.absent(),
                Value<int?> answerToMediaMs = const Value.absent(),
                Value<int> holdCount = const Value.absent(),
                Value<int> holdSeconds = const Value.absent(),
                Value<int?> sipStatusCode = const Value.absent(),
                Value<String?> hangupReason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> missedReadAt = const Value.absent(),
                required DateTime createdAt,
              }) => CallHistoryEntriesCompanion.insert(
                id: id,
                callId: callId,
                sessionKey: sessionKey,
                direction: direction,
                status: status,
                remoteUri: remoteUri,
                phoneNumber: phoneNumber,
                displayName: displayName,
                contactId: contactId,
                accountId: accountId,
                accountLabel: accountLabel,
                startedAt: startedAt,
                ringingAt: ringingAt,
                answeredAt: answeredAt,
                mediaConnectedAt: mediaConnectedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                ringSeconds: ringSeconds,
                timeToRingingMs: timeToRingingMs,
                ringingToAnswerMs: ringingToAnswerMs,
                answerToMediaMs: answerToMediaMs,
                holdCount: holdCount,
                holdSeconds: holdSeconds,
                sipStatusCode: sipStatusCode,
                hangupReason: hangupReason,
                note: note,
                missedReadAt: missedReadAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallHistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({callRecordingsRefs = false, callRecordingLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (callRecordingsRefs) db.callRecordings,
                    if (callRecordingLinksRefs) db.callRecordingLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (callRecordingsRefs)
                        await $_getPrefetchedData<
                          CallHistoryEntry,
                          $CallHistoryEntriesTable,
                          CallRecording
                        >(
                          currentTable: table,
                          referencedTable: $$CallHistoryEntriesTableReferences
                              ._callRecordingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallHistoryEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).callRecordingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.historyEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (callRecordingLinksRefs)
                        await $_getPrefetchedData<
                          CallHistoryEntry,
                          $CallHistoryEntriesTable,
                          CallRecordingLink
                        >(
                          currentTable: table,
                          referencedTable: $$CallHistoryEntriesTableReferences
                              ._callRecordingLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallHistoryEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).callRecordingLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.historyEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CallHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CallHistoryDatabase,
      $CallHistoryEntriesTable,
      CallHistoryEntry,
      $$CallHistoryEntriesTableFilterComposer,
      $$CallHistoryEntriesTableOrderingComposer,
      $$CallHistoryEntriesTableAnnotationComposer,
      $$CallHistoryEntriesTableCreateCompanionBuilder,
      $$CallHistoryEntriesTableUpdateCompanionBuilder,
      (CallHistoryEntry, $$CallHistoryEntriesTableReferences),
      CallHistoryEntry,
      PrefetchHooks Function({
        bool callRecordingsRefs,
        bool callRecordingLinksRefs,
      })
    >;
typedef $$CallRecordingsTableCreateCompanionBuilder =
    CallRecordingsCompanion Function({
      Value<int> id,
      Value<int?> historyEntryId,
      required String sessionKey,
      required int callId,
      Value<String> kind,
      required String relativePath,
      required String status,
      Value<String> format,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      Value<int> fileSizeBytes,
      Value<String?> failureReason,
      required DateTime createdAt,
    });
typedef $$CallRecordingsTableUpdateCompanionBuilder =
    CallRecordingsCompanion Function({
      Value<int> id,
      Value<int?> historyEntryId,
      Value<String> sessionKey,
      Value<int> callId,
      Value<String> kind,
      Value<String> relativePath,
      Value<String> status,
      Value<String> format,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      Value<int> fileSizeBytes,
      Value<String?> failureReason,
      Value<DateTime> createdAt,
    });

final class $$CallRecordingsTableReferences
    extends
        BaseReferences<
          _$CallHistoryDatabase,
          $CallRecordingsTable,
          CallRecording
        > {
  $$CallRecordingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallHistoryEntriesTable _historyEntryIdTable(
    _$CallHistoryDatabase db,
  ) => db.callHistoryEntries.createAlias(
    'call_recordings__history_entry_id__call_history_entries__id',
  );

  $$CallHistoryEntriesTableProcessedTableManager? get historyEntryId {
    final $_column = $_itemColumn<int>('history_entry_id');
    if ($_column == null) return null;
    final manager = $$CallHistoryEntriesTableTableManager(
      $_db,
      $_db.callHistoryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_historyEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CallRecordingLinksTable, List<CallRecordingLink>>
  _callRecordingLinksRefsTable(_$CallHistoryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.callRecordingLinks,
        aliasName: 'call_recordings__id__call_recording_links__recording_id',
      );

  $$CallRecordingLinksTableProcessedTableManager get callRecordingLinksRefs {
    final manager = $$CallRecordingLinksTableTableManager(
      $_db,
      $_db.callRecordingLinks,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _callRecordingLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CallRecordingsTableFilterComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingsTable> {
  $$CallRecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallHistoryEntriesTableFilterComposer get historyEntryId {
    final $$CallHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyEntryId,
      referencedTable: $db.callHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.callHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> callRecordingLinksRefs(
    Expression<bool> Function($$CallRecordingLinksTableFilterComposer f) f,
  ) {
    final $$CallRecordingLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callRecordingLinks,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingLinksTableFilterComposer(
            $db: $db,
            $table: $db.callRecordingLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CallRecordingsTableOrderingComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingsTable> {
  $$CallRecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallHistoryEntriesTableOrderingComposer get historyEntryId {
    final $$CallHistoryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyEntryId,
      referencedTable: $db.callHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallHistoryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.callHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallRecordingsTableAnnotationComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingsTable> {
  $$CallRecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionKey => $composableBuilder(
    column: $table.sessionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CallHistoryEntriesTableAnnotationComposer get historyEntryId {
    final $$CallHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.historyEntryId,
          referencedTable: $db.callHistoryEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CallHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.callHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> callRecordingLinksRefs<T extends Object>(
    Expression<T> Function($$CallRecordingLinksTableAnnotationComposer a) f,
  ) {
    final $$CallRecordingLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.callRecordingLinks,
          getReferencedColumn: (t) => t.recordingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CallRecordingLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.callRecordingLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CallRecordingsTableTableManager
    extends
        RootTableManager<
          _$CallHistoryDatabase,
          $CallRecordingsTable,
          CallRecording,
          $$CallRecordingsTableFilterComposer,
          $$CallRecordingsTableOrderingComposer,
          $$CallRecordingsTableAnnotationComposer,
          $$CallRecordingsTableCreateCompanionBuilder,
          $$CallRecordingsTableUpdateCompanionBuilder,
          (CallRecording, $$CallRecordingsTableReferences),
          CallRecording,
          PrefetchHooks Function({
            bool historyEntryId,
            bool callRecordingLinksRefs,
          })
        > {
  $$CallRecordingsTableTableManager(
    _$CallHistoryDatabase db,
    $CallRecordingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallRecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallRecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallRecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> historyEntryId = const Value.absent(),
                Value<String> sessionKey = const Value.absent(),
                Value<int> callId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CallRecordingsCompanion(
                id: id,
                historyEntryId: historyEntryId,
                sessionKey: sessionKey,
                callId: callId,
                kind: kind,
                relativePath: relativePath,
                status: status,
                format: format,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                failureReason: failureReason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> historyEntryId = const Value.absent(),
                required String sessionKey,
                required int callId,
                Value<String> kind = const Value.absent(),
                required String relativePath,
                required String status,
                Value<String> format = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required DateTime createdAt,
              }) => CallRecordingsCompanion.insert(
                id: id,
                historyEntryId: historyEntryId,
                sessionKey: sessionKey,
                callId: callId,
                kind: kind,
                relativePath: relativePath,
                status: status,
                format: format,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                failureReason: failureReason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallRecordingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({historyEntryId = false, callRecordingLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (callRecordingLinksRefs) db.callRecordingLinks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (historyEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.historyEntryId,
                                    referencedTable:
                                        $$CallRecordingsTableReferences
                                            ._historyEntryIdTable(db),
                                    referencedColumn:
                                        $$CallRecordingsTableReferences
                                            ._historyEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (callRecordingLinksRefs)
                        await $_getPrefetchedData<
                          CallRecording,
                          $CallRecordingsTable,
                          CallRecordingLink
                        >(
                          currentTable: table,
                          referencedTable: $$CallRecordingsTableReferences
                              ._callRecordingLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CallRecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).callRecordingLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recordingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CallRecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CallHistoryDatabase,
      $CallRecordingsTable,
      CallRecording,
      $$CallRecordingsTableFilterComposer,
      $$CallRecordingsTableOrderingComposer,
      $$CallRecordingsTableAnnotationComposer,
      $$CallRecordingsTableCreateCompanionBuilder,
      $$CallRecordingsTableUpdateCompanionBuilder,
      (CallRecording, $$CallRecordingsTableReferences),
      CallRecording,
      PrefetchHooks Function({bool historyEntryId, bool callRecordingLinksRefs})
    >;
typedef $$CallRecordingLinksTableCreateCompanionBuilder =
    CallRecordingLinksCompanion Function({
      required int recordingId,
      required String callSessionKey,
      required int callId,
      Value<int?> historyEntryId,
      required DateTime joinedAt,
      Value<DateTime?> leftAt,
      Value<int> rowid,
    });
typedef $$CallRecordingLinksTableUpdateCompanionBuilder =
    CallRecordingLinksCompanion Function({
      Value<int> recordingId,
      Value<String> callSessionKey,
      Value<int> callId,
      Value<int?> historyEntryId,
      Value<DateTime> joinedAt,
      Value<DateTime?> leftAt,
      Value<int> rowid,
    });

final class $$CallRecordingLinksTableReferences
    extends
        BaseReferences<
          _$CallHistoryDatabase,
          $CallRecordingLinksTable,
          CallRecordingLink
        > {
  $$CallRecordingLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallRecordingsTable _recordingIdTable(_$CallHistoryDatabase db) => db
      .callRecordings
      .createAlias('call_recording_links__recording_id__call_recordings__id');

  $$CallRecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<int>('recording_id')!;

    final manager = $$CallRecordingsTableTableManager(
      $_db,
      $_db.callRecordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CallHistoryEntriesTable _historyEntryIdTable(
    _$CallHistoryDatabase db,
  ) => db.callHistoryEntries.createAlias(
    'call_recording_links__history_entry_id__call_history_entries__id',
  );

  $$CallHistoryEntriesTableProcessedTableManager? get historyEntryId {
    final $_column = $_itemColumn<int>('history_entry_id');
    if ($_column == null) return null;
    final manager = $$CallHistoryEntriesTableTableManager(
      $_db,
      $_db.callHistoryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_historyEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CallRecordingLinksTableFilterComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingLinksTable> {
  $$CallRecordingLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get callSessionKey => $composableBuilder(
    column: $table.callSessionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CallRecordingsTableFilterComposer get recordingId {
    final $$CallRecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.callRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingsTableFilterComposer(
            $db: $db,
            $table: $db.callRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CallHistoryEntriesTableFilterComposer get historyEntryId {
    final $$CallHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyEntryId,
      referencedTable: $db.callHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.callHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallRecordingLinksTableOrderingComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingLinksTable> {
  $$CallRecordingLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get callSessionKey => $composableBuilder(
    column: $table.callSessionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callId => $composableBuilder(
    column: $table.callId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallRecordingsTableOrderingComposer get recordingId {
    final $$CallRecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.callRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.callRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CallHistoryEntriesTableOrderingComposer get historyEntryId {
    final $$CallHistoryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyEntryId,
      referencedTable: $db.callHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallHistoryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.callHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallRecordingLinksTableAnnotationComposer
    extends Composer<_$CallHistoryDatabase, $CallRecordingLinksTable> {
  $$CallRecordingLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get callSessionKey => $composableBuilder(
    column: $table.callSessionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get leftAt =>
      $composableBuilder(column: $table.leftAt, builder: (column) => column);

  $$CallRecordingsTableAnnotationComposer get recordingId {
    final $$CallRecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.callRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallRecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.callRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CallHistoryEntriesTableAnnotationComposer get historyEntryId {
    final $$CallHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.historyEntryId,
          referencedTable: $db.callHistoryEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CallHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.callHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CallRecordingLinksTableTableManager
    extends
        RootTableManager<
          _$CallHistoryDatabase,
          $CallRecordingLinksTable,
          CallRecordingLink,
          $$CallRecordingLinksTableFilterComposer,
          $$CallRecordingLinksTableOrderingComposer,
          $$CallRecordingLinksTableAnnotationComposer,
          $$CallRecordingLinksTableCreateCompanionBuilder,
          $$CallRecordingLinksTableUpdateCompanionBuilder,
          (CallRecordingLink, $$CallRecordingLinksTableReferences),
          CallRecordingLink,
          PrefetchHooks Function({bool recordingId, bool historyEntryId})
        > {
  $$CallRecordingLinksTableTableManager(
    _$CallHistoryDatabase db,
    $CallRecordingLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallRecordingLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallRecordingLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallRecordingLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> recordingId = const Value.absent(),
                Value<String> callSessionKey = const Value.absent(),
                Value<int> callId = const Value.absent(),
                Value<int?> historyEntryId = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<DateTime?> leftAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallRecordingLinksCompanion(
                recordingId: recordingId,
                callSessionKey: callSessionKey,
                callId: callId,
                historyEntryId: historyEntryId,
                joinedAt: joinedAt,
                leftAt: leftAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int recordingId,
                required String callSessionKey,
                required int callId,
                Value<int?> historyEntryId = const Value.absent(),
                required DateTime joinedAt,
                Value<DateTime?> leftAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallRecordingLinksCompanion.insert(
                recordingId: recordingId,
                callSessionKey: callSessionKey,
                callId: callId,
                historyEntryId: historyEntryId,
                joinedAt: joinedAt,
                leftAt: leftAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallRecordingLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recordingId = false, historyEntryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (recordingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recordingId,
                                    referencedTable:
                                        $$CallRecordingLinksTableReferences
                                            ._recordingIdTable(db),
                                    referencedColumn:
                                        $$CallRecordingLinksTableReferences
                                            ._recordingIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (historyEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.historyEntryId,
                                    referencedTable:
                                        $$CallRecordingLinksTableReferences
                                            ._historyEntryIdTable(db),
                                    referencedColumn:
                                        $$CallRecordingLinksTableReferences
                                            ._historyEntryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CallRecordingLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$CallHistoryDatabase,
      $CallRecordingLinksTable,
      CallRecordingLink,
      $$CallRecordingLinksTableFilterComposer,
      $$CallRecordingLinksTableOrderingComposer,
      $$CallRecordingLinksTableAnnotationComposer,
      $$CallRecordingLinksTableCreateCompanionBuilder,
      $$CallRecordingLinksTableUpdateCompanionBuilder,
      (CallRecordingLink, $$CallRecordingLinksTableReferences),
      CallRecordingLink,
      PrefetchHooks Function({bool recordingId, bool historyEntryId})
    >;
typedef $$DbContactsTableCreateCompanionBuilder =
    DbContactsCompanion Function({
      required String id,
      required String name,
      required String number,
      required String normalizedNumber,
      Value<String> company,
      Value<String> department,
      Value<String> remark,
      Value<bool> isFavorite,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$DbContactsTableUpdateCompanionBuilder =
    DbContactsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> number,
      Value<String> normalizedNumber,
      Value<String> company,
      Value<String> department,
      Value<String> remark,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$DbContactsTableReferences
    extends BaseReferences<_$CallHistoryDatabase, $DbContactsTable, DbContact> {
  $$DbContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbContactPhonesTable, List<DbContactPhone>>
  _dbContactPhonesRefsTable(_$CallHistoryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dbContactPhones,
        aliasName: 'db_contacts__id__db_contact_phones__contact_id',
      );

  $$DbContactPhonesTableProcessedTableManager get dbContactPhonesRefs {
    final manager = $$DbContactPhonesTableTableManager(
      $_db,
      $_db.dbContactPhones,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbContactPhonesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbContactsTableFilterComposer
    extends Composer<_$CallHistoryDatabase, $DbContactsTable> {
  $$DbContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbContactPhonesRefs(
    Expression<bool> Function($$DbContactPhonesTableFilterComposer f) f,
  ) {
    final $$DbContactPhonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbContactPhones,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbContactPhonesTableFilterComposer(
            $db: $db,
            $table: $db.dbContactPhones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbContactsTableOrderingComposer
    extends Composer<_$CallHistoryDatabase, $DbContactsTable> {
  $$DbContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbContactsTableAnnotationComposer
    extends Composer<_$CallHistoryDatabase, $DbContactsTable> {
  $$DbContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> dbContactPhonesRefs<T extends Object>(
    Expression<T> Function($$DbContactPhonesTableAnnotationComposer a) f,
  ) {
    final $$DbContactPhonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbContactPhones,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbContactPhonesTableAnnotationComposer(
            $db: $db,
            $table: $db.dbContactPhones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbContactsTableTableManager
    extends
        RootTableManager<
          _$CallHistoryDatabase,
          $DbContactsTable,
          DbContact,
          $$DbContactsTableFilterComposer,
          $$DbContactsTableOrderingComposer,
          $$DbContactsTableAnnotationComposer,
          $$DbContactsTableCreateCompanionBuilder,
          $$DbContactsTableUpdateCompanionBuilder,
          (DbContact, $$DbContactsTableReferences),
          DbContact,
          PrefetchHooks Function({bool dbContactPhonesRefs})
        > {
  $$DbContactsTableTableManager(
    _$CallHistoryDatabase db,
    $DbContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> normalizedNumber = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> department = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbContactsCompanion(
                id: id,
                name: name,
                number: number,
                normalizedNumber: normalizedNumber,
                company: company,
                department: department,
                remark: remark,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String number,
                required String normalizedNumber,
                Value<String> company = const Value.absent(),
                Value<String> department = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbContactsCompanion.insert(
                id: id,
                name: name,
                number: number,
                normalizedNumber: normalizedNumber,
                company: company,
                department: department,
                remark: remark,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DbContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dbContactPhonesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dbContactPhonesRefs) db.dbContactPhones,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbContactPhonesRefs)
                    await $_getPrefetchedData<
                      DbContact,
                      $DbContactsTable,
                      DbContactPhone
                    >(
                      currentTable: table,
                      referencedTable: $$DbContactsTableReferences
                          ._dbContactPhonesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DbContactsTableReferences(
                            db,
                            table,
                            p0,
                          ).dbContactPhonesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contactId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$CallHistoryDatabase,
      $DbContactsTable,
      DbContact,
      $$DbContactsTableFilterComposer,
      $$DbContactsTableOrderingComposer,
      $$DbContactsTableAnnotationComposer,
      $$DbContactsTableCreateCompanionBuilder,
      $$DbContactsTableUpdateCompanionBuilder,
      (DbContact, $$DbContactsTableReferences),
      DbContact,
      PrefetchHooks Function({bool dbContactPhonesRefs})
    >;
typedef $$DbContactPhonesTableCreateCompanionBuilder =
    DbContactPhonesCompanion Function({
      Value<int> id,
      required String contactId,
      Value<String> label,
      required String number,
      required String normalizedNumber,
      Value<bool> isPrimary,
      required DateTime createdAt,
    });
typedef $$DbContactPhonesTableUpdateCompanionBuilder =
    DbContactPhonesCompanion Function({
      Value<int> id,
      Value<String> contactId,
      Value<String> label,
      Value<String> number,
      Value<String> normalizedNumber,
      Value<bool> isPrimary,
      Value<DateTime> createdAt,
    });

final class $$DbContactPhonesTableReferences
    extends
        BaseReferences<
          _$CallHistoryDatabase,
          $DbContactPhonesTable,
          DbContactPhone
        > {
  $$DbContactPhonesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbContactsTable _contactIdTable(_$CallHistoryDatabase db) => db
      .dbContacts
      .createAlias('db_contact_phones__contact_id__db_contacts__id');

  $$DbContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$DbContactsTableTableManager(
      $_db,
      $_db.dbContacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbContactPhonesTableFilterComposer
    extends Composer<_$CallHistoryDatabase, $DbContactPhonesTable> {
  $$DbContactPhonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DbContactsTableFilterComposer get contactId {
    final $$DbContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.dbContacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbContactsTableFilterComposer(
            $db: $db,
            $table: $db.dbContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbContactPhonesTableOrderingComposer
    extends Composer<_$CallHistoryDatabase, $DbContactPhonesTable> {
  $$DbContactPhonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbContactsTableOrderingComposer get contactId {
    final $$DbContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.dbContacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbContactsTableOrderingComposer(
            $db: $db,
            $table: $db.dbContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbContactPhonesTableAnnotationComposer
    extends Composer<_$CallHistoryDatabase, $DbContactPhonesTable> {
  $$DbContactPhonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DbContactsTableAnnotationComposer get contactId {
    final $$DbContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.dbContacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbContactPhonesTableTableManager
    extends
        RootTableManager<
          _$CallHistoryDatabase,
          $DbContactPhonesTable,
          DbContactPhone,
          $$DbContactPhonesTableFilterComposer,
          $$DbContactPhonesTableOrderingComposer,
          $$DbContactPhonesTableAnnotationComposer,
          $$DbContactPhonesTableCreateCompanionBuilder,
          $$DbContactPhonesTableUpdateCompanionBuilder,
          (DbContactPhone, $$DbContactPhonesTableReferences),
          DbContactPhone,
          PrefetchHooks Function({bool contactId})
        > {
  $$DbContactPhonesTableTableManager(
    _$CallHistoryDatabase db,
    $DbContactPhonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbContactPhonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbContactPhonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbContactPhonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> normalizedNumber = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DbContactPhonesCompanion(
                id: id,
                contactId: contactId,
                label: label,
                number: number,
                normalizedNumber: normalizedNumber,
                isPrimary: isPrimary,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contactId,
                Value<String> label = const Value.absent(),
                required String number,
                required String normalizedNumber,
                Value<bool> isPrimary = const Value.absent(),
                required DateTime createdAt,
              }) => DbContactPhonesCompanion.insert(
                id: id,
                contactId: contactId,
                label: label,
                number: number,
                normalizedNumber: normalizedNumber,
                isPrimary: isPrimary,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DbContactPhonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable:
                                    $$DbContactPhonesTableReferences
                                        ._contactIdTable(db),
                                referencedColumn:
                                    $$DbContactPhonesTableReferences
                                        ._contactIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbContactPhonesTableProcessedTableManager =
    ProcessedTableManager<
      _$CallHistoryDatabase,
      $DbContactPhonesTable,
      DbContactPhone,
      $$DbContactPhonesTableFilterComposer,
      $$DbContactPhonesTableOrderingComposer,
      $$DbContactPhonesTableAnnotationComposer,
      $$DbContactPhonesTableCreateCompanionBuilder,
      $$DbContactPhonesTableUpdateCompanionBuilder,
      (DbContactPhone, $$DbContactPhonesTableReferences),
      DbContactPhone,
      PrefetchHooks Function({bool contactId})
    >;

class $CallHistoryDatabaseManager {
  final _$CallHistoryDatabase _db;
  $CallHistoryDatabaseManager(this._db);
  $$CallHistoryEntriesTableTableManager get callHistoryEntries =>
      $$CallHistoryEntriesTableTableManager(_db, _db.callHistoryEntries);
  $$CallRecordingsTableTableManager get callRecordings =>
      $$CallRecordingsTableTableManager(_db, _db.callRecordings);
  $$CallRecordingLinksTableTableManager get callRecordingLinks =>
      $$CallRecordingLinksTableTableManager(_db, _db.callRecordingLinks);
  $$DbContactsTableTableManager get dbContacts =>
      $$DbContactsTableTableManager(_db, _db.dbContacts);
  $$DbContactPhonesTableTableManager get dbContactPhones =>
      $$DbContactPhonesTableTableManager(_db, _db.dbContactPhones);
}
