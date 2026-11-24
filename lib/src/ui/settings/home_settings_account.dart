part of '../../../main.dart';

// 卡片之间的纵向间距。拖动高亮也用这个值扣除卡片底部的空白。
const _accountLineSpacing = 10.0;
const _accountAccent = Color(0xff086950);
const _accountMenuWidth = 176.0;
const _accountMenuPadding = 5.0;

class _AccountLineDragListener extends ReorderableDragStartListener {
  const _AccountLineDragListener({
    required super.index,
    required super.enabled,
    required super.child,
  });

  @override
  DelayedMultiDragGestureRecognizer createRecognizer() =>
      DelayedMultiDragGestureRecognizer(
        delay: const Duration(milliseconds: 50),
        debugOwner: this,
      );
}

extension _HomeSettingsAccountTab on _MyHomePageState {
  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    final isRestarting = uiState.isPhoneServiceRestarting;
    final hasActiveCalls = uiState.calls.isNotEmpty;
    final restartingApplication = _applicationRestarting;
    final accounts = uiState.accountList;
    final onlineCount = accounts
        .where((account) => account.isRegistered)
        .length;
    final hasDisconnectableLine = accounts.any(
      (account) => account.registrationEnabled || account.isRegistered,
    );
    final canDisconnectAll =
        uiState.isInitialized &&
        hasDisconnectableLine &&
        !hasActiveCalls &&
        !isRestarting &&
        !restartingApplication;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        children: [
          _buildAccountToolbar(
            accountCount: accounts.length,
            onlineCount: onlineCount,
            canAddAccount:
                uiState.isNetworkAvailable &&
                !isRestarting &&
                !restartingApplication,
            canDisconnectAll: canDisconnectAll,
            restartingApplication: restartingApplication,
            onAddAccount: () => _showAddAccountDialog(uiState, service),
            onDisconnectAll: () async {
              final confirmed = await _confirmDisconnectAllAccounts(uiState);
              if (confirmed != true || !mounted) return;
              service.disconnectAllAccounts();
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: accounts.isEmpty
                ? _buildEmptyAccountList()
                : ReorderableListView.builder(
                    padding: EdgeInsets.zero,
                    buildDefaultDragHandles: false,
                    proxyDecorator: _buildAccountDragPreview,
                    itemCount: accounts.length,
                    onReorderItem: (oldIndex, newIndex) => _reorderAccountLines(
                      uiState,
                      service,
                      oldIndex,
                      newIndex,
                    ),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isDefault =
                          uiState.defaultAccountId == account.accId;
                      final canReorder =
                          !isDefault && !isRestarting && !restartingApplication;
                      final l10n = context.l10n;
                      return MouseRegion(
                        key: ValueKey('settings-account-${account.accId}'),
                        cursor: canReorder
                            ? SystemMouseCursors.grab
                            : MouseCursor.defer,
                        child: TooltipTheme(
                          // 可排序时将长按手势留给整行，文字和按钮仍支持鼠标悬停提示。
                          data: canReorder
                              ? TooltipTheme.of(context).copyWith(
                                  triggerMode: TooltipTriggerMode.manual,
                                )
                              : TooltipTheme.of(context),
                          child: Tooltip(
                            message: isDefault
                                ? l10n.accountSettingsDefaultPinned
                                : canReorder
                                ? l10n.accountSettingsDragToReorder
                                : l10n.accountSettingsReorderUnavailable,
                            child: _buildAccountLineTile(
                              uiState,
                              service,
                              account,
                              index: index,
                              canReorder: canReorder,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDragPreview(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    final scale = Tween(
      begin: 1.0,
      end: 0.99,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    return ScaleTransition(
      scale: scale,
      child: Stack(
        children: [
          Material(type: MaterialType.transparency, child: child),
          Positioned.fill(
            bottom: _accountLineSpacing,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _brandGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(_radiusSm),
                  border: Border.all(
                    color: _brandGreen.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账号页顶部操作栏，集中放置线路统计和页面级操作。
  Widget _buildAccountToolbar({
    required int accountCount,
    required int onlineCount,
    required bool canAddAccount,
    required bool canDisconnectAll,
    required bool restartingApplication,
    required VoidCallback onAddAccount,
    required VoidCallback onDisconnectAll,
  }) {
    final l10n = context.l10n;
    final summary = Text(
      l10n.accountSettingsSummary(accountCount, onlineCount),
      style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w500),
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: canDisconnectAll ? onDisconnectAll : null,
          icon: const Icon(AppIcons.power),
          label: Text(l10n.accountSettingsDisconnectAll),
        ),
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
          label: Text(
            restartingApplication
                ? l10n.accountSettingsRestarting
                : l10n.accountSettingsRestartApp,
          ),
        ),
        FilledButton.icon(
          onPressed: canAddAccount ? onAddAccount : null,
          icon: const Icon(AppIcons.add),
          label: Text(l10n.accountSettingsAddLine),
          style: FilledButton.styleFrom(backgroundColor: _textPrimary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }
        return Row(
          children: [
            summary,
            const SizedBox(width: 12),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: actions),
            ),
          ],
        );
      },
    );
  }

  /// 账号列表为空时给出简洁引导，不再重复展示连接状态。
  Widget _buildEmptyAccountList() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.lines,
            size: 34,
            color: _textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.accountSettingsEmpty,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.accountSettingsEmptyHint,
            style: TextStyle(color: _textSecondary),
          ),
        ],
      ),
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

  /// 线路卡片左侧分两行显示账号和服务器信息，右侧放主按钮和更多菜单。
  Widget _buildAccountLineTile(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account, {
    required int index,
    required bool canReorder,
  }) {
    final l10n = context.l10n;
    final isDefault = uiState.defaultAccountId == account.accId;
    final status = AccountLocalizer.lineStatus(account);
    final color = switch (status) {
      AccountLineStatus.online => _brandGreen,
      AccountLineStatus.disabled => _textSecondary,
      _ => Colors.orange.shade700,
    };
    final ready =
        !uiState.isPhoneServiceRestarting &&
        !_applicationRestarting &&
        !account.registrationActionInProgress &&
        !account.isRestoringPlaceholder &&
        account.restartPhase == SipAccountRestartPhase.none;
    final canManage = ready && !uiState.hasCallOnAccount(account.accId);
    final canRegister =
        ready && uiState.isInitialized && uiState.isNetworkAvailable;
    final canDisable = canManage && uiState.isInitialized;
    final retry =
        status == AccountLineStatus.failed ||
        status == AccountLineStatus.offline;
    final detail = [
      account.lineName.trim().isEmpty ? account.host : account.lineLabel,
      account.transportLabel,
      if (account.mediaSecurity.usesSrtp)
        _accountDialogMediaLabel(l10n, account.mediaSecurity.mode),
      if (account.iceConfig.stunEnabled) 'STUN',
      if (account.iceConfig.enabled) 'ICE',
      if (account.turnConfig.isUsable) 'TURN',
    ].join(' · ');
    Widget dragArea(Widget child) => _AccountLineDragListener(
      index: index,
      enabled: canReorder,
      child: child,
    );
    final isOnline = status == AccountLineStatus.online;
    final primaryAction = switch (status) {
      AccountLineStatus.online ||
      AccountLineStatus.disabled ||
      AccountLineStatus.failed ||
      AccountLineStatus.offline => OutlinedButton.icon(
        onPressed: (isOnline ? canDisable : canRegister)
            ? () => service.setAccountRegistration(account.accId, !isOnline)
            : null,
        icon: Icon(
          isOnline
              ? AppIcons.pause
              : retry
              ? AppIcons.refresh
              : AppIcons.play,
        ),
        label: Text(
          isOnline
              ? l10n.sidebarDisableLine
              : retry
              ? l10n.settingsStartupRetry
              : l10n.sidebarEnableLine,
        ),
        style:
            OutlinedButton.styleFrom(
              // 启用、停用和重试共用最小尺寸，较长的译文可以撑宽按钮。
              minimumSize: const Size(82, 38),
              iconSize: _iconXs,
              foregroundColor: isOnline ? _textPrimary : _accountAccent,
              backgroundColor: isOnline
                  ? _panelBackground
                  : const Color(0xffe6f5ee),
              disabledForegroundColor: _textSecondary,
              disabledBackgroundColor: _subtlePanel,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(
                  color: states.contains(WidgetState.disabled)
                      ? _softBorder
                      : isOnline
                      ? const Color(0xffc7ccca)
                      : const Color(0xff8fbfae),
                ),
              ),
            ),
      ),
      _ => SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          semanticsLabel: status.label(l10n),
        ),
      ),
    };
    final blockedReason = switch (status) {
      AccountLineStatus.online when uiState.hasCallOnAccount(account.accId) =>
        l10n.runtimeLineActiveCallBlocked(l10n.runtimeActionDisable),
      AccountLineStatus.disabled ||
      AccountLineStatus.failed ||
      AccountLineStatus.offline when !uiState.isNetworkAvailable =>
        l10n.statusNetworkUnavailable,
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: _accountLineSpacing),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: dragArea(const ColoredBox(color: Colors.transparent)),
          ),
          Padding(
            // vertical 控制卡片上下留白；名称与服务器之间的行距由下方 Column 单独控制。
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: dragArea(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: color),
                            const SizedBox(width: 6),
                            Text(
                              status.label(l10n),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 4), // 状态文字与账号名之间的间距
                            Flexible(
                              child: _buildTooltipText(
                                account.displayName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (isDefault) ...[
                              // 账号名到「默认外呼」标签的间距。
                              const SizedBox(width: 10),
                              _buildDefaultOutgoingBadge(l10n),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTooltipText(
                          detail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (blockedReason == null)
                  primaryAction
                else
                  Tooltip(message: blockedReason, child: primaryAction),
                const SizedBox(width: 6),
                MenuAnchor(
                  alignmentOffset: const Offset(-_accountMenuWidth, 4),
                  style: MenuStyle(
                    alignment: AlignmentDirectional.bottomEnd,
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.all(_accountMenuPadding),
                    ),
                    backgroundColor: const WidgetStatePropertyAll(
                      _panelBackground,
                    ),
                    surfaceTintColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    elevation: const WidgetStatePropertyAll(8),
                    shadowColor: const WidgetStatePropertyAll(
                      Color(0x38000000),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: _softBorder),
                      ),
                    ),
                  ),
                  builder: (context, controller, child) => IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).moreButtonTooltip,
                    icon: const Icon(AppIcons.more, size: _iconSm),
                    style: IconButton.styleFrom(
                      backgroundColor: controller.isOpen ? _hoverPanel : null,
                    ),
                    onPressed: controller.isOpen
                        ? controller.close
                        : controller.open,
                  ),
                  menuChildren: [
                    _accountMenuItem(
                      l10n.sidebarEditLine,
                      AppIcons.edit,
                      onPressed: canManage
                          ? () => _showEditAccountDialog(
                              uiState,
                              service,
                              account,
                            )
                          : null,
                    ),
                    if (!isDefault && status == AccountLineStatus.online)
                      _accountMenuItem(
                        l10n.accountSettingsSetDefault,
                        AppIcons.outgoing,
                        onPressed: ready && uiState.isInitialized
                            ? () => service.setDefaultAccount(account.accId)
                            : null,
                      ),
                    if (account.registrationEnabled) ...[
                      if (!retry)
                        _accountMenuItem(
                          l10n.sidebarRefreshLine,
                          AppIcons.refresh,
                          onPressed:
                              canRegister && account.registrationStatus != null
                              ? () => service.setAccountRegistration(
                                  account.accId,
                                  true,
                                )
                              : null,
                        ),
                      _accountMenuItem(
                        l10n.sidebarRestartLine,
                        AppIcons.power,
                        onPressed: canManage && canRegister
                            ? () async {
                                final confirmed =
                                    await _confirmForceReconnectLine(account);
                                if (confirmed == true && mounted) {
                                  service.forceReconnectAccount(account.accId);
                                }
                              }
                            : null,
                      ),
                      if (status != AccountLineStatus.online)
                        _accountMenuItem(
                          l10n.sidebarDisableLine,
                          AppIcons.pause,
                          onPressed: canDisable
                              ? () => service.setAccountRegistration(
                                  account.accId,
                                  false,
                                )
                              : null,
                        ),
                    ],
                    const Divider(height: 9, indent: 8, endIndent: 8),
                    _accountMenuItem(
                      l10n.sidebarDeleteLine,
                      AppIcons.delete,
                      destructive: true,
                      onPressed: canManage
                          ? () async {
                              final confirmed = await _confirmDeleteLine(
                                account,
                              );
                              if (confirmed == true && mounted) {
                                service.removeAccount(account.accId);
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountMenuItem(
    String label,
    IconData icon, {
    required VoidCallback? onPressed,
    bool destructive = false,
  }) {
    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(
          _accountMenuWidth - 2 * _accountMenuPadding,
          36,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: destructive ? _dangerRed : _textPrimary,
        iconColor: destructive ? _dangerRed : _textSecondary,
        iconSize: _iconXs,
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      leadingIcon: Icon(icon),
      child: Text(label),
    );
  }

  /// 默认外呼标签：ShapeDecoration 设置底色与形状，Padding 设置标签内边距。
  Widget _buildDefaultOutgoingBadge(AppLocalizations l10n) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: _accountAccent,
        shape: StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.defaultLine, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              l10n.accountSettingsDefaultOutgoing,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmRestartApplication(PjsipUIState uiState) {
    final l10n = context.l10n;
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
                        Text(
                          l10n.accountSettingsRestartApp,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.accountSettingsRestartDescription,
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
                      _buildRestartStep(l10n.accountSettingsRestartStepSave),
                      const SizedBox(height: 8),
                      _buildRestartStep(l10n.accountSettingsRestartStepClose),
                      const SizedBox(height: 8),
                      _buildRestartStep(l10n.accountSettingsRestartStepRestore),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                uiState.calls.isEmpty
                    ? l10n.accountSettingsRestartRecommended
                    : l10n.accountSettingsRestartCallWarning,
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
            icon: const Icon(AppIcons.refresh),
            label: Text(l10n.accountSettingsRestartApp),
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
