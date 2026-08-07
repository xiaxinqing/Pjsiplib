part of '../../../../main.dart';

// 来电头像动效参数。
// - haloDuration: 单个光圈从内向外扩散的时间；调大 = 波纹更慢、更稳。
// - haloStartScale / haloEndScale: 光圈从多大扩散到多大；end 调大 = 扩散更远。
// - haloOpacity: 光圈初始透明度；调大 = 颜色更明显。
// - avatarShakeAngle: 头像左右摆动幅度；不喜欢晃动可改成 0。
const Duration _incomingHaloDuration = Duration(milliseconds: 2400);
const List<Duration> _incomingHaloDelays = [
  Duration.zero,
  Duration(milliseconds: 800),
  Duration(milliseconds: 1600),
];
const double _incomingHaloStartScale = 0.56;
const double _incomingHaloEndScale = 1.18;
const double _incomingHaloOpacity = 0.42;
const double _incomingAvatarShakeAngle = 0.045;

// 接听按钮脉冲参数：end 越大越明显，duration 越小越急促。
const Duration _answerPulseDuration = Duration(milliseconds: 980);
const double _answerPulseStartScale = 0.96;
const double _answerPulseEndScale = 1.13;

/// 当前通话页入口：负责主舞台和右侧通话面板的页面级组合。
extension _HomeCalls on _MyHomePageState {
  Widget _buildCallsPage(PjsipUIState uiState, PjsipService service) {
    _traceWorkspacePageBuild(_WorkspaceSection.calls);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: _buildPrimaryCallStage(uiState, service)),
        const SizedBox(width: 20),
        Expanded(flex: 4, child: _buildLiveCallsPanel(uiState, service)),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    Widget? action,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (action != null) ...[const SizedBox(height: 18), action],
          ],
        ),
      ),
    );
  }
}

/// 通话联系人匹配结果：记录通话号码命中的联系人和号码字段。
class _CallContactMatch {
  const _CallContactMatch({required this.contact, required this.phone});

  final ContactEntry contact;
  final ContactPhoneEntry phone;
}

/// 当前通话统一身份展示：有联系人时以姓名为主、号码为辅；未匹配时只展示号码。
class _CallDisplayIdentity {
  const _CallDisplayIdentity({required this.primary, this.secondary});

  final String primary;
  final String? secondary;

  String get tooltip => secondary == null ? primary : '$primary · $secondary';
}

/// 通话视觉状态：把通话状态转换成图标、颜色、标签和详情文案。
class _LiveCallVisualState {
  const _LiveCallVisualState({
    required this.label,
    required this.detail,
    required this.icon,
    required this.color,
    this.emphasizeDetail = false,
  });

  final String label;
  final String detail;
  final IconData icon;
  final Color color;
  final bool emphasizeDetail;
}

/// 通话质量视图模型：封装媒体/加密状态在 UI 中的展示信息。
class _CallQualityView {
  const _CallQualityView({
    required this.label,
    required this.compactLabel,
    required this.tooltip,
    required this.color,
    required this.icon,
  });

  final String label;
  final String compactLabel;
  final String tooltip;
  final Color color;
  final IconData icon;
}

/// 盲转弹窗：收集联系人目标或手动号码，并发起 SIP REFER 转接。
class _BlindTransferDialog extends StatefulWidget {
  const _BlindTransferDialog({
    required this.participant,
    required this.lineLabel,
    required this.exampleTarget,
    required this.contacts,
  });

  final String participant;
  final String lineLabel;
  final String exampleTarget;
  final List<ContactEntry> contacts;

  @override
  State<_BlindTransferDialog> createState() => _BlindTransferDialogState();
}

