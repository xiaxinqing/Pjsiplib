part of '../../../main.dart';

extension _HomeSettingsCallTab on _MyHomePageState {
  Widget _buildCallSettingsTab(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildSettingsSection(
          title: l10n.callSettingsControls,
          icon: AppIcons.call,
          children: [
            _buildSettingTile(
              icon: AppIcons.contacts,
              title: l10n.callSettingsMaxCalls,
              trailing: Text(l10n.callSettingsMaxCallsValue(4)),
            ),
            _buildSettingDivider(),
            _buildSettingTile(
              icon: AppIcons.dialpad,
              title: l10n.callSettingsDtmfMethod,
              trailing: const Text('RFC2833'),
            ),
            _buildSettingDivider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.autoHoldOtherCalls,
              onChanged: service.setAutoHoldOtherCalls,
              secondary: const Icon(AppIcons.pause),
              title: Text(l10n.callSettingsAutoHold),
              subtitle: Text(l10n.callSettingsAutoHoldDescription),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: l10n.callSettingsRecordingSection,
          icon: AppIcons.audio,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.localCallRecordingEnabled,
              onChanged: service.setLocalCallRecordingEnabled,
              secondary: Icon(
                AppIcons.audio,
                color: uiState.localCallRecordingEnabled
                    ? _dangerRed
                    : _textSecondary,
              ),
              title: Text(l10n.callSettingsLocalRecording),
              subtitle: Text(l10n.callSettingsLocalRecordingDescription),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: l10n.callSettingsShortcuts,
          icon: AppIcons.bolt,
          children: [
            _buildSettingTile(
              icon: AppIcons.microphoneOff,
              title: l10n.callSettingsDefaultMute,
              trailing: Text(l10n.callSettingsOff),
            ),
            _buildSettingDivider(),
            _buildSettingTile(
              icon: AppIcons.merge,
              title: l10n.callSettingsConference,
              trailing: Text(
                uiState.hasConference
                    ? l10n.callSettingsActive
                    : l10n.commonAvailable,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
