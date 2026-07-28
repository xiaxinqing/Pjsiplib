part of '../../../../main.dart';

/// 联系人和通话记录共用的拨打按钮。
///
/// hover、focus 和 pressed 状态只属于按钮自身，不放到页面级状态里，避免列表行
/// hover 与按钮焦点互相影响；两个页面也能保持一致的绿色背景与白色图标反馈。
class _CallActionButton extends StatefulWidget {
  const _CallActionButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_CallActionButton> createState() => _CallActionButtonState();
}

class _CallActionButtonState extends State<_CallActionButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  bool get _active => _enabled && (_hovered || _focused || _pressed);

  @override
  void didUpdateWidget(covariant _CallActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && (_hovered || _focused || _pressed)) {
      _hovered = false;
      _focused = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _active
        ? _callGreen
        : _enabled
        ? _subtlePanel
        : _subtlePanel.withValues(alpha: 0.72);
    final iconColor = _active
        ? Colors.white
        : _enabled
        ? _textPrimary
        : _textSecondary.withValues(alpha: 0.55);

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (hovered) {
          if (!_enabled || _hovered == hovered) return;
          setState(() => _hovered = hovered);
        },
        onShowFocusHighlight: (focused) {
          if (!_enabled || _focused == focused) return;
          setState(() => _focused = focused);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            child: Icon(AppIcons.call, size: _iconMd, color: iconColor),
          ),
        ),
      ),
    );
  }
}
