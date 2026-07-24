part of '../../../main.dart';

const int _historyPageSize = 100;

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

  Widget _buildHistoryToolbar({
    required int itemCount,
    required bool canClearHistory,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
              child: TextField(
                controller: _historySearchController,
                onChanged: (_) => _refreshHistorySearch(),
                decoration: InputDecoration(
                  hintText: '搜索号码、客户、线路、备注',
                  prefixIcon: const Icon(AppIcons.search),
                  suffixIcon: _historySearchController.text.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: '清空搜索',
                          onPressed: _clearHistorySearch,
                          icon: const Icon(AppIcons.clear),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<CallHistoryDirection?>(
            segments: const [
              ButtonSegment(value: null, label: Text('全部')),
              ButtonSegment(
                value: CallHistoryDirection.outbound,
                icon: Icon(AppIcons.outgoing),
                label: Text('呼出'),
              ),
              ButtonSegment(
                value: CallHistoryDirection.inbound,
                icon: Icon(AppIcons.incoming),
                label: Text('来电'),
              ),
            ],
            selected: {_historyDirectionFilter},
            onSelectionChanged: (value) =>
                _setHistoryDirectionFilter(value.first),
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radiusSm),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_HistoryDateFilter>(
            tooltip: '按时间筛选',
            initialValue: _historyDateFilter,
            onSelected: _setHistoryDateFilter,
            itemBuilder: (context) => [
              for (final filter in _HistoryDateFilter.values)
                PopupMenuItem(value: filter, child: Text(filter.label)),
            ],
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(AppIcons.calendar),
              label: Text(_historyDateFilter.label),
              style: OutlinedButton.styleFrom(
                disabledForegroundColor: _textPrimary,
                side: const BorderSide(color: _softBorder),
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$itemCount 条',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _textSecondary),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '清空记录',
            onPressed: canClearHistory ? _confirmClearHistory : null,
            icon: const Icon(AppIcons.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryEmptyState({
    required IconData icon,
    required String title,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: _textSecondary),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    List<_HistoryItem> items,
    PjsipService service, {
    required String? selectedKey,
    required bool showDetailInline,
    required bool hasMorePersistedEntries,
    required int persistedEntryCount,
  }) {
    final grouped = _groupHistoryItems(items);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length + 1,
      itemBuilder: (context, groupIndex) {
        if (groupIndex == grouped.length) {
          return _buildHistoryLoadMoreFooter(
            hasMorePersistedEntries: hasMorePersistedEntries,
            persistedEntryCount: persistedEntryCount,
          );
        }
        final group = grouped[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
              child: Text(
                group.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final item in group.items)
              _buildHistoryRow(
                item,
                service: service,
                selectedKey: selectedKey,
                showDetailInline: showDetailInline,
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryRow(
    _HistoryItem item, {
    required PjsipService service,
    required String? selectedKey,
    required bool showDetailInline,
  }) {
    final statusColor = _historyItemColor(item);
    final primary = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : item.phoneNumber;
    final selected = showDetailInline && selectedKey == item.key;
    final note = _historyNoteText(item);

    return Material(
      color: selected
          ? _brandGreen.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        hoverColor: _subtlePanel,
        onHover: showDetailInline
            ? (hovering) {
                if (hovering) _selectHistoryItem(item.key);
              }
            : null,
        onTap: () {
          if (showDetailInline) {
            _selectHistoryItem(item.key);
          } else {
            _showHistoryDetail(item, service);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(_radiusSm),
                ),
                child: Icon(
                  item.direction == CallHistoryDirection.inbound
                      ? AppIcons.incoming
                      : AppIcons.outgoing,
                  size: _iconMd,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            primary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (item.isLive) ...[
                          const SizedBox(width: 8),
                          _buildLiveHistoryBadge(),
                        ],
                        if (note != null) ...[
                          const SizedBox(width: 8),
                          _buildHistoryNoteBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.accountLabel ?? '未知线路',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ),
              SizedBox(
                width: 96,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildHistoryStatusChip(item),
                ),
              ),
              SizedBox(
                width: 96,
                child: Text(
                  _formatHistoryDuration(item),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              SizedBox(
                width: 86,
                child: Text(
                  DateFormat('HH:mm').format(item.startedAt),
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              _buildHistoryCallButton(item, service),
              IconButton(
                tooltip: item.canDelete ? '删除记录' : '进行中的通话不能删除',
                onPressed: item.canDelete
                    ? () => _deleteHistoryEntry(item.databaseId!)
                    : null,
                icon: const Icon(AppIcons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHistoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _callGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        '实时',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _callGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHistoryNoteBadge() {
    return Tooltip(
      message: '有备注，点击记录查看',
      waitDuration: const Duration(milliseconds: 350),
      child: SizedBox.square(
        dimension: 22,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _brandGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(_radiusXs),
            border: Border.all(color: _brandGreen.withValues(alpha: 0.16)),
          ),
          child: const Icon(AppIcons.note, size: _iconXs, color: _brandGreen),
        ),
      ),
    );
  }

  Widget _buildHistoryLoadMoreFooter({
    required bool hasMorePersistedEntries,
    required int persistedEntryCount,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Center(
        child: hasMorePersistedEntries
            ? OutlinedButton.icon(
                onPressed: _loadMoreHistoryEntries,
                icon: const Icon(AppIcons.next),
                label: Text('加载更多 · 已显示 $persistedEntryCount 条'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _softBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                ),
              )
            : Text(
                persistedEntryCount == 0
                    ? '没有更多历史记录'
                    : '已显示全部 $persistedEntryCount 条历史记录',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
      ),
    );
  }

  Widget _buildHistoryCallButton(_HistoryItem item, PjsipService service) {
    final canCall = !item.isLive && item.phoneNumber.trim().isNotEmpty;
    return Tooltip(
      message: item.isLive ? '进行中的通话不能回拨' : '回拨',
      child: IconButton(
        onPressed: canCall ? () => _callHistoryItem(item, service) : null,
        icon: const Icon(AppIcons.call),
        style: IconButton.styleFrom(
          backgroundColor: _subtlePanel,
          foregroundColor: _textPrimary,
          hoverColor: _callGreen,
        ),
      ),
    );
  }

  Widget _buildHistorySummary(
    _HistoryItem item, {
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.direction == CallHistoryDirection.inbound
                      ? AppIcons.incoming
                      : AppIcons.outgoing,
                  color: _historyItemColor(item),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName?.trim().isNotEmpty == true
                            ? item.displayName!.trim()
                            : item.phoneNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '点击左侧记录切换详情',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHistoryContactAction(item),
            const SizedBox(height: 18),
            if (item.hasDeletedContactSnapshot)
              _buildHistoryDetailLine('联系人', '原联系人已删除，可重新添加'),
            _buildHistoryDetailLine('号码', item.phoneNumber),
            _buildHistoryDetailLine('方向', item.direction.label),
            _buildHistoryDetailLine('状态', item.statusLabel),
            _buildHistoryDetailLine('线路', item.accountLabel ?? '未知线路'),
            _buildHistoryDetailLine(
              '呼叫时间',
              DateFormat('yyyy-MM-dd HH:mm:ss').format(item.startedAt),
            ),
            _buildHistoryDetailLine(
              '接通时间',
              item.answeredAt == null
                  ? '未接通'
                  : DateFormat('yyyy-MM-dd HH:mm:ss').format(item.answeredAt!),
            ),
            _buildHistoryDetailLine(
              '挂断时间',
              item.endedAt == null
                  ? '进行中'
                  : DateFormat('yyyy-MM-dd HH:mm:ss').format(item.endedAt!),
            ),
            _buildHistoryDetailLine('通话时长', _formatHistoryDuration(item)),
            if (item.hangupReason?.trim().isNotEmpty == true)
              _buildHistoryDetailLine('结束原因', item.hangupReason!.trim()),
            const SizedBox(height: 2),
            _buildHistoryNoteArea(item),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryNoteArea(_HistoryItem item) {
    final note = _historyNoteText(item);
    if (note == null) {
      if (!item.canEditNote) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _showEditHistoryNoteDialog(item),
          icon: const Icon(AppIcons.note),
          label: const Text('添加备注'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _softBorder),
          ),
        ),
      );
    }
    return _buildHistoryNoteCard(item, note);
  }

  Widget _buildHistoryNoteCard(_HistoryItem item, String note) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.note, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '通话备注',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (item.canEditNote)
                  IconButton(
                    tooltip: '编辑备注',
                    onPressed: () => _showEditHistoryNoteDialog(item),
                    icon: const Icon(AppIcons.edit),
                    iconSize: _iconSm,
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditHistoryNoteDialog(_HistoryItem item) {
    final databaseId = item.databaseId;
    if (databaseId == null) return Future<void>.value();
    final controller = TextEditingController(text: item.note?.trim() ?? '');
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('编辑通话备注'),
          content: SizedBox(
            width: 460,
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 5,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(hintText: '记录本次沟通重点'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(
                  ref
                      .read(callHistoryDatabaseProvider)
                      .updateEntryNote(databaseId, controller.text),
                );
              },
              icon: const Icon(AppIcons.save),
              label: const Text('保存'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildHistoryDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStatusChip(_HistoryItem item) {
    final color = _historyItemColor(item);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        item.statusLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showHistoryDetail(_HistoryItem item, PjsipService service) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 18, 14, 0),
          title: Row(
            children: [
              const Expanded(child: Text('通话详情')),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(AppIcons.close),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.min(560, size.width - 80),
              maxWidth: math.min(680, size.width - 80),
              maxHeight: size.height * 0.74,
            ),
            child: _buildHistorySummary(item, padding: EdgeInsets.zero),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            FilledButton.icon(
              onPressed: item.isLive || item.phoneNumber.trim().isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _callHistoryItem(item, service);
                    },
              icon: const Icon(AppIcons.call),
              label: const Text('回拨'),
            ),
            FilledButton.tonalIcon(
              onPressed: item.phoneNumber.trim().isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _handleHistoryContactAction(item);
                    },
              icon: Icon(
                item.hasCurrentContact ? AppIcons.person : AppIcons.contactAdd,
              ),
              label: Text(
                item.hasCurrentContact
                    ? '查看联系人'
                    : item.hasDeletedContactSnapshot
                    ? '重新添加联系人'
                    : '添加联系人',
              ),
            ),
          ],
        );
      },
    );
  }

  void _callHistoryItem(_HistoryItem item, PjsipService service) {
    if (item.isLive) {
      ToastUtil.showWarning('进行中的通话不能重复回拨');
      return;
    }
    final number = item.phoneNumber.trim();
    if (number.isEmpty) {
      ToastUtil.showWarning('这条记录没有可回拨号码');
      return;
    }
    final uiState = ref.read(pjsipServiceProvider);
    if (!uiState.isNetworkAvailable) {
      ToastUtil.showWarning('当前网络不可用，无法呼叫');
      return;
    }
    if (uiState.accounts.isEmpty) {
      ToastUtil.showWarning('请先添加线路');
      return;
    }
    if (uiState.calls.length >= 4) {
      ToastUtil.showWarning('当前通话已达 4 路上限');
      return;
    }
    if (uiState.hasConference) {
      ToastUtil.showWarning('请先拆分三方通话，再发起新的呼叫');
      return;
    }
    final historyAccount = item.accountId == null
        ? null
        : uiState.accounts[item.accountId];
    final account = historyAccount?.isRegistered == true
        ? historyAccount
        : uiState.bestOutgoingAccount;
    if (account == null) {
      ToastUtil.showWarning('暂无已注册线路，无法呼叫');
      return;
    }
    _numberController.text = number;
    _selectOutgoingAccount(account.accId);
    service.makeCallFromAccount(number, account.accId);
    _selectSection(_WorkspaceSection.calls);
  }

  Future<void> _deleteHistoryEntry(int id) async {
    if (_selectedHistoryItemKey == 'history:$id') {
      _selectedHistoryItemKey = null;
    }
    await ref.read(callHistoryDatabaseProvider).deleteEntry(id);
  }

  Future<void> _confirmClearHistory() {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: const Text('清空通话记录'),
        content: const Text('清空后本地通话记录将无法恢复；正在进行的通话不会被清空。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectedHistoryItemKey = null;
              ref.read(callHistoryDatabaseProvider).clearAll();
            },
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
            child: const Text('清空'),
          ),
        ],
      ),
    );
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

  Widget _buildHistoryContactAction(_HistoryItem item) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: item.phoneNumber.trim().isEmpty
            ? null
            : () => _handleHistoryContactAction(item),
        icon: Icon(
          item.hasCurrentContact ? AppIcons.person : AppIcons.contactAdd,
        ),
        label: Text(
          item.hasCurrentContact
              ? '查看联系人'
              : item.hasDeletedContactSnapshot
              ? '重新添加到联系人'
              : '添加到联系人',
        ),
      ),
    );
  }

  void _handleHistoryContactAction(_HistoryItem item) {
    final contact = _findHistoryContact(item.phoneNumber);
    if (contact != null) {
      _contactSearchController.text = item.phoneNumber;
      _selectSection(_WorkspaceSection.contacts);
      return;
    }
    unawaited(
      _showContactDialog(
        initialName: item.displayName?.trim() ?? '',
        initialNumber: item.phoneNumber,
      ),
    );
  }
}

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

class _HistoryDateRange {
  const _HistoryDateRange(this.from, this.before);

  final DateTime from;
  final DateTime before;
}

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
    this.answeredAt,
    this.endedAt,
    this.hangupReason,
    this.note,
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
  final DateTime? answeredAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String? hangupReason;
  final String? note;

  bool get canDelete => databaseId != null && !isLive;

  bool get canEditNote => databaseId != null && !isLive;

  bool get hasCurrentContact => contactId != null;

  bool get hasDeletedContactSnapshot =>
      contactId == null && deletedContactId != null;
}

class _HistoryGroup {
  _HistoryGroup(this.label, this.items);

  final String label;
  final List<_HistoryItem> items;
}
