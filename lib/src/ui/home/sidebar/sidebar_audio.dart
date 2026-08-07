part of '../../../../main.dart';

/// 侧边栏音频状态模块：展示当前输入/输出设备，并提供快速音频操作。
extension _HomeSidebarAudio on _MyHomePageState {
  /// 构建音频迷你状态卡，显示当前麦克风和扬声器。
  Widget _buildAudioMiniStatus(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    final hasIssue = uiState.hasAudioDeviceIssue;
    final issueColor = Colors.orange.shade700;
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showAudioStatusMenu(uiState, service, details.globalPosition),
      child: Material(
        color: _panelBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(_radiusSm),
        child: InkWell(
          hoverColor: _hoverPanel,
          borderRadius: BorderRadius.circular(_radiusSm),
          onTapDown: (details) =>
              _showAudioStatusMenu(uiState, service, details.globalPosition),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sidebarAudio,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hasIssue ? issueColor : _textPrimary,
                        ),
                      ),
                    ),
                    if (hasIssue) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: issueColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.sidebarAudioIssue,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: issueColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(AppIcons.next, size: _iconSm, color: _textSecondary),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTinyDeviceLine(
                  AppIcons.microphone,
                  mic,
                  iconColor: hasIssue ? issueColor : null,
                ),
                const SizedBox(height: 8),
                _buildTinyDeviceLine(
                  AppIcons.speaker,
                  speaker,
                  iconColor: hasIssue ? issueColor : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 打开音频设备菜单，支持切换自动/手动、刷新设备和进入音频设置。
  Future<void> _showAudioStatusMenu(
    PjsipUIState uiState,
    PjsipService service,
    Offset position,
  ) async {
    final l10n = context.l10n;
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    final issueMessage = uiState.audioDeviceIssueMessage;
    final isAutomatic =
        uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic;
    final action = await showMenu<String>(
      context: context,
      position: _popupMenuPosition(position),
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      color: Colors.white,
      elevation: 14,
      shadowColor: _sidebarMenuShadowColor,
      surfaceTintColor: Colors.transparent,
      shape: _sidebarMenuShape,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.sidebarAudioDevices,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusSummaryRow(
                icon: AppIcons.microphone,
                label: l10n.sidebarAudioInput,
                value: mic,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.speaker,
                label: l10n.sidebarAudioOutput,
                value: speaker,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.automatic,
                label: l10n.sidebarAudioMode,
                value: isAutomatic
                    ? l10n.sidebarAudioAutomatic
                    : l10n.sidebarAudioManual,
              ),
              _buildStatusSummaryRow(
                icon: AppIcons.info,
                label: l10n.sidebarAudioStatus,
                value: issueMessage ?? uiState.audioDeviceStatus,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'toggle_auto',
          enabled: uiState.isInitialized,
          child: _buildPopupActionRow(
            isAutomatic ? AppIcons.tune : AppIcons.automatic,
            isAutomatic
                ? l10n.sidebarAudioSwitchToManual
                : l10n.sidebarAudioSwitchToAutomatic,
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          enabled: uiState.isInitialized,
          child: _buildPopupActionRow(
            AppIcons.refresh,
            l10n.sidebarAudioRefreshDevices,
          ),
        ),
        PopupMenuItem<String>(
          value: 'open_settings',
          child: _buildPopupActionRow(
            AppIcons.settings,
            l10n.sidebarOpenAudioSettings,
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case 'toggle_auto':
        unawaited(service.setAutomaticAudioDeviceSelection(!isAutomatic));
      case 'refresh':
        unawaited(service.refreshAudioDevices());
      case 'open_settings':
        _openSettingsDrawer(tabIndex: _settingsAudioIndex);
    }
  }

  /// 构建音频卡片中的一行设备名称。
  Widget _buildTinyDeviceLine(IconData icon, String value, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: _iconSm, color: iconColor),
        const SizedBox(width: 8),
        Expanded(child: _buildTooltipText(value)),
      ],
    );
  }
}
