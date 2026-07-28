part of '../../../../main.dart';

/// 侧边栏共享小组件：提供菜单定位、状态摘要行和菜单操作行。
extension _HomeSidebarShared on _MyHomePageState {
  /// 侧边栏浮层菜单统一圆角，让菜单和底层页面有清晰层级。
  ShapeBorder get _sidebarMenuShape {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _softBorder),
    );
  }

  /// 侧边栏浮层菜单统一阴影颜色，保持柔和但能从页面中浮起来。
  Color get _sidebarMenuShadowColor {
    return Colors.black.withValues(alpha: 0.16);
  }

  /// 把鼠标点击的全局坐标转换成 showMenu 需要的相对位置。
  RelativeRect _popupMenuPosition(Offset globalPosition) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    return RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    );
  }

  /// 构建菜单顶部的状态摘要行。
  Widget _buildStatusSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: _iconSm, color: _textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTooltipText(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建菜单操作项，危险操作会使用红色强调。
  Widget _buildPopupActionRow(
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? Colors.red.shade700 : null;
    return Row(
      children: [
        Icon(icon, size: _iconMd, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTooltipText(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
