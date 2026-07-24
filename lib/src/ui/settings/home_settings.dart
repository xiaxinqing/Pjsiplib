part of '../../../main.dart';

extension _HomeSettings on _MyHomePageState {
  Widget _buildSettingsDialog(
    PjsipUIState uiState,
    PjsipService service, {
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    final viewport = MediaQuery.sizeOf(context);
    final width = math.min(viewport.width - 48, 860.0).clamp(640.0, 860.0);
    final height = math.min(viewport.height - 48, 640.0).clamp(520.0, 640.0);
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
                                    '设置',
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
                            index: 0,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.account,
                            label: '账号',
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: 1,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.audio,
                            label: '音频',
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: 2,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.call,
                            label: '通话',
                            onSelected: onSelected,
                          ),
                          _buildSettingsNavItem(
                            index: 3,
                            selectedIndex: selectedIndex,
                            icon: AppIcons.diagnostics,
                            label: '诊断',
                            onSelected: onSelected,
                          ),
                          const Spacer(),
                          Text(
                            uiState.isInitialized ? '电话服务已启动' : '电话服务未启动',
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
                                tooltip: '关闭',
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
    return switch (index) {
      0 => '账号',
      1 => '音频',
      2 => '通话',
      3 => '诊断',
      _ => '账号',
    };
  }

  String _settingsSubtitle(int index) {
    return switch (index) {
      0 => '管理 SIP 线路、默认外呼和注册状态',
      1 => '选择输入输出设备，并测试通话音频',
      2 => '配置通话行为、快捷操作和会议状态',
      3 => '查看设备、注册和通话事件日志',
      _ => '管理 SIP 线路、默认外呼和注册状态',
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: _panelBackground,
            borderRadius: BorderRadius.circular(_radiusSm),
          ),
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
