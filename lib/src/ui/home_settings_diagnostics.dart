part of '../../main.dart';

extension _HomeSettingsDiagnosticsTab on _MyHomePageState {
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
