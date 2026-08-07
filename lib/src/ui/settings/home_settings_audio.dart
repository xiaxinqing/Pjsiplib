part of '../../../main.dart';

extension _HomeSettingsAudioTab on _MyHomePageState {
  Widget _buildAudioSettingsTab(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    if (!uiState.isInitialized) {
      return Center(
        child: FilledButton.icon(
          onPressed: uiState.isNetworkAvailable
              ? () => _showAddAccountDialog(uiState, service)
              : null,
          icon: const Icon(AppIcons.login),
          label: Text(l10n.audioAddLine),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildAudioStatusPanel(uiState, service),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: l10n.audioSoundAlerts,
          icon: AppIcons.audio,
          children: [
            _buildAudioEffectSwitch(
              icon: AppIcons.incoming,
              title: l10n.audioIncomingRingtone,
              subtitle: l10n.audioIncomingRingtoneDescription,
              value: uiState.incomingRingtoneEnabled,
              onChanged: service.setIncomingRingtoneEnabled,
            ),
            _buildAudioEffectSwitch(
              icon: AppIcons.outgoing,
              title: l10n.audioOutgoingRingback,
              subtitle: l10n.audioOutgoingRingbackDescription,
              value: uiState.outgoingRingbackEnabled,
              onChanged: service.setOutgoingRingbackEnabled,
            ),
            _buildAudioEffectSwitch(
              icon: AppIcons.callEnd,
              title: l10n.audioCallEndedTone,
              subtitle: l10n.audioCallEndedToneDescription,
              value: uiState.callEndedSoundEnabled,
              onChanged: service.setCallEndedSoundEnabled,
            ),
            _buildAudioEffectSwitch(
              icon: AppIcons.dialpad,
              title: l10n.audioDialpadTones,
              subtitle: l10n.audioDialpadTonesDescription,
              value: uiState.dialpadKeySoundEnabled,
              onChanged: service.setDialpadKeySoundEnabled,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: l10n.audioRouting,
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
              segments: [
                ButtonSegment(
                  value: PjsipAudioDeviceMode.automatic,
                  icon: const Icon(AppIcons.automatic),
                  label: Text(l10n.audioFollowSystem),
                ),
                ButtonSegment(
                  value: PjsipAudioDeviceMode.manual,
                  icon: const Icon(AppIcons.tune),
                  label: Text(l10n.audioChooseDevices),
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
            Text(
              uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic
                  ? l10n.audioFollowSystemDescription
                  : l10n.audioChooseDevicesDescription,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(AppIcons.refresh),
              title: Text(l10n.audioAutoSwitch),
              subtitle: Text(l10n.audioAutoSwitchDescription),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: l10n.audioInputOutput,
          icon: AppIcons.devices,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn = constraints.maxWidth >= 560;
                final microphoneTestLabel =
                    switch (uiState.microphoneTestPhase) {
                      PjsipMicrophoneTestPhase.recording =>
                        uiState.microphoneTestRemainingSeconds > 0
                            ? l10n.audioRecordingRemaining(
                                uiState.microphoneTestRemainingSeconds,
                              )
                            : l10n.audioRecording,
                      PjsipMicrophoneTestPhase.preparingPlayback =>
                        l10n.audioPreparingPlayback,
                      PjsipMicrophoneTestPhase.playing => l10n.audioPlaying,
                      PjsipMicrophoneTestPhase.idle => l10n.audioRecordingTest,
                    };
                final microphoneTestIcon =
                    switch (uiState.microphoneTestPhase) {
                      PjsipMicrophoneTestPhase.recording => AppIcons.stop,
                      PjsipMicrophoneTestPhase.preparingPlayback =>
                        AppIcons.activity,
                      PjsipMicrophoneTestPhase.playing => AppIcons.speaker,
                      PjsipMicrophoneTestPhase.idle => AppIcons.microphone,
                    };
                final cards = [
                  _buildAudioDeviceCard(
                    icon: uiState.isMicrophoneMuted
                        ? AppIcons.microphoneOff
                        : AppIcons.microphone,
                    title: l10n.audioMicrophone,
                    subtitle: l10n.audioInputDevice,
                    level: _audioSettingsLevel(uiState.microphoneLevel),
                    volume: uiState.microphoneVolume,
                    muted: uiState.isMicrophoneMuted,
                    testing: uiState.isMicrophoneTesting,
                    onVolumeChanged: service.setMicrophoneVolume,
                    dropdown: _buildAudioDeviceDropdown(
                      label: l10n.audioMicrophone,
                      icon: AppIcons.microphone,
                      value: _selectedCaptureDeviceValue(uiState),
                      devices: uiState.captureDevices,
                      automaticMode:
                          uiState.audioDeviceMode ==
                          PjsipAudioDeviceMode.automatic,
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
                      icon: Icon(microphoneTestIcon),
                      label: Text(microphoneTestLabel),
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
                      label: Text(
                        uiState.isMicrophoneMuted
                            ? l10n.audioUnmute
                            : l10n.audioMute,
                      ),
                    ),
                  ),
                  _buildAudioDeviceCard(
                    icon: uiState.isSpeakerMuted
                        ? AppIcons.speakerOff
                        : AppIcons.speaker,
                    title: l10n.audioSpeaker,
                    subtitle: l10n.audioOutputDevice,
                    level: _audioSettingsLevel(uiState.speakerLevel),
                    volume: uiState.speakerVolume,
                    muted: uiState.isSpeakerMuted,
                    testing: uiState.isSpeakerTesting,
                    onVolumeChanged: service.setSpeakerVolume,
                    dropdown: _buildAudioDeviceDropdown(
                      label: l10n.audioSpeaker,
                      icon: AppIcons.speaker,
                      value: _selectedPlaybackDeviceValue(uiState),
                      devices: uiState.playbackDevices,
                      automaticMode:
                          uiState.audioDeviceMode ==
                          PjsipAudioDeviceMode.automatic,
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
                      label: Text(
                        uiState.isSpeakerTesting
                            ? l10n.audioPlaying
                            : l10n.audioTestOutput,
                      ),
                    ),
                    secondaryAction: TextButton.icon(
                      onPressed: () =>
                          service.setSpeakerMuted(!uiState.isSpeakerMuted),
                      icon: Icon(
                        uiState.isSpeakerMuted
                            ? AppIcons.speaker
                            : AppIcons.speakerOff,
                      ),
                      label: Text(
                        uiState.isSpeakerMuted
                            ? l10n.audioUnmute
                            : l10n.audioMute,
                      ),
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
      ],
    );
  }

  Widget _buildAudioStatusPanel(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    final automatic = uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic;
    final hasIssue = uiState.hasAudioDeviceIssue;
    final needsPermissionAction =
        uiState.microphonePermissionStatus ==
            PjsipMicrophonePermissionStatus.denied ||
        uiState.microphonePermissionStatus ==
            PjsipMicrophonePermissionStatus.restricted;
    final showRepairAction = hasIssue && !needsPermissionAction;
    final issueColor = Colors.orange.shade700;
    final statusText = hasIssue
        ? AudioSettingsLocalizer.deviceIssue(
            l10n,
            uiState.audioDeviceIssueStatus,
            diagnosticMessage: uiState.audioDeviceIssueMessage,
          )
        : automatic
        ? l10n.audioFollowingSystemStatus
        : l10n.audioUsingSelectedDevicesStatus;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasIssue ? issueColor.withValues(alpha: 0.06) : _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(
          color: hasIssue ? issueColor.withValues(alpha: 0.28) : _softBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: hasIssue
                        ? issueColor.withValues(alpha: 0.10)
                        : _subtlePanel,
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                  child: Icon(
                    hasIssue
                        ? AppIcons.info
                        : automatic
                        ? AppIcons.automatic
                        : AppIcons.tune,
                    size: _iconMd,
                    color: hasIssue ? issueColor : _textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasIssue
                            ? l10n.audioDeviceNeedsAttention
                            : automatic
                            ? l10n.audioFollowingSystem
                            : l10n.audioUsingSelectedDevices,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasIssue ? issueColor : _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: service.refreshAudioDevices,
                      tooltip: l10n.audioRefreshDevices,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(38, 38),
                        backgroundColor: _subtlePanel,
                        foregroundColor: hasIssue ? issueColor : _textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radiusSm),
                        ),
                      ),
                      icon: const Icon(AppIcons.refresh),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => unawaited(_openSystemSoundSettings()),
                      tooltip: l10n.audioOpenSystemSoundSettings,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(38, 38),
                        backgroundColor: _subtlePanel,
                        foregroundColor: hasIssue ? issueColor : _textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radiusSm),
                        ),
                      ),
                      icon: const Icon(AppIcons.settings),
                    ),
                    if (showRepairAction) ...[
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: service.repairAudioPath,
                        icon: const Icon(AppIcons.activity),
                        label: Text(l10n.audioReconnectDevices),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildMicrophonePermissionRow(uiState, service),
          ],
        ),
      ),
    );
  }

  /// 打开操作系统的声音设置页。
  ///
  /// macOS 的 PJSIP/CoreAudio 在 VoiceProcessingIO 下可能忽略具体设备 ID，
  /// 因此设置页给用户一个明确的系统入口，比在应用里做过多判断更可靠。
  Future<void> _openSystemSoundSettings() async {
    final message = context.l10n.audioOpenSystemSoundSettingsHint;
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [
          'x-apple.systempreferences:com.apple.Sound-Settings.extension',
        ]);
        return;
      }
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', 'ms-settings:sound']);
        return;
      }
    } catch (_) {
      // 下面统一提示即可，避免系统设置 URI 差异影响主流程。
    }
    ToastUtil.showInfo(message);
  }

  Widget _buildMicrophonePermissionRow(
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final l10n = context.l10n;
    final status = uiState.microphonePermissionStatus;
    final enabled = status == PjsipMicrophonePermissionStatus.authorized;
    final color = switch (status) {
      PjsipMicrophonePermissionStatus.authorized => Colors.green.shade700,
      PjsipMicrophonePermissionStatus.denied ||
      PjsipMicrophonePermissionStatus.restricted => Colors.orange.shade700,
      PjsipMicrophonePermissionStatus.notDetermined => Colors.orange.shade700,
      PjsipMicrophonePermissionStatus.unsupported => _textSecondary,
      PjsipMicrophonePermissionStatus.unknown => _textSecondary,
    };
    final title = switch (status) {
      PjsipMicrophonePermissionStatus.authorized => l10n.audioPermissionEnabled,
      PjsipMicrophonePermissionStatus.denied => l10n.audioPermissionDisabled,
      PjsipMicrophonePermissionStatus.restricted =>
        l10n.audioPermissionRestricted,
      PjsipMicrophonePermissionStatus.notDetermined =>
        l10n.audioPermissionPending,
      PjsipMicrophonePermissionStatus.unsupported =>
        l10n.audioPermissionSystemManaged,
      PjsipMicrophonePermissionStatus.unknown => l10n.audioPermissionUnknown,
    };
    final subtitle = switch (status) {
      PjsipMicrophonePermissionStatus.authorized =>
        l10n.audioPermissionEnabledDescription,
      PjsipMicrophonePermissionStatus.denied =>
        l10n.audioPermissionDisabledDescription,
      PjsipMicrophonePermissionStatus.restricted =>
        l10n.audioPermissionRestrictedDescription,
      PjsipMicrophonePermissionStatus.notDetermined =>
        l10n.audioPermissionPendingDescription,
      PjsipMicrophonePermissionStatus.unsupported =>
        l10n.audioPermissionSystemManagedDescription,
      PjsipMicrophonePermissionStatus.unknown =>
        l10n.audioPermissionUnknownDescription,
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radiusSm),
        onTap: service.handleMicrophonePermissionAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(_radiusSm),
                ),
                child: Icon(
                  enabled ? AppIcons.microphone : AppIcons.microphoneOff,
                  size: _iconMd,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildPermissionSwitchPill(
                enabled: enabled,
                status: status,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSwitchPill({
    required bool enabled,
    required PjsipMicrophonePermissionStatus status,
    required Color color,
  }) {
    final tooltip = switch (status) {
      PjsipMicrophonePermissionStatus.authorized =>
        context.l10n.audioPermissionEnabled,
      PjsipMicrophonePermissionStatus.denied ||
      PjsipMicrophonePermissionStatus.restricted =>
        context.l10n.audioPermissionOpenSettings,
      PjsipMicrophonePermissionStatus.notDetermined =>
        context.l10n.audioPermissionRequest,
      PjsipMicrophonePermissionStatus.unsupported =>
        context.l10n.audioPermissionSystemManaged,
      PjsipMicrophonePermissionStatus.unknown =>
        context.l10n.audioPermissionCheck,
    };

    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? color : _hoverPanel,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled ? color : color.withValues(alpha: 0.24),
          ),
        ),
        child: SizedBox(
          width: 50,
          height: 28,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: enabled ? Colors.white : color.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioDeviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double level,
    required int volume,
    required bool muted,
    required bool testing,
    required ValueChanged<int> onVolumeChanged,
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
                      ? context.l10n.audioTesting
                      : muted
                      ? context.l10n.audioMute
                      : context.l10n.audioReady,
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
            _buildVolumeSlider(
              value: volume,
              muted: muted,
              onChanged: onVolumeChanged,
            ),
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

  Widget _buildAudioEffectSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final trackColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _brandGreen;
      if (states.contains(WidgetState.hovered)) return const Color(0xffd9dfdc);
      return const Color(0xffe3e7e5);
    });
    final outlineColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _brandGreen;
      return const Color(0xffcfd6d2);
    });

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_radiusSm),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: _iconMd, color: _textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                trackColor: trackColor,
                trackOutlineColor: outlineColor,
                trackOutlineWidth: WidgetStateProperty.all(1),
                thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return const Color(0xfff9faf9);
                }),
              ),
            ],
          ),
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
    required bool automaticMode,
  }) {
    final dropdown = DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        helperText: automaticMode
            ? context.l10n.audioFollowSystemDeviceHint
            : context.l10n.audioSelectedDeviceHint,
      ),
      items: devices
          .map(
            (device) => DropdownMenuItem<int>(
              value: device.id,
              child: Text(device.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: automaticMode ? null : onChanged,
    );
    if (!automaticMode) return dropdown;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () =>
          ToastUtil.showInfo(context.l10n.audioChangeDevicesInSystemHint),
      child: IgnorePointer(child: dropdown),
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
        const Icon(AppIcons.meters, size: _iconSm, color: _textSecondary),
        const SizedBox(width: 10),
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
            muted ? context.l10n.audioMute : '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider({
    required int value,
    required bool muted,
    required ValueChanged<int> onChanged,
  }) {
    final activeColor = muted ? _textSecondary : _brandGreen;
    return Row(
      children: [
        const Icon(AppIcons.audioMode, size: _iconSm, color: _textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: activeColor.withValues(alpha: 0.88),
              inactiveTrackColor: _softBorder.withValues(alpha: 0.72),
              thumbColor: _panelBackground,
              overlayColor: activeColor.withValues(alpha: 0.10),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7,
                elevation: 1,
                pressedElevation: 2,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              valueIndicatorColor: _textPrimary,
              valueIndicatorTextStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
            child: Slider(
              padding: EdgeInsets.zero,
              value: value.clamp(0, 100).toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '$value%',
              onChanged: (next) => onChanged(next.round()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(
            '$value%',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: muted ? _textSecondary : _textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
