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
                        ? '操作中'
                        : connected
                        ? '通话时长'
                        : '当前状态',
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
                label: call.isRemoteOnHold ? '对方保持' : '本地保持',
                color: Colors.orange.shade700,
              ),
          ],
        ),
      ),
    );
  }
}
