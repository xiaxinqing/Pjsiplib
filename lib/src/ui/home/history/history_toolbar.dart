part of '../../../../main.dart';

/// 通话记录工具栏：负责搜索、方向筛选、时间筛选、清空入口和空状态。
extension _HistoryToolbar on _MyHomePageState {
  Widget _buildHistoryToolbar({
    required int itemCount,
    required bool canClearHistory,
    required Stream<int> unreadMissedCountStream,
  }) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
              child: Tooltip(
                message: l10n.historySearchHint,
                waitDuration: const Duration(milliseconds: 350),
                child: TextField(
                  controller: _historySearchController,
                  onChanged: (_) => _refreshHistorySearch(),
                  decoration: InputDecoration(
                    hintText: l10n.historySearchPlaceholder,
                    prefixIcon: const Icon(AppIcons.search),
                    suffixIcon: _historySearchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.historyClearSearch,
                            onPressed: _clearHistorySearch,
                            icon: const Icon(AppIcons.clear),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<_HistoryCallFilter>(
            segments: [
              ButtonSegment(
                value: _HistoryCallFilter.all,
                label: Text(l10n.historyFilterAll),
              ),
              ButtonSegment(
                value: _HistoryCallFilter.outbound,
                icon: const Icon(AppIcons.outgoing),
                label: Text(l10n.historyFilterOutbound),
              ),
              ButtonSegment(
                value: _HistoryCallFilter.inbound,
                icon: const Icon(AppIcons.incoming),
                label: Text(l10n.historyFilterInbound),
              ),
              ButtonSegment(
                value: _HistoryCallFilter.missed,
                icon: const Icon(AppIcons.missed),
                label: Text(l10n.historyFilterMissed),
              ),
            ],
            selected: {_historyCallFilter},
            onSelectionChanged: (value) => _setHistoryCallFilter(value.first),
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
            tooltip: l10n.historyFilterByDate,
            initialValue: _historyDateFilter,
            onSelected: _setHistoryDateFilter,
            itemBuilder: (context) => [
              for (final filter in _HistoryDateFilter.values)
                PopupMenuItem(
                  value: filter,
                  child: Text(_historyDateFilterLabel(filter, l10n)),
                ),
            ],
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(AppIcons.calendar),
              label: Text(_historyDateFilterLabel(_historyDateFilter, l10n)),
              style: OutlinedButton.styleFrom(
                disabledForegroundColor: _textPrimary,
                side: const BorderSide(color: _softBorder),
              ),
            ),
          ),
          const Spacer(),
          StreamBuilder<int>(
            stream: unreadMissedCountStream,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () => _confirmMarkAllMissedCallsRead(count),
                  icon: const Icon(AppIcons.check),
                  label: Text(l10n.historyMarkAllReadCount(count)),
                  style: TextButton.styleFrom(
                    foregroundColor: _dangerRed,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              );
            },
          ),
          Text(
            l10n.historyRecordCount(itemCount),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _textSecondary),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.historyClearRecords,
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
}
