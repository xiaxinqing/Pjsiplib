part of '../../../main.dart';

extension _HomeSettingsDiagnosticsTab on _MyHomePageState {
  Widget _buildDiagnosticsTab(PjsipUIState uiState, PjsipService service) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        children: [
          _buildSettingsSection(
            title: l10n.settingsDiagnostics,
            icon: AppIcons.diagnostics,
            children: [
              SwitchListTile(
                value: _showDiagnosticLogs,
                onChanged: (value) => _setDiagnosticLogsVisible(value),
                secondary: const Icon(AppIcons.receipt),
                title: Text(l10n.diagnosticsShowLogs),
                subtitle: Text(l10n.diagnosticsEventTypes),
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
                  onPressed: uiState.logs.isEmpty ? null : service.clearLogs,
                  icon: const Icon(AppIcons.clean),
                  label: Text(l10n.diagnosticsClearLogs),
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
                  label: Text(
                    _exportingDiagnosticLogs
                        ? l10n.diagnosticsExporting
                        : l10n.diagnosticsExportLogs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.diagnosticsPrivacyNotice,
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showDiagnosticLogs
                ? _buildLogList(uiState)
                : Center(child: Text(l10n.diagnosticsLogsHidden)),
          ),
        ],
      ),
    );
  }

  /// 调起系统保存窗口并导出完整诊断日志。
  Future<void> _exportDiagnosticLogs(PjsipService service) async {
    if (_exportingDiagnosticLogs) return;
    final exportedMessage = context.l10n.diagnosticsExported;
    final failedMessage = context.l10n.diagnosticsExportFailed;
    _update(() => _exportingDiagnosticLogs = true);
    try {
      final path = await service.exportDiagnosticLogs();
      if (path != null) {
        ToastUtil.showSuccess(exportedMessage);
      }
    } catch (error, stackTrace) {
      debugPrint('导出诊断日志失败: $error\n$stackTrace');
      ToastUtil.showError(failedMessage, longTime: true);
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
