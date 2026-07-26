part of '../../../../main.dart';

/// 通话记录工具栏：负责搜索、方向筛选、时间筛选、清空入口和空状态。
extension _HistoryToolbar on _MyHomePageState {
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
}
