part of '../../../../main.dart';

/// 通话记录动作层：负责回拨、删除、清空以及添加/查看联系人。
extension _HistoryActions on _MyHomePageState {
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
