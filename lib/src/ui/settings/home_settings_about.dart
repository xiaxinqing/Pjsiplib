part of '../../../main.dart';

extension _HomeSettingsAboutTab on _MyHomePageState {
  Widget _buildAboutSettingsTab(PjsipUIState uiState) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        _buildAboutInfoCard(
          child: FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final info = snapshot.data;
              final versionText = info == null
                  ? l10n.aboutLoading
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
                              l10n.aboutTagline,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAboutInfoRow(l10n.aboutVersion, versionText),
                  _buildSettingDivider(),
                  _buildAboutInfoRow(l10n.aboutRuntime, _aboutRuntimeText()),
                  _buildSettingDivider(),
                  _buildAboutInfoRow(l10n.aboutAppId, packageName),
                  _buildSettingDivider(),
                  _buildAboutInfoRow(l10n.aboutCompany, appCompanyName),
                  _buildSettingDivider(),
                  _buildAboutContactRow(l10n.aboutContact, appSupportEmail),
                  _buildSettingDivider(),
                  _buildAboutInfoRow(
                    l10n.aboutPhoneService,
                    uiState.isInitialized
                        ? l10n.aboutServiceRunning
                        : l10n.aboutServiceStopped,
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
    final copiedMessage = context.l10n.aboutEmailCopied;
    await Clipboard.setData(ClipboardData(text: email));
    ToastUtil.showSuccess(copiedMessage);
  }
}
