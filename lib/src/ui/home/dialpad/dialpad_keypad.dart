part of '../../../../main.dart';

/// 拨号键盘：负责数字键布局、hover/按压反馈，以及长按 0 输入加号。
extension _DialpadKeypad on _MyHomePageState {
  Widget _buildNumberPad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return TextFieldTapRegion(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.68,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final active = _activeDialpadKey == key;
          final hovered = _hoveredDialpadKey == key;
          return _buildDialpadKey(key, active: active, hovered: hovered);
        },
      ),
    );
  }

  Widget _buildDialpadKey(
    String key, {
    required bool active,
    required bool hovered,
  }) {
    final backgroundColor = active
        ? _brandGreen.withValues(alpha: 0.08)
        : hovered
        ? _subtlePanel
        : _panelBackground;
    return MouseRegion(
      onEnter: (_) => _setHoveredDialpadKey(key),
      onExit: (_) {
        if (_hoveredDialpadKey == key) _setHoveredDialpadKey(null);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _insertDialpadKey(key),
        onLongPress: key == '0' ? () => _insertDialpadKey('+') : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: _buildDialpadKeyLabel(key),
        ),
      ),
    );
  }

  Widget _buildDialpadKeyLabel(String key) {
    final secondary = key == '0' ? '+' : null;
    if (secondary == null) {
      return Text(
        key,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          secondary,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            height: 1,
          ),
        ),
      ],
    );
  }
}
