part of '../../../../main.dart';

/// 首页左侧栏主组合：只负责侧边栏整体骨架，并把导航、音频、线路等模块拼装起来。
extension _HomeSidebar on _MyHomePageState {
  /// 构建固定宽度侧边栏，并在高度不足时允许整体纵向滚动。
  Widget _buildSidebar(PjsipUIState uiState, PjsipService service) {
    return Container(
      width: 228,
      color: _sidebarBackground,
      padding: const EdgeInsets.fromLTRB(12, 48, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSidebarBrand(),
                    const SizedBox(height: 18),
                    _buildConnectionPill(uiState, service),
                    const SizedBox(height: 14),
                    _buildSidebarNavigation(uiState),
                    const Spacer(),
                    const SizedBox(height: 20),
                    _buildAudioMiniStatus(uiState, service),
                    const SizedBox(height: 10),
                    _buildLineStatusPanel(uiState, service),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建侧边栏顶部品牌区。
  Widget _buildSidebarBrand() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _subtlePanel,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Image.asset(
            'assets/tray/tray_icon_macos_template.png',
            width: 24,
            height: 24,
            color: _textPrimary,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'VPhone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
