part of '../../../../../main.dart';

/// 通话主舞台：负责展示当前聚焦通话、会议提示、状态面板和操作区。
extension _HomeCallStage on _MyHomePageState {
  Widget _buildPrimaryCallStage(PjsipUIState uiState, PjsipService service) {
    if (_focusedCallDetailId != null &&
        !uiState.calls.containsKey(_focusedCallDetailId)) {
      _focusedCallDetailId = null;
    }
    final primary = _primaryCall(uiState);
    if (primary == null) {
      return _buildEmptyState(
        icon: AppIcons.call,
        title: context.l10n.activeCallEmpty,
        action: FilledButton.icon(
          onPressed: () => _selectSection(_WorkspaceSection.dialpad),
          icon: const Icon(AppIcons.dialpad),
          label: Text(context.l10n.activeCallGoToDialpad),
        ),
      );
    }

    final isConferenceMember = uiState.isInConference(primary.callId);
    final isConferencePaused = uiState.isConferencePaused;
    final showConferenceStage = uiState.hasConference && isConferenceMember;
    final conferenceCalls = _conferenceCalls(uiState);
    final isIncoming = primary.isIncoming && !primary.isConnected;
    final account = uiState.accountForCall(primary);
    final statusColor = _callStatusColor(primary);
    final contactMatch = _callContactMatch(primary);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 620;
          final avatarSize = compact ? 104.0 : 132.0;
          final topInset = compact ? 20.0 : 44.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, topInset, 28, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > topInset + 28
                    ? constraints.maxHeight - topInset - 28
                    : 0,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFocusedCallBanner(primary, uiState),
                      if (uiState.isConferencePaused &&
                          !uiState.isInConference(primary.callId)) ...[
                        const SizedBox(height: 8),
                        _buildConferenceInterruptedBanner(uiState),
                      ],
                      SizedBox(height: compact ? 14 : 18),
                      if (showConferenceStage)
                        _buildConferenceHero(
                          conferenceCalls,
                          uiState,
                          avatarSize: avatarSize,
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _CallAvatar(
                              label:
                                  contactMatch?.contact.initials ??
                                  _avatarText(primary.remoteUri),
                              isIncoming: isIncoming,
                              size: avatarSize,
                            ),
                            SizedBox(width: compact ? 16 : 22),
                            Expanded(
                              child: _buildPrimaryCallSummary(
                                primary,
                                account,
                                contactMatch: contactMatch,
                                isIncoming: isIncoming,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: compact ? 18 : 24),
                      if (showConferenceStage)
                        _buildConferenceStatePanel(conferenceCalls, uiState)
                      else
                        _buildCallStatePanel(primary, statusColor),
                      if (uiState.hasAudioDeviceIssue) ...[
                        SizedBox(height: compact ? 12 : 14),
                        _buildCallAudioIssueBanner(uiState),
                      ],
                      if (_shouldShowCallAudioMeters(primary, uiState)) ...[
                        SizedBox(height: compact ? 12 : 14),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _subtlePanel,
                            borderRadius: BorderRadius.circular(_radiusSm),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: _buildCallAudioMeters(
                              uiState,
                              service,
                              compact: compact,
                            ),
                          ),
                        ),
                      ],
                      if (showConferenceStage) ...[
                        SizedBox(height: compact ? 12 : 14),
                        _buildConferenceMemberPreview(conferenceCalls, uiState),
                      ] else if (isConferenceMember) ...[
                        SizedBox(height: compact ? 12 : 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            avatar: Icon(
                              isConferencePaused
                                  ? AppIcons.pause
                                  : AppIcons.contacts,
                            ),
                            label: Text(
                              isConferencePaused
                                  ? context.l10n.activeCallConferencePaused
                                  : context.l10n.activeCallConferenceTitle,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? 18 : 24),
                      showConferenceStage
                          ? _buildConferenceControls(
                              primary,
                              conferenceCalls,
                              uiState,
                              service,
                            )
                          : _buildPrimaryCallControls(
                              primary,
                              uiState,
                              service,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<CallInfo> _conferenceCalls(PjsipUIState uiState) {
    return [
      for (final callId in uiState.conferenceCallIds)
        if (uiState.calls[callId] != null) uiState.calls[callId]!,
    ];
  }

  Widget _buildFocusedCallBanner(CallInfo call, PjsipUIState uiState) {
    final label = _callContextTargetLabel(call, _callContactMatch(call));
    final pendingLabel = _callOperationLabel(call.callId);
    final isConferenceMember = uiState.isInConference(call.callId);
    final isActive = uiState.activeCallId == call.callId;
    final title = isConferenceMember
        ? context.l10n.activeCallViewingConferenceMember
        : isActive
        ? context.l10n.activeCallCurrentActiveCall
        : context.l10n.activeCallViewingCall;
    final subtitle = isActive || isConferenceMember
        ? pendingLabel
        : pendingLabel ?? context.l10n.activeCallResumeForAudio(label);
    final text = subtitle == null ? title : '$title · $subtitle';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(
              isConferenceMember
                  ? AppIcons.contacts
                  : isActive
                  ? AppIcons.activity
                  : AppIcons.pointer,
              size: _iconSm,
              color: isActive || isConferenceMember
                  ? _brandGreen
                  : _textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTooltipText(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceInterruptedBanner(PjsipUIState uiState) {
    final count = uiState.conferenceCallIds.length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.orange.shade700.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(
          color: Colors.orange.shade700.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(AppIcons.pause, size: _iconSm, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.activeCallConferenceInterrupted(count),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceHero(
    List<CallInfo> calls,
    PjsipUIState uiState, {
    required double avatarSize,
  }) {
    final paused = uiState.isConferencePaused;
    final memberNames = calls
        .map((call) => _callParticipantLabel(call))
        .where((label) => label.trim().isNotEmpty)
        .join('、');
    final accountLabels = calls
        .map(uiState.accountForCall)
        .whereType<SipAccountInfo>()
        .map((account) => '${account.lineLabel} · ${account.transportLabel}')
        .toSet()
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ConferenceAvatar(
          size: avatarSize,
          memberCount: calls.length,
          paused: paused,
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.activeCallConferenceTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              _buildTooltipText(
                memberNames.isEmpty
                    ? context.l10n.activeCallMemberCount(calls.length)
                    : memberNames,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildCallMetaStrip(
                    icon: paused ? AppIcons.pause : AppIcons.contacts,
                    label: paused
                        ? context.l10n.activeCallConferencePaused
                        : context.l10n.activeCallConferenceInProgress,
                    color: paused ? Colors.orange.shade700 : _brandGreen,
                  ),
                  _buildCallMetaStrip(
                    icon: AppIcons.person,
                    label: context.l10n.activeCallCustomerCount(calls.length),
                  ),
                  if (accountLabels.isNotEmpty)
                    _buildCallMetaStrip(
                      icon: AppIcons.line,
                      label: accountLabels.length == 1
                          ? accountLabels.first
                          : context.l10n.activeCallLineCount(
                              accountLabels.length,
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConferenceStatePanel(
    List<CallInfo> calls,
    PjsipUIState uiState,
  ) {
    final paused = uiState.isConferencePaused;
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
              paused ? AppIcons.pause : AppIcons.activity,
              size: _iconLg,
              color: paused ? Colors.orange.shade700 : _callGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paused
                        ? context.l10n.activeCallConferenceStatus
                        : context.l10n.activeCallConferenceDuration,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paused
                        ? context.l10n.activeCallPaused
                        : _conferenceDurationLabel(calls),
                    style: TextStyle(
                      fontSize: paused ? 28 : 38,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            _buildCallMetaStrip(
              icon: AppIcons.contacts,
              label: context.l10n.activeCallMemberCount(calls.length),
              color: paused ? Colors.orange.shade700 : _brandGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceMemberPreview(
    List<CallInfo> calls,
    PjsipUIState uiState,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumn = constraints.maxWidth < 460;
        final children = [
          for (final call in calls)
            _buildConferenceMemberPreviewTile(call, uiState),
        ];
        if (useColumn) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _buildConferenceMemberPreviewTile(
    CallInfo call,
    PjsipUIState uiState,
  ) {
    final match = _callContactMatch(call);
    final account = uiState.accountForCall(call);
    final identity = _callDisplayIdentity(call, match);
    final statusColor = _callStatusColor(call);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              foregroundColor: statusColor,
              child: Text(
                match?.contact.initials ?? _avatarText(call.remoteUri),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCallIdentityLine(
                    identity,
                    primaryStyle: const TextStyle(fontWeight: FontWeight.w800),
                    secondaryStyle:
                        (Theme.of(context).textTheme.bodySmall ??
                                const TextStyle())
                            .copyWith(
                              color: _textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  if (account != null) ...[
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      '${account.username} · ${account.transportLabel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceControls(
    CallInfo primary,
    List<CallInfo> calls,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final hasPendingOperation = _hasPendingCallOperation(primary.callId);
    final isCoolingDown = _isConferenceActionCoolingDown;
    final controls = Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        _roundCallButton(
          icon: uiState.isMicrophoneMuted
              ? AppIcons.microphoneOff
              : AppIcons.microphone,
          label: uiState.isMicrophoneMuted
              ? context.l10n.activeCallUnmute
              : context.l10n.activeCallMute,
          color: uiState.isMicrophoneMuted
              ? Colors.orange.shade700
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () =>
              service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
        ),
        _roundCallButton(
          icon: AppIcons.dialpad,
          label: context.l10n.activeCallKeypad,
          color: _showInCallDialpad
              ? _brandGreen
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: primary.isConnected ? () => _toggleInCallDialpad() : null,
        ),
        _roundCallButton(
          icon: uiState.isConferencePaused ? AppIcons.play : AppIcons.split,
          label: uiState.isConferencePaused
              ? context.l10n.activeCallResumeConference
              : context.l10n.activeCallSplit,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: hasPendingOperation || isCoolingDown
              ? null
              : uiState.isConferencePaused
              ? () => _runConferenceAction(service.resumeConference)
              : calls.isEmpty
              ? null
              : () => _runConferenceActionAndFocus(
                  primary.callId,
                  _CallOperationType.split,
                  () => service.splitConference(primary.callId),
                ),
        ),
        _roundCallButton(
          icon: AppIcons.tune,
          label: context.l10n.activeCallAudio,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () => _openSettingsDrawer(tabIndex: _settingsAudioIndex),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: context.l10n.activeCallHangUpAll,
          color: _dangerRed,
          onPressed: calls.isEmpty
              ? null
              : () {
                  for (final call in calls) {
                    _hangupCall(service, call.callId);
                  }
                },
        ),
      ],
    );
    return _buildCallControlsWithDtmfPad(primary, service, controls);
  }

  String _callParticipantLabel(CallInfo call) {
    final match = _callContactMatch(call);
    return match?.contact.name ?? _displayRemote(call.remoteUri);
  }

  String _conferenceDurationLabel(List<CallInfo> calls) {
    final connectedTimes = calls
        .map((call) => call.connectedAt)
        .whereType<DateTime>()
        .toList();
    if (connectedTimes.isEmpty) return '00:00';
    connectedTimes.sort();
    return _formatCallDuration(DateTime.now().difference(connectedTimes.first));
  }

  String _formatCallDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }
}
