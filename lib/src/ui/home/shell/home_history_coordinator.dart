part of '../../../../main.dart';

/// 通话记录协调方法：管理搜索、方向/时间筛选、右侧详情选中和分页加载。
extension _HomeHistoryCoordinator on _MyHomePageState {
  /// 根据当前搜索词刷新通话记录，并重置分页。
  void _refreshHistorySearch() {
    _update(_resetHistoryPagination);
  }

  /// 清空通话记录搜索词，并回到第一页。
  void _clearHistorySearch() {
    _historySearchController.clear();
    _update(_resetHistoryPagination);
  }

  /// 设置全部/呼出/来电/未接筛选条件，并重置分页。
  void _setHistoryCallFilter(_HistoryCallFilter filter) {
    _update(() {
      _historyCallFilter = filter;
      _resetHistoryPagination();
    });
  }

  /// 设置时间范围筛选条件，并重置分页。
  void _setHistoryDateFilter(_HistoryDateFilter filter) {
    _update(() {
      _historyDateFilter = filter;
      _resetHistoryPagination();
    });
  }

  /// 选中一条通话记录，用于右侧详情或窄屏弹窗展示。
  void _selectHistoryItem(String key, [_HistoryItem? item]) {
    if (item?.isUnreadMissedCall == true) {
      unawaited(_markHistoryItemRead(item!));
    }
    if (_selectedHistoryItemKey == key) return;
    _update(() => _selectedHistoryItemKey = key);
  }

  /// 加载下一页通话记录。
  Future<void> _loadMoreHistoryEntries() async {
    if (_historyLoadingMore) return;
    final cursor = _historyCursorForEntries(_historyCurrentPersistedEntries);
    if (cursor == null) return;

    final keyword = _historySearchController.text.trim();
    final range = _historyDateFilter.range();
    final token = _historyPagingToken();
    _update(() {
      _historyLoadingMore = true;
      _historyLoadMoreToken = token;
    });

    try {
      final entries = await ref
          .read(callHistoryDatabaseProvider)
          .listRecentPage(
            keyword: keyword,
            direction: _historyCallFilter.direction,
            missedOnly: _historyCallFilter.missedOnly,
            startedFrom: range?.from,
            startedBefore: range?.before,
            cursorStartedAt: cursor.startedAt,
            cursorId: cursor.id,
            limit: _historyPageSize + 1,
          );
      if (!mounted || _historyLoadMoreToken != token) return;

      final pageEntries = entries.length > _historyPageSize
          ? entries.take(_historyPageSize).toList()
          : entries;
      _update(() {
        _historyLoadedMoreEntries
          ..addAll(pageEntries)
          ..sort((a, b) {
            final started = b.startedAt.compareTo(a.startedAt);
            if (started != 0) return started;
            return b.id.compareTo(a.id);
          });
        _historyHasMoreAfterLoaded = entries.length > _historyPageSize;
        _historyLoadingMore = false;
        _historyLoadMoreToken = null;
      });
    } catch (error) {
      if (!mounted || _historyLoadMoreToken != token) return;
      _update(() {
        _historyLoadingMore = false;
        _historyLoadMoreToken = null;
      });
      debugPrint('加载更多通话记录失败: $error');
      ToastUtil.showError('加载更多通话记录失败，请稍后重试');
    }
  }

  /// 将通话记录分页和详情选中状态恢复到初始值。
  void _resetHistoryPagination() {
    _historyLoadedMoreEntries.clear();
    _historyCurrentPersistedEntries = <CallHistoryEntry>[];
    _historyHasMoreAfterLoaded = false;
    _historyLoadingMore = false;
    _historyLoadMoreToken = null;
    _historyEntriesStream = null;
    _selectedHistoryItemKey = null;
  }

  /// 当前分页查询条件的快照，用来丢弃筛选切换后的旧异步结果。
  String _historyPagingToken() {
    return [
      _historySearchController.text.trim(),
      _historyCallFilter.name,
      _historyDateFilter.name,
    ].join('\n');
  }
}
