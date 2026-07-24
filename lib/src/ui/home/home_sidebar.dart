part of '../../../main.dart';

extension _HomeSidebar on _MyHomePageState {
  Widget _buildSidebar(PjsipUIState uiState, PjsipService service) {
    return Container(
      width: 228,
      color: _sidebarBackground,
      padding: const EdgeInsets.fromLTRB(12, 48, 12, 12),
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _textPrimary,
                            borderRadius: BorderRadius.circular(_radiusSm),
                          ),
                          child: const Icon(
                            AppIcons.appLogo,
                            color: Colors.white,
                            size: _iconMd,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'VPhone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildConnectionPill(uiState, service),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: AppIcons.dialpad,
                      label: '拨号',
                      section: _WorkspaceSection.dialpad,
                    ),
                    _buildNavItem(
                      icon: AppIcons.call,
                      label: '当前通话',
                      section: _WorkspaceSection.calls,
                      badge: uiState.calls.isEmpty
                          ? null
                          : '${uiState.calls.length}',
                    ),
                    _buildNavItem(
                      icon: AppIcons.contacts,
                      label: '联系人',
                      section: _WorkspaceSection.contacts,
                    ),
                    _buildNavItem(
                      icon: AppIcons.history,
                      label: '通话记录',
                      section: _WorkspaceSection.history,
                    ),
                    const Spacer(),
                    _buildLineStatusPanel(uiState, service),
                    const SizedBox(height: 10),
                    _buildAudioMiniStatus(uiState, service),
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(_radiusSm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(_radiusSm),
                        onTap: _openSettingsDrawer,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              Icon(AppIcons.settings, size: _iconMd),
                              SizedBox(width: 10),
                              Expanded(child: Text('设置')),
                              Icon(AppIcons.next, size: _iconSm),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildLineStatusPanel(PjsipUIState uiState, PjsipService service) {
    final accounts = _sortedSidebarAccounts(uiState);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '线路',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(AppIcons.pointer, size: _iconXs, color: _textSecondary),
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
    final status = isDefault
        ? '默认外呼 · ${account.transportLabel}'
        : '${account.registrationStatusText} · ${account.transportLabel}';
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
                      _buildTooltipText(
                        account.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      _buildTooltipText(
                        status,
                        style: Theme.of(context).textTheme.bodySmall,
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
            child: _buildPopupActionRow(AppIcons.refresh, '重连异常线路'),
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
      constraints: const BoxConstraints(minWidth: 248, maxWidth: 292),
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
          child: _buildPopupActionRow(AppIcons.refresh, '重新注册'),
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
      case 'pause':
        service.setAccountRegistration(account.accId, false);
      case 'delete':
        final confirmed = await _confirmDeleteLine(account);
        if (confirmed != true || !mounted) return;
        service.removeAccount(account.accId);
    }
  }

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

  Widget _buildStatusSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: _iconSm, color: _textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: _buildTooltipText(value, textAlign: TextAlign.right)),
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
        Icon(icon, size: _iconMd, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTooltipText(
            label,
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? _hoverPanel : Colors.transparent,
        borderRadius: BorderRadius.circular(_radiusSm),
        child: InkWell(
          hoverColor: selected ? _hoverPanel : _panelBackground,
          borderRadius: BorderRadius.circular(_radiusSm),
          onTap: () => _selectSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: _iconMd,
                  color: selected ? _textPrimary : _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(_radiusXs),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
      color: _panelBackground.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        hoverColor: _hoverPanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        onTapDown: (details) =>
            _showAudioStatusMenu(uiState, service, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusSm),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(AppIcons.next, size: _iconSm, color: _textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              _buildTinyDeviceLine(AppIcons.microphone, mic),
              const SizedBox(height: 8),
              _buildTinyDeviceLine(AppIcons.speaker, speaker),
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
              _buildStatusSummaryRow(
                icon: AppIcons.microphone,
                label: '输入',
                value: mic,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.speaker,
                label: '输出',
                value: speaker,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.automatic,
                label: '模式',
                value: isAutomatic ? '自动选择' : '手动选择',
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.info,
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
            isAutomatic ? AppIcons.tune : AppIcons.automatic,
            isAutomatic ? '切换为手动选择' : '切换为自动选择',
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          enabled: uiState.isInitialized,
          child: _buildPopupActionRow(AppIcons.refresh, '刷新设备'),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(AppIcons.settings, '打开音频设置'),
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
        Icon(icon, size: _iconSm),
        const SizedBox(width: 8),
        Expanded(child: _buildTooltipText(value)),
      ],
    );
  }
}
