part of '../../../main.dart';

const int _historyPageSize = 50;

/// 通话记录页入口：负责历史数据流、实时通话合并、筛选匹配和通用格式化。
extension _HomeHistory on _MyHomePageState {
  /// 通话记录达到该宽度后展示右侧详情。
  ///
  /// 详情内容是辅助信息，必须先保证左侧列表可读。双栏比例是 6:4，
  /// 所以这里需要整体宽度足够大，避免列表区被压到线路和操作列溢出。
  static const double _historyDetailPaneBreakpoint = 800;

  Widget _buildHistoryPage(PjsipUIState uiState, PjsipService service) {
    _traceWorkspacePageBuild(_WorkspaceSection.history);
    final database = ref.watch(callHistoryDatabaseProvider);
    final stream = _watchHistoryEntries(database);
    final unreadMissedStream = _watchUnreadMissedCallCount();
    return StreamBuilder<List<CallHistoryEntry>>(
      stream: stream,
      builder: (context, snapshot) {
        final rawPersistedEntries = snapshot.data ?? const <CallHistoryEntry>[];
        final firstPageHasMore = rawPersistedEntries.length > _historyPageSize;
        final firstPageEntries = rawPersistedEntries.length > _historyPageSize
            ? rawPersistedEntries.take(_historyPageSize).toList()
            : rawPersistedEntries;
        final persistedEntries = _mergeHistoryPersistedEntries(
          firstPageEntries,
          _historyLoadedMoreEntries,
        );
        _historyCurrentPersistedEntries = persistedEntries;
        final hasMorePersistedEntries = _historyLoadedMoreEntries.isEmpty
            ? firstPageHasMore
            : _historyHasMoreAfterLoaded;
        final items = _buildHistoryItems(uiState, persistedEntries);
        final selected = _selectedHistoryItem(items);
        if (snapshot.hasError) {
          _traceWorkspacePageDataReady(
            _WorkspaceSection.history,
            summary: '查询失败=${snapshot.error}',
          );
        } else if (snapshot.hasData) {
          _traceWorkspacePageDataReady(
            _WorkspaceSection.history,
            summary:
                '查询返回=${rawPersistedEntries.length}, '
                '页面条目=${items.length}, 已加载更多=${_historyLoadedMoreEntries.length}',
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _panelBackground,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Column(
            children: [
              _buildHistoryToolbar(
                itemCount: items.length,
                canClearHistory: persistedEntries.isNotEmpty,
                unreadMissedCountStream: unreadMissedStream,
              ),
              const Divider(height: 1),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? _buildHistoryEmptyState(
                        icon: AppIcons.history,
                        title: _historySearchController.text.trim().isEmpty
                            ? '暂无通话记录'
                            : '没有匹配的通话记录',
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final wide =
                              constraints.maxWidth >=
                              _historyDetailPaneBreakpoint;
                          if (!wide) {
                            return _buildHistoryList(
                              items,
                              service,
                              selectedKey: null,
                              showDetailInline: false,
                              hasMorePersistedEntries: hasMorePersistedEntries,
                              persistedEntryCount: persistedEntries.length,
                              isLoadingMore: _historyLoadingMore,
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildHistoryList(
                                  items,
                                  service,
                                  selectedKey: selected?.key,
                                  showDetailInline: true,
                                  hasMorePersistedEntries:
                                      hasMorePersistedEntries,
                                  persistedEntryCount: persistedEntries.length,
                                  isLoadingMore: _historyLoadingMore,
                                ),
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(
                                flex: 4,
                                child: selected == null
                                    ? const SizedBox.shrink()
                                    : _buildHistorySummary(selected),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<List<CallHistoryEntry>> _watchHistoryEntries(
    CallHistoryDatabase database,
  ) {
    final keyword = _historySearchController.text.trim();
    final range = _historyDateFilter.range();
    if (_historyEntriesStream == null ||
        _historyStreamKeyword != keyword ||
        _historyStreamCallFilter != _historyCallFilter ||
        _historyStreamDateFilter != _historyDateFilter) {
      _historyStreamKeyword = keyword;
      _historyStreamCallFilter = _historyCallFilter;
      _historyStreamDateFilter = _historyDateFilter;
      _historyEntriesStream = database.watchRecent(
        keyword: keyword,
        direction: _historyCallFilter.direction,
        missedOnly: _historyCallFilter.missedOnly,
        startedFrom: range?.from,
        startedBefore: range?.before,
        limit: _historyPageSize + 1,
      );
    }
    return _historyEntriesStream!;
  }

  List<CallHistoryEntry> _mergeHistoryPersistedEntries(
    List<CallHistoryEntry> firstPage,
    List<CallHistoryEntry> loadedMore,
  ) {
    final seenIds = <int>{};
    final entries = <CallHistoryEntry>[];
    for (final entry in [...firstPage, ...loadedMore]) {
      if (seenIds.add(entry.id)) entries.add(entry);
    }
    entries.sort((a, b) {
      final started = b.startedAt.compareTo(a.startedAt);
      if (started != 0) return started;
      return b.id.compareTo(a.id);
    });
    return entries;
  }

  _HistoryPageCursor? _historyCursorForEntries(List<CallHistoryEntry> entries) {
    if (entries.isEmpty) return null;
    final last = entries.last;
    return _HistoryPageCursor(startedAt: last.startedAt, id: last.id);
  }

  List<_HistoryItem> _buildHistoryItems(
    PjsipUIState uiState,
    List<CallHistoryEntry> persistedEntries,
  ) {
    final contactIndex = _historyContactIndexForCurrentContacts();
    final persistedKeys = persistedEntries
        .map(
          (entry) => _archivedCallKey(
            callId: entry.callId,
            startedAt: entry.startedAt,
          ),
        )
        .toSet();
    final liveItems = uiState.calls.values
        .where(
          (call) => !persistedKeys.contains(
            _archivedCallKey(callId: call.callId, startedAt: call.startedAt),
          ),
        )
        .map(
          (call) => _liveHistoryItem(uiState, call, contactIndex: contactIndex),
        )
        .where(_matchesHistoryFilters)
        .toList();
    final items = [
      ...liveItems,
      ...persistedEntries.map(
        (entry) => _persistedHistoryItem(entry, contactIndex: contactIndex),
      ),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return items;
  }

  _HistoryItem? _selectedHistoryItem(List<_HistoryItem> items) {
    if (items.isEmpty) return null;
    final selectedKey = _selectedHistoryItemKey;
    if (selectedKey != null) {
      for (final item in items) {
        if (item.key == selectedKey) return item;
      }
    }
    return items.first;
  }

  _HistoryItem _persistedHistoryItem(
    CallHistoryEntry entry, {
    Map<String, ContactEntry>? contactIndex,
  }) {
    final status = CallHistoryStatus.fromStorage(entry.status);
    final contact = _findHistoryContact(
      entry.phoneNumber,
      contactIndex: contactIndex,
    );
    return _HistoryItem(
      key: 'history:${entry.id}',
      databaseId: entry.id,
      callId: entry.callId,
      direction: CallHistoryDirection.fromStorage(entry.direction),
      status: status,
      statusLabel: status.label,
      remoteUri: entry.remoteUri,
      phoneNumber: entry.phoneNumber,
      displayName: contact?.name ?? entry.displayName,
      contactId: contact?.id,
      deletedContactId: contact == null ? entry.contactId : null,
      accountId: entry.accountId,
      accountLabel: entry.accountLabel,
      startedAt: entry.startedAt,
      ringingAt: entry.ringingAt,
      answeredAt: entry.answeredAt,
      mediaConnectedAt: entry.mediaConnectedAt,
      endedAt: entry.endedAt,
      durationSeconds: entry.durationSeconds,
      sipStatusCode: entry.sipStatusCode,
      hangupReason: entry.hangupReason,
      note: entry.note,
      missedReadAt: entry.missedReadAt,
      timeToRingingMs: entry.timeToRingingMs,
      ringingToAnswerMs: entry.ringingToAnswerMs,
      answerToMediaMs: entry.answerToMediaMs,
      holdCount: entry.holdCount,
      holdSeconds: entry.holdSeconds,
    );
  }

  _HistoryItem _liveHistoryItem(
    PjsipUIState uiState,
    CallInfo call, {
    Map<String, ContactEntry>? contactIndex,
  }) {
    final direction = call.direction == PjsipCallDirection.inbound
        ? CallHistoryDirection.inbound
        : CallHistoryDirection.outbound;
    final phoneNumber = _extractHistoryPhoneNumber(call.remoteUri);
    final contact = _findHistoryContact(
      phoneNumber,
      contactIndex: contactIndex,
    );
    final account = call.accountId == null
        ? null
        : uiState.accounts[call.accountId];
    final durationSeconds = call.connectedAt == null
        ? 0
        : DateTime.now().difference(call.connectedAt!).inSeconds;
    return _HistoryItem(
      key: 'live:${call.callId}',
      callId: call.callId,
      isLive: true,
      direction: direction,
      statusLabel: _liveHistoryStatusLabel(call),
      remoteUri: call.remoteUri,
      phoneNumber: phoneNumber,
      displayName: contact?.name,
      contactId: contact?.id,
      accountId: call.accountId,
      accountLabel: account?.lineLabel,
      startedAt: call.startedAt,
      ringingAt: call.ringingAt,
      answeredAt: call.connectedAt,
      mediaConnectedAt: call.mediaConnectedAt,
      durationSeconds: durationSeconds,
      timeToRingingMs: call.timeToRinging?.inMilliseconds,
      ringingToAnswerMs: call.ringingToAnswer?.inMilliseconds,
      answerToMediaMs: call.answerToMedia?.inMilliseconds,
      holdCount: call.holdCount,
      holdSeconds: call.effectiveHoldDuration(DateTime.now()).inSeconds,
    );
  }

  bool _matchesHistoryFilters(_HistoryItem item) {
    if (_historyCallFilter.missedOnly && !item.isMissedCall) {
      return false;
    }
    final direction = _historyCallFilter.direction;
    if (direction != null && item.direction != direction) return false;
    final range = _historyDateFilter.range();
    if (range != null) {
      if (item.startedAt.isBefore(range.from) ||
          !item.startedAt.isBefore(range.before)) {
        return false;
      }
    }
    final keyword = _historySearchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return true;
    return [
      item.phoneNumber,
      item.remoteUri,
      item.displayName ?? '',
      item.accountLabel ?? '',
      item.note ?? '',
    ].any((value) => value.toLowerCase().contains(keyword));
  }

  /// 返回当前联系人列表对应的号码索引，同一份联系人状态只构建一次。
  Map<String, ContactEntry> _historyContactIndexForCurrentContacts() {
    final contacts = ref.watch(contactBookProvider).contacts;
    if (identical(_historyContactIndexSource, contacts)) {
      return _historyContactIndex;
    }

    final index = <String, ContactEntry>{};
    for (final contact in contacts) {
      for (final phone in contact.phoneEntries) {
        final normalized = _normalizeHistoryPhoneNumber(phone.number);
        if (normalized.isNotEmpty) {
          index.putIfAbsent(normalized, () => contact);
        }
      }
    }
    _historyContactIndexSource = contacts;
    _historyContactIndex = index;
    return index;
  }

  ContactEntry? _findHistoryContact(
    String phoneNumber, {
    Map<String, ContactEntry>? contactIndex,
  }) {
    final normalized = _normalizeHistoryPhoneNumber(phoneNumber);
    if (normalized.isEmpty) return null;
    if (contactIndex != null) return contactIndex[normalized];
    for (final contact in ref.watch(contactBookProvider).contacts) {
      if (contact.phoneEntries.any(
        (phone) => _normalizeHistoryPhoneNumber(phone.number) == normalized,
      )) {
        return contact;
      }
    }
    return null;
  }

  String _liveHistoryStatusLabel(CallInfo call) {
    if (call.isOnHold) return '保持中';
    if (call.isRemoteOnHold) return '对方保持';
    if (call.isConnected) return '通话中';
    if (call.direction == PjsipCallDirection.inbound) return '响铃中';
    if (call.state == 3) {
      return '对方振铃';
    }
    return '呼叫中';
  }

  /// 将日期标题和记录行展平，交给 ListView 按可视区域懒加载。
  List<_HistoryListEntry> _flattenHistoryItems(List<_HistoryItem> items) {
    final entries = <_HistoryListEntry>[];
    String? lastLabel;
    for (final item in items) {
      final label = _formatHistoryGroupLabel(item.startedAt);
      if (label != lastLabel) {
        entries.add(_HistoryListEntry.header(label));
        lastLabel = label;
      }
      entries.add(_HistoryListEntry.item(item));
    }
    return entries;
  }

  String _formatHistoryGroupLabel(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    }
    return DateFormat('yyyy年M月d日').format(time);
  }

  String _formatHistoryDuration(_HistoryItem item) {
    final seconds = item.durationSeconds;
    if (seconds <= 0) return item.isLive ? '计时中' : '--';
    final duration = Duration(seconds: seconds);
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  String? _historyNoteText(_HistoryItem item) {
    final note = item.note?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  Color _historyItemColor(_HistoryItem item) {
    if (item.isLive) return _callGreen;
    return switch (item.status) {
      CallHistoryStatus.completed => _callGreen,
      CallHistoryStatus.missed => _dangerRed,
      CallHistoryStatus.rejected => _textSecondary,
      CallHistoryStatus.failed => _dangerRed,
      CallHistoryStatus.canceled => _textSecondary,
      null => _textSecondary,
    };
  }

  String _extractHistoryPhoneNumber(String remoteUri) {
    final sipMatch = RegExp(
      r'sip:([^@;>]+)',
      caseSensitive: false,
    ).firstMatch(remoteUri);
    final raw = sipMatch?.group(1) ?? remoteUri;
    return _normalizeHistoryPhoneNumber(raw);
  }

  String _normalizeHistoryPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9+*#]'), '');
  }

  String _archivedCallKey({required int callId, required DateTime startedAt}) {
    return '$callId:${startedAt.millisecondsSinceEpoch ~/ 1000}';
  }
}
