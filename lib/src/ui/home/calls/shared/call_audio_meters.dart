part of '../../../../../main.dart';

// 通话页声平条调参集中放这里，方便按真实设备效果微调。
//
// MicroSIP 基本直接使用 PJSIP signal level，没有把安静环境下的小电平放大。
// 这里保留轻微视觉增强，但提高底噪门限，并把极小值钳回 0，避免安静时常亮。
const double _callAudioNoiseFloor = 0.075;
const double _callAudioVisualPower = 0.72;
const double _callAudioVisibleFloor = 0.08;
const Duration _callAudioRiseDuration = Duration(milliseconds: 70);
const Duration _callAudioFallDuration = Duration(milliseconds: 320);

/// 通话音频电平入口：负责主舞台和紧凑列表里的音量条组合。
extension _HomeCallAudioMeters on _MyHomePageState {
  Widget _buildCallAudioMeters(
    PjsipUIState uiState,
    PjsipService service, {
    required bool compact,
    required bool microphoneMuted,
  }) {
    return Column(
      children: [
        _buildAudioMeterRow(
          icon: microphoneMuted ? AppIcons.microphoneOff : AppIcons.microphone,
          label: context.l10n.activeCallMyAudio,
          value: _audioMeterValue(
            uiState.microphoneLevel,
            muted: microphoneMuted,
          ),
          muted: microphoneMuted,
          color: _callGreen,
          volume: uiState.microphoneVolume,
          onVolumeChanged: service.setMicrophoneVolume,
        ),
        SizedBox(height: compact ? 9 : 11),
        _buildAudioMeterRow(
          icon: uiState.isSpeakerMuted ? AppIcons.speakerOff : AppIcons.meters,
          label: context.l10n.activeCallRemoteAudio,
          value: _audioMeterValue(
            uiState.speakerLevel,
            muted: uiState.isSpeakerMuted,
          ),
          muted: uiState.isSpeakerMuted,
          color: Theme.of(context).colorScheme.primary,
          volume: uiState.speakerVolume,
          onVolumeChanged: service.setSpeakerVolume,
        ),
      ],
    );
  }

