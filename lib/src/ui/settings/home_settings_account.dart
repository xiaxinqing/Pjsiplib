part of '../../../main.dart';

extension _HomeSettingsAccountTab on _MyHomePageState {
  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    final isRestarting = uiState.isPhoneServiceRestarting;
    final hasActiveCalls = uiState.calls.isNotEmpty;
    final restartingApplication = _applicationRestarting;
    final accounts = uiState.accountList;
    final onlineCount = accounts
        .where((account) => account.isRegistered)
        .length;
    final hasDisconnectableLine = accounts.any(
      (account) => account.registrationEnabled || account.isRegistered,
    );
    final canDisconnectAll =
        uiState.isInitialized &&
        hasDisconnectableLine &&
        !hasActiveCalls &&
        !isRestarting &&
        !restartingApplication;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        children: [
          _buildAccountToolbar(
            accountCount: accounts.length,
            onlineCount: onlineCount,
            canAddAccount:
                uiState.isNetworkAvailable &&
                !isRestarting &&
                !restartingApplication,
            canDisconnectAll: canDisconnectAll,
            restartingApplication: restartingApplication,
            onAddAccount: () => _showAddAccountDialog(uiState, service),
            onDisconnectAll: () async {
              final confirmed = await _confirmDisconnectAllAccounts(uiState);
              if (confirmed != true || !mounted) return;
              service.disconnectAllAccounts();
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: accounts.isEmpty
                ? _buildEmptyAccountList()
                : ReorderableListView.builder(
                    padding: EdgeInsets.zero,
                    buildDefaultDragHandles: false,
                    itemCount: accounts.length,
                    onReorderItem: (oldIndex, newIndex) => _reorderAccountLines(
                      uiState,
                      service,
                      oldIndex,
                      newIndex,
                    ),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isDefault =
                          uiState.defaultAccountId == account.accId;
                      final canReorder =
                          !isDefault && !isRestarting && !restartingApplication;
                      return KeyedSubtree(
                        key: ValueKey('settings-account-${account.accId}'),
                        child: _buildAccountLineTile(
                          uiState,
                          service,
                          account,
                          reorderHandle: _buildAccountReorderHandle(
                            index: index,
                            isDefault: isDefault,
                            enabled: canReorder,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建账号页顶部操作栏，集中放置线路统计和页面级操作。
  Widget _buildAccountToolbar({
    required int accountCount,
    required int onlineCount,
    required bool canAddAccount,
    required bool canDisconnectAll,
    required bool restartingApplication,
    required VoidCallback onAddAccount,
    required VoidCallback onDisconnectAll,
  }) {
    final l10n = context.l10n;
    final summary = Text(
      l10n.accountSettingsSummary(accountCount, onlineCount),
      style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w500),
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: canDisconnectAll ? onDisconnectAll : null,
          icon: const Icon(AppIcons.power),
          label: Text(l10n.accountSettingsDisconnectAll),
        ),
        OutlinedButton.icon(
          onPressed: restartingApplication
              ? null
              : _confirmAndRestartApplication,
          icon: restartingApplication
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(AppIcons.refresh),
          label: Text(
            restartingApplication
                ? l10n.accountSettingsRestarting
                : l10n.accountSettingsRestartApp,
          ),
        ),
        FilledButton.icon(
          onPressed: canAddAccount ? onAddAccount : null,
          icon: const Icon(AppIcons.add),
          label: Text(l10n.accountSettingsAddLine),
          style: FilledButton.styleFrom(backgroundColor: _textPrimary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }
        return Row(
          children: [
            summary,
            const SizedBox(width: 12),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: actions),
            ),
          ],
        );
      },
    );
  }

  /// 账号列表为空时给出简洁引导，不再重复展示连接状态。
  Widget _buildEmptyAccountList() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.lines,
            size: 34,
            color: _textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.accountSettingsEmpty,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.accountSettingsEmptyHint,
            style: TextStyle(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  /// 将拖动后的线路顺序一次性交给服务层存储。
  ///
  /// 默认外呼线路占用第一位，其他线路最多只能拖到它的下方。
  void _reorderAccountLines(
    PjsipUIState uiState,
    PjsipService service,
    int oldIndex,
    int newIndex,
  ) {
    final accounts = uiState.accountList;
    if (oldIndex < 0 || oldIndex >= accounts.length) return;
    if (uiState.defaultAccountId == accounts[oldIndex].accId) return;

    final firstMovableIndex = uiState.defaultAccountId == null ? 0 : 1;
    final targetIndex = math.max(
      firstMovableIndex,
      math.min(newIndex, accounts.length - 1),
    );
    if (targetIndex == oldIndex) return;

    final reordered = List<SipAccountInfo>.of(accounts);
    final movedAccount = reordered.removeAt(oldIndex);
    reordered.insert(targetIndex, movedAccount);
    service.reorderAccounts([for (final account in reordered) account.accId]);
  }

  /// 构建线路排序手柄。默认外呼线路仅显示固定状态。
  Widget _buildAccountReorderHandle({
    required int index,
    required bool isDefault,
    required bool enabled,
  }) {
    final l10n = context.l10n;
    final tooltip = isDefault
        ? l10n.accountSettingsDefaultPinned
        : enabled
        ? l10n.accountSettingsDragToReorder
        : l10n.accountSettingsReorderUnavailable;
    final handle = Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.grab : SystemMouseCursors.basic,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            AppIcons.drag,
            size: _iconMd,
            color: enabled ? _textSecondary : _softBorder,
          ),
        ),
      ),
    );
    if (!enabled) return handle;
    return ReorderableDragStartListener(index: index, child: handle);
  }

