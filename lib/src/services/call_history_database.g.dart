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
    direction,
    status,
    remoteUri,
    phoneNumber,
    displayName,
    contactId,
    accountId,
    accountLabel,
    startedAt,
    answeredAt,
    endedAt,
    durationSeconds,
    ringSeconds,
    sipStatusCode,
    hangupReason,
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
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
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
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
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
      sipStatusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sip_status_code'],
      ),
      hangupReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hangup_reason'],
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
  final String direction;
  final String status;
  final String remoteUri;
  final String phoneNumber;
  final String? displayName;
  final String? contactId;
  final int? accountId;
  final String? accountLabel;
  final DateTime startedAt;
  final DateTime? answeredAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int ringSeconds;
  final int? sipStatusCode;
  final String? hangupReason;
  final DateTime createdAt;
  const CallHistoryEntry({
    required this.id,
    required this.callId,
    required this.direction,
    required this.status,
    required this.remoteUri,
    required this.phoneNumber,
    this.displayName,
    this.contactId,
    this.accountId,
    this.accountLabel,
    required this.startedAt,
    this.answeredAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.ringSeconds,
    this.sipStatusCode,
    this.hangupReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['call_id'] = Variable<int>(callId);
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
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['ring_seconds'] = Variable<int>(ringSeconds);
    if (!nullToAbsent || sipStatusCode != null) {
      map['sip_status_code'] = Variable<int>(sipStatusCode);
    }
    if (!nullToAbsent || hangupReason != null) {
      map['hangup_reason'] = Variable<String>(hangupReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CallHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return CallHistoryEntriesCompanion(
      id: Value(id),
      callId: Value(callId),
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
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      ringSeconds: Value(ringSeconds),
      sipStatusCode: sipStatusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(sipStatusCode),
      hangupReason: hangupReason == null && nullToAbsent
          ? const Value.absent()
          : Value(hangupReason),
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
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String>(json['status']),
      remoteUri: serializer.fromJson<String>(json['remoteUri']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      accountLabel: serializer.fromJson<String?>(json['accountLabel']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      ringSeconds: serializer.fromJson<int>(json['ringSeconds']),
      sipStatusCode: serializer.fromJson<int?>(json['sipStatusCode']),
      hangupReason: serializer.fromJson<String?>(json['hangupReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'callId': serializer.toJson<int>(callId),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String>(status),
      'remoteUri': serializer.toJson<String>(remoteUri),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'displayName': serializer.toJson<String?>(displayName),
      'contactId': serializer.toJson<String?>(contactId),
      'accountId': serializer.toJson<int?>(accountId),
      'accountLabel': serializer.toJson<String?>(accountLabel),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'ringSeconds': serializer.toJson<int>(ringSeconds),
      'sipStatusCode': serializer.toJson<int?>(sipStatusCode),
      'hangupReason': serializer.toJson<String?>(hangupReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CallHistoryEntry copyWith({
    int? id,
    int? callId,
    String? direction,
    String? status,
    String? remoteUri,
    String? phoneNumber,
    Value<String?> displayName = const Value.absent(),
    Value<String?> contactId = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    Value<String?> accountLabel = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> answeredAt = const Value.absent(),
    DateTime? endedAt,
    int? durationSeconds,
    int? ringSeconds,
    Value<int?> sipStatusCode = const Value.absent(),
    Value<String?> hangupReason = const Value.absent(),
    DateTime? createdAt,
  }) => CallHistoryEntry(
    id: id ?? this.id,
    callId: callId ?? this.callId,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    remoteUri: remoteUri ?? this.remoteUri,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    displayName: displayName.present ? displayName.value : this.displayName,
    contactId: contactId.present ? contactId.value : this.contactId,
    accountId: accountId.present ? accountId.value : this.accountId,
    accountLabel: accountLabel.present ? accountLabel.value : this.accountLabel,
    startedAt: startedAt ?? this.startedAt,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
    endedAt: endedAt ?? this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    ringSeconds: ringSeconds ?? this.ringSeconds,
    sipStatusCode: sipStatusCode.present
        ? sipStatusCode.value
        : this.sipStatusCode,
    hangupReason: hangupReason.present ? hangupReason.value : this.hangupReason,
    createdAt: createdAt ?? this.createdAt,
  );
  CallHistoryEntry copyWithCompanion(CallHistoryEntriesCompanion data) {
    return CallHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      callId: data.callId.present ? data.callId.value : this.callId,
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
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      ringSeconds: data.ringSeconds.present
          ? data.ringSeconds.value
          : this.ringSeconds,
      sipStatusCode: data.sipStatusCode.present
          ? data.sipStatusCode.value
          : this.sipStatusCode,
      hangupReason: data.hangupReason.present
          ? data.hangupReason.value
          : this.hangupReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryEntry(')
          ..write('id: $id, ')
          ..write('callId: $callId, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('remoteUri: $remoteUri, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('contactId: $contactId, ')
          ..write('accountId: $accountId, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('startedAt: $startedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('ringSeconds: $ringSeconds, ')
          ..write('sipStatusCode: $sipStatusCode, ')
          ..write('hangupReason: $hangupReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    direction,
    status,
    remoteUri,
    phoneNumber,
    displayName,
    contactId,
    accountId,
    accountLabel,
    startedAt,
    answeredAt,
    endedAt,
    durationSeconds,
    ringSeconds,
    sipStatusCode,
    hangupReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallHistoryEntry &&
          other.id == this.id &&
          other.callId == this.callId &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.remoteUri == this.remoteUri &&
          other.phoneNumber == this.phoneNumber &&
          other.displayName == this.displayName &&
          other.contactId == this.contactId &&
          other.accountId == this.accountId &&
          other.accountLabel == this.accountLabel &&
          other.startedAt == this.startedAt &&
          other.answeredAt == this.answeredAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.ringSeconds == this.ringSeconds &&
          other.sipStatusCode == this.sipStatusCode &&
          other.hangupReason == this.hangupReason &&
          other.createdAt == this.createdAt);
}

class CallHistoryEntriesCompanion extends UpdateCompanion<CallHistoryEntry> {
  final Value<int> id;
  final Value<int> callId;
  final Value<String> direction;
  final Value<String> status;
  final Value<String> remoteUri;
  final Value<String> phoneNumber;
  final Value<String?> displayName;
  final Value<String?> contactId;
  final Value<int?> accountId;
  final Value<String?> accountLabel;
  final Value<DateTime> startedAt;
  final Value<DateTime?> answeredAt;
  final Value<DateTime> endedAt;
  final Value<int> durationSeconds;
  final Value<int> ringSeconds;
  final Value<int?> sipStatusCode;
  final Value<String?> hangupReason;
  final Value<DateTime> createdAt;
  const CallHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.callId = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.remoteUri = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.displayName = const Value.absent(),
    this.contactId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountLabel = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.ringSeconds = const Value.absent(),
    this.sipStatusCode = const Value.absent(),
    this.hangupReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CallHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int callId,
    required String direction,
    required String status,
    required String remoteUri,
    required String phoneNumber,
    this.displayName = const Value.absent(),
    this.contactId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountLabel = const Value.absent(),
    required DateTime startedAt,
    this.answeredAt = const Value.absent(),
    required DateTime endedAt,
    this.durationSeconds = const Value.absent(),
    this.ringSeconds = const Value.absent(),
    this.sipStatusCode = const Value.absent(),
    this.hangupReason = const Value.absent(),
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
    Expression<String>? direction,
    Expression<String>? status,
    Expression<String>? remoteUri,
    Expression<String>? phoneNumber,
    Expression<String>? displayName,
    Expression<String>? contactId,
    Expression<int>? accountId,
    Expression<String>? accountLabel,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? answeredAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<int>? ringSeconds,
    Expression<int>? sipStatusCode,
    Expression<String>? hangupReason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callId != null) 'call_id': callId,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (remoteUri != null) 'remote_uri': remoteUri,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (displayName != null) 'display_name': displayName,
      if (contactId != null) 'contact_id': contactId,
      if (accountId != null) 'account_id': accountId,
      if (accountLabel != null) 'account_label': accountLabel,
      if (startedAt != null) 'started_at': startedAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (ringSeconds != null) 'ring_seconds': ringSeconds,
      if (sipStatusCode != null) 'sip_status_code': sipStatusCode,
      if (hangupReason != null) 'hangup_reason': hangupReason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CallHistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? callId,
    Value<String>? direction,
    Value<String>? status,
    Value<String>? remoteUri,
    Value<String>? phoneNumber,
    Value<String?>? displayName,
    Value<String?>? contactId,
    Value<int?>? accountId,
    Value<String?>? accountLabel,
    Value<DateTime>? startedAt,
    Value<DateTime?>? answeredAt,
    Value<DateTime>? endedAt,
    Value<int>? durationSeconds,
    Value<int>? ringSeconds,
    Value<int?>? sipStatusCode,
    Value<String?>? hangupReason,
    Value<DateTime>? createdAt,
  }) {
    return CallHistoryEntriesCompanion(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      remoteUri: remoteUri ?? this.remoteUri,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      contactId: contactId ?? this.contactId,
      accountId: accountId ?? this.accountId,
      accountLabel: accountLabel ?? this.accountLabel,
      startedAt: startedAt ?? this.startedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      ringSeconds: ringSeconds ?? this.ringSeconds,
      sipStatusCode: sipStatusCode ?? this.sipStatusCode,
      hangupReason: hangupReason ?? this.hangupReason,
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
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
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
    if (sipStatusCode.present) {
      map['sip_status_code'] = Variable<int>(sipStatusCode.value);
    }
    if (hangupReason.present) {
      map['hangup_reason'] = Variable<String>(hangupReason.value);
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
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('remoteUri: $remoteUri, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('contactId: $contactId, ')
          ..write('accountId: $accountId, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('startedAt: $startedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('ringSeconds: $ringSeconds, ')
          ..write('sipStatusCode: $sipStatusCode, ')
          ..write('hangupReason: $hangupReason, ')
          ..write('createdAt: $createdAt')
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
    dbContacts,
    dbContactPhones,
  ];
}

typedef $$CallHistoryEntriesTableCreateCompanionBuilder =
    CallHistoryEntriesCompanion Function({
      Value<int> id,
      required int callId,
      required String direction,
      required String status,
      required String remoteUri,
      required String phoneNumber,
      Value<String?> displayName,
      Value<String?> contactId,
      Value<int?> accountId,
      Value<String?> accountLabel,
      required DateTime startedAt,
      Value<DateTime?> answeredAt,
      required DateTime endedAt,
      Value<int> durationSeconds,
      Value<int> ringSeconds,
      Value<int?> sipStatusCode,
      Value<String?> hangupReason,
      required DateTime createdAt,
    });
typedef $$CallHistoryEntriesTableUpdateCompanionBuilder =
    CallHistoryEntriesCompanion Function({
      Value<int> id,
      Value<int> callId,
      Value<String> direction,
      Value<String> status,
      Value<String> remoteUri,
      Value<String> phoneNumber,
      Value<String?> displayName,
      Value<String?> contactId,
      Value<int?> accountId,
      Value<String?> accountLabel,
      Value<DateTime> startedAt,
      Value<DateTime?> answeredAt,
      Value<DateTime> endedAt,
      Value<int> durationSeconds,
      Value<int> ringSeconds,
      Value<int?> sipStatusCode,
      Value<String?> hangupReason,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
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

  ColumnFilters<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
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

  ColumnOrderings<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
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

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
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

  GeneratedColumn<int> get sipStatusCode => $composableBuilder(
    column: $table.sipStatusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hangupReason => $composableBuilder(
    column: $table.hangupReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            CallHistoryEntry,
            BaseReferences<
              _$CallHistoryDatabase,
              $CallHistoryEntriesTable,
              CallHistoryEntry
            >,
          ),
          CallHistoryEntry,
          PrefetchHooks Function()
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
                Value<String> direction = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> remoteUri = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> accountLabel = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> ringSeconds = const Value.absent(),
                Value<int?> sipStatusCode = const Value.absent(),
                Value<String?> hangupReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CallHistoryEntriesCompanion(
                id: id,
                callId: callId,
                direction: direction,
                status: status,
                remoteUri: remoteUri,
                phoneNumber: phoneNumber,
                displayName: displayName,
                contactId: contactId,
                accountId: accountId,
                accountLabel: accountLabel,
                startedAt: startedAt,
                answeredAt: answeredAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                ringSeconds: ringSeconds,
                sipStatusCode: sipStatusCode,
                hangupReason: hangupReason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int callId,
                required String direction,
                required String status,
                required String remoteUri,
                required String phoneNumber,
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> accountLabel = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> answeredAt = const Value.absent(),
                required DateTime endedAt,
                Value<int> durationSeconds = const Value.absent(),
                Value<int> ringSeconds = const Value.absent(),
                Value<int?> sipStatusCode = const Value.absent(),
                Value<String?> hangupReason = const Value.absent(),
                required DateTime createdAt,
              }) => CallHistoryEntriesCompanion.insert(
                id: id,
                callId: callId,
                direction: direction,
                status: status,
                remoteUri: remoteUri,
                phoneNumber: phoneNumber,
                displayName: displayName,
                contactId: contactId,
                accountId: accountId,
                accountLabel: accountLabel,
                startedAt: startedAt,
                answeredAt: answeredAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                ringSeconds: ringSeconds,
                sipStatusCode: sipStatusCode,
                hangupReason: hangupReason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        CallHistoryEntry,
        BaseReferences<
          _$CallHistoryDatabase,
          $CallHistoryEntriesTable,
          CallHistoryEntry
        >,
      ),
      CallHistoryEntry,
      PrefetchHooks Function()
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
  $$DbContactsTableTableManager get dbContacts =>
      $$DbContactsTableTableManager(_db, _db.dbContacts);
  $$DbContactPhonesTableTableManager get dbContactPhones =>
      $$DbContactPhonesTableTableManager(_db, _db.dbContactPhones);
}
