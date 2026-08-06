part of '../../../main.dart';

// 设置页索引集中定义，避免调整导航顺序后各入口仍使用旧的数字索引。
const int _settingsAccountIndex = 0;
const int _settingsGeneralIndex = 1;
const int _settingsAudioIndex = 2;
const int _settingsCallsIndex = 3;
const int _settingsDiagnosticsIndex = 4;
const int _settingsAboutIndex = 5;

extension _HomeSettings on _MyHomePageState {
  Widget _buildSettingsDialog(
    PjsipUIState uiState,
    PjsipService service, {
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    final l10n = context.l10n;
    final viewport = MediaQuery.sizeOf(context);
    final width = math.min(viewport.width - 48, 980.0).clamp(640.0, 980.0);
    final height = math.min(viewport.height - 48, 720.0).clamp(520.0, 720.0);
    final title = _settingsTitle(selectedIndex);
    final subtitle = _settingsSubtitle(selectedIndex);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _panelBackground,
            borderRadius: BorderRadius.circular(_radiusMd),
            border: Border.all(color: _softBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radiusMd),
            child: Row(
              children: [
                SizedBox(
                  width: 188,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: _sidebarBackground),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                const Icon(AppIcons.settings, size: _iconLg),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.settings,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildSettingsNavItem(
                            index: _settingsAccountIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.account,
                            label: l10n.settingsAccount,
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: _settingsGeneralIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.public,
                            label: l10n.settingsGeneral,
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: _settingsAudioIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.audio,
                            label: l10n.settingsAudio,
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: _settingsCallsIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.call,
                            label: l10n.settingsCalls,
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: _settingsDiagnosticsIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.diagnostics,
                            label: l10n.settingsDiagnostics,
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: _settingsAboutIndex,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.info,
                            label: l10n.settingsAbout,
                            onSelected: onSelected,
                          ),
                          const Spacer(),
                          Text(
                            uiState.isInitialized
                                ? l10n.phoneServiceStarted
                                : l10n.phoneServiceStopped,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: _softBorder),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 64,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.settingsClose,
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(AppIcons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildSettingsContent(
                          uiState,
                          service,
                          selectedIndex,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsNavItem({
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
    required ValueChanged<int> onSelected,
  }) {
    final selected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? _hoverPanel : Colors.transparent,
        borderRadius: BorderRadius.circular(_radiusSm),
        child: InkWell(
          hoverColor: selected ? _hoverPanel : _panelBackground,
          borderRadius: BorderRadius.circular(_radiusSm),
          onTap: () => onSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: _iconMd,
                  color: selected ? _textPrimary : _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _settingsTitle(int index) {
    final l10n = context.l10n;
    return switch (index) {
      _settingsAccountIndex => l10n.settingsAccount,
      _settingsAudioIndex => l10n.settingsAudio,
      _settingsCallsIndex => l10n.settingsCalls,
      _settingsGeneralIndex => l10n.settingsGeneral,
      _settingsDiagnosticsIndex => l10n.settingsDiagnostics,
      _settingsAboutIndex => l10n.settingsAbout,
      _ => l10n.settingsAccount,
    };
  }

  String _settingsSubtitle(int index) {
    final l10n = context.l10n;
    return switch (index) {
      _settingsAccountIndex => l10n.settingsAccountDescription,
      _settingsAudioIndex => l10n.settingsAudioDescription,
      _settingsCallsIndex => l10n.settingsCallsDescription,
      _settingsGeneralIndex => l10n.settingsGeneralDescription,
      _settingsDiagnosticsIndex => l10n.settingsDiagnosticsDescription,
      _settingsAboutIndex => l10n.settingsAboutDescription,
      _ => l10n.settingsAccountDescription,
    };
  }

  Widget _buildSettingsContent(
    PjsipUIState uiState,
    PjsipService service,
    int selectedIndex,
  ) {
    return KeyedSubtree(
      key: ValueKey(selectedIndex),
      child: switch (selectedIndex) {
        _settingsAccountIndex => _buildAccountSettingsTab(uiState, service),
        _settingsAudioIndex => _buildAudioSettingsTab(uiState, service),
        _settingsCallsIndex => _buildCallSettingsTab(uiState, service),
        _settingsGeneralIndex => _buildGeneralSettingsTab(),
        _settingsDiagnosticsIndex => _buildDiagnosticsTab(uiState, service),
        _settingsAboutIndex => _buildAboutSettingsTab(uiState),
        _ => _buildAccountSettingsTab(uiState, service),
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Row(
            children: [
              Icon(icon, size: _iconSm),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        Material(
          color: _panelBackground,
          borderRadius: BorderRadius.circular(_radiusSm),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingDivider() {
    return const Divider(height: 1, indent: 38);
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: _iconMd),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        hoverColor: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
