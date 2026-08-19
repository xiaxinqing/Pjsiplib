part of '../../../../main.dart';

/// 通话记录日期筛选项：仅保存查询语义，展示文案由本地化层提供。
enum _HistoryDateFilter {
  all,
  today,
  last7Days,
  thisMonth;

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

/// 通话记录分页游标：记录当前列表最后一条数据库记录的位置。
///
/// 列表按 startedAt desc, id desc 排序，所以“加载更多”需要同时带上时间和 id，
/// 避免同一秒内多条记录或新记录插入顶部时造成分页重复/漏项。
class _HistoryPageCursor {
  const _HistoryPageCursor({required this.startedAt, required this.id});

  final DateTime startedAt;
  final int id;
}

/// 通话记录类型筛选：比单纯方向多一个“未接”，但未接仍只代表本机漏接来电。
enum _HistoryCallFilter {
  all(null, false),
  outbound(CallHistoryDirection.outbound, false),
  inbound(CallHistoryDirection.inbound, false),
  missed(CallHistoryDirection.inbound, true);

  const _HistoryCallFilter(this.direction, this.missedOnly);

  final CallHistoryDirection? direction;
  final bool missedOnly;
}

/// 返回日期筛选项的本地化显示文案。
String _historyDateFilterLabel(
  _HistoryDateFilter filter,
  AppLocalizations l10n,
) => switch (filter) {
  _HistoryDateFilter.all => l10n.historyDateAll,
  _HistoryDateFilter.today => l10n.historyDateToday,
  _HistoryDateFilter.last7Days => l10n.historyDateLast7Days,
  _HistoryDateFilter.thisMonth => l10n.historyDateThisMonth,
};

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
    this.hasRecording = false,
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
  final bool hasRecording;
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

/// 通话记录懒加载节点：表示一个日期标题或一条通话记录。
///
/// 日期标题和记录行位于 ListView 的同一层，避免同一天的记录被包进 Column 后
/// 在首帧一次性全部构建。
class _HistoryListEntry {
  const _HistoryListEntry.header(this.label) : item = null;

  const _HistoryListEntry.item(this.item) : label = null;

  final String? label;
  final _HistoryItem? item;
}
