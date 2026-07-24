part of '../../../main.dart';

extension _HomeSettingsAudioTab on _MyHomePageState {
  Widget _buildAudioSettingsTab(PjsipUIState uiState, PjsipService service) {
    if (!uiState.isInitialized) {
      return Center(
        child: FilledButton.icon(
          onPressed: uiState.isNetworkAvailable
              ? () => _showAddAccountDialog(uiState, service)
              : null,
          icon: const Icon(AppIcons.login),
          label: const Text('添加电话线路'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildAudioStatusPanel(uiState, service),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: '输入与输出',
          icon: AppIcons.devices,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn = constraints.maxWidth >= 560;
                final cards = [
                  _buildAudioDeviceCard(
                    icon: uiState.isMicrophoneMuted
                        ? AppIcons.microphoneOff
                        : AppIcons.microphone,
                    title: '麦克风',
                    subtitle: '输入设备',
                    level: _audioSettingsLevel(uiState.microphoneLevel),
                    muted: uiState.isMicrophoneMuted,
                    testing: uiState.isMicrophoneTesting,
                    dropdown: _buildAudioDeviceDropdown(
                      label: '麦克风',
                      icon: AppIcons.microphone,
                      value: _selectedCaptureDeviceValue(uiState),
                      devices: uiState.captureDevices,
                      onChanged: (value) {
                        if (value != null) {
                          service.setAudioDevices(captureDeviceId: value);
                        }
                      },
                    ),
                    primaryAction: FilledButton.tonalIcon(
                      onPressed: () => service.setMicrophoneTesting(
                        !uiState.isMicrophoneTesting,
                      ),
                      icon: Icon(
                        uiState.isMicrophoneTesting
                            ? AppIcons.stop
                            : AppIcons.microphone,
                      ),
                      label: Text(
                        uiState.isMicrophoneTesting ? '停止测试' : '测试输入',
                      ),
                    ),
                    secondaryAction: TextButton.icon(
                      onPressed: () => service.setMicrophoneMuted(
                        !uiState.isMicrophoneMuted,
                      ),
                      icon: Icon(
                        uiState.isMicrophoneMuted
                            ? AppIcons.microphone
                            : AppIcons.microphoneOff,
                      ),
                      label: Text(uiState.isMicrophoneMuted ? '取消静音' : '静音'),
                    ),
                  ),
                  _buildAudioDeviceCard(
                    icon: uiState.isSpeakerMuted
                        ? AppIcons.speakerOff
                        : AppIcons.speaker,
                    title: '扬声器',
                    subtitle: '输出设备',
                    level: _audioSettingsLevel(uiState.speakerLevel),
                    muted: uiState.isSpeakerMuted,
                    testing: uiState.isSpeakerTesting,
                    dropdown: _buildAudioDeviceDropdown(
                      label: '扬声器',
                      icon: AppIcons.speaker,
                      value: _selectedPlaybackDeviceValue(uiState),
                      devices: uiState.playbackDevices,
                      onChanged: (value) {
                        if (value != null) {
                          service.setAudioDevices(playbackDeviceId: value);
                        }
                      },
                    ),
                    primaryAction: FilledButton.tonalIcon(
                      onPressed: uiState.isSpeakerTesting
                          ? null
                          : service.testSpeakerOutput,
                      icon: const Icon(AppIcons.speaker),
                      label: Text(uiState.isSpeakerTesting ? '播放中' : '测试输出'),
                    ),
                    secondaryAction: TextButton.icon(
                      onPressed: () =>
                          service.setSpeakerMuted(!uiState.isSpeakerMuted),
                      icon: Icon(
                        uiState.isSpeakerMuted
                            ? AppIcons.speaker
                            : AppIcons.speakerOff,
                      ),
                      label: Text(uiState.isSpeakerMuted ? '取消静音' : '静音'),
                    ),
                  ),
                ];

                if (!twoColumn) {
                  return Column(
                    children: [cards[0], const SizedBox(height: 12), cards[1]],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: '策略',
          icon: AppIcons.automatic,
          children: [
            SegmentedButton<PjsipAudioDeviceMode>(
              style: ButtonStyle(
                side: const WidgetStatePropertyAll(
                  BorderSide(color: _softBorder),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: PjsipAudioDeviceMode.automatic,
                  icon: Icon(AppIcons.automatic),
                  label: Text('自动'),
                ),
                ButtonSegment(
                  value: PjsipAudioDeviceMode.manual,
                  icon: Icon(AppIcons.tune),
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
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic,
              onChanged: service.setAutomaticAudioDeviceSelection,
              secondary: const Icon(AppIcons.automatic),
              title: const Text('自动选择设备'),
              subtitle: const Text('优先耳机/蓝牙设备'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(AppIcons.refresh),
              title: const Text('通话中自动切换'),
              subtitle: const Text('耳机插拔时恢复音频路径'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioStatusPanel(PjsipUIState uiState, PjsipService service) {
    final automatic = uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _subtlePanel,
                borderRadius: BorderRadius.circular(_radiusSm),
              ),
              child: Icon(
                automatic ? AppIcons.automatic : AppIcons.tune,
                size: _iconMd,
                color: _textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(automatic ? '自动音频路由' : '手动音频路由'),
                  const SizedBox(height: 2),
                  Text(
                    uiState.audioDeviceStatus,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: service.refreshAudioDevices,
              icon: const Icon(AppIcons.refresh),
              label: const Text('刷新'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: service.repairAudioPath,
              icon: const Icon(AppIcons.activity),
              label: const Text('修复'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioDeviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double level,
    required bool muted,
    required bool testing,
    required Widget dropdown,
    required Widget primaryAction,
    required Widget secondaryAction,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: _iconMd),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  testing
                      ? '测试中'
                      : muted
                      ? '静音'
                      : '就绪',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: muted ? _textSecondary : _textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            dropdown,
            const SizedBox(height: 12),
            _buildLevelTile(value: level, muted: muted),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [primaryAction, secondaryAction],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioDeviceDropdown({
    required String label,
    required IconData icon,
    required int? value,
    required List<PjsipAudioDevice> devices,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: devices
          .map(
            (device) => DropdownMenuItem<int>(
              value: device.id,
              child: Text(device.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  int? _selectedCaptureDeviceValue(PjsipUIState uiState) {
    return uiState.captureDevices.any(
          (device) => device.id == uiState.selectedCaptureDeviceId,
        )
        ? uiState.selectedCaptureDeviceId
        : null;
  }

  int? _selectedPlaybackDeviceValue(PjsipUIState uiState) {
    return uiState.playbackDevices.any(
          (device) => device.id == uiState.selectedPlaybackDeviceId,
        )
        ? uiState.selectedPlaybackDeviceId
        : null;
  }

  double _audioSettingsLevel(int value) {
    return (value / 255.0).clamp(0.0, 1.0);
  }

  Widget _buildLevelTile({required double value, required bool muted}) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: muted ? 0 : value,
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(
            muted ? '静音' : '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
