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
    final l10n = context.l10n;
    final title = switch (_section) {
      _WorkspaceSection.dialpad => l10n.navDialpad,
      _WorkspaceSection.calls => l10n.navCurrentCalls,
      _WorkspaceSection.contacts => l10n.navContacts,
      _WorkspaceSection.history => l10n.navCallHistory,
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
            tooltip: l10n.settings,
            onPressed: _openSettingsDrawer,
            icon: const Icon(AppIcons.settings, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    if (uiState.accounts.isNotEmpty) {
      final hasDisconnectableLine = uiState.accounts.values.any(
        (account) => account.registrationEnabled || account.isRegistered,
      );
      final canDisconnect =
          uiState.isInitialized &&
          uiState.calls.isEmpty &&
          hasDisconnectableLine;
      final tooltip = uiState.calls.isNotEmpty
          ? l10n.headerEndCallsFirst
          : !uiState.isInitialized
          ? l10n.headerPhoneServiceUnavailable
          : !hasDisconnectableLine
          ? l10n.headerAllLinesDisconnected
          : l10n.headerDisconnectAllLines;
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
      label: Text(l10n.headerAddLine),
      style: FilledButton.styleFrom(backgroundColor: _textPrimary),
    );
  }

  Future<bool?> _confirmDisconnectAllAccounts(PjsipUIState uiState) {
    final l10n = context.l10n;
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
                        Text(
                          l10n.headerDisconnectAllLines,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.disconnectAllDescription,
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
                          l10n.disconnectAllSummary(
                            uiState.accounts.length,
                            uiState.registeredAccounts.length,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disconnectAllQuestion,
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
            label: Text(l10n.disconnectAllAction),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
          ),
        ],
      ),
    );
  }

  String _statusSubtitle(PjsipUIState uiState) {
    final l10n = context.l10n;
    if (!uiState.isNetworkAvailable) return l10n.statusNetworkUnavailable;
    if (uiState.seatEnvironmentState == SeatEnvironmentState.checking) {
      return l10n.statusCheckingSeatEnvironment;
    }
    if (uiState.seatEnvironmentState == SeatEnvironmentState.restoring) {
      return l10n.statusRestoringLines;
    }
    if (uiState.accounts.isNotEmpty) {
      final outgoingAccount = uiState.bestOutgoingAccount;
      if (outgoingAccount == null) {
        return l10n.statusConnectedNoOutgoing(uiState.accounts.length);
      }
      if (uiState.isUsingFallbackOutgoingAccount) {
        return l10n.statusConnectedCurrentOutgoing(
          uiState.accounts.length,
          outgoingAccount.displayName,
        );
      }
      return l10n.statusConnectedDefaultOutgoing(
        uiState.accounts.length,
        outgoingAccount.displayName,
      );
    }
    if (uiState.isInitialized) return l10n.statusInitializedNoAccounts;
    return l10n.statusConnectServiceHint;
  }
}
