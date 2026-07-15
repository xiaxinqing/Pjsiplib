part of '../../../main.dart';

extension _HomeSettingsAudioTab on _MyHomePageState {
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
}
