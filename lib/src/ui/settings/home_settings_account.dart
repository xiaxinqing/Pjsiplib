part of '../../../main.dart';

extension _HomeSettingsAccountTab on _MyHomePageState {
  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    final isRestarting = uiState.isPhoneServiceRestarting;
    final hasActiveCalls = uiState.calls.isNotEmpty;
    final restartingApplication = _applicationRestarting;
    final accounts = uiState.accountList;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildSettingsSection(
          title: '线路状态',
          icon: AppIcons.route,
          children: [
            _buildConnectionPill(uiState, service),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: uiState.isNetworkAvailable && !isRestarting
                        ? () => _showAddAccountDialog(uiState, service)
                        : null,
                    icon: const Icon(AppIcons.add),
                    label: const Text('添加线路'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (accounts.isEmpty)
              Text('尚未接入线路', style: Theme.of(context).textTheme.bodyMedium)
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: accounts.length,
                onReorderItem: (oldIndex, newIndex) =>
                    _reorderAccountLines(uiState, service, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final isDefault = uiState.defaultAccountId == account.accId;
                  final canReorder = !isDefault && !isRestarting;
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
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed:
                  uiState.isInitialized && !hasActiveCalls && !isRestarting
                  ? service.disconnectAllAccounts
                  : null,
              icon: const Icon(AppIcons.power),
              label: const Text('断开全部线路'),
            ),
            const SizedBox(height: 8),
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
              label: Text(restartingApplication ? '正在重启应用' : '重启应用'),
            ),
          ],
        ),
      ],
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
    final color = account.isRegistered ? _brandGreen : Colors.orange.shade700;
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
              TextButton.icon(
                onPressed:
                    isRestarting ||
                        account.registrationActionInProgress ||
                        (account.registrationEnabled &&
                            account.registrationStatus == null)
                    ? null
                    : () => service.setAccountRegistration(account.accId, true),
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
                        !account.registrationEnabled
                    ? null
                    : () =>
                          service.setAccountRegistration(account.accId, false),
                icon: const Icon(AppIcons.pause),
                label: const Text('停止'),
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
