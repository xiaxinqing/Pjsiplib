part of '../../../main.dart';

extension _HomeSettingsDiagnosticsTab on _MyHomePageState {
  Widget _buildDiagnosticsTab(PjsipUIState uiState, PjsipService service) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        children: [
          _buildSettingsSection(
            title: '诊断',
            icon: AppIcons.diagnostics,
            children: [
              SwitchListTile(
                value: _showDiagnosticLogs,
                onChanged: (value) => _setDiagnosticLogsVisible(value),
                secondary: const Icon(AppIcons.receipt),
                title: const Text('显示日志'),
                subtitle: const Text('设备、注册、通话事件'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: uiState.isInitialized
                    ? service.refreshAudioDevices
                    : null,
                icon: const Icon(AppIcons.refresh),
                label: const Text('刷新设备'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: uiState.logs.isEmpty ? null : service.clearLogs,
                icon: const Icon(AppIcons.clean),
                label: const Text('清空日志'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showDiagnosticLogs
                ? _buildLogList(uiState)
                : const Center(child: Text('日志已隐藏')),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(PjsipUIState uiState) {
    return Container(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
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
