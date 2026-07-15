part of '../../../main.dart';

extension _HomeSettingsAccountTab on _MyHomePageState {
  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '线路状态',
          icon: Icons.route,
          children: [
            _buildConnectionPill(uiState, service),
            const SizedBox(height: 12),
            if (uiState.accounts.isEmpty)
              Text('尚未接入线路', style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final account in uiState.accounts.values)
                _buildAccountLineTile(uiState, service, account),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: uiState.isInitialized ? service.stop : null,
              icon: const Icon(Icons.power_settings_new),
              label: const Text('断开全部线路'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '新增线路',
          icon: Icons.add_call,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '线路账号',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? '显示密码' : '隐藏密码',
                  onPressed: () => _togglePasswordVisibility(),
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: '服务器',
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: uiState.isNetworkAvailable
                        ? () => _registerLine(service)
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('添加并注册线路'),
                  ),
                ),
              ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
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
                    Text(
                      account.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.host} · ${account.registrationStatusText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                icon: const Icon(Icons.refresh),
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
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('暂停'),
              ),
              const Spacer(),
              IconButton(
                tooltip: '删除线路',
                onPressed: () => service.removeAccount(account.accId),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
