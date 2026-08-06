part of '../../../../main.dart';

/// 侧边栏线路列表模块：展示账号在线状态、默认线路和线路管理入口。
extension _HomeSidebarLines on _MyHomePageState {
  /// 构建线路状态面板；标题和管理入口固定，仅中间账号列表滚动。
  Widget _buildLineStatusPanel(PjsipUIState uiState, PjsipService service) {
    final accounts = uiState.accountList;
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _panelBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '线路',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${uiState.registeredAccounts.length}/${accounts.length} 在线',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            fit: FlexFit.loose,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context, index) =>
                    _buildSidebarLineItem(uiState, service, accounts[index]),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildManageLinesButton(accounts.length),
        ],
      ),
    );
  }

  /// 构建单条线路展示行，点击时打开线路操作菜单。
  Widget _buildSidebarLineItem(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
  ) {
    final isDefault = uiState.defaultAccountId == account.accId;
    final color = !account.registrationEnabled
        ? _textSecondary
        : account.isRegistered
        ? _brandGreen
        : Colors.orange.shade700;
    final identityPrefix = account.lineName.trim().isEmpty
        ? ''
        : '${account.username} · ';
    final status = isDefault
        ? '$identityPrefix默认外呼 · ${account.transportLabel}'
        : '$identityPrefix${account.registrationStatusText} · ${account.transportLabel}';
    return GestureDetector(
      onSecondaryTapDown: (details) => _showLineActionMenu(
        uiState,
        service,
        account,
        details.globalPosition,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTapDown: (details) => _showLineActionMenu(
              uiState,
              service,
              account,
              details.globalPosition,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 9, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTooltipText(
                          account.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _buildTooltipText(
                          status,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isDefault ? AppIcons.outgoing : AppIcons.more,
                    size: isDefault ? 14 : 18,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建线路管理入口，跳转到设置页的账号分组。
  Widget _buildManageLinesButton(int count) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: _hoverPanel,
        onTap: () => _openSettingsDrawer(tabIndex: 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(AppIcons.settings, size: _iconSm, color: _textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '管理 $count 条线路',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(AppIcons.next, size: _iconSm, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
