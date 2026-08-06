part of '../../../../main.dart';

/// 侧边栏导航模块：负责工作区入口、选中态和当前通话数量 badge。
extension _HomeSidebarNavigation on _MyHomePageState {
  /// 构建主导航入口列表。
  Widget _buildSidebarNavigation(PjsipUIState uiState) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNavItem(
          icon: AppIcons.dialpad,
          label: l10n.navDialpad,
          section: _WorkspaceSection.dialpad,
        ),
        _buildNavItem(
          icon: AppIcons.call,
          label: l10n.navCurrentCalls,
          section: _WorkspaceSection.calls,
          badge: uiState.calls.isEmpty ? null : '${uiState.calls.length}',
        ),
        _buildNavItem(
          icon: AppIcons.contacts,
          label: l10n.navContacts,
          section: _WorkspaceSection.contacts,
        ),
        if (_isRunningWidgetTest)
          _buildNavItem(
            icon: AppIcons.history,
            label: l10n.navCallHistory,
            section: _WorkspaceSection.history,
          )
        else
          StreamBuilder<int>(
            stream: _watchUnreadMissedCallCount(),
            builder: (context, snapshot) {
              final missedCount = snapshot.data ?? 0;
              return _buildNavItem(
                icon: AppIcons.history,
                label: l10n.navCallHistory,
                section: _WorkspaceSection.history,
                badge: missedCount <= 0 ? null : '$missedCount',
                badgeColor: _dangerRed,
              );
            },
          ),
      ],
    );
  }

  /// 侧边栏未接来电 badge 使用缓存流，避免导航区重建时反复创建数据库订阅。
  Stream<int> _watchUnreadMissedCallCount() {
    return _unreadMissedCallCountStream ??= ref
        .read(callHistoryDatabaseProvider)
        .watchUnreadMissedCallCount();
  }

  /// 构建单个导航项，并在点击时切换首页工作区。
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required _WorkspaceSection section,
    String? badge,
    Color? badgeColor,
  }) {
    final selected = _section == section;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? _hoverPanel : Colors.transparent,
        borderRadius: BorderRadius.circular(_radiusSm),
        child: InkWell(
          hoverColor: selected ? _hoverPanel : _panelBackground,
          borderRadius: BorderRadius.circular(_radiusSm),
          onTap: () => _selectSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
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
                      color: _textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor ?? colors.primary,
                      borderRadius: BorderRadius.circular(_radiusXs),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
}
