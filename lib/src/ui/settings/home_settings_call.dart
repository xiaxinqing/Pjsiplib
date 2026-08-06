part of '../../../main.dart';

extension _HomeSettingsCallTab on _MyHomePageState {
  Widget _buildCallSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildSettingsSection(
          title: '通话控制',
          icon: AppIcons.call,
          children: [
            _buildSettingTile(
              icon: AppIcons.contacts,
              title: '最大同时通话',
              trailing: const Text('4 路'),
            ),
            _buildSettingDivider(),
            _buildSettingTile(
              icon: AppIcons.dialpad,
              title: 'DTMF 方式',
              trailing: const Text('RFC2833'),
            ),
            _buildSettingDivider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.autoHoldOtherCalls,
              onChanged: service.setAutoHoldOtherCalls,
              secondary: const Icon(AppIcons.pause),
              title: const Text('通话自动暂停'),
              subtitle: Text('接听、外呼或恢复通话时，自动暂停其他通话'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildSettingsSection(
          title: '快捷操作',
          icon: AppIcons.bolt,
          children: [
            _buildSettingTile(
              icon: AppIcons.microphoneOff,
              title: '默认静音状态',
              trailing: const Text('关闭'),
            ),
            _buildSettingDivider(),
            _buildSettingTile(
              icon: AppIcons.merge,
              title: '会议通话',
              trailing: Text(uiState.hasConference ? '进行中' : '可用'),
            ),
          ],
        ),
      ],
    );
  }
}
