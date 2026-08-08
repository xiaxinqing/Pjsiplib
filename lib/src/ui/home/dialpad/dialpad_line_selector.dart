part of '../../../../main.dart';

/// 外呼线路选择器：负责展示当前线路、切换线路菜单和无可用线路提示。
extension _DialpadLineSelector on _MyHomePageState {
  Widget _buildOutgoingLineSelector(
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final l10n = context.l10n;
    final accounts = uiState.accountList;
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
            Text(
              l10n.dialOutgoingLine,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.dialNoLinesAdded,
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
              label: Text(l10n.commonAdd),
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
    final isShowingFallback =
        uiState.isUsingFallbackOutgoingAccount &&
        selectedAccount?.accId == uiState.bestOutgoingAccount?.accId;
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
              Text(
                l10n.dialOutgoingLine,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
                  tooltip: l10n.dialOpenLineSettings,
                  onPressed: () =>
                      _openSettingsDrawer(tabIndex: _settingsAccountIndex),
                  icon: const Icon(AppIcons.settings),
                ),
              ],
            ],
          ),
          if (!hasUsableLine) ...[
            const SizedBox(height: 4),
            Text(
              l10n.dialNoAvailableOutgoing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
            ),
          ] else if (isShowingFallback) ...[
            const SizedBox(height: 4),
            Text(
              l10n.dialFallbackOutgoing(uiState.defaultAccount!.lineLabel),
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

  Widget _buildOutgoingLineMenuButton(
    SipAccountInfo? account, {
    required VoidCallback onPressed,
    required bool isOpen,
  }) {
    final label = account == null
        ? context.l10n.dialNoAvailableLine
        : _buildCompactOutgoingLineLabel(account);
    final tooltip = account == null
        ? label
        : '$label\n${account.lineLabel} · ${account.transportLabel}';
    return Tooltip(
      message: tooltip,
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

  /// 拨号区空间有限，线路名称未包含账号时补充账号，便于快速辨认具体线路。
  String _buildCompactOutgoingLineLabel(SipAccountInfo account) {
    final displayName = account.displayName.trim();
    final username = account.username.trim();
    if (username.isEmpty ||
        displayName.toLowerCase().contains(username.toLowerCase())) {
      return displayName;
    }
    return '$displayName · $username';
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
                account.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              _buildTooltipText(
                '${account.lineLabel} · ${account.transportLabel}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AccountLocalizer.status(context.l10n, account),
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
        Expanded(
          flex: 3,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
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
}
