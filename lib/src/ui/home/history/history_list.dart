part of '../../../../main.dart';

/// 通话记录列表：负责日期分组、记录行、状态徽标、备注标识和加载更多。
extension _HistoryList on _MyHomePageState {
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
}
