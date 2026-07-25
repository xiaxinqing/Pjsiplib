part of '../../../main.dart';

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
                          '所有线路会暂停注册，之后可在左侧线路菜单中重新注册。',
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
          : '，默认外呼 ${outgoingAccount.displayName}';
      return '已接入 ${uiState.accounts.length} 条线路$suffix';
    }
    if (uiState.isInitialized) return '初始化完成，账号尚未连接';
    return '连接电话服务后即可发起和接听通话';
  }

  Widget _buildDialpadPage(PjsipUIState uiState, PjsipService service) {
    final selectedAccountId =
        _selectedOutgoingAccountId ?? uiState.bestOutgoingAccount?.accId;
    final selectedAccount = selectedAccountId == null
        ? null
        : uiState.accounts[selectedAccountId];
    final canCall =
        uiState.isNetworkAvailable &&
        selectedAccount?.isRegistered == true &&
        uiState.calls.length < 4 &&
        !uiState.hasConference;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dialpadWidth = math.min(
          420.0,
          math.max(360.0, constraints.maxWidth * 0.42),
        );
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                _clearDialpadNumber(),
            const SingleActivator(LogicalKeyboardKey.numpadEnter): () =>
                _callNumberIfPossible(canCall, service, selectedAccountId),
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: dialpadWidth,
                child: _buildDialpadCard(
                  uiState,
                  service,
                  canCall,
                  selectedAccountId,
                  selectedAccount,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildLiveCallsPanel(
                  uiState,
                  service,
                  emptyContent: _buildDialpadStandbyPanel(
                    uiState,
                    service,
                    canCall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialpadCard(
    PjsipUIState uiState,
    PjsipService service,
    bool canCall,
    int? selectedAccountId,
    SipAccountInfo? selectedAccount,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final topInset = constraints.maxHeight < 620 ? 18.0 : 64.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, topInset, 18, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > topInset + 18
                    ? constraints.maxHeight - topInset - 18
                    : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _numberController,
                    focusNode: _numberFocusNode,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      hintText: '输入号码',
                      prefixIcon: const Icon(AppIcons.dialpad),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _numberController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            tooltip: '清空',
                            onPressed: _clearDialpadNumber,
                            icon: const Icon(AppIcons.clear),
                          );
                        },
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: const [_DialpadNumberInputFormatter()],
                    onSubmitted: (_) => _callNumberIfPossible(
                      canCall,
                      service,
                      selectedAccountId,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _numberController,
                    builder: (context, value, _) {
                      final match = _dialpadContactMatch(value.text);
                      if (match == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildDialpadContactMatch(match),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildOutgoingLineSelector(uiState, service),
                  const SizedBox(height: 14),
                  _buildNumberPad(),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _numberController,
                    builder: (context, value, _) {
                      final number = value.text.trim();
                      final unavailableReason = _dialpadCallUnavailableReason(
                        uiState,
                        selectedAccount,
                        number,
                      );
                      final enabled = unavailableReason == null;
                      return Tooltip(
                        message: enabled ? '发起外呼' : unavailableReason,
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: enabled
                                ? () => _callNumberIfPossible(
                                    true,
                                    service,
                                    selectedAccountId,
                                  )
                                : null,
                            icon: const Icon(AppIcons.call),
                            label: Text(unavailableReason ?? '呼叫'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _callGreen,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutgoingLineSelector(
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final accounts = uiState.accounts.values.toList();
    if (accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _subtlePanel,
          borderRadius: BorderRadius.circular(_radiusSm),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.outgoing, size: _iconSm),
            const SizedBox(width: 8),
            const Text('外呼线路', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '尚未添加',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: uiState.isNetworkAvailable
                  ? () => _showAddAccountDialog(uiState, service)
                  : null,
              icon: const Icon(AppIcons.add),
              label: const Text('添加'),
            ),
          ],
        ),
      );
    }
    final selectedCandidate =
        _selectedOutgoingAccountId ?? uiState.bestOutgoingAccount?.accId;
    final selectedId =
        accounts.any((account) => account.accId == selectedCandidate)
        ? selectedCandidate
        : accounts.first.accId;
    final selectedAccount = selectedId == null
        ? null
        : uiState.accounts[selectedId];
    final hasUsableLine = uiState.bestOutgoingAccount != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 9,
                color: selectedAccount?.isRegistered == true
                    ? _brandGreen
                    : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              const Text('外呼线路', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final menuWidth = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 300.0;
                    final itemWidth = math.max(0.0, menuWidth - 16);
                    return MenuAnchor(
                      alignmentOffset: const Offset(0, 6),
                      style: MenuStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          _panelBackground,
                        ),
                        elevation: const WidgetStatePropertyAll(8),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 6),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radiusSm),
                            side: const BorderSide(color: _softBorder),
                          ),
                        ),
                      ),
                      menuChildren: [
                        for (final account in accounts)
                          MenuItemButton(
                            onPressed: () =>
                                _selectOutgoingAccount(account.accId),
                            style: ButtonStyle(
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              minimumSize: WidgetStatePropertyAll(
                                Size(menuWidth, 42),
                              ),
                              overlayColor: WidgetStatePropertyAll(
                                _brandGreen.withValues(alpha: 0.08),
                              ),
                            ),
                            child: SizedBox(
                              width: itemWidth,
                              child: _buildOutgoingLineMenuItem(
                                account,
                                selected: account.accId == selectedId,
                              ),
                            ),
                          ),
                      ],
                      builder: (context, controller, child) {
                        return _buildOutgoingLineMenuButton(
                          selectedAccount,
                          onPressed: controller.isOpen
                              ? controller.close
                              : controller.open,
                          isOpen: controller.isOpen,
                        );
                      },
                    );
                  },
                ),
              ),
              if (!hasUsableLine) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '打开线路设置',
                  onPressed: () => _openSettingsDrawer(tabIndex: 0),
                  icon: const Icon(AppIcons.settings),
                ),
              ],
            ],
          ),
          if (!hasUsableLine) ...[
            const SizedBox(height: 4),
            Text(
              '暂无可用外呼线路，请检查注册状态',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDialpadStandbyPanel(
    PjsipUIState uiState,
    PjsipService service,
    bool canCall,
  ) {
    final account = _selectedOutgoingAccountId == null
        ? uiState.bestOutgoingAccount
        : uiState.accounts[_selectedOutgoingAccountId];
    final status = _dialpadAvailabilityStatus(uiState, account, canCall);
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentMaxWidth = constraints.maxWidth >= 720 ? 520.0 : 420.0;
        final topInset = constraints.maxHeight < 620 ? 28.0 : 64.0;
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topInset),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    canCall ? AppIcons.call : AppIcons.info,
                    size: 42,
                    color: canCall ? _callGreen : _textSecondary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    status.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _subtlePanel,
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _buildDialpadStandbyLine(
                            AppIcons.outgoing,
                            '默认外呼',
                            account == null
                                ? '暂无可用线路'
                                : '${account.displayName} · ${account.transportLabel}',
                          ),
                          const SizedBox(height: 10),
                          _buildDialpadStandbyLine(
                            AppIcons.calls,
                            '通话容量',
                            '${uiState.calls.length}/4 路',
                          ),
                          const SizedBox(height: 10),
                          _buildDialpadStandbyLine(
                            AppIcons.network,
                            '网络',
                            uiState.isNetworkAvailable ? '可用' : '不可用',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDialpadRecentCalls(service),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialpadRecentCalls(PjsipService service) {
    if (_isRunningWidgetTest) {
      return _buildDialpadRecentCallsShell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            '暂无最近通话',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _textSecondary),
          ),
        ),
      );
    }

    return _buildDialpadRecentCallsShell(
      child: StreamBuilder<List<CallHistoryEntry>>(
        stream: _watchDialpadRecentHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final entries = snapshot.data ?? const <CallHistoryEntry>[];
          if (entries.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                '暂无最近通话',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            );
          }

          return Column(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                _buildDialpadRecentCallRow(
                  _persistedHistoryItem(entries[index]),
                  service,
                ),
                if (index != entries.length - 1) const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialpadRecentCallsShell({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(AppIcons.history, size: _iconSm),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '最近通话',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectSection(_WorkspaceSection.history),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('全部'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }

  Stream<List<CallHistoryEntry>> _watchDialpadRecentHistory() {
    return _dialpadRecentHistoryStream ??= ref
        .read(callHistoryDatabaseProvider)
        .watchRecent(limit: 3);
  }

  Widget _buildDialpadRecentCallRow(_HistoryItem item, PjsipService service) {
    final color = _historyItemColor(item);
    final title = _dialpadRecentCallTitle(item);
    final number = item.phoneNumber.trim();
    final lineLabel = item.accountLabel?.trim();
    final shouldShowNumber = number.isNotEmpty && title != number;
    final statusLabel = [
      item.direction.label,
      item.statusLabel,
      _formatDialpadRecentCallTime(item.startedAt),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(_radiusXs),
            ),
            child: Icon(
              item.direction == CallHistoryDirection.inbound
                  ? AppIcons.incoming
                  : AppIcons.outgoing,
              size: _iconSm,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipText(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (shouldShowNumber) ...[
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    number,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                _buildTooltipText(
                  statusLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
                if (lineLabel != null && lineLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    lineLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textSecondary.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: number.isEmpty ? '没有可回拨号码' : '回拨 $number',
            child: IconButton(
              onPressed: number.isEmpty
                  ? null
                  : () => _callHistoryItem(item, service),
              icon: const Icon(AppIcons.call),
              color: _callGreen,
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                disabledBackgroundColor: _panelBackground,
                disabledForegroundColor: _textSecondary.withValues(alpha: 0.5),
                foregroundColor: _callGreen,
                hoverColor: _callGreen.withValues(alpha: 0.08),
                highlightColor: _callGreen.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dialpadRecentCallTitle(_HistoryItem item) {
    final displayName = item.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final phoneNumber = item.phoneNumber.trim();
    if (phoneNumber.isNotEmpty) return phoneNumber;
    return _displayRemote(item.remoteUri);
  }

  String _formatDialpadRecentCallTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return DateFormat('HH:mm').format(time);
    if (diff == 1) return '昨天 ${DateFormat('HH:mm').format(time)}';
    if (diff < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${weekdays[time.weekday - 1]} ${DateFormat('HH:mm').format(time)}';
    }
    return DateFormat('M/d HH:mm').format(time);
  }

  Widget _buildOutgoingLineMenuButton(
    SipAccountInfo? account, {
    required VoidCallback onPressed,
    required bool isOpen,
  }) {
    final label = account == null
        ? '暂无可用线路'
        : '${account.lineLabel} · ${account.transportLabel}';
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          hoverColor: _brandGreen.withValues(alpha: 0.06),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isOpen
                  ? _brandGreen.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isOpen ? _brandGreen : Colors.transparent,
                width: isOpen ? 1.1 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isOpen ? AppIcons.chevronUp : AppIcons.chevronDown,
                  size: _iconSm,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutgoingLineMenuItem(
    SipAccountInfo account, {
    required bool selected,
  }) {
    final color = account.isRegistered ? _brandGreen : Colors.orange.shade700;
    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTooltipText(
                account.lineLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              _buildTooltipText(
                account.transportLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          account.registrationStatusText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: account.isRegistered ? _brandGreen : Colors.orange.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 18,
          child: selected
              ? const Icon(AppIcons.check, size: _iconSm, color: _brandGreen)
              : null,
        ),
      ],
    );
  }

  Widget _buildDialpadStandbyLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: _iconSm, color: _textSecondary),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTooltipText(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildDialpadContactMatch(_DialpadContactMatch match) {
    final organization = match.contact.organizationLabel;
    final phoneLabel = match.phone.label.trim().isEmpty
        ? '默认'
        : match.phone.label.trim();
    return Material(
      color: _subtlePanel,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radiusSm),
        hoverColor: _brandGreen.withValues(alpha: 0.06),
        onTap: () {
          _selectContactDetail(match.contact.id);
          _selectSection(_WorkspaceSection.contacts);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: match.contact.isFavorite
                    ? _brandGreen
                    : _hoverPanel,
                foregroundColor: match.contact.isFavorite
                    ? Colors.white
                    : _textPrimary,
                child: Text(
                  match.contact.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTooltipText(
                      match.contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      organization,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.exact ? '已匹配' : '尾号匹配',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _brandGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    '$phoneLabel · ${match.phone.number}',
                    textAlign: TextAlign.right,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DialpadAvailabilityStatus _dialpadAvailabilityStatus(
    PjsipUIState uiState,
    SipAccountInfo? account,
    bool canCall,
  ) {
    if (!uiState.isNetworkAvailable) {
      return const _DialpadAvailabilityStatus('网络不可用', '恢复网络后即可拨打电话');
    }
    if (uiState.accounts.isEmpty) {
      return const _DialpadAvailabilityStatus('尚未添加线路', '添加 SIP 线路后即可外呼');
    }
    if (account?.isRegistered != true) {
      return const _DialpadAvailabilityStatus('暂无可用外呼线路', '请检查线路注册状态');
    }
    if (uiState.hasConference) {
      return const _DialpadAvailabilityStatus('会议通话中', '请先拆分会议后再发起新呼叫');
    }
    if (uiState.calls.length >= 4) {
      return const _DialpadAvailabilityStatus('通话已达上限', '最多同时保持 4 路通话');
    }
    if (canCall) {
      return const _DialpadAvailabilityStatus('可以发起外呼', '输入号码后点击呼叫');
    }
    return const _DialpadAvailabilityStatus('暂不可外呼', '请检查号码或线路状态');
  }

  String? _dialpadCallUnavailableReason(
    PjsipUIState uiState,
    SipAccountInfo? account,
    String number,
  ) {
    if (number.isEmpty) return '输入号码后呼叫';
    if (!uiState.isNetworkAvailable) return '网络不可用';
    if (uiState.accounts.isEmpty) return '请先添加线路';
    if (account?.isRegistered != true) return '暂无可用线路';
    if (uiState.hasConference) return '会议中不可外呼';
    if (uiState.calls.length >= 4) return '通话已达上限';
    return null;
  }

  _DialpadContactMatch? _dialpadContactMatch(String number) {
    final normalizedInput = normalizeContactPhoneNumber(number);
    if (normalizedInput.isEmpty) return null;

    final contacts = ref.watch(contactBookProvider).contacts;
    _DialpadContactMatch? suffixMatch;
    for (final contact in contacts) {
      for (final phone in contact.phoneEntries) {
        final normalizedPhone = normalizeContactPhoneNumber(phone.number);
        if (normalizedPhone.isEmpty) continue;
        if (normalizedPhone == normalizedInput) {
          return _DialpadContactMatch(
            contact: contact,
            phone: phone,
            exact: true,
          );
        }
        if (suffixMatch == null &&
            normalizedInput.length >= 4 &&
            normalizedPhone.endsWith(normalizedInput)) {
          suffixMatch = _DialpadContactMatch(
            contact: contact,
            phone: phone,
            exact: false,
          );
        }
      }
    }
    return suffixMatch;
  }

  Widget _buildNumberPad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return TextFieldTapRegion(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.68,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final active = _activeDialpadKey == key;
          final hovered = _hoveredDialpadKey == key;
          return _buildDialpadKey(key, active: active, hovered: hovered);
        },
      ),
    );
  }

  Widget _buildDialpadKey(
    String key, {
    required bool active,
    required bool hovered,
  }) {
    final backgroundColor = active
        ? _brandGreen.withValues(alpha: 0.08)
        : hovered
        ? _subtlePanel
        : _panelBackground;
    return MouseRegion(
      onEnter: (_) => _setHoveredDialpadKey(key),
      onExit: (_) {
        if (_hoveredDialpadKey == key) _setHoveredDialpadKey(null);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _insertDialpadKey(key),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumberControllerChanged() {
    if (_normalizingDialpadNumber) return;

    final value = _numberController.value;
    final cleaned = _sanitizeDialpadNumber(value.text);
    var current = value.text;
    if (cleaned != value.text) {
      final selectionOffset = _cleanedDialpadSelectionOffset(
        value.text,
        value.selection.extentOffset,
        cleaned.length,
      );
      _normalizingDialpadNumber = true;
      _numberController.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: selectionOffset),
      );
      _normalizingDialpadNumber = false;
      current = cleaned;
    }

    final feedbackKey = _latestInsertedDialpadKey(_lastDialpadValue, current);
    _lastDialpadValue = current;
    if (feedbackKey != null) _flashDialpadKey(feedbackKey);
  }

  void _insertDialpadKey(String key) {
    final value = _numberController.text;
    final selection = _numberController.selection;
    final start = selection.start < 0 ? value.length : selection.start;
    final end = selection.end < 0 ? value.length : selection.end;
    _numberController.value = TextEditingValue(
      text: value.replaceRange(start, end, key),
      selection: TextSelection.collapsed(offset: start + key.length),
    );
  }

  void _clearDialpadNumber() {
    _numberFocusNode.requestFocus();
    _numberController.clear();
  }

  String? _latestInsertedDialpadKey(String before, String after) {
    if (before == after) return null;

    var prefix = 0;
    while (prefix < before.length &&
        prefix < after.length &&
        before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
      prefix++;
    }

    var beforeEnd = before.length;
    var afterEnd = after.length;
    while (beforeEnd > prefix &&
        afterEnd > prefix &&
        before.codeUnitAt(beforeEnd - 1) == after.codeUnitAt(afterEnd - 1)) {
      beforeEnd--;
      afterEnd--;
    }

    final inserted = after.substring(prefix, afterEnd);
    for (var index = inserted.length - 1; index >= 0; index--) {
      final key = inserted[index];
      if (_isDialpadFeedbackKey(key)) return key;
    }
    return null;
  }

  void _flashDialpadKey(String key) {
    if (!_isDialpadFeedbackKey(key)) return;
    _dialpadKeyFeedbackTimer?.cancel();
    _setActiveDialpadKey(key);
    _dialpadKeyFeedbackTimer = Timer(const Duration(milliseconds: 140), () {
      _setActiveDialpadKey(null);
    });
  }

  void _callNumberIfPossible(
    bool canCall,
    PjsipService service,
    int? accountId,
  ) {
    final number = _numberController.text.trim();
    if (!canCall || number.isEmpty) return;
    service.makeCallFromAccount(number, accountId);
    _selectSection(_WorkspaceSection.calls);
  }
}

class _DialpadNumberInputFormatter extends TextInputFormatter {
  const _DialpadNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = _sanitizeDialpadNumber(newValue.text);
    if (cleaned == newValue.text) return newValue;

    final selectionOffset = _cleanedDialpadSelectionOffset(
      newValue.text,
      newValue.selection.extentOffset,
      cleaned.length,
    );
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class _DialpadContactMatch {
  const _DialpadContactMatch({
    required this.contact,
    required this.phone,
    required this.exact,
  });

  final ContactEntry contact;
  final ContactPhoneEntry phone;
  final bool exact;
}

bool _isDialpadFeedbackKey(String value) {
  return value.length == 1 && '0123456789*#'.contains(value);
}

String _sanitizeDialpadNumber(String input) {
  var value = input.trim();
  final uriMatch = RegExp(
    r'(?:sip|sips|tel):([^@;>\s]+)',
    caseSensitive: false,
  ).firstMatch(value);
  if (uriMatch != null) value = uriMatch.group(1) ?? value;

  final buffer = StringBuffer();
  var usedPlus = false;
  for (var index = 0; index < value.length; index++) {
    final char = value[index];
    if ('0123456789*#'.contains(char)) {
      buffer.write(char);
      continue;
    }
    if (char == '+' && buffer.isEmpty && !usedPlus) {
      buffer.write(char);
      usedPlus = true;
    }
  }
  return buffer.toString();
}

int _cleanedDialpadSelectionOffset(
  String value,
  int rawOffset,
  int cleanedLength,
) {
  final safeOffset = math.max(0, math.min(rawOffset, value.length));
  final prefix = value.substring(0, safeOffset);
  final offset = _sanitizeDialpadNumber(prefix).length;
  return math.min(offset, cleanedLength);
}