  Widget _buildCompactCallAudioMeters(
    PjsipUIState uiState, {
    required bool microphoneMuted,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTinyAudioMeter(
            icon: microphoneMuted
                ? AppIcons.microphoneOff
                : AppIcons.microphone,
            value: _audioMeterValue(
              uiState.microphoneLevel,
              muted: microphoneMuted,
            ),
            muted: microphoneMuted,
            color: _callGreen,
            tooltip: context.l10n.activeCallMyAudio,
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
            tooltip: context.l10n.activeCallRemoteAudio,
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
    required int volume,
    required ValueChanged<int> onVolumeChanged,
  }) {
    final effectiveColor = muted ? _textSecondary : color;
    return Row(
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: _CallAudioMeterBar(
            value: value,
            color: effectiveColor,
            muted: muted,
            label: label,
            height: 16,
            volume: volume,
            onVolumeChanged: onVolumeChanged,
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
    final effectiveColor = muted ? _textSecondary : color;
    return Tooltip(
      message: muted ? context.l10n.activeCallMutedValue(tooltip) : tooltip,
      child: Row(
        children: [
          Icon(icon, size: 15, color: effectiveColor),
          const SizedBox(width: 6),
          Expanded(
            child: _CallAudioMeterBar(
              value: value,
              height: 6,
              color: effectiveColor,
              muted: muted,
              compact: true,
              label: tooltip,
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
    final value = math
        .pow(gated, _callAudioVisualPower)
        .toDouble()
        .clamp(0.0, 1.0);
    return value < _callAudioVisibleFloor ? 0 : value;
  }
}

/// 可调音量电平条：展示当前电平并允许拖动调整输入/输出音量。
class _CallAudioMeterBar extends StatefulWidget {
  const _CallAudioMeterBar({
    required this.value,
    required this.color,
    required this.muted,
    required this.label,
    this.volume = 100,
    this.onVolumeChanged,
    this.height = 9,
    this.compact = false,
  });

  final double value;
  final Color color;
  final bool muted;
  final String label;
  final int volume;
  final ValueChanged<int>? onVolumeChanged;
  final double height;
  final bool compact;

  @override
  State<_CallAudioMeterBar> createState() => _CallAudioMeterBarState();
}

/// 可调音量电平条状态：处理拖动、延迟保存和本地显示值同步。
class _CallAudioMeterBarState extends State<_CallAudioMeterBar> {
  late double _previousTarget;
  late double _peakTarget;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _previousTarget = widget.value.clamp(0.0, 1.0);
    _peakTarget = _previousTarget;
    _duration = _callAudioRiseDuration;
  }

  @override
  void didUpdateWidget(_CallAudioMeterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.value.clamp(0.0, 1.0);
    _duration = target >= _previousTarget
        ? _callAudioRiseDuration
        : _callAudioFallDuration;
    // MicroSIP 用 slider selection 显示当前电平。这里额外保留一个很短的
    // 峰值位置，方便比较“刚才最大值”和“当前值”，后续叠加音量滑块也自然。
    _peakTarget = target >= _peakTarget
        ? target
        : math.max(target, _peakTarget - 0.045);
    _previousTarget = target;
  }

  @override
  Widget build(BuildContext context) {
    final normalized = widget.value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: normalized),
      duration: _duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return _SegmentedAudioMeter(
          value: animatedValue,
          color: widget.color,
          height: widget.height,
          compact: widget.compact,
          muted: widget.muted,
          label: widget.label,
          peakValue: _peakTarget,
          volume: widget.volume,
          onVolumeChanged: widget.onVolumeChanged,
        );
      },
    );
  }
}

/// 分段电平条：用固定格子展示最大范围、当前电平和当前音量上限。
class _SegmentedAudioMeter extends StatelessWidget {
  const _SegmentedAudioMeter({
    required this.value,
    required this.color,
    required this.height,
    required this.compact,
    required this.muted,
    required this.label,
    required this.peakValue,
    required this.volume,
    this.onVolumeChanged,
  });

  final double value;
  final Color color;
  final double height;
  final bool compact;
  final bool muted;
  final String label;
  final double peakValue;
  final int volume;
  final ValueChanged<int>? onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    final activeValue = muted ? 0.0 : value.clamp(0.0, 1.0);
    final activePeakValue = muted ? 0.0 : peakValue.clamp(0.0, 1.0);
    final segmentCount = compact ? 18 : 26;
    final litSegments = activeValue <= 0
        ? 0
        : (activeValue * segmentCount).floor().clamp(1, segmentCount);
    final peakSegment = activePeakValue <= 0
        ? -1
        : ((activePeakValue * segmentCount).ceil() - 1).clamp(
            0,
            segmentCount - 1,
          );
    final normalizedVolume = (volume.clamp(0, 100).toDouble() / 100).clamp(
      0.0,
      1.0,
    );
    final trackColor = Color.lerp(
      Theme.of(context).colorScheme.surface,
      _textSecondary,
      compact ? 0.20 : 0.24,
    )!;
    final activeColor = color.withValues(alpha: compact ? 0.78 : 0.84);
    final markerColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.82);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = compact ? 2.0 : 2.5;
        final rawSegmentWidth =
            (constraints.maxWidth - gap * (segmentCount - 1)) / segmentCount;
        final segmentWidth = rawSegmentWidth.clamp(compact ? 2.5 : 3.0, 9.0);
        final trackWidth = math.min(
          constraints.maxWidth,
          segmentWidth * segmentCount + gap * (segmentCount - 1),
        );
        void updateVolume(Offset localPosition) {
          final handler = onVolumeChanged;
          if (handler == null || trackWidth <= 0) return;
          final ratio = (localPosition.dx / trackWidth).clamp(0.0, 1.0);
          handler((ratio * 100).round());
        }

        final volumeText = onVolumeChanged == null
            ? ''
            : context.l10n.activeCallVolumeValue(volume);
        final meter = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var index = 0; index < segmentCount; index++) ...[
              _AudioMeterSegment(
                active: index < litSegments,
                peak: index == peakSegment && activePeakValue > 0.12,
                color: activeColor,
                trackColor: trackColor,
                height: compact ? height : 9,
                width: segmentWidth,
              ),
              if (index != segmentCount - 1) SizedBox(width: gap),
            ],
          ],
        );
        final canAdjustVolume = onVolumeChanged != null;
        final thumbWidth = compact ? 7.0 : 10.0;
        final thumbHeight = compact ? height + 3 : height + 6;
        final meterHeight = math.max(height, thumbHeight);
        final thumbLeft = normalizedVolume * (trackWidth - thumbWidth);
        final stackedMeter = SizedBox(
          width: trackWidth,
          height: meterHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: Align(alignment: Alignment.center, child: meter),
              ),
              if (canAdjustVolume)
                Positioned(
                  left: thumbLeft,
                  top: (meterHeight - thumbHeight) / 2,
                  child: _AudioVolumeThumb(
                    color: markerColor,
                    accentColor: color,
                    width: thumbWidth,
                    height: thumbHeight,
                    compact: compact,
                  ),
                ),
            ],
          ),
        );

        return Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: muted
                ? context.l10n.activeCallMeterMuted(label, volumeText)
                : context.l10n.activeCallMeterValues(
                    label,
                    (activeValue * 100).round(),
                    (activePeakValue * 100).round(),
                    volumeText,
                  ),
            child: MouseRegion(
              cursor: onVolumeChanged == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: onVolumeChanged == null
                    ? null
                    : (details) => updateVolume(details.localPosition),
                onHorizontalDragStart: onVolumeChanged == null
                    ? null
                    : (details) => updateVolume(details.localPosition),
                onHorizontalDragUpdate: onVolumeChanged == null
                    ? null
                    : (details) => updateVolume(details.localPosition),
                child: stackedMeter,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 单个电平格：负责格子的颜色、尺寸和圆角表现。
class _AudioMeterSegment extends StatelessWidget {
  const _AudioMeterSegment({
    required this.active,
    required this.peak,
    required this.color,
    required this.trackColor,
    required this.height,
    required this.width,
  });

  final bool active;
  final bool peak;
  final Color color;
  final Color trackColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: active
                ? _callAudioRiseDuration
                : const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: peak ? 1 : 0.82)
                  : trackColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: peak
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.16),
                        blurRadius: 5,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 音量滑块手柄：展示可拖动的当前音量位置。
class _AudioVolumeThumb extends StatelessWidget {
  const _AudioVolumeThumb({
    required this.color,
    required this.accentColor,
    required this.width,
    required this.height,
    required this.compact,
  });

  final Color color;
  final Color accentColor;
  final double width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
        border: Border.all(color: color.withValues(alpha: 0.70), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Container(
            width: compact ? 2 : 3,
            height: compact ? height - 5 : height - 7,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }
}
