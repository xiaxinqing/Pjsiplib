part of '../../../../main.dart';

/// 侧边栏线路操作模块：负责单条线路菜单以及危险操作确认弹窗。
extension _HomeSidebarLineActions on _MyHomePageState {
  /// 打开单条线路操作菜单，支持设默认、刷新、强制重连、暂停和删除。
  Future<void> _showLineActionMenu(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
    Offset position,
  ) async {
    final isDefault = uiState.defaultAccountId == account.accId;
    final status = isDefault
        ? '默认外呼 · ${account.registrationStatusText} · ${account.transportLabel}'
        : '${account.registrationStatusText} · ${account.transportLabel}';
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
      color: Colors.white,
      elevation: 14,
      shadowColor: _sidebarMenuShadowColor,
      surfaceTintColor: Colors.transparent,
      shape: _sidebarMenuShape,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTooltipText(
                account.lineLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _buildTooltipText(status),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        if (!isDefault)
          PopupMenuItem<String>(
            value: account.isRegistered ? 'set_default' : null,
            enabled: account.isRegistered,
            child: _buildPopupActionRow(AppIcons.outgoing, '设为默认外呼'),
          ),
        PopupMenuItem<String>(
          value:
              account.registrationActionInProgress ||
                  (account.registrationEnabled &&
                      account.registrationStatus == null)
              ? null
              : 'retry',
          enabled:
              !account.registrationActionInProgress &&
              !(account.registrationEnabled &&
                  account.registrationStatus == null),
          child: _buildPopupActionRow(AppIcons.refresh, '刷新注册'),
        ),
        PopupMenuItem<String>(
          value: account.registrationActionInProgress
              ? null
              : 'force_reconnect',
          enabled: !account.registrationActionInProgress,
          child: _buildPopupActionRow(AppIcons.power, '强制重连'),
        ),
        PopupMenuItem<String>(
          value:
              account.registrationActionInProgress ||
                  !account.registrationEnabled
              ? null
              : 'pause',
          enabled:
              !account.registrationActionInProgress &&
              account.registrationEnabled,
          child: _buildPopupActionRow(AppIcons.pause, '暂停线路'),
        ),
        PopupMenuItem<String>(
          value: account.registrationActionInProgress ? null : 'delete',
          enabled: !account.registrationActionInProgress,
          child: _buildPopupActionRow(
            AppIcons.delete,
            '删除线路',
            destructive: true,
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case 'set_default':
        service.setDefaultAccount(account.accId);
      case 'retry':
        service.setAccountRegistration(account.accId, true);
      case 'force_reconnect':
        final confirmed = await _confirmForceReconnectLine(account);
        if (confirmed != true || !mounted) return;
        service.forceReconnectAccount(account.accId);
      case 'pause':
        service.setAccountRegistration(account.accId, false);
      case 'delete':
        final confirmed = await _confirmDeleteLine(account);
        if (confirmed != true || !mounted) return;
        service.removeAccount(account.accId);
    }
  }

  /// 强制重连前二次确认，避免误触导致线路短暂不可用。
  Future<bool?> _confirmForceReconnectLine(SipAccountInfo account) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: SizedBox(
          width: 380,
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
                      AppIcons.power,
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
                          '强制重连线路',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '会短暂注销后重新注册，不会删除这条线路。',
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
                      _buildTooltipText(
                        account.lineLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${account.registrationStatusText} · ${account.transportLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '适合网络恢复、电脑休眠唤醒后线路状态不对的情况。',
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
            icon: const Icon(AppIcons.power),
            label: const Text('强制重连'),
          ),
        ],
      ),
    );
  }

  /// 删除线路前二次确认，防止账号配置被误删。
  Future<bool?> _confirmDeleteLine(SipAccountInfo account) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: SizedBox(
          width: 380,
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
                      color: _dangerRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: Icon(
                      AppIcons.delete,
                      size: _iconMd,
                      color: _dangerRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '删除线路',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '删除后需要重新添加账号才能恢复。',
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTooltipText(
                              account.lineLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${account.registrationStatusText} · ${account.transportLabel}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w600,
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
              Text(
                '确定删除这条线路吗？',
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
            icon: const Icon(AppIcons.delete),
            label: const Text('删除线路'),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
          ),
        ],
      ),
    );
  }
}
