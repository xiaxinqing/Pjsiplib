part of '../../../../main.dart';

/// 通话记录动作层：负责回拨、删除、清空以及添加/查看联系人。
extension _HistoryActions on _MyHomePageState {
  Future<void> _callHistoryItem(_HistoryItem item, PjsipService service) async {
    final l10n = context.l10n;
    unawaited(_markHistoryItemRead(item));
    if (item.isLive) {
      ToastUtil.showWarning(l10n.historyCannotRedialActive);
      return;
    }
    final number = item.phoneNumber.trim();
    if (number.isEmpty) {
      ToastUtil.showWarning(l10n.historyNoCallbackNumber);
      return;
    }
    final uiState = ref.read(pjsipServiceProvider);
    if (!uiState.isNetworkAvailable) {
      ToastUtil.showWarning(l10n.historyNetworkUnavailable);
      return;
    }
    if (uiState.accounts.isEmpty) {
      ToastUtil.showWarning(l10n.historyAddLineFirst);
      return;
    }
    if (uiState.calls.length >= 4) {
      ToastUtil.showWarning(l10n.historyCallLimitReached);
      return;
    }
    if (uiState.hasConference) {
      ToastUtil.showWarning(l10n.historySplitConferenceFirst);
      return;
    }
    final historyAccount = item.accountId == null
        ? null
        : uiState.accounts[item.accountId];
    final account = historyAccount?.isRegistered == true
        ? historyAccount
        : uiState.bestOutgoingAccount;
    if (account == null) {
      ToastUtil.showWarning(l10n.historyNoRegisteredLine);
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
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: Text(l10n.historyMarkAllReadTitle),
        content: SizedBox(
          width: 380,
          child: Text(l10n.historyMarkAllReadBody(count)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.check),
            label: Text(l10n.historyMarkAllReadConfirm),
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
    await ref
        .read(pjsipServiceProvider.notifier)
        .deleteCallRecordingsForHistory(id);
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
    final l10n = context.l10n;
    final title = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : number;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) => AlertDialog(
        title: Text(l10n.historyConfirmCallbackTitle),
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
                label: l10n.historyDialLine,
                value: '${account.displayName} · ${account.transportLabel}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.call),
            label: Text(l10n.historyConfirmCallback),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showDeleteHistoryConfirm(_HistoryItem item) async {
    final l10n = context.l10n;
    final title = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : item.phoneNumber;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: Text(l10n.historyDeleteTitle),
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
                              '${CallHistoryLocalizer.direction(context.l10n, item.direction)} · '
                              '${_historyListStatusLabel(item)}',
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
                label: l10n.historyFieldNumber,
                value: item.phoneNumber,
              ),
              const SizedBox(height: 10),
              _buildHistoryConfirmRow(
                icon: AppIcons.outgoing,
                label: l10n.historyFieldLine,
                value: item.accountLabel ?? l10n.historyUnknownLine,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.historyDeleteBody,
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
            child: Text(l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.delete),
            label: Text(l10n.historyDeleteConfirm),
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
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: Text(l10n.historyClearTitle),
        content: Text(l10n.historyClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _update(_resetHistoryPagination);
              try {
                await ref
                    .read(pjsipServiceProvider.notifier)
                    .deleteAllArchivedCallRecordings();
                await ref.read(callHistoryDatabaseProvider).clearAll();
              } catch (error, stackTrace) {
                debugPrint('Clear call history failed: $error');
                debugPrint('$stackTrace');
                ToastUtil.showError(l10n.historyClearError);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
            child: Text(l10n.historyClearConfirm),
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
              ? context.l10n.historyViewContact
              : item.hasDeletedContactSnapshot
              ? context.l10n.historyReAddContact
              : context.l10n.historyAddContact,
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
