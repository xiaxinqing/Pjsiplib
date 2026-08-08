part of '../../../../main.dart';

/// 侧边栏线路操作模块：负责单条线路菜单、编辑入口以及危险操作确认弹窗。
extension _HomeSidebarLineActions on _MyHomePageState {
  /// 打开单条线路操作菜单。
  ///
  /// 启用状态提供刷新、重启和停用；停用状态只提供启用，避免展示无效操作。
  Future<void> _showLineActionMenu(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
    Offset position,
  ) async {
    final l10n = context.l10n;
    final isDefault = uiState.defaultAccountId == account.accId;
    final hasActiveCalls = uiState.calls.values.any(
      (call) => call.accountId == account.accId,
    );
    final isRestarting = uiState.isPhoneServiceRestarting;
    final canSetDefault = account.isRegistered && !isDefault;
    final defaultColor = isDefault
        ? _brandGreen
        : canSetDefault
        ? _textPrimary
        : _textSecondary;
    final defaultLabel = isDefault
        ? l10n.sidebarDefaultDial
        : l10n.sidebarSetDefaultDial;
    final status = isDefault
        ? l10n.sidebarDefaultDialStatus(
            AccountLocalizer.status(l10n, account),
            account.transportLabel,
          )
        : '${AccountLocalizer.status(l10n, account)} · ${account.transportLabel}';
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 188, maxWidth: 218),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _buildTooltipText(
                status,
                style: const TextStyle(
                  color: _textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: canSetDefault ? 'set_default' : null,
          enabled: canSetDefault,
          child: _buildPopupActionRow(
            isDefault ? AppIcons.check : AppIcons.outgoing,
            defaultLabel,
            color: defaultColor,
          ),
        ),
        if (account.registrationEnabled) ...[
          PopupMenuItem<String>(
            value:
                isRestarting ||
                    account.registrationActionInProgress ||
                    account.registrationStatus == null
                ? null
                : 'retry',
            enabled:
                !isRestarting &&
                !account.registrationActionInProgress &&
                account.registrationStatus != null,
            child: _buildPopupActionRow(
              AppIcons.refresh,
              l10n.sidebarRefreshLine,
            ),
          ),
          PopupMenuItem<String>(
            value:
                isRestarting ||
                    account.registrationActionInProgress ||
                    hasActiveCalls ||
                    !uiState.isNetworkAvailable
                ? null
                : 'force_reconnect',
            enabled:
                !isRestarting &&
                !account.registrationActionInProgress &&
                !hasActiveCalls &&
                uiState.isNetworkAvailable,
            child: _buildPopupActionRow(
              AppIcons.power,
              l10n.sidebarRestartLine,
            ),
          ),
          PopupMenuItem<String>(
            value:
                isRestarting ||
                    account.registrationActionInProgress ||
                    hasActiveCalls
                ? null
                : 'disable',
            enabled:
                !isRestarting &&
                !account.registrationActionInProgress &&
                !hasActiveCalls,
            child: _buildPopupActionRow(
              AppIcons.pause,
              l10n.sidebarDisableLine,
            ),
          ),
        ] else
          PopupMenuItem<String>(
            value:
                isRestarting ||
                    account.registrationActionInProgress ||
                    !uiState.isNetworkAvailable
                ? null
                : 'enable',
            enabled:
                !isRestarting &&
                !account.registrationActionInProgress &&
                uiState.isNetworkAvailable,
            child: _buildPopupActionRow(
              AppIcons.play,
              l10n.sidebarEnableLine,
              color: _brandGreen,
            ),
          ),
        PopupMenuItem<String>(
          value: account.registrationActionInProgress ? null : 'edit',
          enabled: !account.registrationActionInProgress,
          child: _buildPopupActionRow(AppIcons.edit, l10n.sidebarEditLine),
        ),
        PopupMenuItem<String>(
          value: account.registrationActionInProgress ? null : 'delete',
          enabled: !account.registrationActionInProgress,
          child: _buildPopupActionRow(
            AppIcons.delete,
            l10n.sidebarDeleteLine,
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
      case 'disable':
        service.setAccountRegistration(account.accId, false);
      case 'enable':
        service.setAccountRegistration(account.accId, true);
      case 'edit':
        _showEditAccountDialog(uiState, service, account);
      case 'delete':
        final confirmed = await _confirmDeleteLine(account);
        if (confirmed != true || !mounted) return;
        service.removeAccount(account.accId);
    }
  }

  /// 重启线路前二次确认，避免误触导致线路短暂不可用。
  Future<bool?> _confirmForceReconnectLine(SipAccountInfo account) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
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
                          Text(
                            l10n.sidebarRestartLineTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.sidebarRestartLineDescription,
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${AccountLocalizer.status(l10n, account)} · ${account.transportLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.sidebarRestartLineHint,
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
              icon: const Icon(AppIcons.power),
              label: Text(l10n.sidebarRestartLine),
            ),
          ],
        );
      },
    );
  }

  /// 删除线路前二次确认，防止账号配置被误删。
  Future<bool?> _confirmDeleteLine(SipAccountInfo account) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
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
                          Text(
                            l10n.sidebarDeleteLineTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.sidebarDeleteLineDescription,
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
                                '${AccountLocalizer.status(l10n, account)} · ${account.transportLabel}',
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
                  l10n.sidebarDeleteLineQuestion,
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
              icon: const Icon(AppIcons.delete),
              label: Text(l10n.sidebarDeleteLineTitle),
              style: FilledButton.styleFrom(backgroundColor: _dangerRed),
            ),
          ],
        );
      },
    );
  }
}
