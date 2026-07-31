part of '../../../../main.dart';

/// 通话记录动作层：负责回拨、删除、清空以及添加/查看联系人。
extension _HistoryActions on _MyHomePageState {
  Future<void> _callHistoryItem(_HistoryItem item, PjsipService service) async {
    unawaited(_markHistoryItemRead(item));
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
    final confirmed = await _showCallHistoryConfirm(
      item: item,
      number: number,
      account: account,
    );
    if (!confirmed || !mounted) return;

    _numberController.text = number;
    _selectOutgoingAccount(account.accId);
    service.makeCallFromAccount(number, account.accId);
    _selectSection(_WorkspaceSection.calls);
  }

  Future<void> _markHistoryItemRead(_HistoryItem item) async {
    final id = item.databaseId;
    if (id == null || !item.isUnreadMissedCall) return;
    await ref.read(callHistoryDatabaseProvider).markMissedCallRead(id);
  }

  Future<void> _markAllMissedCallsRead() async {
    await ref.read(callHistoryDatabaseProvider).markAllMissedCallsRead();
    if (!mounted) return;
    _update(_resetHistoryPagination);
  }

  Future<void> _confirmMarkAllMissedCallsRead(int count) async {
    if (count <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: const Text('全部标记为已读'),
        content: SizedBox(
          width: 380,
          child: Text('将 $count 条未读未接来电标记为已读，列表中的未读红点会被清除。'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.check),
            label: const Text('全部已读'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _markAllMissedCallsRead();
  }

  Future<void> _deleteHistoryEntry(_HistoryItem item) async {
    final id = item.databaseId;
    if (id == null) return;

    final confirmed = await _showDeleteHistoryConfirm(item);
    if (!confirmed || !mounted) return;

    if (_selectedHistoryItemKey == 'history:$id') {
      _selectedHistoryItemKey = null;
    }
    await ref.read(callHistoryDatabaseProvider).deleteEntry(id);
    if (!mounted) return;
    _update(() {
      _historyLoadedMoreEntries.removeWhere((entry) => entry.id == id);
      _historyCurrentPersistedEntries.removeWhere((entry) => entry.id == id);
    });
  }

  Future<bool> _showCallHistoryConfirm({
    required _HistoryItem item,
    required String number,
    required SipAccountInfo account,
  }) async {
    final title = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : number;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) => AlertDialog(
        title: const Text('确认回拨'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _subtlePanel,
                  borderRadius: BorderRadius.circular(_radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(AppIcons.call, size: _iconLg, color: _callGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              number,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _textSecondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildHistoryConfirmRow(
                icon: AppIcons.outgoing,
                label: '外呼线路',
                value: '${account.displayName} · ${account.transportLabel}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.call),
            label: const Text('确认回拨'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showDeleteHistoryConfirm(_HistoryItem item) async {
    final title = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : item.phoneNumber;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: const Text('删除通话记录'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _subtlePanel,
                  borderRadius: BorderRadius.circular(_radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: _iconLg, color: _dangerRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${item.direction.label} · ${item.statusLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildHistoryConfirmRow(
                icon: AppIcons.call,
                label: '号码',
                value: item.phoneNumber,
              ),
              const SizedBox(height: 10),
              _buildHistoryConfirmRow(
                icon: AppIcons.outgoing,
                label: '线路',
                value: item.accountLabel ?? '未知线路',
              ),
              const SizedBox(height: 12),
              Text(
                '删除后这条本地通话记录将无法恢复。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.delete),
            label: const Text('删除'),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildHistoryConfirmRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: _iconMd, color: _textPrimary),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            onPressed: () async {
              Navigator.of(context).pop();
              _update(_resetHistoryPagination);
              try {
                await ref.read(callHistoryDatabaseProvider).clearAll();
              } catch (error, stackTrace) {
                debugPrint('Clear call history failed: $error');
                debugPrint('$stackTrace');
                ToastUtil.showError('清空通话记录失败，请稍后重试');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
            child: const Text('清空'),
          ),
        ],
      ),
    );
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
