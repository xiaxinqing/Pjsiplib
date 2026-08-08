part of '../../../../main.dart';

/// 通话记录工具栏：负责搜索、方向筛选、时间筛选、清空入口和空状态。
extension _HistoryToolbar on _MyHomePageState {
  Widget _buildHistoryToolbar({
    required int itemCount,
    required bool canClearHistory,
    required Stream<int> unreadMissedCountStream,
  }) {
    final l10n = context.l10n;
    return StreamBuilder<int>(
      stream: unreadMissedCountStream,
      builder: (context, snapshot) {
        final unreadMissedCount = snapshot.data ?? 0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 300,
                  ),
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
              _buildHistoryDirectionFilter(l10n: l10n),
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
                  label: Text(
                    _historyDateFilterLabel(_historyDateFilter, l10n),
                  ),
                  style: OutlinedButton.styleFrom(
                    disabledForegroundColor: _textPrimary,
                    side: const BorderSide(color: _softBorder),
                  ),
                ),
              ),
              const Spacer(),
              if (unreadMissedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () =>
                        _confirmMarkAllMissedCallsRead(unreadMissedCount),
                    icon: const Icon(AppIcons.check),
                    label: Text(
                      l10n.historyMarkAllReadCount(unreadMissedCount),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: _dangerRed,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
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
      },
    );
  }

  Widget _buildHistoryDirectionFilter({required AppLocalizations l10n}) {
    final selectedLabel = _historyCallFilterLabel(_historyCallFilter, l10n);
    return PopupMenuButton<_HistoryCallFilter>(
      tooltip: selectedLabel,
      initialValue: _historyCallFilter,
      onSelected: _setHistoryCallFilter,
      itemBuilder: (context) => [
        for (final filter in _HistoryCallFilter.values)
          PopupMenuItem(
            value: filter,
            child: Row(
              children: [
                Icon(_historyCallFilterIcon(filter), size: _iconSm),
                const SizedBox(width: 8),
                Expanded(child: Text(_historyCallFilterLabel(filter, l10n))),
                if (filter == _historyCallFilter) ...[
                  const SizedBox(width: 12),
                  const Icon(AppIcons.check, size: _iconSm),
                ],
              ],
            ),
          ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(_historyCallFilterIcon(_historyCallFilter)),
        label: Text(selectedLabel),
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: _textPrimary,
          side: const BorderSide(color: _softBorder),
        ),
      ),
    );
  }

  String _historyCallFilterLabel(
    _HistoryCallFilter filter,
    AppLocalizations l10n,
  ) => switch (filter) {
    _HistoryCallFilter.all => l10n.historyFilterAll,
    _HistoryCallFilter.outbound => l10n.historyFilterOutbound,
    _HistoryCallFilter.inbound => l10n.historyFilterInbound,
    _HistoryCallFilter.missed => l10n.historyFilterMissed,
  };

  IconData _historyCallFilterIcon(_HistoryCallFilter filter) =>
      switch (filter) {
        _HistoryCallFilter.all => AppIcons.calls,
        _HistoryCallFilter.outbound => AppIcons.outgoing,
        _HistoryCallFilter.inbound => AppIcons.incoming,
        _HistoryCallFilter.missed => AppIcons.missed,
      };

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