/// 盲转弹窗状态：管理搜索、手动输入、目标选择和提交状态。
class _BlindTransferDialogState extends State<_BlindTransferDialog> {
  late final TextEditingController _manualController;
  late final TextEditingController _contactSearchController;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController();
    _contactSearchController = TextEditingController()
      ..addListener(_handleContactSearchChanged);
  }

  @override
  void dispose() {
    _contactSearchController
      ..removeListener(_handleContactSearchChanged)
      ..dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _handleContactSearchChanged() {
    if (mounted) setState(() {});
  }

  List<_BlindTransferContactTarget> get _contactTargets {
    final keyword = _contactSearchController.text.trim();
    final targets = <_BlindTransferContactTarget>[];
    for (final contact in widget.contacts) {
      if (!contact.matches(keyword)) continue;
      for (final phone in contact.phoneEntries) {
        targets.add(
          _BlindTransferContactTarget(contact: contact, phone: phone),
        );
        if (targets.length >= 16) return targets;
      }
    }
    return targets;
  }

  void _submitManual() {
    final target = _manualController.text.trim();
    if (target.isEmpty) return;
    Navigator.of(context).pop(target);
  }

  void _submitContact(_BlindTransferContactTarget target) {
    Navigator.of(context).pop(target.phone.number);
  }

  @override
  Widget build(BuildContext context) {
    final targets = _contactTargets;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _brandGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                  child: const Icon(
                    AppIcons.route,
                    size: _iconMd,
                    color: _brandGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.activeCallTransferTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.activeCallTransferDescription,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                color: _subtlePanel,
                borderRadius: BorderRadius.circular(_radiusSm),
                border: Border.all(color: _softBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: widget.participant,
                      child: Text(
                        widget.participant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Tooltip(
                      message: widget.lineLabel,
                      child: Text(
                        widget.lineLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _BlindTransferSectionTitle(
              icon: AppIcons.contacts,
              title: context.l10n.activeCallChooseContact,
              trailing: context.l10n.activeCallNumberCount(targets.length),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contactSearchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.activeCallTransferSearchHint,
                prefixIcon: const Icon(AppIcons.search),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            _buildContactTargetList(targets),
            const SizedBox(height: 16),
            _BlindTransferSectionTitle(
              icon: AppIcons.dialpad,
              title: context.l10n.activeCallEnterTransferNumber,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _manualController,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: widget.exampleTarget,
                prefixIcon: const Icon(AppIcons.call),
              ),
              onSubmitted: (_) => _submitManual(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _manualController,
          builder: (context, value, _) {
            return FilledButton.icon(
              onPressed: value.text.trim().isEmpty ? null : _submitManual,
              icon: const Icon(AppIcons.route),
              label: Text(context.l10n.activeCallConfirmTransfer),
              style: FilledButton.styleFrom(backgroundColor: _brandGreen),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactTargetList(List<_BlindTransferContactTarget> targets) {
    if (widget.contacts.isEmpty) {
      return _BlindTransferEmptyContacts(
        message: context.l10n.activeCallNoContacts,
      );
    }
    if (targets.isEmpty) {
      return _BlindTransferEmptyContacts(
        message: context.l10n.activeCallNoContactMatches,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 230),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          itemCount: targets.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 52,
            endIndent: 12,
            color: _softBorder,
          ),
          itemBuilder: (context, index) {
            final target = targets[index];
            final contact = target.contact;
            final phone = target.phone;
            final subtitle = [
              phone.label,
              if (contact.hasOrganization) contact.organizationLabel,
            ].join(' · ');
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _submitContact(target),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _brandGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(_radiusSm),
                        ),
                        child: Text(
                          contact.initials,
                          style: const TextStyle(
                            color: _brandGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name.trim().isEmpty
                                  ? context.l10n.activeCallUnnamedContact
                                  : contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          phone.number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        AppIcons.route,
                        size: _iconSm,
                        color: _brandGreen,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 盲转联系人目标：把联系人号码整理成可选的转接目标。
class _BlindTransferContactTarget {
  const _BlindTransferContactTarget({
    required this.contact,
    required this.phone,
  });

  final ContactEntry contact;
  final ContactPhoneEntry phone;
}

/// 盲转分区标题：用于分隔联系人选择和手动输入区域。
class _BlindTransferSectionTitle extends StatelessWidget {
  const _BlindTransferSectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: _iconSm, color: _textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// 盲转空联系人提示：展示没有可选联系人或搜索无结果的状态。
class _BlindTransferEmptyContacts extends StatelessWidget {
  const _BlindTransferEmptyContacts({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.contacts, size: _iconSm, color: _textSecondary),
            const SizedBox(width: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 会议头像：展示会议人数和暂停/进行中的视觉状态。
class _ConferenceAvatar extends StatelessWidget {
  const _ConferenceAvatar({
    required this.size,
    required this.memberCount,
    required this.paused,
  });

  final double size;
  final int memberCount;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final color = paused ? Colors.orange.shade700 : _brandGreen;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            paused ? AppIcons.pause : AppIcons.contacts,
            size: size * 0.36,
            color: Colors.white,
          ),
          Positioned(
            right: size * 0.2,
            bottom: size * 0.2,
            child: Container(
              height: size * 0.25,
              constraints: BoxConstraints(minWidth: size * 0.25),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$memberCount',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 通话头像：根据通话状态展示联系人首字和可选的动态光晕。
class _CallAvatar extends StatefulWidget {
  const _CallAvatar({
    required this.label,
    required this.isIncoming,
    required this.size,
  });

  final String label;
  final bool isIncoming;
  final double size;

  @override
  State<_CallAvatar> createState() => _CallAvatarState();
}

/// 通话头像状态：管理头像入场和状态变化动画。
class _CallAvatarState extends State<_CallAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isIncoming) _shakeController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_CallAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isIncoming && !_shakeController.isAnimating) {
      _shakeController.repeat(reverse: true);
    } else if (!widget.isIncoming) {
      _shakeController.stop();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = widget.size <= 120 ? 34.0 : 42.0;
    final fontSize = widget.size <= 120 ? 23.0 : 28.0;
    final avatar = CircleAvatar(
      radius: avatarRadius,
      backgroundColor: widget.isIncoming
          ? _callGreen
          : Theme.of(context).colorScheme.primary,
      child: Text(
        widget.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );

    if (!widget.isIncoming) {
      // 普通通话不需要为来电光晕预留画布，直接使用头像实际尺寸，避免身份信息
      // 与头像之间出现一段不可见的空白。
      return avatar;
    }

    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_shakeController.value);
          return Transform.rotate(
            angle: (t - 0.5) * _incomingAvatarShakeAngle,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final delay in _incomingHaloDelays)
              _PulseHalo(color: _callGreen, delay: delay),
            avatar,
          ],
        ),
      ),
    );
  }
}

/// 脉冲光晕：用于来电、呼叫中等需要强调的状态动画。
class _PulseHalo extends StatefulWidget {
  const _PulseHalo({required this.color, required this.delay});

  final Color color;
  final Duration delay;

  @override
  State<_PulseHalo> createState() => _PulseHaloState();
}

/// 脉冲光晕状态：驱动循环缩放和透明度动画。
class _PulseHaloState extends State<_PulseHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _incomingHaloDuration,
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_controller.value);
        final scaleRange = _incomingHaloEndScale - _incomingHaloStartScale;
        return Transform.scale(
          scale: _incomingHaloStartScale + t * scaleRange,
          child: Opacity(opacity: (1 - t) * _incomingHaloOpacity, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.color, width: 4),
        ),
      ),
    );
  }
}

/// 动画图标按钮：统一通话操作按钮的尺寸、颜色和禁用表现。
class _AnimatedIconButton extends StatelessWidget {
  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    this.foregroundColor,
    required this.onPressed,
    required this.emphasized,
  });

  final IconData icon;
  final Color color;
  final Color? foregroundColor;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: emphasized && onPressed != null
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.38),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 24,
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor:
              foregroundColor ??
              (color.computeLuminance() > 0.45 ? Colors.black87 : Colors.white),
          disabledBackgroundColor: Theme.of(context).disabledColor,
          minimumSize: const Size.square(54),
          fixedSize: const Size.square(54),
        ),
      ),
    );

    return emphasized && onPressed != null
        ? _PulsingCallAction(child: button)
        : button;
  }
}

/// 脉冲通话操作：用于接听等强行动按钮的轻量动效包装。
class _PulsingCallAction extends StatefulWidget {
  const _PulsingCallAction({required this.child});

  final Widget child;

  @override
  State<_PulsingCallAction> createState() => _PulsingCallActionState();
}

/// 脉冲通话操作状态：驱动按钮背景的循环强调动画。
class _PulsingCallActionState extends State<_PulsingCallAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _answerPulseDuration,
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: _answerPulseStartScale,
      end: _answerPulseEndScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
