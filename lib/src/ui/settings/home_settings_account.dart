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
    final summary = Text(
      '$accountCount 条线路 · $onlineCount 条在线',
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
          label: const Text('断开全部'),
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
          label: Text(restartingApplication ? '正在重启' : '重启应用'),
        ),
        FilledButton.icon(
          onPressed: canAddAccount ? onAddAccount : null,
          icon: const Icon(AppIcons.add),
          label: const Text('添加线路'),
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
        return Row(children: [summary, const Spacer(), actions]);
      },
    );
  }

  /// 账号列表为空时给出简洁引导，不再重复展示连接状态。
  Widget _buildEmptyAccountList() {
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
            '尚未接入线路',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('点击右上角添加线路', style: TextStyle(color: _textSecondary)),
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
    final tooltip = isDefault
        ? '默认外呼线路固定置顶'
        : enabled
        ? '拖动调整线路顺序'
        : '当前无法调整顺序';
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
        '${account.mediaSecurity.usesSrtp ? ' · ${account.mediaSecurity.mode.label}' : ''}'
        ' · STUN'
        '${account.iceConfig.enabled ? ' · ICE' : ''}'
        '${account.turnConfig.isUsable ? ' · TURN' : ''}'
        ' · ${account.registrationStatusText}';
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
                  label: const Text('刷新'),
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
                  label: const Text('重启'),
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
                  label: const Text('停用'),
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
                  label: const Text('启用'),
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
                label: const Text('编辑'),
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
                label: const Text('删除'),
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
      label: Text(isDefault ? '默认外呼' : '设为默认外呼'),
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
                        const Text(
                          '重启应用',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '会关闭当前应用进程并自动重新打开，不会删除账号配置。',
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
                      _buildRestartStep('保存当前本地配置和通话记录'),
                      const SizedBox(height: 8),
                      _buildRestartStep('关闭当前应用进程并自动重新打开'),
                      const SizedBox(height: 8),
                      _buildRestartStep('重新打开后恢复已保存线路'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                uiState.calls.isEmpty
                    ? '适合休眠唤醒、网络切换后只能接听不能外呼，或线路状态明显异常的情况。'
                    : '当前仍有通话，重启应用会直接中断通话和线路连接。',
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
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.refresh),
            label: const Text('重启应用'),
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
