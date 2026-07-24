part of '../../../main.dart';

// 来电头像动效参数。
// - haloBoxSize: 光圈动画可用区域；调大 = 扩散范围更大，但会占更多垂直空间。
// - haloDuration: 单个光圈从内向外扩散的时间；调大 = 波纹更慢、更稳。
// - haloStartScale / haloEndScale: 光圈从多大扩散到多大；end 调大 = 扩散更远。
// - haloOpacity: 光圈初始透明度；调大 = 颜色更明显。
// - avatarShakeAngle: 头像左右摆动幅度；不喜欢晃动可改成 0。
const double _incomingHaloBoxSize = 156;
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

extension _HomeCalls on _MyHomePageState {
  Widget _buildCallsPage(PjsipUIState uiState, PjsipService service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: _buildPrimaryCallStage(uiState, service)),
        const SizedBox(width: 20),
        Expanded(flex: 4, child: _buildLiveCallsPanel(uiState, service)),
      ],
    );
  }

  Widget _buildPrimaryCallStage(PjsipUIState uiState, PjsipService service) {
    final primary = _primaryCall(uiState);
    if (primary == null) {
      return _buildEmptyState(
        icon: AppIcons.call,
        title: '暂无通话',
        action: FilledButton.icon(
          onPressed: () => _selectSection(_WorkspaceSection.dialpad),
          icon: const Icon(AppIcons.dialpad),
          label: const Text('去拨号'),
        ),
      );
    }

    final isConferenceMember = uiState.isInConference(primary.callId);
    final isConferencePaused = uiState.isConferencePaused;
    final isIncoming = primary.isIncoming && !primary.isConnected;
    final account = uiState.accountForCall(primary);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 620;
          final avatarSize = compact ? 118.0 : _incomingHaloBoxSize;
          return SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 20 : 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > (compact ? 40 : 56)
                    ? constraints.maxHeight - (compact ? 40 : 56)
                    : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallAvatar(
                    label: _avatarText(primary.remoteUri),
                    isIncoming: isIncoming,
                    size: avatarSize,
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  Text(
                    _displayRemote(primary.remoteUri),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 24 : 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    primary.statusLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (account != null) ...[
                    const SizedBox(height: 10),
                    _buildCallLineChip(account, isIncoming: isIncoming),
                  ],
                  SizedBox(height: compact ? 8 : 12),
                  if (primary.isConnected)
                    Text(
                      primary.durationLabel,
                      style: TextStyle(
                        fontSize: compact ? 34 : 42,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
                  else
                    SizedBox(height: compact ? 32 : 50),
                  if (primary.isConnected) ...[
                    SizedBox(height: compact ? 12 : 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _buildCallAudioMeters(uiState, compact: compact),
                    ),
                  ],
                  SizedBox(height: compact ? 14 : 20),
                  if (isConferenceMember)
                    Chip(
                      avatar: Icon(
                        isConferencePaused ? AppIcons.pause : AppIcons.contacts,
                      ),
                      label: Text(isConferencePaused ? '会议已暂停' : '三方通话'),
                    ),
                  SizedBox(height: compact ? 16 : 22),
                  _buildPrimaryCallControls(primary, uiState, service),
                  if (_showInCallDialpad && primary.isConnected) ...[
                    SizedBox(height: compact ? 16 : 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: _buildDtmfPad(primary, service),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryCallControls(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isConferenceMember = uiState.isInConference(call.callId);
    final controls = <Widget>[];

    if (call.isIncoming && !call.isConnected) {
      controls.addAll([
        _roundCallButton(
          icon: AppIcons.call,
          label: '接听',
          color: _callGreen,
          emphasized: true,
          onPressed: () => _answerCall(service, call.callId),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: '拒接',
          color: _dangerRed,
          onPressed: () => _rejectCall(service, call.callId),
        ),
      ]);
    } else {
      controls.addAll([
        _roundCallButton(
          icon: uiState.isMicrophoneMuted
              ? AppIcons.microphoneOff
              : AppIcons.microphone,
          label: uiState.isMicrophoneMuted ? '取消静音' : '静音',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () =>
              service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
        ),
        _roundCallButton(
          icon: AppIcons.dialpad,
          label: '键盘',
          color: _showInCallDialpad
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected ? () => _toggleInCallDialpad() : null,
        ),
        _roundCallButton(
          icon: call.isOnHold ? AppIcons.play : AppIcons.pause,
          label: call.isOnHold ? '恢复' : '保持',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected && !isConferenceMember
              ? () => call.isOnHold
                    ? service.unholdCall(call.callId)
                    : service.holdCall(call.callId)
              : null,
        ),
        _roundCallButton(
          icon: AppIcons.tune,
          label: '音频',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () => _openSettingsDrawer(tabIndex: 1),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: '挂断',
          color: _dangerRed,
          onPressed: () => _hangupCall(service, call.callId),
        ),
      ]);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: controls,
    );
  }

  Widget _buildDtmfPad(CallInfo call, PjsipService service) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return FilledButton.tonal(
          onPressed: () => service.sendDtmf(call.callId, key),
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }

  Widget _roundCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool emphasized = false,
  }) {
    final button = SizedBox(
      width: 86,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 78,
            child: Center(
              child: _AnimatedIconButton(
                icon: icon,
                color: color,
                onPressed: onPressed,
                emphasized: emphasized,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
    return button;
  }

  Widget _buildLiveCallsPanel(PjsipUIState uiState, PjsipService service) {
    final calls = uiState.calls.values.toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(AppIcons.call, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '当前通话',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (uiState.isConferencePaused)
                  TextButton.icon(
                    onPressed: service.resumeConference,
                    icon: const Icon(AppIcons.play),
                    label: const Text('恢复会议'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: calls.isEmpty
                  ? Center(
                      child: Text(
                        '没有活动通话',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: calls.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _buildCallListTile(calls[index], uiState, service),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallListTile(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isActive = uiState.activeCallId == call.callId;
    final isConferenceMember = uiState.isInConference(call.callId);
    final account = uiState.accountForCall(call);
    final canMergeWithActive =
        !uiState.hasConference &&
        call.isConnected &&
        !call.isRemoteOnHold &&
        uiState.activeCallId != null &&
        uiState.activeCallId != call.callId;

    final highlighted = isActive || isConferenceMember;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? _brandGreen.withValues(alpha: 0.06) : _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(_avatarText(call.remoteUri)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTooltipText(
                        _displayRemote(call.remoteUri),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        call.isConnected
                            ? call.durationLabel
                            : call.statusLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (account != null) ...[
                        const SizedBox(height: 3),
                        _buildTooltipText(
                          '${account.lineLabel} · ${account.transportLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: _textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isConferenceMember)
                  const Icon(AppIcons.contacts, size: 18)
                else if (isActive)
                  const Icon(AppIcons.meters, size: 18),
              ],
            ),
            if (call.isConnected && (isActive || isConferenceMember)) ...[
              const SizedBox(height: 10),
              _buildCompactCallAudioMeters(uiState),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (call.isIncoming && !call.isConnected) ...[
                  FilledButton.tonalIcon(
                    onPressed: () => _answerCall(service, call.callId),
                    icon: const Icon(AppIcons.call),
                    label: const Text('接听'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _rejectCall(service, call.callId),
                    icon: const Icon(AppIcons.callEnd),
                    label: const Text('拒接'),
                  ),
                ],
                if (call.isConnected && !isConferenceMember)
                  OutlinedButton.icon(
                    onPressed: () => call.isOnHold
                        ? service.unholdCall(call.callId)
                        : service.holdCall(call.callId),
                    icon: Icon(call.isOnHold ? AppIcons.play : AppIcons.pause),
                    label: Text(call.isOnHold ? '恢复' : '保持'),
                  ),
                if (canMergeWithActive)
                  OutlinedButton.icon(
                    onPressed: () => service.mergeWithActiveCall(call.callId),
                    icon: const Icon(AppIcons.contacts),
                    label: const Text('合并'),
                  ),
                if (isConferenceMember && !uiState.isConferencePaused)
                  OutlinedButton.icon(
                    onPressed: () => service.splitConference(call.callId),
                    icon: const Icon(AppIcons.split),
                    label: const Text('拆分'),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () => _hangupCall(service, call.callId),
                  icon: const Icon(AppIcons.callEnd),
                  label: const Text('挂断'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLineChip(
    SipAccountInfo account, {
    required bool isIncoming,
  }) {
    return Chip(
      avatar: Icon(isIncoming ? AppIcons.incoming : AppIcons.outgoing),
      label: Text(
        isIncoming
            ? '来电线路：${account.lineLabel} · ${account.transportLabel}'
            : '${account.lineLabel} · ${account.transportLabel}',
      ),
      side: const BorderSide(color: _softBorder),
      backgroundColor: _subtlePanel,
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
      return SizedBox.square(
        dimension: widget.size,
        child: Center(child: avatar),
      );
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

class _PulseHalo extends StatefulWidget {
  const _PulseHalo({required this.color, required this.delay});

  final Color color;
  final Duration delay;

  @override
  State<_PulseHalo> createState() => _PulseHaloState();
}

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

class _AnimatedIconButton extends StatelessWidget {
  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.emphasized,
  });

  final IconData icon;
  final Color color;
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
        iconSize: 28,
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color.computeLuminance() > 0.45
              ? Colors.black87
              : Colors.white,
          disabledBackgroundColor: Theme.of(context).disabledColor,
          minimumSize: const Size(60, 60),
        ),
      ),
    );

    return emphasized && onPressed != null
        ? _PulsingCallAction(child: button)
        : button;
  }
}

class _PulsingCallAction extends StatefulWidget {
  const _PulsingCallAction({required this.child});

  final Widget child;

  @override
  State<_PulsingCallAction> createState() => _PulsingCallActionState();
}

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
