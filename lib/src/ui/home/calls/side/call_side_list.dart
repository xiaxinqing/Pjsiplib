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
    final pendingOperation = _callOperation(call.callId);
    final hasPendingOperation = pendingOperation != null;
    final isCoolingDown = _isMediaBridgeActionCoolingDown;
    final account = uiState.accountForCall(call);
    final visualState = _liveCallVisualState(call, uiState, pendingOperation);
    final quality = _callQualityView(call, account);
    final statusColor = visualState.color;
    final contactMatch = _callContactMatch(call);
    final contact = contactMatch?.contact;
    final identity = _callDisplayIdentity(call, contactMatch);
    final remoteMuted = uiState.remoteMutedCallIds.contains(call.callId);
    final microphoneMuted = uiState.isMicrophoneMutedForCall(call.callId);
    final held = call.isOnHold || call.isRemoteOnHold;
    final detailColor = held
        ? _textPrimary
        : !visualState.emphasizeDetail
        ? _textPrimary
        : statusColor;
    final detailLabel = held ? call.durationLabel : visualState.detail;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _brandGreen.withValues(alpha: 0.12),
                    foregroundColor: _brandGreen,
                    child: Text(
                      contact?.initials ?? _avatarText(call.remoteUri),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCallIdentityLine(
                          identity,
                          primaryStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          secondaryStyle:
                              (Theme.of(context).textTheme.bodySmall ??
                                      const TextStyle())
                                  .copyWith(
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              visualState.icon,
                              size: _iconXs,
                              color: held ? _textSecondary : statusColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              detailLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: detailColor,
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
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (isFocused)
                          _buildCallTinyBadge(
                            context.l10n.activeCallViewing,
                            _brandGreen,
                          ),
                        _buildCallTinyBadge(
                          visualState.label,
                          visualState.color,
                        ),
                        if (remoteMuted)
                          _buildCallTinyBadge(
                            context.l10n.activeCallRemoteAudioMuted,
                            _textSecondary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (account != null || call.isConnected) ...[
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: _buildCallLineAndSecurityRow(
                    call: call,
                    account: account,
                    quality: quality,
                  ),
                ),
              ],
              if (_shouldShowCallAudioMeters(call, uiState)) ...[
                const SizedBox(height: 10),
                _buildCompactCallAudioMeters(
                  uiState,
                  microphoneMuted: microphoneMuted,
                ),
              ],
              if (call.isIncoming && !call.isConnected) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: hasPendingOperation
                          ? null
                          : () => _answerCall(service, call.callId),
                      icon: const Icon(AppIcons.call),
                      label: Text(context.l10n.activeCallAnswer),
                      style: FilledButton.styleFrom(
                        foregroundColor: _callGreen,
                        backgroundColor: _callGreen.withValues(alpha: 0.1),
                      ),
                    ),
                    const Spacer(),
                    _compactCallEndAction(
                      label: context.l10n.activeCallReject,
                      height: 40,
                      onPressed: hasPendingOperation
                          ? null
                          : () => _rejectCall(service, call.callId),
                    ),
                  ],
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
                            ? context.l10n.activeCallStatusRemoteHold
                            : call.isOnHold
                            ? context.l10n.activeCallResume
                            : context.l10n.activeCallHold,
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
                                      _CallOperationType.resume,
                                      () => service.unholdCall(call.callId),
                                    )
                                  : _runMediaBridgeActionAndFocus(
                                      call.callId,
                                      _CallOperationType.hold,
                                      () => service.holdCall(call.callId),
                                    ),
                      ),
                    _compactCallAction(
                      icon: remoteMuted
                          ? AppIcons.speaker
                          : AppIcons.speakerOff,
                      label: remoteMuted
                          ? context.l10n.activeCallRestoreRemoteAudio
                          : context.l10n.activeCallMuteRemoteAudio,
                      active: remoteMuted,
                      activeColor: _textSecondary,
                      onPressed: () => service.setRemoteAudioMuted(
                        call.callId,
                        !remoteMuted,
                      ),
                    ),
                    if (!isConferenceMember)
                      _compactCallAction(
                        icon: AppIcons.route,
                        label: context.l10n.activeCallTransfer,
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
                        label: context.l10n.activeCallMerge,
                        onPressed: hasPendingOperation || isCoolingDown
                            ? null
                            : () => _runConferenceActionAndFocus(
                                call.callId,
                                _CallOperationType.merge,
                                () => service.mergeWithActiveCall(call.callId),
                              ),
                      ),
                    if (isConferenceMember && !uiState.isConferencePaused)
                      _compactCallAction(
                        icon: AppIcons.split,
                        label: context.l10n.activeCallSplit,
                        onPressed: hasPendingOperation || isCoolingDown
                            ? null
                            : () => _runConferenceActionAndFocus(
                                call.callId,
                                _CallOperationType.split,
                                () => service.splitConference(call.callId),
                              ),
                      ),
                    _compactCallEndAction(
                      label: context.l10n.activeCallHangUp,
                      onPressed: hasPendingOperation
                          ? null
                          : () => _hangupCall(service, call.callId),
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

  Widget _buildCallLineAndSecurityRow({
    required CallInfo call,
    required SipAccountInfo? account,
    required _CallQualityView quality,
  }) {
    final lineDisplay = account == null ? null : _callLineDisplayLabel(account);
    final technicalLine = account == null
        ? null
        : '${account.lineLabel} · ${account.transportLabel}';
    final lineTooltip = lineDisplay == null
        ? null
        : lineDisplay == technicalLine
        ? lineDisplay
        : '$lineDisplay\n$technicalLine';

    return Row(
      children: [
        if (account != null) ...[
          Icon(AppIcons.line, size: _iconXs, color: _textSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: Tooltip(
              message: lineTooltip!,
              waitDuration: const Duration(milliseconds: 350),
              child: Text(
                lineDisplay!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ),
          ),
        ],
        if (call.isConnected && !call.isOnHold && !call.isRemoteOnHold) ...[
          if (account != null) const SizedBox(width: 10),
          Tooltip(
            message: quality.tooltip,
            waitDuration: const Duration(milliseconds: 350),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(quality.icon, size: _iconXs, color: quality.color),
                const SizedBox(width: 5),
                Text(
                  quality.compactLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: quality.color,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _callLineDisplayLabel(SipAccountInfo account) {
    final name = account.displayName.trim();
    final username = account.username.trim();
    if (name.isEmpty) return username;
    if (username.isEmpty || name.toLowerCase() == username.toLowerCase()) {
      return name;
    }
    return '$name · $username';
  }

  Widget _buildCallTinyBadge(String label, Color color) {
    return Tooltip(
      message: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 116),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(_radiusXs),
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
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
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
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

  Widget _compactCallEndAction({
    required String label,
    required VoidCallback? onPressed,
    double height = 30,
  }) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: const Icon(AppIcons.callEnd),
      iconSize: _iconSm,
      constraints: BoxConstraints.tightFor(width: 36, height: height),
      padding: EdgeInsets.zero,
      color: _dangerRed,
      style: IconButton.styleFrom(
        backgroundColor: _dangerRed.withValues(alpha: 0.08),
        hoverColor: _dangerRed.withValues(alpha: 0.12),
        highlightColor: _dangerRed.withValues(alpha: 0.16),
      ),
    );
  }
}
