part of '../../../../main.dart';

/// 侧边栏连接状态模块：展示整体网络/服务/线路状态，并提供快速入口。
extension _HomeSidebarConnection on _MyHomePageState {
  /// 构建顶部连接状态按钮，根据当前状态展示圆点、加载态和默认外呼线路。
  Widget _buildConnectionPill(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    final isRegistered = uiState.hasRegisteredAccount;
    final outgoingAccount = uiState.bestOutgoingAccount;
    final isUsingFallback = uiState.isUsingFallbackOutgoingAccount;
    final isCheckingSeat =
        uiState.seatEnvironmentState == SeatEnvironmentState.checking;
    final isRestoringSeat =
        uiState.accounts.isNotEmpty &&
        uiState.seatEnvironmentState == SeatEnvironmentState.restoring;
    final color = isCheckingSeat || isRestoringSeat
        ? _brandGreen
        : !uiState.isNetworkAvailable
        ? Colors.orange.shade700
        : isRegistered
        ? _brandGreen
        : Theme.of(context).colorScheme.outline;
    final label = isCheckingSeat
        ? l10n.statusCheckingSeatEnvironment
        : isRestoringSeat
        ? l10n.statusRestoringLines
        : !uiState.isNetworkAvailable
        ? l10n.statusNetworkUnavailable
        : isRegistered
        ? isUsingFallback
              ? l10n.sidebarConnectedTemporary(
                  outgoingAccount?.displayName ?? '--',
                )
              : l10n.sidebarConnectedDefault(
                  outgoingAccount?.displayName ?? '--',
                )
        : uiState.isInitialized
        ? l10n.sidebarWaitingAccounts
        : l10n.sidebarDisconnected;

    return Material(
      color: _panelBackground.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        hoverColor: _hoverPanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        onTapDown: (details) =>
            _showConnectionStatusMenu(uiState, service, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusSm),
          ),
          child: Row(
            children: [
              if (isCheckingSeat || isRestoringSeat)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(Icons.circle, size: 9, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              Icon(AppIcons.next, size: _iconSm, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开连接状态菜单，可查看网络、电话服务、默认外呼线路和在线数量。
  Future<void> _showConnectionStatusMenu(
    PjsipUIState uiState,
    PjsipService service,
    Offset position,
  ) async {
    final l10n = context.l10n;
    final accounts = uiState.accountList;
    // 用户主动停用的线路不是异常线路，批量恢复时不能擅自重新启用。
    final failedAccounts = accounts
        .where(
          (account) => account.registrationEnabled && !account.isRegistered,
        )
        .toList();
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 240),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.sidebarConnectionStatus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusSummaryRow(
                icon: AppIcons.network,
                label: l10n.dialNetwork,
                value: uiState.isNetworkAvailable
                    ? l10n.commonAvailable
                    : l10n.commonUnavailable,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.server,
                label: l10n.sidebarPhoneService,
                value: uiState.isInitialized
                    ? l10n.sidebarServiceStarted
                    : l10n.sidebarServiceStopped,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.outgoing,
                label: l10n.sidebarDefaultDialLine,
                value: uiState.defaultAccount == null
                    ? l10n.sidebarNone
                    : '${uiState.defaultAccount!.lineLabel} · ${uiState.defaultAccount!.isRegistered ? uiState.defaultAccount!.transportLabel : l10n.commonUnavailable}',
              ),
              if (uiState.isUsingFallbackOutgoingAccount)
                _buildStatusSummaryRow(
                  icon: AppIcons.call,
                  label: l10n.sidebarCurrentDialLine,
                  value:
                      '${uiState.bestOutgoingAccount!.lineLabel} · ${l10n.sidebarTemporaryUse}',
                ),
              _buildStatusSummaryRow(
                icon: AppIcons.lines,
                label: l10n.sidebarLines,
                value: l10n.sidebarOnlineCount(
                  uiState.registeredAccounts.length,
                  uiState.accounts.length,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        if (failedAccounts.isNotEmpty)
          PopupMenuItem<String>(
            value: 'retry_failed',
            child: _buildPopupActionRow(
              AppIcons.refresh,
              l10n.sidebarRetryFailedLines,
            ),
          ),
        PopupMenuItem<String>(
          value: 'add_line',
          child: _buildPopupActionRow(AppIcons.line, l10n.headerAddLine),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(
            AppIcons.settings,
            l10n.sidebarOpenLineSettings,
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case 'retry_failed':
        for (final account in failedAccounts) {
          service.setAccountRegistration(account.accId, true);
        }
      case 'add_line':
      case 'open_settings':
        _openSettingsDrawer(tabIndex: _settingsAccountIndex);
    }
  }
}
