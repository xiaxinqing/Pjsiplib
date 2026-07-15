import 'dart:async';

import 'package:flutter/material.dart';

import '../src/ui/core/app_colors.dart';

enum ToastType { info, success, error, warning }

enum ToastPosition { top, center, bottom }

/// 全局 Toast 工具。
///
/// 不依赖 GetX，也不要求调用处传 BuildContext。
/// 使用前需要在 MaterialApp / GoRouter 上接入 [navigatorKey]。
class ToastUtil {
  ToastUtil._();

  /// 给 MaterialApp 或 GoRouter 使用的全局 navigatorKey。
  ///
  /// 主窗口和设置窗口是不同 Flutter engine，各自会持有一份全局静态对象；
  /// 在各自窗口里都接入这个 key 后，ToastUtil 就能找到当前窗口的 Overlay。
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show({
    required String message,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.center,
    Duration duration = const Duration(seconds: 2),
    double maxWidth = 360,
  }) {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint('[ToastUtil] $trimmedMessage');
      return;
    }

    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _ToastOverlay(
          message: trimmedMessage,
          type: type,
          position: position,
          duration: duration,
          maxWidth: maxWidth,
          onDismissed: () {
            if (_currentEntry != entry) return;
            dismiss();
          },
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // 兜底定时器，避免极端情况下动画回调没有执行导致 Overlay 残留。
    _dismissTimer = Timer(duration + _ToastOverlayState.animationDuration, () {
      if (_currentEntry == entry) {
        dismiss();
      }
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    final entry = _currentEntry;
    _currentEntry = null;
    if (entry == null) return;

    try {
      if (entry.mounted) {
        entry.remove();
      }
    } catch (_) {
      // Overlay 可能已经随窗口销毁而失效，忽略即可。
    }
  }

  static void showToast(String message, {bool longTime = false}) {
    show(
      message: message,
      type: ToastType.info,
      duration: longTime
          ? const Duration(seconds: 3)
          : const Duration(seconds: 2),
    );
  }

  static void showInfo(
    String message, {
    ToastPosition position = ToastPosition.center,
  }) {
    show(message: message, type: ToastType.info, position: position);
  }

  static void showSuccess(
    String message, {
    ToastPosition position = ToastPosition.center,
  }) {
    show(message: message, type: ToastType.success, position: position);
  }

  static void showError(
    String message, {
    ToastPosition position = ToastPosition.center,
    bool longTime = false,
  }) {
    show(
      message: message,
      type: ToastType.error,
      position: position,
      duration: longTime
          ? const Duration(seconds: 3)
          : const Duration(seconds: 2),
    );
  }

  static void showWarning(
    String message, {
    ToastPosition position = ToastPosition.center,
  }) {
    show(message: message, type: ToastType.warning, position: position);
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    required this.maxWidth,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final double maxWidth;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> {
  static const Duration animationDuration = Duration(milliseconds: 180);

  bool _visible = false;
  Timer? _hideTimer;
  Timer? _removeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });

    _hideTimer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(() => _visible = false);
      _removeTimer = Timer(animationDuration, widget.onDismissed);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = switch (widget.position) {
      ToastPosition.top => const Alignment(0, -0.72),
      ToastPosition.center => Alignment.center,
      ToastPosition.bottom => const Alignment(0, 0.72),
    };
    final slideOffset = switch (widget.position) {
      ToastPosition.top => const Offset(0, -0.04),
      ToastPosition.center => const Offset(0, 0.02),
      ToastPosition.bottom => const Offset(0, 0.04),
    };

    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: alignment,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : slideOffset,
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  scale: _visible ? 1 : 0.98,
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  child: _ToastContent(
                    message: widget.message,
                    type: widget.type,
                    maxWidth: widget.maxWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.message,
    required this.type,
    required this.maxWidth,
  });

  final String message;
  final ToastType type;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final visual = _ToastVisual.fromType(type);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.toastBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.toastBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.toastShadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (visual.icon != null) ...[
                  Icon(visual.icon, color: visual.color, size: 20),
                  const SizedBox(width: 9),
                ],
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
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

class _ToastVisual {
  const _ToastVisual({required this.icon, required this.color});

  final IconData? icon;
  final Color color;

  factory _ToastVisual.fromType(ToastType type) {
    return switch (type) {
      ToastType.success => const _ToastVisual(
        icon: Icons.check_circle_rounded,
        color: AppColors.statusSuccess,
      ),
      ToastType.error => const _ToastVisual(
        icon: Icons.cancel_rounded,
        color: AppColors.statusError,
      ),
      ToastType.warning => const _ToastVisual(
        icon: Icons.error_rounded,
        color: AppColors.statusWarning,
      ),
      ToastType.info => const _ToastVisual(
        icon: Icons.info_rounded,
        color: AppColors.statusInfo,
      ),
    };
  }
}
