part of '../../main.dart';

extension _HomeSettings on _MyHomePageState {
  Widget _buildSettingsDrawer(PjsipUIState uiState, PjsipService service) {
    return Drawer(
      width: 460,
      child: SafeArea(
        child: DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.account_circle), text: '账号'),
                  Tab(icon: Icon(Icons.headphones), text: '音频'),
                  Tab(icon: Icon(Icons.call), text: '通话'),
                  Tab(icon: Icon(Icons.bug_report), text: '诊断'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAccountSettingsTab(uiState, service),
                    _buildAudioSettingsTab(uiState, service),
                    _buildCallSettingsTab(uiState, service),
                    _buildDiagnosticsTab(uiState, service),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildAudioSettingsTab(PjsipUIState uiState, PjsipService service) {
    if (!uiState.isInitialized) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => _registerLine(service),
          icon: const Icon(Icons.login),
          label: const Text('添加电话线路'),
        ),
      );
    }

    final micLevel = (uiState.microphoneLevel / 255.0).clamp(0.0, 1.0);
    final speakerLevel = (uiState.speakerLevel / 255.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '设备',
          icon: Icons.devices,
          children: [_buildAudioDevicePanel(uiState, service)],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '测试',
          icon: Icons.graphic_eq,
          children: [
            _buildLevelTile(
              icon: Icons.mic,
              label: '麦克风输入',
              value: micLevel,
              muted: uiState.isMicrophoneMuted,
            ),
            const SizedBox(height: 12),
            _buildLevelTile(
              icon: Icons.volume_up,
              label: '扬声器输出',
              value: speakerLevel,
              muted: uiState.isSpeakerMuted,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => service.setMicrophoneTesting(
                    !uiState.isMicrophoneTesting,
                  ),
                  icon: Icon(
                    uiState.isMicrophoneTesting ? Icons.stop : Icons.mic,
                  ),
                  label: Text(
                    uiState.isMicrophoneTesting ? '停止麦克风测试' : '开始麦克风测试',
                  ),
                ),
                FilledButton.icon(
                  onPressed: uiState.isSpeakerTesting
                      ? null
                      : service.testSpeakerOutput,
                  icon: const Icon(Icons.volume_up),
                  label: Text(uiState.isSpeakerTesting ? '播放中' : '测试扬声器'),
                ),
                OutlinedButton.icon(
                  onPressed: service.repairAudioPath,
                  icon: const Icon(Icons.healing),
                  label: const Text('修复音频'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '策略',
          icon: Icons.auto_mode,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic,
              onChanged: service.setAutomaticAudioDeviceSelection,
              secondary: const Icon(Icons.auto_mode),
              title: const Text('自动选择设备'),
              subtitle: const Text('优先耳机/蓝牙设备'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(Icons.sync),
              title: const Text('通话中自动切换'),
              subtitle: const Text('耳机插拔时恢复音频路径'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '通话控制',
          icon: Icons.call,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups),
              title: const Text('最大同时通话'),
              trailing: const Text('4 路'),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dialpad),
              title: const Text('DTMF 方式'),
              trailing: const Text('RFC2833'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(Icons.headset_mic),
              title: const Text('通话中跟随耳机切换'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '快捷操作',
          icon: Icons.bolt,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.mic_off),
              title: const Text('默认静音状态'),
              trailing: const Text('关闭'),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.call_merge),
              title: const Text('会议通话'),
              trailing: Text(uiState.hasConference ? '进行中' : '可用'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioDevicePanel(PjsipUIState uiState, PjsipService service) {
    final captureValue =
        uiState.captureDevices.any(
          (device) => device.id == uiState.selectedCaptureDeviceId,
        )
        ? uiState.selectedCaptureDeviceId
        : null;
    final playbackValue =
        uiState.playbackDevices.any(
          (device) => device.id == uiState.selectedPlaybackDeviceId,
        )
        ? uiState.selectedPlaybackDeviceId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                uiState.audioDeviceStatus,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            OutlinedButton.icon(
              onPressed: service.refreshAudioDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<PjsipAudioDeviceMode>(
          segments: const [
            ButtonSegment(
              value: PjsipAudioDeviceMode.automatic,
              icon: Icon(Icons.auto_mode),
              label: Text('自动'),
            ),
            ButtonSegment(
              value: PjsipAudioDeviceMode.manual,
              icon: Icon(Icons.tune),
              label: Text('手动'),
            ),
          ],
          selected: {uiState.audioDeviceMode},
          onSelectionChanged: (values) {
            service.setAutomaticAudioDeviceSelection(
              values.first == PjsipAudioDeviceMode.automatic,
            );
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: captureValue,
          decoration: const InputDecoration(
            labelText: '麦克风',
            prefixIcon: Icon(Icons.mic),
          ),
          items: uiState.captureDevices
              .map(
                (device) => DropdownMenuItem<int>(
                  value: device.id,
                  child: Text(device.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) service.setAudioDevices(captureDeviceId: value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: playbackValue,
          decoration: const InputDecoration(
            labelText: '扬声器',
            prefixIcon: Icon(Icons.volume_up),
          ),
          items: uiState.playbackDevices
              .map(
                (device) => DropdownMenuItem<int>(
                  value: device.id,
                  child: Text(device.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) service.setAudioDevices(playbackDeviceId: value);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: () =>
                  service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
              icon: Icon(uiState.isMicrophoneMuted ? Icons.mic_off : Icons.mic),
              label: Text(uiState.isMicrophoneMuted ? '取消静音' : '麦克风静音'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => service.setSpeakerMuted(!uiState.isSpeakerMuted),
              icon: Icon(
                uiState.isSpeakerMuted ? Icons.volume_off : Icons.volume_up,
              ),
              label: Text(uiState.isSpeakerMuted ? '取消静音' : '扬声器静音'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: _panelBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required IconData icon,
    required String label,
    required double value,
    required bool muted,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        SizedBox(width: 86, child: Text(label)),
        Expanded(child: LinearProgressIndicator(value: muted ? 0 : value)),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          child: Text(
            muted ? '静音' : '${(value * 100).round()}%',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsTab(PjsipUIState uiState, PjsipService service) {
    return Column(
      children: [
        SwitchListTile(
          value: _showDiagnosticLogs,
          onChanged: (value) => _setDiagnosticLogsVisible(value),
          secondary: const Icon(Icons.receipt_long),
          title: const Text('显示日志'),
          subtitle: const Text('设备、注册、通话事件'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: uiState.isInitialized
                    ? service.refreshAudioDevices
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新设备'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: uiState.logs.isEmpty ? null : service.clearLogs,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('清空日志'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _showDiagnosticLogs
              ? _buildLogList(uiState)
              : const Center(child: Text('日志已隐藏')),
        ),
      ],
    );
  }

  Widget _buildLogList(PjsipUIState uiState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBorder),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: uiState.logs.length,
        itemBuilder: (context, index) {
          final log = uiState.logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '[${DateFormat('HH:mm:ss').format(log.time)}] ${log.message}',
              style: const TextStyle(
                color: _textPrimary,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}
