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
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: uiState.isInitialized
                      ? service.refreshAudioDevices
                      : null,
                  icon: const Icon(AppIcons.refresh),
                  label: const Text('刷新设备'),
                ),
                OutlinedButton.icon(
                  onPressed: uiState.logs.isEmpty ? null : service.clearLogs,
                  icon: const Icon(AppIcons.clean),
                  label: const Text('清空日志'),
                ),
                OutlinedButton.icon(
                  onPressed: _exportingDiagnosticLogs
                      ? null
                      : () => _exportDiagnosticLogs(service),
                  icon: _exportingDiagnosticLogs
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(AppIcons.export),
                  label: Text(_exportingDiagnosticLogs ? '正在导出' : '导出日志'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '日志可能包含电话号码、服务器地址和网络信息，请仅发送给可信人员。',
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
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

  /// 调起系统保存窗口并导出完整诊断日志。
  Future<void> _exportDiagnosticLogs(PjsipService service) async {
    if (_exportingDiagnosticLogs) return;
    _update(() => _exportingDiagnosticLogs = true);
    try {
      final path = await service.exportDiagnosticLogs();
      if (path != null) {
        ToastUtil.showSuccess('诊断日志已导出');
      }
    } catch (error, stackTrace) {
      debugPrint('导出诊断日志失败: $error\n$stackTrace');
      ToastUtil.showError('导出日志失败，请稍后重试', longTime: true);
    } finally {
      if (mounted) {
        _update(() => _exportingDiagnosticLogs = false);
      }
    }
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
