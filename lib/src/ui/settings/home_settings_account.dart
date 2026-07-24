part of '../../../main.dart';

extension _HomeSettingsAccountTab on _MyHomePageState {
  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildSettingsSection(
          title: '线路状态',
          icon: AppIcons.route,
          children: [
            _buildConnectionPill(uiState, service),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: uiState.isNetworkAvailable
                        ? () => _showAddAccountDialog(uiState, service)
                        : null,
                    icon: const Icon(AppIcons.add),
                    label: const Text('添加线路'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (uiState.accounts.isEmpty)
              Text('尚未接入线路', style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final account in uiState.accounts.values)
                _buildAccountLineTile(uiState, service, account),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: uiState.isInitialized
                  ? service.disconnectAllAccounts
                  : null,
              icon: const Icon(AppIcons.power),
              label: const Text('断开全部线路'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountLineTile(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
  ) {
    final isDefault = uiState.defaultAccountId == account.accId;
    final color = account.isRegistered ? _brandGreen : Colors.orange.shade700;
    final hasActiveCalls = uiState.calls.values.any(
      (call) => call.accountId == account.accId,
    );
    final detail =
        '${account.host} · ${account.transportLabel}'
        '${account.mediaSecurity.usesSrtp ? ' · ${account.mediaSecurity.mode.label}' : ''}'
        '${account.iceConfig.hasStunServer ? ' · STUN' : ''}'
        '${account.iceConfig.enabled ? ' · ICE' : ''}'
        '${account.turnConfig.isUsable ? ' · TURN' : ''}'
        ' · ${account.registrationStatusText}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTooltipText(
                      account.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isDefault)
                const Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('默认外呼'),
                )
              else
                TextButton(
                  onPressed: account.isRegistered
                      ? () => service.setDefaultAccount(account.accId)
                      : null,
                  child: const Text('设为默认'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed:
                    account.registrationActionInProgress ||
                        (account.registrationEnabled &&
                            account.registrationStatus == null)
                    ? null
                    : () => service.setAccountRegistration(account.accId, true),
                icon: const Icon(AppIcons.refresh),
                label: const Text('重连'),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed:
                    account.registrationActionInProgress ||
                        !account.registrationEnabled
                    ? null
                    : () =>
                          service.setAccountRegistration(account.accId, false),
                icon: const Icon(AppIcons.pause),
                label: const Text('暂停'),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed:
                    account.registrationActionInProgress || hasActiveCalls
                    ? null
                    : () => _showEditAccountDialog(uiState, service, account),
                icon: const Icon(AppIcons.edit),
                label: const Text('编辑'),
              ),
              const Spacer(),
              IconButton(
                tooltip: '删除线路',
                onPressed: () => service.removeAccount(account.accId),
                icon: const Icon(AppIcons.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
