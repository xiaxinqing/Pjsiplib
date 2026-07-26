part of '../../../../main.dart';

/// 侧边栏连接状态模块：展示整体网络/服务/线路状态，并提供快速入口。
extension _HomeSidebarConnection on _MyHomePageState {
  /// 构建顶部连接状态按钮，根据当前状态展示圆点、加载态和默认外呼线路。
  Widget _buildConnectionPill(PjsipUIState uiState, PjsipService service) {
    final isRegistered = uiState.hasRegisteredAccount;
    final outgoingAccount = uiState.bestOutgoingAccount;
    final isCheckingSeat =
        uiState.seatEnvironmentState == SeatEnvironmentState.checking;
    final isRestoringSeat =
        uiState.seatEnvironmentState == SeatEnvironmentState.restoring;
    final color = isCheckingSeat || isRestoringSeat
        ? _brandGreen
        : !uiState.isNetworkAvailable
        ? Colors.orange.shade700
        : isRegistered
        ? _brandGreen
        : Theme.of(context).colorScheme.outline;
    final label = isCheckingSeat
        ? '正在检查坐席环境'
        : isRestoringSeat
        ? '正在恢复线路'
        : !uiState.isNetworkAvailable
        ? '网络不可用'
        : isRegistered
        ? '已连接 · 默认 ${outgoingAccount?.displayName ?? '--'}'
        : uiState.isInitialized
        ? '等待账号连接'
        : '未连接';

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

  /// 打开连接状态菜单，可查看网络、电话服务、默认外呼和线路在线数量。
  Future<void> _showConnectionStatusMenu(
    PjsipUIState uiState,
    PjsipService service,
    Offset position,
  ) async {
    final accounts = _sortedSidebarAccounts(uiState);
    final failedAccounts = accounts
        .where((account) => !account.isRegistered)
        .toList();
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 112, maxWidth: 162),
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
              const Text(
                '连接状态',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusSummaryRow(
                icon: AppIcons.network,
                label: '网络',
                value: uiState.isNetworkAvailable ? '可用' : '不可用',
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.server,
                label: '电话服务',
                value: uiState.isInitialized ? '已启动' : '未启动',
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.outgoing,
                label: '默认外呼',
                value: uiState.bestOutgoingAccount == null
                    ? '暂无'
                    : '${uiState.bestOutgoingAccount!.lineLabel} · ${uiState.bestOutgoingAccount!.transportLabel}',
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.lines,
                label: '线路',
                value:
                    '${uiState.registeredAccounts.length}/${uiState.accounts.length} 在线',
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        if (failedAccounts.isNotEmpty)
          PopupMenuItem<String>(
            value: 'retry_failed',
            child: _buildPopupActionRow(AppIcons.refresh, '刷新异常线路'),
          ),
        PopupMenuItem<String>(
          value: 'add_line',
          child: _buildPopupActionRow(AppIcons.line, '添加线路'),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(AppIcons.settings, '打开线路设置'),
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
        _openSettingsDrawer();
    }
  }
}
