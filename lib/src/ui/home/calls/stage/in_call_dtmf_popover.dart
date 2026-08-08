import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/app_colors.dart';

/// 独立的通话中 DTMF 键盘浮层。
///
/// 组件只负责展示、定位和输入交互，不依赖首页状态、PJSIP 或本地化实现。
/// 调用方通过文案和回调提供业务数据，因此可以独立测试和复用。
class InCallDtmfPopover extends StatelessWidget {
  const InCallDtmfPopover({
    super.key,
    required this.anchorLink,
    required this.tapRegionGroupId,
    required this.title,
    required this.closeTooltip,
    required this.previewText,
    required this.previewActive,
    required this.statusText,
    required this.statusFailed,
    required this.onDismiss,
    required this.onDigitPressed,
  });

  static const _digits = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '*',
    '0',
    '#',
  ];
  static const double _popoverWidth = 284;

  final LayerLink anchorLink;
  final Object tapRegionGroupId;
  final String title;
  final String closeTooltip;
  final String previewText;
  final bool previewActive;
  final String? statusText;
  final bool statusFailed;
  final VoidCallback onDismiss;
  final ValueChanged<String> onDigitPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: _popoverWidth,
      child: CompositedTransformFollower(
        link: anchorLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: const Offset(0, -12),
        child: TapRegion(
          groupId: tapRegionGroupId,
          onTapOutside: (_) => onDismiss(),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
            },
            child: Focus(
              autofocus: true,
              child: Material(
                type: MaterialType.transparency,
                child: _buildPanel(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final statusColor = statusFailed
        ? AppColors.dangerRed
        : AppColors.textSecondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.grid3x3300,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: closeTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onDismiss,
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(32),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(LucideIcons.x300, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.subtlePanel,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                previewText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: previewActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (statusText != null) ...[
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    statusFailed ? LucideIcons.info300 : LucideIcons.check300,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _buildDialpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialpad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.85,
      ),
      itemCount: _digits.length,
      itemBuilder: (context, index) {
        final digit = _digits[index];
        return FilledButton(
          onPressed: () => onDigitPressed(digit),
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            foregroundColor: const WidgetStatePropertyAll(
              AppColors.textPrimary,
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.brandGreen.withValues(alpha: 0.18);
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return AppColors.brandGreen.withValues(alpha: 0.10);
              }
              return AppColors.subtlePanel;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
