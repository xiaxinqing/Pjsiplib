part of '../../../main.dart';

extension _HomeSidebar on _MyHomePageState {
  Widget _buildSidebar(PjsipUIState uiState, PjsipService service) {
    return Container(
      width: 236,
      color: _sidebarBackground,
      padding: const EdgeInsets.fromLTRB(14, 54, 14, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _textPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.phone_in_talk,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Thruv',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildConnectionPill(uiState, service),
                    const SizedBox(height: 18),
                    _buildNavItem(
                      icon: Icons.dialpad,
                      label: '拨号',
                      section: _WorkspaceSection.dialpad,
                    ),
                    _buildNavItem(
                      icon: Icons.call,
                      label: '当前通话',
                      section: _WorkspaceSection.calls,
                      badge: uiState.calls.isEmpty
                          ? null
                          : '${uiState.calls.length}',
                    ),
                    _buildNavItem(
                      icon: Icons.contacts,
                      label: '联系人',
                      section: _WorkspaceSection.contacts,
                    ),
                    _buildNavItem(
                      icon: Icons.history,
                      label: '通话记录',
                      section: _WorkspaceSection.history,
                    ),
                    const Spacer(),
                    _buildLineStatusPanel(uiState, service),
                    const SizedBox(height: 12),
                    _buildAudioMiniStatus(uiState, service),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openSettingsDrawer,
                      icon: const Icon(Icons.settings),
                      label: const Text('设置'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionPill(PjsipUIState uiState, PjsipService service) {
    final isRegistered = uiState.hasRegisteredAccount;
    final outgoingAccount = uiState.bestOutgoingAccount;
    final color = !uiState.isNetworkAvailable
        ? Colors.orange.shade700
        : isRegistered
        ? _brandGreen
        : Theme.of(context).colorScheme.outline;
    final label = !uiState.isNetworkAvailable
        ? '网络不可用'
        : isRegistered
        ? '已连接 · 默认 ${outgoingAccount?.displayName ?? '--'}'
        : uiState.isInitialized
        ? '等待账号连接'
        : '未连接';

    return Material(
      color: _panelBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTapDown: (details) =>
            _showConnectionStatusMenu(uiState, service, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _softBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 18, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineStatusPanel(PjsipUIState uiState, PjsipService service) {
    final accounts = _sortedSidebarAccounts(uiState);
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '线路',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Icon(Icons.touch_app_outlined, size: 14, color: _textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          for (final account in accounts.take(3))
            _buildSidebarLineItem(uiState, service, account),
          if (accounts.length > 3)
            TextButton(
              onPressed: () => _showConnectionStatusMenu(
                uiState,
                service,
                _sidebarMenuFallbackPosition,
              ),
              child: Text('+${accounts.length - 3} 条线路'),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarLineItem(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
  ) {
    final isDefault = uiState.defaultAccountId == account.accId;
    final color = account.isRegistered ? _brandGreen : Colors.orange.shade700;
    return Padding(
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
                      Text(
                        account.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        isDefault
                            ? '默认外呼 · ${account.transportLabel}'
                            : '${account.registrationStatusText} · ${account.transportLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isDefault ? Icons.outbound : Icons.more_horiz,
                  size: isDefault ? 14 : 18,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SipAccountInfo> _sortedSidebarAccounts(PjsipUIState uiState) {
    final accounts = uiState.accounts.values.toList();
    accounts.sort((a, b) {
      final defaultId = uiState.defaultAccountId;
      if (a.accId == defaultId) return -1;
      if (b.accId == defaultId) return 1;
      if (a.isRegistered != b.isRegistered) return a.isRegistered ? -1 : 1;
      return a.displayName.compareTo(b.displayName);
    });
    return accounts;
  }

  Offset get _sidebarMenuFallbackPosition => const Offset(214, 520);

  RelativeRect _popupMenuPosition(Offset globalPosition) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    return RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    );
  }

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
      constraints: const BoxConstraints(minWidth: 292, maxWidth: 320),
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
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusSummaryRow(
                icon: Icons.network_check,
                label: '网络',
                value: uiState.isNetworkAvailable ? '可用' : '不可用',
              ),
              _buildStatusSummaryRow(
                icon: Icons.settings_input_component,
                label: '电话服务',
                value: uiState.isInitialized ? '已启动' : '未启动',
              ),
              _buildStatusSummaryRow(
                icon: Icons.outbound,
                label: '默认外呼',
                value: uiState.bestOutgoingAccount == null
                    ? '暂无'
                    : '${uiState.bestOutgoingAccount!.lineLabel} · ${uiState.bestOutgoingAccount!.transportLabel}',
              ),
              _buildStatusSummaryRow(
                icon: Icons.account_tree_outlined,
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
            child: _buildPopupActionRow(Icons.refresh, '重连异常线路'),
          ),
        PopupMenuItem<String>(
          value: 'add_line',
          child: _buildPopupActionRow(Icons.add_call, '添加线路'),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(Icons.settings, '打开线路设置'),
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

  Future<void> _showLineActionMenu(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
    Offset position,
  ) async {
    final isDefault = uiState.defaultAccountId == account.accId;
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 248, maxWidth: 292),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.lineLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isDefault
                    ? '默认外呼 · ${account.registrationStatusText} · ${account.transportLabel}'
                    : '${account.registrationStatusText} · ${account.transportLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        if (!isDefault)
          PopupMenuItem<String>(
            value: account.isRegistered ? 'set_default' : null,
            enabled: account.isRegistered,
            child: _buildPopupActionRow(Icons.outbound, '设为默认外呼'),
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
          child: _buildPopupActionRow(Icons.refresh, '重新注册'),
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
          child: _buildPopupActionRow(Icons.pause_circle_outline, '暂停线路'),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: _buildPopupActionRow(
            Icons.delete_outline,
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
      case 'pause':
        service.setAccountRegistration(account.accId, false);
      case 'delete':
        service.removeAccount(account.accId);
    }
  }

  Widget _buildStatusSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupActionRow(
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? Colors.red.shade700 : null;
    return Row(
      children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required _WorkspaceSection section,
    String? badge,
  }) {
    final selected = _section == section;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? _hoverPanel : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? _textPrimary : _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMiniStatus(PjsipUIState uiState, PjsipService service) {
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    return Material(
      color: _panelBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTapDown: (details) =>
            _showAudioStatusMenu(uiState, service, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _softBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '音频',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: _textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              _buildTinyDeviceLine(Icons.mic, mic),
              const SizedBox(height: 8),
              _buildTinyDeviceLine(Icons.volume_up, speaker),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAudioStatusMenu(
    PjsipUIState uiState,
    PjsipService service,
    Offset position,
  ) async {
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    final isAutomatic =
        uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic;
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 292, maxWidth: 340),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '音频设备',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusSummaryRow(icon: Icons.mic, label: '输入', value: mic),
              _buildStatusSummaryRow(
                icon: Icons.volume_up,
                label: '输出',
                value: speaker,
              ),
              _buildStatusSummaryRow(
                icon: Icons.auto_awesome,
                label: '模式',
                value: isAutomatic ? '自动选择' : '手动选择',
              ),
              _buildStatusSummaryRow(
                icon: Icons.info_outline,
                label: '状态',
                value: uiState.audioDeviceStatus,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'toggle_auto',
          enabled: uiState.isInitialized,
          child: _buildPopupActionRow(
            isAutomatic ? Icons.tune : Icons.auto_awesome,
            isAutomatic ? '切换为手动选择' : '切换为自动选择',
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          enabled: uiState.isInitialized,
          child: _buildPopupActionRow(Icons.refresh, '刷新设备'),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(Icons.settings, '打开音频设置'),
        ),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case 'toggle_auto':
        unawaited(service.setAutomaticAudioDeviceSelection(!isAutomatic));
      case 'refresh':
        unawaited(service.refreshAudioDevices());
      case 'open_settings':
        _openSettingsDrawer(tabIndex: 1);
    }
  }

  Widget _buildTinyDeviceLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
