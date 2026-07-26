part of '../../../main.dart';

const int _historyPageSize = 100;

/// 通话记录页入口：负责历史数据流、实时通话合并、筛选匹配和通用格式化。
extension _HomeHistory on _MyHomePageState {
  Widget _buildHistoryPage(PjsipUIState uiState, PjsipService service) {
    final database = ref.watch(callHistoryDatabaseProvider);
    final stream = _watchHistoryEntries(database);
    return StreamBuilder<List<CallHistoryEntry>>(
      stream: stream,
      builder: (context, snapshot) {
        final rawPersistedEntries = snapshot.data ?? const <CallHistoryEntry>[];
        final hasMorePersistedEntries =
            rawPersistedEntries.length > _historyVisibleLimit;
        final persistedEntries = hasMorePersistedEntries
            ? rawPersistedEntries.take(_historyVisibleLimit).toList()
            : rawPersistedEntries;
        final items = _buildHistoryItems(uiState, persistedEntries);
        final selected = _selectedHistoryItem(items);
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
                          final wide = constraints.maxWidth >= 920;
                          if (!wide) {
                            return _buildHistoryList(
                              items,
                              service,
                              selectedKey: null,
                              showDetailInline: false,
                              hasMorePersistedEntries: hasMorePersistedEntries,
                              persistedEntryCount: persistedEntries.length,
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _buildHistoryList(
                                  items,
                                  service,
                                  selectedKey: selected?.key,
                                  showDetailInline: true,
                                  hasMorePersistedEntries:
                                      hasMorePersistedEntries,
                                  persistedEntryCount: persistedEntries.length,
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
    final queryLimit = _historyVisibleLimit + 1;
    if (_historyEntriesStream == null ||
        _historyStreamKeyword != keyword ||
        _historyStreamDirectionFilter != _historyDirectionFilter ||
        _historyStreamDateFilter != _historyDateFilter ||
        _historyStreamVisibleLimit != _historyVisibleLimit) {
      _historyStreamKeyword = keyword;
      _historyStreamDirectionFilter = _historyDirectionFilter;
      _historyStreamDateFilter = _historyDateFilter;
      _historyStreamVisibleLimit = _historyVisibleLimit;
      _historyEntriesStream = database.watchRecent(
        keyword: keyword,
        direction: _historyDirectionFilter,
        startedFrom: range?.from,
        startedBefore: range?.before,
        limit: queryLimit,
      );
    }
    return _historyEntriesStream!;
  }

  List<_HistoryItem> _buildHistoryItems(
    PjsipUIState uiState,
    List<CallHistoryEntry> persistedEntries,
  ) {
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
        .map((call) => _liveHistoryItem(uiState, call))
        .where(_matchesHistoryFilters)
        .toList();
    final items = [...liveItems, ...persistedEntries.map(_persistedHistoryItem)]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
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

  _HistoryItem _persistedHistoryItem(CallHistoryEntry entry) {
    final status = CallHistoryStatus.fromStorage(entry.status);
    final contact = _findHistoryContact(entry.phoneNumber);
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
      answeredAt: entry.answeredAt,
      endedAt: entry.endedAt,
      durationSeconds: entry.durationSeconds,
      hangupReason: entry.hangupReason,
      note: entry.note,
    );
  }

  _HistoryItem _liveHistoryItem(PjsipUIState uiState, CallInfo call) {
    final direction = call.direction == PjsipCallDirection.inbound
        ? CallHistoryDirection.inbound
        : CallHistoryDirection.outbound;
    final phoneNumber = _extractHistoryPhoneNumber(call.remoteUri);
    final contact = _findHistoryContact(phoneNumber);
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
      answeredAt: call.connectedAt,
      durationSeconds: durationSeconds,
    );
  }

  bool _matchesHistoryFilters(_HistoryItem item) {
    final direction = _historyDirectionFilter;
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

  ContactEntry? _findHistoryContact(String phoneNumber) {
    final normalized = _normalizeHistoryPhoneNumber(phoneNumber);
    if (normalized.isEmpty) return null;
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

  List<_HistoryGroup> _groupHistoryItems(List<_HistoryItem> items) {
    final groups = <_HistoryGroup>[];
    for (final item in items) {
      final label = _formatHistoryGroupLabel(item.startedAt);
      if (groups.isEmpty || groups.last.label != label) {
        groups.add(_HistoryGroup(label, [item]));
      } else {
        groups.last.items.add(item);
      }
    }
    return groups;
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
      CallHistoryStatus.rejected => Colors.orange.shade700,
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
