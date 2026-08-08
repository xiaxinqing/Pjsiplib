part of '../../../../main.dart';

/// 联系人协调方法：管理联系人多选、搜索刷新、详情选中和跳转后的列表定位提示。
extension _HomeContactCoordinator on _MyHomePageState {
  /// 设置单个联系人是否进入多选集合。
  void _setSelectedContact(String id, bool selected) {
    _update(() {
      if (selected) {
        _selectedContactIds.add(id);
      } else {
        _selectedContactIds.remove(id);
      }
    });
  }

  /// 批量设置当前可见联系人是否选中，用于全选/取消当前筛选结果。
  void _setVisibleContactsSelected(Iterable<String> ids, bool selected) {
    _update(() {
      if (selected) {
        _selectedContactIds.addAll(ids);
      } else {
        _selectedContactIds.removeAll(ids.toSet());
      }
    });
  }

  /// 清空联系人多选状态。
  void _clearSelectedContacts() {
    if (_selectedContactIds.isEmpty) return;
    _update(_selectedContactIds.clear);
  }

  /// 刷新联系人搜索结果。
  void _refreshContactSearch() {
    _update(() {});
  }

  /// 清空联系人搜索词并刷新列表。
  void _clearContactSearch() {
    _contactSearchController.clear();
    _update(() {});
  }

  /// 切换右侧联系人详情展示对象。
  void _selectContactDetail(String id) {
    if (_selectedContactDetailId == id) return;
    _update(() => _selectedContactDetailId = id);
  }

  /// 从其他页面跳到联系人页时，准备滚动并高亮目标联系人行。
  void _revealContactRow(String id) {
    _contactFlashTimer?.cancel();
    _contactSearchController.clear();
    if (!mounted) return;
    _update(() {
      _pendingContactRevealId = id;
      _flashingContactId = null;
      _contactFlashPhase = 0;
    });
  }

  /// 等联系人数据加载完成后滚动到目标行，并处理联系人不存在的提示。
  void _schedulePendingContactReveal(
    ContactBookState state,
    List<ContactEntry> contacts,
  ) {
    final targetId = _pendingContactRevealId;
    if (targetId == null || state.isLoading) return;
    if (_scheduledContactRevealId == targetId) return;

    final index = contacts.indexWhere((contact) => contact.id == targetId);
    if (index < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _pendingContactRevealId != targetId) return;
        _update(() => _pendingContactRevealId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.contactNoLongerExists)),
        );
      });
      return;
    }

    _scheduledContactRevealId = targetId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _pendingContactRevealId != targetId) {
        _scheduledContactRevealId = null;
        return;
      }

      if (_contactListScrollController.hasClients) {
        final position = _contactListScrollController.position;
        final targetOffset =
            (index * _contactListRowExtentEstimate -
                    _contactListRowExtentEstimate)
                .clamp(0.0, position.maxScrollExtent);
        await _contactListScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      }

      if (!mounted || _pendingContactRevealId != targetId) {
        _scheduledContactRevealId = null;
        return;
      }

      _scheduledContactRevealId = null;
      _update(() => _pendingContactRevealId = null);
      _flashContactRow(targetId);
    });
  }

  /// 对目标联系人行做短暂背景闪烁，帮助用户看清跳转落点。
  void _flashContactRow(String id) {
    _contactFlashTimer?.cancel();
    if (!mounted) return;

    var phase = 0;
    _update(() {
      _flashingContactId = id;
      _contactFlashPhase = phase;
    });

    _contactFlashTimer = Timer.periodic(const Duration(milliseconds: 170), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      phase += 1;
      if (phase >= 6) {
        timer.cancel();
        _update(() {
          _flashingContactId = null;
          _contactFlashPhase = 0;
        });
        return;
      }

      _update(() => _contactFlashPhase = phase);
    });
  }
}
