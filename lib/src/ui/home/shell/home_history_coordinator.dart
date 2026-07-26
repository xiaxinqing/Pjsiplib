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

  /// 设置呼入/呼出筛选条件，并重置分页。
  void _setHistoryDirectionFilter(CallHistoryDirection? direction) {
    _update(() {
      _historyDirectionFilter = direction;
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
  void _selectHistoryItem(String key) {
    if (_selectedHistoryItemKey == key) return;
    _update(() => _selectedHistoryItemKey = key);
  }

  /// 加载下一页通话记录。
  void _loadMoreHistoryEntries() {
    _update(() => _historyVisibleLimit += _historyPageSize);
  }

  /// 将通话记录分页和详情选中状态恢复到初始值。
  void _resetHistoryPagination() {
    _historyVisibleLimit = _historyPageSize;
    _selectedHistoryItemKey = null;
  }
}