  Widget _buildAccountLineTile(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account, {
    required Widget reorderHandle,
  }) {
    final l10n = context.l10n;
    final isDefault = uiState.defaultAccountId == account.accId;
    final color = !account.registrationEnabled
        ? _textSecondary
        : account.isRegistered
        ? _brandGreen
        : Colors.orange.shade700;
    final hasActiveCalls = uiState.calls.values.any(
      (call) => call.accountId == account.accId,
    );
    final isRestarting = uiState.isPhoneServiceRestarting;
    final identity = account.lineName.trim().isEmpty
        ? account.host
        : account.lineLabel;
    final detail =
        '$identity · ${account.transportLabel}'
        '${account.mediaSecurity.usesSrtp ? ' · ${_accountDialogMediaLabel(l10n, account.mediaSecurity.mode)}' : ''}'
        ' · STUN'
        '${account.iceConfig.enabled ? ' · ICE' : ''}'
        '${account.turnConfig.isUsable ? ' · TURN' : ''}'
        ' · ${AccountLocalizer.status(l10n, account)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTooltipText(
                      account.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildDefaultRouteButton(
                account: account,
                isDefault: isDefault,
                isRestarting: isRestarting,
                onSetDefault: () => service.setDefaultAccount(account.accId),
              ),
              const SizedBox(width: 4),
              reorderHandle,
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (account.registrationEnabled) ...[
                TextButton.icon(
                  onPressed:
                      isRestarting ||
                          account.registrationActionInProgress ||
                          account.registrationStatus == null
                      ? null
                      : () =>
                            service.setAccountRegistration(account.accId, true),
                  icon: const Icon(AppIcons.refresh),
                  label: Text(l10n.sidebarRefreshLine),
                ),
                TextButton.icon(
                  onPressed:
                      isRestarting ||
                          account.registrationActionInProgress ||
                          hasActiveCalls ||
                          !uiState.isNetworkAvailable
                      ? null
                      : () async {
                          final confirmed = await _confirmForceReconnectLine(
                            account,
                          );
                          if (confirmed != true || !mounted) return;
                          service.forceReconnectAccount(account.accId);
                        },
                  icon: const Icon(AppIcons.power),
                  label: Text(l10n.sidebarRestartLine),
                ),
                TextButton.icon(
                  onPressed:
                      isRestarting ||
                          account.registrationActionInProgress ||
                          hasActiveCalls
                      ? null
                      : () => service.setAccountRegistration(
                          account.accId,
                          false,
                        ),
                  icon: const Icon(AppIcons.pause),
                  label: Text(l10n.sidebarDisableLine),
                ),
              ] else
                TextButton.icon(
                  onPressed:
                      isRestarting ||
                          account.registrationActionInProgress ||
                          !uiState.isNetworkAvailable
                      ? null
                      : () =>
                            service.setAccountRegistration(account.accId, true),
                  icon: const Icon(AppIcons.play),
                  label: Text(l10n.sidebarEnableLine),
                  style: TextButton.styleFrom(foregroundColor: _brandGreen),
                ),
              TextButton.icon(
                onPressed:
                    isRestarting ||
                        account.registrationActionInProgress ||
                        hasActiveCalls
                    ? null
                    : () => _showEditAccountDialog(uiState, service, account),
                icon: const Icon(AppIcons.edit),
                label: Text(l10n.sidebarEditLine),
              ),
              TextButton.icon(
                onPressed:
                    isRestarting ||
                        account.registrationActionInProgress ||
                        hasActiveCalls
                    ? null
                    : () async {
                        final confirmed = await _confirmDeleteLine(account);
                        if (confirmed != true || !mounted) return;
                        service.removeAccount(account.accId);
                      },
                icon: const Icon(AppIcons.delete),
                label: Text(l10n.sidebarDeleteLine),
                style: TextButton.styleFrom(foregroundColor: _dangerRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建“设为默认外呼”按钮。
  ///
  /// 视觉规则：
  /// - 当前默认线路：绿色、不可点击；
  /// - 在线但非默认：深色、可点击；
  /// - 离线或电话服务重启中：灰色、不可点击。
  Widget _buildDefaultRouteButton({
    required SipAccountInfo account,
    required bool isDefault,
    required bool isRestarting,
    required VoidCallback onSetDefault,
  }) {
    final l10n = context.l10n;
    final canSetDefault = account.isRegistered && !isDefault && !isRestarting;
    final foregroundColor = isDefault
        ? _brandGreen
        : canSetDefault
        ? _textPrimary
        : _textSecondary;
    final backgroundColor = isDefault
        ? _brandGreen.withValues(alpha: 0.1)
        : canSetDefault
        ? Colors.white
        : _subtlePanel;
    final borderColor = isDefault
        ? _brandGreen.withValues(alpha: 0.24)
        : canSetDefault
        ? _textPrimary.withValues(alpha: 0.18)
        : _softBorder;

    return OutlinedButton.icon(
      onPressed: canSetDefault ? onSetDefault : null,
      icon: Icon(isDefault ? AppIcons.check : AppIcons.outgoing, size: _iconSm),
      label: Text(
        isDefault
            ? l10n.accountSettingsDefaultOutgoing
            : l10n.accountSettingsSetDefault,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        disabledForegroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Future<bool?> _confirmRestartApplication(PjsipUIState uiState) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _brandGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: const Icon(
                      AppIcons.refresh,
                      size: _iconMd,
                      color: _brandGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.accountSettingsRestartApp,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.accountSettingsRestartDescription,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _subtlePanel,
                  borderRadius: BorderRadius.circular(_radiusSm),
                  border: Border.all(color: _softBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRestartStep(l10n.accountSettingsRestartStepSave),
                      const SizedBox(height: 8),
                      _buildRestartStep(l10n.accountSettingsRestartStepClose),
                      const SizedBox(height: 8),
                      _buildRestartStep(l10n.accountSettingsRestartStepRestore),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                uiState.calls.isEmpty
                    ? l10n.accountSettingsRestartRecommended
                    : l10n.accountSettingsRestartCallWarning,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
            icon: const Icon(AppIcons.refresh),
            label: Text(l10n.accountSettingsRestartApp),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartStep(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(AppIcons.confirm, size: _iconSm, color: _brandGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
