part of '../../../main.dart';

extension _HomeSettingsCallTab on _MyHomePageState {
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
}
