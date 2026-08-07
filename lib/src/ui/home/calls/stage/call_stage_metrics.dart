part of '../../../../../main.dart';

/// 主舞台指标区：负责通话时长、保持状态和音频电平是否显示的判断。
extension _CallStageMetrics on _MyHomePageState {
  bool _shouldShowCallAudioMeters(CallInfo call, PjsipUIState uiState) {
    if (!call.isConnected || call.isOnHold || call.isRemoteOnHold) {
      return false;
    }
    if (uiState.isInConference(call.callId)) {
      return !uiState.isConferencePaused;
    }
    return uiState.activeCallId == call.callId;
  }

  Widget _buildCallStatePanel(CallInfo call, Color statusColor) {
    final connected = call.isConnected;
    final pendingLabel = _callOperationLabel(call.callId);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(
              connected ? AppIcons.activity : AppIcons.info,
              size: _iconLg,
              color: statusColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pendingLabel != null
                        ? context.l10n.activeCallOperationInProgress
                        : connected
                        ? context.l10n.activeCallDuration
                        : context.l10n.activeCallCurrentStatus,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pendingLabel ??
                        (connected
                            ? call.durationLabel
                            : _plainCallStatusLabel(call)),
                    style: TextStyle(
                      fontSize: pendingLabel != null
                          ? 22
                          : connected
                          ? 38
                          : 22,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (call.isOnHold || call.isRemoteOnHold)
              _buildCallMetaStrip(
                icon: AppIcons.pause,
                label: call.isRemoteOnHold
                    ? context.l10n.activeCallMediaRemoteHold
                    : context.l10n.activeCallMediaLocalHold,
                color: Colors.orange.shade700,
              ),
          ],
        ),
      ),
    );
  }

  /// 通话中音频设备异常提示。
  ///
  /// 只在服务层确认声卡打开失败或降级时显示，避免把普通“自动选择设备”的状态
  /// 放进主舞台干扰用户接听、保持、挂断这些核心动作。
  Widget _buildCallAudioIssueBanner(PjsipUIState uiState) {
    final message = uiState.audioDeviceIssueMessage;
    if (message == null || message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final color = Colors.orange.shade700;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(AppIcons.info, size: _iconMd, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
