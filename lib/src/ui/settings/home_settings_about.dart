part of '../../../main.dart';

extension _HomeSettingsAboutTab on _MyHomePageState {
  Widget _buildAboutSettingsTab(PjsipUIState uiState) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildSettingsSection(
          title: '关于',
          icon: AppIcons.info,
          children: [
            FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final info = snapshot.data;
                final versionText = info == null
                    ? '读取中'
                    : '${info.version}+${info.buildNumber}';
                final packageName = info?.packageName ?? appBundleIdentifier;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(_radiusMd),
                          child: Image.asset(
                            'assets/branding/app_logo.png',
                            width: 56,
                            height: 56,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appDisplayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Veserve 桌面软电话',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: _textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAboutInfoRow('版本', versionText),
                    _buildSettingDivider(),
                    _buildAboutInfoRow('应用标识', packageName),
                    _buildSettingDivider(),
                    _buildAboutInfoRow('公司', appCompanyName),
                    _buildSettingDivider(),
                    _buildAboutInfoRow(
                      '电话服务',
                      uiState.isInitialized ? '已启动' : '未启动',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSettingsSection(
          title: '维护',
          icon: AppIcons.refresh,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _applicationRestarting
                        ? null
                        : _confirmAndRestartApplication,
                    icon: _applicationRestarting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(AppIcons.refresh),
                    label: Text(_applicationRestarting ? '正在重启应用' : '重启应用'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '遇到线路或音频状态异常时，可以重启应用后重新连接线路。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
