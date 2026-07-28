part of '../../../main.dart';

extension _HomeSettingsAboutTab on _MyHomePageState {
  Widget _buildAboutSettingsTab(PjsipUIState uiState) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildAboutInfoCard(
          child: FutureBuilder<PackageInfo>(
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
                              'VeServe 桌面软电话',
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
                  _buildAboutInfoRow('运行环境', _aboutRuntimeText()),
                  _buildSettingDivider(),
                  _buildAboutInfoRow('应用标识', packageName),
                  _buildSettingDivider(),
                  _buildAboutInfoRow('公司', appCompanyName),
                  _buildSettingDivider(),
                  _buildAboutContactRow('联系我们', appSupportEmail),
                  _buildSettingDivider(),
                  _buildAboutInfoRow(
                    '电话服务',
                    uiState.isInitialized ? '已启动' : '未启动',
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutInfoCard({required Widget child}) {
    return Material(
      color: _panelBackground,
      borderRadius: BorderRadius.circular(_radiusSm),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  String _aboutRuntimeText() {
    final mode = kReleaseMode
        ? 'Release'
        : kProfileMode
        ? 'Profile'
        : 'Debug';
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
    return '$platform · $mode';
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

  Widget _buildAboutContactRow(String label, String email) {
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
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyAboutEmail(email),
                icon: const Icon(AppIcons.copy, size: _iconSm),
                label: Text(email, overflow: TextOverflow.ellipsis),
                style: TextButton.styleFrom(
                  foregroundColor: _textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyAboutEmail(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    ToastUtil.showSuccess('邮箱已复制');
  }
}
