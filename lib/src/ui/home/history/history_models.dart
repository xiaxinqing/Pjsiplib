part of '../../../../main.dart';

/// 通话记录日期筛选项：提供常用时间范围和展示文案。
enum _HistoryDateFilter {
  all('全部时间'),
  today('今天'),
  last7Days('近 7 天'),
  thisMonth('本月');

  const _HistoryDateFilter(this.label);

  final String label;

  _HistoryDateRange? range() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      _HistoryDateFilter.all => null,
      _HistoryDateFilter.today => _HistoryDateRange(
        today,
        today.add(const Duration(days: 1)),
      ),
      _HistoryDateFilter.last7Days => _HistoryDateRange(
        today.subtract(const Duration(days: 6)),
        today.add(const Duration(days: 1)),
      ),
      _HistoryDateFilter.thisMonth => _HistoryDateRange(
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      ),
    };
  }
}

/// 通话记录日期范围：保存查询起止时间。
class _HistoryDateRange {
  const _HistoryDateRange(this.from, this.before);

  final DateTime from;
  final DateTime before;
}

/// 通话记录类型筛选：比单纯方向多一个“未接”，但未接仍只代表本机漏接来电。
enum _HistoryCallFilter {
  all('全部', null, false),
  outbound('呼出', CallHistoryDirection.outbound, false),
  inbound('来电', CallHistoryDirection.inbound, false),
  missed('未接', CallHistoryDirection.inbound, true);

  const _HistoryCallFilter(this.label, this.direction, this.missedOnly);

  final String label;
  final CallHistoryDirection? direction;
  final bool missedOnly;
}

/// 通话记录视图模型：统一数据库记录和实时通话在列表里的展示字段。
class _HistoryItem {
  const _HistoryItem({
    required this.key,
    required this.callId,
    required this.direction,
    required this.statusLabel,
    required this.remoteUri,
    required this.phoneNumber,
    required this.startedAt,
    required this.durationSeconds,
    this.databaseId,
    this.isLive = false,
    this.status,
    this.displayName,
    this.contactId,
    this.deletedContactId,
    this.accountId,
    this.accountLabel,
    this.ringingAt,
    this.answeredAt,
    this.mediaConnectedAt,
    this.endedAt,
    this.sipStatusCode,
    this.hangupReason,
    this.note,
    this.missedReadAt,
    this.timeToRingingMs,
    this.ringingToAnswerMs,
    this.answerToMediaMs,
    this.holdCount = 0,
    this.holdSeconds = 0,
  });

  final String key;
  final int? databaseId;
  final int callId;
  final bool isLive;
  final CallHistoryDirection direction;
  final CallHistoryStatus? status;
  final String statusLabel;
  final String remoteUri;
  final String phoneNumber;
  final String? displayName;
  final String? contactId;
  final String? deletedContactId;
  final int? accountId;
  final String? accountLabel;
  final DateTime startedAt;
  final DateTime? ringingAt;
  final DateTime? answeredAt;
  final DateTime? mediaConnectedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int? sipStatusCode;
  final String? hangupReason;
  final String? note;
  final DateTime? missedReadAt;
  final int? timeToRingingMs;
  final int? ringingToAnswerMs;
  final int? answerToMediaMs;
  final int holdCount;
  final int holdSeconds;

  bool get canDelete => databaseId != null && !isLive;

  bool get canEditNote => databaseId != null && !isLive;

  bool get isMissedCall =>
      !isLive &&
      databaseId != null &&
      direction == CallHistoryDirection.inbound &&
      status == CallHistoryStatus.missed &&
      answeredAt == null;

  bool get isUnreadMissedCall =>
      isMissedCall && answeredAt == null && missedReadAt == null;

  bool get hasCurrentContact => contactId != null;

  bool get hasDeletedContactSnapshot =>
      contactId == null && deletedContactId != null;

  bool get hasCallStats =>
      timeToRingingMs != null ||
      ringingToAnswerMs != null ||
      answerToMediaMs != null ||
      holdCount > 0 ||
      holdSeconds > 0;
}

/// 通话记录分组：按日期标签聚合记录列表。
class _HistoryGroup {
  _HistoryGroup(this.label, this.items);

  final String label;
  final List<_HistoryItem> items;
}
