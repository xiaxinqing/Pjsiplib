part of '../../../../../main.dart';

/// 右侧通话列表：负责单路通话卡片、状态徽标和快捷操作按钮。
extension _CallSideList on _MyHomePageState {
  Widget _buildCallListTile(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isActive = uiState.activeCallId == call.callId;
    final isFocused = _primaryCall(uiState)?.callId == call.callId;
    final isConferenceMember = uiState.isInConference(call.callId);
    final pendingLabel = _callOperationLabel(call.callId);
    final hasPendingOperation = pendingLabel != null;
    final isCoolingDown = _isMediaBridgeActionCoolingDown;
    final account = uiState.accountForCall(call);
    final visualState = _liveCallVisualState(call, uiState, pendingLabel);
    final quality = _callQualityView(call, account);
    final statusColor = visualState.color;
    final contactMatch = _callContactMatch(call);
    final contact = contactMatch?.contact;
    final displayName = contact?.name ?? _displayRemote(call.remoteUri);
    final displayNumber = contact == null
        ? null
        : contactMatch?.phone.number ?? _callDisplayNumber(call);
    final canMergeWithActive =
        !uiState.hasConference &&
        call.isConnected &&
        !call.isRemoteOnHold &&
        uiState.activeCallId != null &&
        uiState.activeCallId != call.callId;

    final highlighted = isFocused || isActive || isConferenceMember;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_radiusSm),
        onTap: () => _focusCallDetail(call.callId),
        child: Ink(
          decoration: BoxDecoration(
            color: highlighted
                ? _brandGreen.withValues(alpha: isFocused ? 0.08 : 0.05)
                : _subtlePanel,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(
              color: isFocused
                  ? _brandGreen.withValues(alpha: 0.34)
                  : highlighted
                  ? _brandGreen.withValues(alpha: 0.2)
                  : _softBorder,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    foregroundColor: statusColor,
                    child: Text(
                      contact?.initials ?? _avatarText(call.remoteUri),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTooltipText(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isFocused) ...[
                              const SizedBox(width: 6),
                              _buildCallTinyBadge('查看中', _brandGreen),
                            ],
                            const SizedBox(width: 6),
                            _buildCallTinyBadge(
                              visualState.label,
                              visualState.color,
                            ),
                          ],
                        ),
                        if (displayNumber != null &&
                            displayNumber.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          _buildTooltipText(
                            displayNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              visualState.icon,
                              size: _iconXs,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              visualState.detail,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: !visualState.emphasizeDetail
                                        ? _textPrimary
                                        : statusColor,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                            if (isConferenceMember) ...[
                              const SizedBox(width: 8),
                              Icon(
                                AppIcons.contacts,
                                size: _iconXs,
                                color: _textSecondary,
                              ),
                            ] else if (isActive) ...[
                              const SizedBox(width: 8),
                              Icon(
                                AppIcons.meters,
                                size: _iconXs,
                                color: _textSecondary,
                              ),
                            ],
                          ],
                        ),
                        if (account != null) ...[
                          const SizedBox(height: 3),
                          _buildTooltipText(
                            '${account.lineLabel} · ${account.transportLabel}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: _textSecondary),
                          ),
                        ],
                        if (call.isConnected) ...[
                          const SizedBox(height: 3),
                          Tooltip(
                            message: quality.tooltip,
                            child: Row(
                              children: [
                                Icon(
                                  quality.icon,
                                  size: _iconXs,
                                  color: quality.color,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    quality.compactLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: quality.color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: call.isIncoming && !call.isConnected ? '拒接' : '挂断',
                    onPressed: hasPendingOperation
                        ? null
                        : () => call.isIncoming && !call.isConnected
                              ? _rejectCall(service, call.callId)
                              : _hangupCall(service, call.callId),
                    icon: const Icon(AppIcons.callEnd),
                    color: _dangerRed,
                    style: IconButton.styleFrom(
                      backgroundColor: _dangerRed.withValues(alpha: 0.08),
                      hoverColor: _dangerRed.withValues(alpha: 0.12),
                      highlightColor: _dangerRed.withValues(alpha: 0.16),
                    ),
                  ),
                ],
              ),
              if (_shouldShowCallAudioMeters(call, uiState)) ...[
                const SizedBox(height: 10),
                _buildCompactCallAudioMeters(uiState),
              ],
              if (call.isIncoming && !call.isConnected) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: hasPendingOperation
                        ? null
                        : () => _answerCall(service, call.callId),
                    icon: const Icon(AppIcons.call),
                    label: const Text('接听'),
                    style: FilledButton.styleFrom(
                      foregroundColor: _callGreen,
                      backgroundColor: _callGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ] else if (call.isConnected) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (!isConferenceMember)
                      _compactCallAction(
                        icon: call.isOnHold ? AppIcons.play : AppIcons.pause,
                        label: call.isRemoteOnHold && !call.isOnHold
                            ? '对方保持'
                            : call.isOnHold
                            ? '恢复'
                            : '保持',
                        active: call.isOnHold || call.isRemoteOnHold,
                        activeColor: Colors.orange.shade700,
                        onPressed:
                            hasPendingOperation ||
                                isCoolingDown ||
                                (call.isRemoteOnHold && !call.isOnHold)
                            ? null
                            : () => call.isOnHold
                                  ? _runMediaBridgeActionAndFocus(
                                      call.callId,
                                      '正在恢复',
                                      () => service.unholdCall(call.callId),
                                    )
                                  : _runMediaBridgeActionAndFocus(
                                      call.callId,
                                      '正在保持',
                                      () => service.holdCall(call.callId),
                                    ),
                      ),
                    if (!isConferenceMember)
                      _compactCallAction(
                        icon: AppIcons.route,
                        label: '转接',
                        onPressed: hasPendingOperation
                            ? null
                            : () => _showBlindTransferDialog(
                                call,
                                uiState,
                                service,
                              ),
                      ),
                    if (canMergeWithActive)
                      _compactCallAction(
                        icon: AppIcons.contacts,
                        label: '合并',
                        onPressed: hasPendingOperation || isCoolingDown
                            ? null
                            : () => _runConferenceActionAndFocus(
                                call.callId,
                                '正在合并',
                                () => service.mergeWithActiveCall(call.callId),
                              ),
                      ),
                    if (isConferenceMember && !uiState.isConferencePaused)
                      _compactCallAction(
                        icon: AppIcons.split,
                        label: '拆分',
                        onPressed: hasPendingOperation || isCoolingDown
                            ? null
                            : () => _runConferenceActionAndFocus(
                                call.callId,
                                '正在拆分',
                                () => service.splitConference(call.callId),
                              ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallTinyBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _compactCallAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool active = false,
    Color? activeColor,
  }) {
    final color = activeColor ?? _brandGreen;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        textStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        iconSize: _iconSm,
        foregroundColor: active ? color : _textPrimary,
        backgroundColor: active
            ? color.withValues(alpha: 0.1)
            : _panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusXs),
          side: BorderSide(
            color: active ? color.withValues(alpha: 0.22) : _softBorder,
          ),
        ),
      ),
    );
  }
}
