part of '../../../main.dart';

extension _HomeSettings on _MyHomePageState {
  Widget _buildSettingsDrawer(PjsipUIState uiState, PjsipService service) {
    return Drawer(
      width: 460,
      child: SafeArea(
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
            TabBar(
              controller: _settingsTabController,
              tabs: const [
                Tab(icon: Icon(Icons.account_circle), text: '账号'),
                Tab(icon: Icon(Icons.headphones), text: '音频'),
                Tab(icon: Icon(Icons.call), text: '通话'),
                Tab(icon: Icon(Icons.bug_report), text: '诊断'),
              ],
            ),
            Expanded(child: _buildActiveSettingsTab(uiState, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSettingsTab(PjsipUIState uiState, PjsipService service) {
    return KeyedSubtree(
      key: ValueKey(_settingsTabIndex),
      child: switch (_settingsTabIndex) {
        0 => _buildAccountSettingsTab(uiState, service),
        1 => _buildAudioSettingsTab(uiState, service),
        2 => _buildCallSettingsTab(uiState, service),
        3 => _buildDiagnosticsTab(uiState, service),
        _ => _buildAccountSettingsTab(uiState, service),
      },
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
}
