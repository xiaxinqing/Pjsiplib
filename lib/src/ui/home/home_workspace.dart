part of '../../../main.dart';

/// 工作区：负责顶部栏、全局操作入口，以及按当前栏目切换主内容。
extension _HomeWorkspace on _MyHomePageState {
  Widget _buildWorkspace(PjsipUIState uiState, PjsipService service) {
    return Column(
      children: [
        _buildTopBar(uiState, service),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: switch (_section) {
              _WorkspaceSection.dialpad => _buildDialpadPage(uiState, service),
              _WorkspaceSection.calls => _buildCallsPage(uiState, service),
              _WorkspaceSection.contacts => _buildContactsPage(
                uiState,
                service,
              ),
              _WorkspaceSection.history => _buildHistoryPage(uiState, service),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(PjsipUIState uiState, PjsipService service) {
    final title = switch (_section) {
      _WorkspaceSection.dialpad => '拨号',
      _WorkspaceSection.calls => '当前通话',
      _WorkspaceSection.contacts => '联系人',
      _WorkspaceSection.history => '通话记录',
    };
    final subtitle = _statusSubtitle(uiState);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: _appBackground,
        border: Border(bottom: BorderSide(color: _softBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildHeaderAction(uiState, service),
          const SizedBox(width: 4),
          IconButton(
            tooltip: '设置',
            onPressed: _openSettingsDrawer,
            icon: const Icon(AppIcons.settings, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(PjsipUIState uiState, PjsipService service) {
    if (uiState.accounts.isNotEmpty) {
      final hasDisconnectableLine = uiState.accounts.values.any(
        (account) => account.registrationEnabled || account.isRegistered,
      );
      final canDisconnect =
          uiState.isInitialized &&
          uiState.calls.isEmpty &&
          hasDisconnectableLine;
      final tooltip = uiState.calls.isNotEmpty
          ? '请先结束当前通话'
          : !uiState.isInitialized
          ? '电话服务未初始化'
          : !hasDisconnectableLine
          ? '线路已全部断开'
          : '断开全部线路';
      return IconButton(
        tooltip: tooltip,
        onPressed: canDisconnect
            ? () async {
                final confirmed = await _confirmDisconnectAllAccounts(uiState);
                if (confirmed != true || !mounted) return;
                service.disconnectAllAccounts();
              }
            : null,
        icon: const Icon(AppIcons.power, color: _textPrimary),
      );
    }
    return FilledButton.icon(
      onPressed: uiState.isNetworkAvailable
          ? () => _showAddAccountDialog(uiState, service)
          : null,
      icon: const Icon(AppIcons.login),
      label: const Text('添加线路'),
      style: FilledButton.styleFrom(backgroundColor: _textPrimary),
    );
  }

  Future<bool?> _confirmDisconnectAllAccounts(PjsipUIState uiState) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        content: SizedBox(
          width: 390,
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
                      AppIcons.power,
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
                          '断开全部线路',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '所有线路会停用注册，之后可在左侧线路菜单中重新启用。',
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
                      Icon(
                        AppIcons.lines,
                        size: _iconMd,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '已接入 ${uiState.accounts.length} 条线路，'
                          '${uiState.registeredAccounts.length} 条在线',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '确定断开全部线路吗？',
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
            label: const Text('断开全部'),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
          ),
        ],
      ),
    );
  }

  String _statusSubtitle(PjsipUIState uiState) {
    if (!uiState.isNetworkAvailable) return '当前网络不可用';
    if (uiState.seatEnvironmentState == SeatEnvironmentState.checking) {
      return '正在检查上次坐席环境';
    }
    if (uiState.seatEnvironmentState == SeatEnvironmentState.restoring) {
      return '正在恢复上次线路配置';
    }
    if (uiState.accounts.isNotEmpty) {
      final outgoingAccount = uiState.bestOutgoingAccount;
      final suffix = outgoingAccount == null
          ? '，暂无可外呼线路'
          : uiState.isUsingFallbackOutgoingAccount
          ? '，临时外呼 ${outgoingAccount.displayName}'
          : '，默认外呼 ${outgoingAccount.displayName}';
      return '已接入 ${uiState.accounts.length} 条线路$suffix';
    }
    if (uiState.isInitialized) return '初始化完成，账号尚未连接';
    return '连接电话服务后即可发起和接听通话';
  }
}
