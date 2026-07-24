part of '../../../main.dart';

// 通话页声平条调参集中放这里，方便按真实设备效果微调。
//
// - _callAudioNoiseFloor：原始 signal level 的底噪门限，低于它直接显示安静。
// - _callAudioVisualPower：视觉增强指数，越小越“灵敏”，越大越接近原始电平。
// - _callAudioRiseDuration：说话时上升速度，短一点会更跟嘴。
// - _callAudioFallDuration：停止说话后回落速度，长一点会更柔和。
// - _callAudioIdlePulseMax：安静时的小幅闪烁，表示电平监测仍在工作。
const double _callAudioNoiseFloor = 0.04;
const double _callAudioVisualPower = 0.45;
const double _callAudioIdlePulseMax = 0.005;
const Duration _callAudioRiseDuration = Duration(milliseconds: 90);
const Duration _callAudioFallDuration = Duration(milliseconds: 120);
const Duration _callAudioIdlePulseDuration = Duration(milliseconds: 200);

extension _HomeCallAudioMeters on _MyHomePageState {
  Widget _buildCallAudioMeters(PjsipUIState uiState, {required bool compact}) {
    final microphoneValue = _audioMeterValue(
      uiState.microphoneLevel,
      muted: uiState.isMicrophoneMuted,
    );
    final speakerValue = _audioMeterValue(
      uiState.speakerLevel,
      muted: uiState.isSpeakerMuted,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 10 : 12,
        ),
        child: Column(
          children: [
            _buildAudioMeterRow(
              icon: uiState.isMicrophoneMuted
                  ? AppIcons.microphoneOff
                  : AppIcons.microphone,
              label: '我方说话',
              value: microphoneValue,
              muted: uiState.isMicrophoneMuted,
              color: _callGreen,
            ),
            SizedBox(height: compact ? 8 : 10),
            _buildAudioMeterRow(
              icon: uiState.isSpeakerMuted
                  ? AppIcons.speakerOff
                  : AppIcons.meters,
              label: '对方声音',
              value: speakerValue,
              muted: uiState.isSpeakerMuted,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCallAudioMeters(PjsipUIState uiState) {
    return Row(
      children: [
        Expanded(
          child: _buildTinyAudioMeter(
            icon: uiState.isMicrophoneMuted
                ? AppIcons.microphoneOff
                : AppIcons.microphone,
            value: _audioMeterValue(
              uiState.microphoneLevel,
              muted: uiState.isMicrophoneMuted,
            ),
            muted: uiState.isMicrophoneMuted,
            color: _callGreen,
            tooltip: '我方说话',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTinyAudioMeter(
            icon: uiState.isSpeakerMuted
                ? AppIcons.speakerOff
                : AppIcons.meters,
            value: _audioMeterValue(
              uiState.speakerLevel,
              muted: uiState.isSpeakerMuted,
            ),
            muted: uiState.isSpeakerMuted,
            color: Theme.of(context).colorScheme.primary,
            tooltip: '对方声音',
          ),
        ),
      ],
    );
  }

  Widget _buildAudioMeterRow({
    required IconData icon,
    required String label,
    required double value,
    required bool muted,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: muted ? _textSecondary : color),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: _CallAudioMeterBar(
            value: value,
            color: muted ? _textSecondary : color,
            idlePulse: !muted,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            _audioMeterStatusLabel(value, muted: muted),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: muted ? _textSecondary : _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTinyAudioMeter({
    required IconData icon,
    required double value,
    required bool muted,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: muted ? '$tooltip：静音' : tooltip,
      child: Row(
        children: [
          Icon(icon, size: 15, color: muted ? _textSecondary : color),
          const SizedBox(width: 6),
          Expanded(
            child: _CallAudioMeterBar(
              value: value,
              height: 6,
              color: muted ? _textSecondary : color,
              idlePulse: !muted,
            ),
          ),
        ],
      ),
    );
  }

  double _audioMeterValue(int level, {required bool muted}) {
    if (muted) return 0;
    final raw = (level / 255.0).clamp(0.0, 1.0);
    if (raw <= _callAudioNoiseFloor) return 0;

    final gated = ((raw - _callAudioNoiseFloor) / (1 - _callAudioNoiseFloor))
        .clamp(0.0, 1.0);
    // 通话页关注“有没有声音”的可感知反馈，而不是工程测量值。PJSIP 返回的
    // signal level 在线性显示下会偏小。先切掉安静环境下常见的底噪残留，再做
    // 非线性增强，避免没人说话时也一直显示 8% 左右。
    return math.pow(gated, _callAudioVisualPower).toDouble().clamp(0.0, 1.0);
  }

  String _audioMeterStatusLabel(double value, {required bool muted}) {
    if (muted) return '静音';
    if (value <= 0) return '安静';
    if (value < 0.36) return '低';
    if (value < 0.72) return '中';
    return '高';
  }
}

class _CallAudioMeterBar extends StatefulWidget {
  const _CallAudioMeterBar({
    required this.value,
    required this.color,
    required this.idlePulse,
    this.height = 9,
  });

  final double value;
  final Color color;
  final bool idlePulse;
  final double height;

  @override
  State<_CallAudioMeterBar> createState() => _CallAudioMeterBarState();
}

class _CallAudioMeterBarState extends State<_CallAudioMeterBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  late final Animation<double> _idlePulseValue;
  late double _previousTarget;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: _callAudioIdlePulseDuration,
    );
    _idlePulseValue = Tween<double>(begin: 0, end: _callAudioIdlePulseMax)
        .animate(
          CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
        );
    // 两条电平不要完全同步闪，起始相位错开一点会更自然。
    _idleController.value = math.Random().nextDouble();
    _previousTarget = widget.value.clamp(0.0, 1.0);
    _duration = _callAudioRiseDuration;
    _syncIdlePulse();
  }

  @override
  void didUpdateWidget(_CallAudioMeterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.value.clamp(0.0, 1.0);
    _duration = target >= _previousTarget
        ? _callAudioRiseDuration
        : _callAudioFallDuration;
    _previousTarget = target;
    _syncIdlePulse();
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  void _syncIdlePulse() {
    final shouldPulse = widget.idlePulse && widget.value <= 0;
    if (shouldPulse && !_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    } else if (!shouldPulse && _idleController.isAnimating) {
      _idleController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = widget.value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.55),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: normalized),
              duration: _duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return AnimatedBuilder(
                  animation: _idleController,
                  builder: (context, _) {
                    final idleValue = widget.idlePulse && normalized <= 0
                        ? _idlePulseValue.value
                        : 0.0;
                    final widthFactor = math
                        .max(animatedValue, idleValue)
                        .clamp(0.0, 1.0);
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widthFactor,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(widget.height),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
