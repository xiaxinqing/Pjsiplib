part of '../../../main.dart';

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
    if (_focusedCallDetailId != null &&
        !uiState.calls.containsKey(_focusedCallDetailId)) {
      _focusedCallDetailId = null;
    }
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
                      if (primary.isConnected) ...[
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
                            label: Text(isConferencePaused ? '会议已暂停' : '三方通话'),
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
                      if (_showInCallDialpad && primary.isConnected) ...[
                        SizedBox(height: compact ? 16 : 22),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: _buildDtmfPad(primary, service),
                          ),
                        ),
                      ],
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
        ? '当前查看会议成员'
        : isActive
        ? '当前活动通话'
        : '当前查看通话';
    final subtitle = pendingLabel != null
        ? '$label · $pendingLabel'
        : isActive || isConferenceMember
        ? label
        : '$label · 如需接入声音，请点击恢复';
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
                '$title · $subtitle',
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
                '三方会议已自动保持，正在处理当前通话。处理完成后可恢复 $count 位会议成员。',
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
              const Text(
                '三方通话',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              _buildTooltipText(
                memberNames.isEmpty ? '${calls.length} 位成员' : memberNames,
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
                    label: paused ? '会议已暂停' : '会议中',
                    color: paused ? Colors.orange.shade700 : _brandGreen,
                  ),
                  _buildCallMetaStrip(
                    icon: AppIcons.person,
                    label: '${calls.length} 位客户',
                  ),
                  if (accountLabels.isNotEmpty)
                    _buildCallMetaStrip(
                      icon: AppIcons.line,
                      label: accountLabels.length == 1
                          ? accountLabels.first
                          : '${accountLabels.length} 条线路',
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
                    paused ? '会议状态' : '会议时长',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paused ? '已暂停' : _conferenceDurationLabel(calls),
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
              label: '${calls.length} 位成员',
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
    final name = match?.contact.name ?? _displayRemote(call.remoteUri);
    final number = match?.phone.number ?? _callDisplayNumber(call);
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
                  _buildTooltipText(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    number,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        _roundCallButton(
          icon: uiState.isMicrophoneMuted
              ? AppIcons.microphoneOff
              : AppIcons.microphone,
          label: uiState.isMicrophoneMuted ? '取消静音' : '静音',
          color: uiState.isMicrophoneMuted
              ? Colors.orange.shade700
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () =>
              service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
        ),
        _roundCallButton(
          icon: AppIcons.dialpad,
          label: '键盘',
          color: _showInCallDialpad
              ? _brandGreen
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: primary.isConnected ? () => _toggleInCallDialpad() : null,
        ),
        _roundCallButton(
          icon: uiState.isConferencePaused ? AppIcons.play : AppIcons.split,
          label: uiState.isConferencePaused ? '恢复会议' : '拆分',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: hasPendingOperation || isCoolingDown
              ? null
              : uiState.isConferencePaused
              ? () => _runConferenceAction(service.resumeConference)
              : calls.isEmpty
              ? null
              : () => _runConferenceActionAndFocus(
                  primary.callId,
                  '正在拆分',
                  () => service.splitConference(primary.callId),
                ),
        ),
        _roundCallButton(
          icon: AppIcons.tune,
          label: '音频',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () => _openSettingsDrawer(tabIndex: 1),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: '挂断全部',
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

  Widget _buildPrimaryCallSummary(
    CallInfo call,
    SipAccountInfo? account, {
    _CallContactMatch? contactMatch,
    required bool isIncoming,
  }) {
    final contact = contactMatch?.contact;
    final displayName = contact?.name ?? _displayRemote(call.remoteUri);
    final displayNumber = contact == null
        ? null
        : contactMatch?.phone.number ?? _callDisplayNumber(call);
    final organization = contact?.organizationLabel;
    final remark = contact?.remark.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTooltipText(
          displayName,
          maxLines: 2,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        if (displayNumber != null && displayNumber.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildTooltipText(
            displayNumber,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCallStatusPill(call),
            _buildCallMetaStrip(
              icon: isIncoming ? AppIcons.incoming : AppIcons.outgoing,
              label: isIncoming ? '来电' : '呼出',
            ),
            if (contact?.isFavorite == true)
              _buildCallMetaStrip(
                icon: AppIcons.favorite,
                label: '重点客户',
                color: _brandGreen,
              ),
            if (organization != null && organization != '未设置组织')
              _buildCallMetaStrip(
                icon: AppIcons.organization,
                label: organization,
              ),
          ],
        ),
        if (account != null) ...[
          const SizedBox(height: 10),
          _buildCallMetaStrip(
            icon: AppIcons.line,
            label: '${account.lineLabel} · ${account.transportLabel}',
          ),
        ],
        if (remark.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildCallMetaStrip(icon: AppIcons.note, label: remark),
        ],
        if (contact != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openCallContact(contact),
              icon: const Icon(AppIcons.person),
              label: const Text('查看联系人'),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ],
    );
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

  Widget _buildCallStatusPill(CallInfo call) {
    final color = _callStatusColor(call);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_callStatusIcon(call), size: _iconXs, color: color),
          const SizedBox(width: 6),
          Text(
            _plainCallStatusLabel(call),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallMetaStrip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final foreground = color ?? _textSecondary;
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: _subtlePanel,
          borderRadius: BorderRadius.circular(_radiusXs),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: _iconXs, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _callStatusIcon(CallInfo call) {
    if (call.isOnHold || call.isRemoteOnHold) return AppIcons.pause;
    if (call.isIncoming && !call.isConnected) return AppIcons.incoming;
    if (call.isConnected) return AppIcons.activity;
    return AppIcons.outgoing;
  }

  Color _callStatusColor(CallInfo call) {
    if (call.isOnHold || call.isRemoteOnHold) return Colors.orange.shade700;
    if (call.isIncoming && !call.isConnected) return _callGreen;
    if (call.isConnected) return _callGreen;
    if (call.state == 6) return _textSecondary;
    return _brandGreen;
  }

  String _plainCallStatusLabel(CallInfo call) {
    return call.statusLabel
        .replaceAll('⏸ ', '')
        .replaceAll('📲 ', '')
        .replaceAll('🔔 ', '')
        .replaceAll('📳 ', '')
        .replaceAll('🔗 ', '')
        .replaceAll('📞 ', '')
        .replaceAll('🔚 ', '');
  }

  _CallContactMatch? _callContactMatch(CallInfo call) {
    final normalizedNumber = normalizeContactPhoneNumber(
      _callDisplayNumber(call),
    );
    if (normalizedNumber.isEmpty) return null;

    for (final contact in ref.watch(contactBookProvider).contacts) {
      for (final phone in contact.phoneEntries) {
        if (normalizeContactPhoneNumber(phone.number) == normalizedNumber) {
          return _CallContactMatch(contact: contact, phone: phone);
        }
      }
    }
    return null;
  }

  String _callDisplayNumber(CallInfo call) {
    final remote = _displayRemote(call.remoteUri).trim();
    final normalized = normalizeContactPhoneNumber(remote);
    return normalized.isEmpty ? remote : normalized;
  }

  void _openCallContact(ContactEntry contact) {
    _selectContactDetail(contact.id);
    _selectSection(_WorkspaceSection.contacts);
  }

  Widget _buildPrimaryCallControls(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isConferenceMember = uiState.isInConference(call.callId);
    final hasPendingOperation = _hasPendingCallOperation(call.callId);
    final isCoolingDown = _isMediaBridgeActionCoolingDown;
    final controls = <Widget>[];

    if (call.isIncoming && !call.isConnected) {
      controls.addAll([
        _roundCallButton(
          icon: AppIcons.call,
          label: '接听',
          color: _callGreen,
          emphasized: true,
          onPressed: hasPendingOperation
              ? null
              : () => _answerCall(service, call.callId),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: '拒接',
          color: _dangerRed,
          onPressed: hasPendingOperation
              ? null
              : () => _rejectCall(service, call.callId),
        ),
      ]);
    } else {
      controls.addAll([
        _roundCallButton(
          icon: uiState.isMicrophoneMuted
              ? AppIcons.microphoneOff
              : AppIcons.microphone,
          label: uiState.isMicrophoneMuted ? '取消静音' : '静音',
          color: uiState.isMicrophoneMuted
              ? Colors.orange.shade700
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () =>
              service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
        ),
        _roundCallButton(
          icon: AppIcons.dialpad,
          label: '键盘',
          color: _showInCallDialpad
              ? _brandGreen
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected ? () => _toggleInCallDialpad() : null,
        ),
        _roundCallButton(
          icon: call.isOnHold ? AppIcons.play : AppIcons.pause,
          label: call.isOnHold ? '恢复' : '保持',
          color: call.isOnHold
              ? Colors.orange.shade700
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed:
              call.isConnected &&
                  !isConferenceMember &&
                  !hasPendingOperation &&
                  !isCoolingDown
              ? () => call.isOnHold
                    ? _runMediaBridgeActionAndFocus(
                        call.callId,
                        '正在恢复',
                        () => service.unholdCall(call.callId),
                      )
                    : _runMediaBridgeActionAndFocus(
                        call.callId,
                        '正在保持',
                        () => service.holdCall(call.callId),
                      )
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
          onPressed: hasPendingOperation
              ? null
              : () => _hangupCall(service, call.callId),
        ),
      ]);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
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
      width: 76,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 64,
            child: Center(
              child: _AnimatedIconButton(
                icon: icon,
                color: color,
                onPressed: onPressed,
                emphasized: emphasized,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return button;
  }

  Widget _buildLiveCallsPanel(
    PjsipUIState uiState,
    PjsipService service, {
    Widget? emptyContent,
  }) {
    final calls = _sortedLiveCalls(uiState.calls.values, uiState);
    final conferenceCalls = _conferenceCalls(uiState);
    final focusedCall = _primaryCall(uiState);
    final standaloneCalls = calls
        .where((call) => !uiState.isInConference(call.callId))
        .toList();
    final hasStandaloneIncoming = standaloneCalls.any(
      (call) => call.isIncoming && !call.isConnected,
    );
    final panelTitle = uiState.hasConference ? '会议成员' : '当前通话';
    final panelCount = uiState.hasConference
        ? '${conferenceCalls.length}/${calls.length} 路'
        : '${calls.length}/4 路';
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
                Expanded(
                  child: Text(
                    panelTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (calls.isNotEmpty) ...[
                  Text(
                    panelCount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (uiState.isConferencePaused)
                  TextButton.icon(
                    onPressed: _isConferenceActionCoolingDown
                        ? null
                        : () => _runConferenceAction(service.resumeConference),
                    icon: const Icon(AppIcons.play),
                    label: const Text('恢复会议'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: calls.isEmpty
                  ? emptyContent ?? _buildCallsIdleContext(service)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (uiState.hasConference) ...[
                            _buildCallPanelGroupLabel(
                              uiState.isConferencePaused ? '会议已暂停' : '会议中',
                            ),
                            const SizedBox(height: 8),
                            for (
                              var index = 0;
                              index < conferenceCalls.length;
                              index++
                            ) ...[
                              _buildCallListTile(
                                conferenceCalls[index],
                                uiState,
                                service,
                              ),
                              if (index != conferenceCalls.length - 1)
                                const SizedBox(height: 8),
                            ],
                            if (standaloneCalls.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildCallPanelGroupLabel(
                                hasStandaloneIncoming ? '新来电 / 其他通话' : '其他通话',
                              ),
                              const SizedBox(height: 8),
                              for (
                                var index = 0;
                                index < standaloneCalls.length;
                                index++
                              ) ...[
                                _buildCallListTile(
                                  standaloneCalls[index],
                                  uiState,
                                  service,
                                ),
                                if (index != standaloneCalls.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          ] else ...[
                            for (
                              var index = 0;
                              index < calls.length;
                              index++
                            ) ...[
                              _buildCallListTile(
                                calls[index],
                                uiState,
                                service,
                              ),
                              if (index != calls.length - 1)
                                const SizedBox(height: 8),
                            ],
                          ],
                          const SizedBox(height: 12),
                          if (uiState.hasConference)
                            _buildConferenceCustomerContext(
                              conferenceCalls,
                              uiState,
                              service,
                            )
                          else
                            _buildCallCustomerContext(
                              focusedCall ?? calls.first,
                              service,
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<CallInfo> _sortedLiveCalls(
    Iterable<CallInfo> calls,
    PjsipUIState uiState,
  ) {
    final result = calls.toList();
    result.sort((a, b) {
      final priority = _liveCallSortPriority(
        a,
        uiState,
      ).compareTo(_liveCallSortPriority(b, uiState));
      if (priority != 0) return priority;
      return b.startedAt.compareTo(a.startedAt);
    });
    return result;
  }

  int _liveCallSortPriority(CallInfo call, PjsipUIState uiState) {
    if (call.isIncoming && !call.isConnected) return 0;
    if (uiState.activeCallId == call.callId) return 1;
    if (_focusedCallDetailId == call.callId) return 2;
    if (uiState.isInConference(call.callId)) return 3;
    if (call.isConnected && !call.isOnHold && !call.isRemoteOnHold) return 4;
    if (call.isOnHold || call.isRemoteOnHold) return 5;
    return 6;
  }

  Widget _buildCallPanelGroupLabel(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: _softBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider(color: _softBorder)),
      ],
    );
  }

  Widget _buildCallsIdleContext(PjsipService service) {
    if (_isRunningWidgetTest) {
      return Center(
        child: Text('没有活动通话', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return SingleChildScrollView(
      child: _buildCallContextSection(
        icon: AppIcons.history,
        title: '最近通话',
        child: StreamBuilder<List<CallHistoryEntry>>(
          stream: _watchCallsIdleRecentHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final entries = snapshot.data ?? const <CallHistoryEntry>[];
            if (entries.isEmpty) {
              return _buildCallContextEmpty('暂无最近通话');
            }

            return Column(
              children: [
                for (var index = 0; index < entries.length; index++) ...[
                  _buildCallsIdleRecentRow(entries[index], service),
                  if (index != entries.length - 1) const Divider(height: 1),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCallCustomerContext(CallInfo call, PjsipService service) {
    final match = _callContactMatch(call);
    final contact = match?.contact;
    final number = match?.phone.number ?? _callDisplayNumber(call);
    final contextLabel = _callContextTargetLabel(call, match);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCallContextFollowerLabel(contextLabel),
        const SizedBox(height: 8),
        if (contact == null)
          _buildUnknownCallCustomerCard(number, contextLabel)
        else
          _buildCallCustomerCard(contact, match?.phone, contextLabel),
        const SizedBox(height: 12),
        _buildCallNoteSection(call, service, contextLabel),
        const SizedBox(height: 12),
        _buildCallRecentHistorySection(contact, number, contextLabel),
      ],
    );
  }

  Widget _buildConferenceCustomerContext(
    List<CallInfo> calls,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final focused = _primaryCall(uiState);
    final primary = focused == null || !uiState.isInConference(focused.callId)
        ? (calls.isEmpty ? null : calls.first)
        : focused;
    final primaryLabel = primary == null
        ? ''
        : _callContextTargetLabel(primary, _callContactMatch(primary));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCallContextFollowerLabel('会议通话 · ${calls.length} 位客户'),
        const SizedBox(height: 8),
        _buildCallContextSection(
          icon: AppIcons.contacts,
          title: '会议客户',
          subtitle: '合并通话中的客户',
          child: Column(
            children: [
              for (var index = 0; index < calls.length; index++) ...[
                _buildConferenceCustomerRow(calls[index]),
                if (index != calls.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
        if (primary != null) ...[
          const SizedBox(height: 12),
          _buildConferenceNoteSection(calls, primary, service, primaryLabel),
        ],
      ],
    );
  }

  Widget _buildConferenceCustomerRow(CallInfo call) {
    final match = _callContactMatch(call);
    final contact = match?.contact;
    final phone = match?.phone;
    final number = phone?.number ?? _callDisplayNumber(call);
    final statusColor = _callStatusColor(call);
    final title = contact?.name ?? '未匹配联系人';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            foregroundColor: statusColor,
            child: Text(contact?.initials ?? _avatarText(call.remoteUri)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipText(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                _buildTooltipText(
                  phone == null ? number : '${phone.label} · $number',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (contact == null)
            IconButton(
              tooltip: number.isEmpty ? '未知号码' : '添加到联系人',
              onPressed: number.isEmpty
                  ? null
                  : () => unawaited(_showContactDialog(initialNumber: number)),
              icon: const Icon(AppIcons.contactAdd),
              color: _brandGreen,
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                hoverColor: _brandGreen.withValues(alpha: 0.08),
                highlightColor: _brandGreen.withValues(alpha: 0.12),
              ),
            )
          else
            IconButton(
              tooltip: '查看联系人',
              onPressed: () => _openCallContact(contact),
              icon: const Icon(AppIcons.next),
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                hoverColor: _hoverPanel,
                highlightColor: _hoverPanel,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallContextFollowerLabel(String label) {
    return Row(
      children: [
        Icon(AppIcons.pointer, size: _iconXs, color: _textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTooltipText(
            '跟随主通话：$label',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallNoteSection(
    CallInfo call,
    PjsipService service,
    String contextLabel, {
    String title = '当前通话备注',
  }) {
    _syncCallNoteController(call, service);
    return _buildCallContextSection(
      icon: AppIcons.note,
      title: title,
      subtitle: contextLabel,
      trailing: _buildCallNoteStatusBadge(
        _callNoteController.text.trim().isEmpty ? '未填写' : '已暂存',
      ),
      child: TextField(
        controller: _callNoteController,
        minLines: 3,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        onChanged: (value) {
          service.setCallNote(call.callId, value);
          _refreshCallNoteState();
        },
        decoration: const InputDecoration(hintText: '记录本次沟通重点，挂断后保存到通话记录'),
      ),
    );
  }

  Widget _buildConferenceNoteSection(
    List<CallInfo> calls,
    CallInfo primary,
    PjsipService service,
    String primaryLabel,
  ) {
    final callIds = calls.map((call) => call.callId).toSet();
    final isSharedMode = _callNoteMode == _CallNoteMode.conference;
    _syncConferenceNoteController(calls, primary, service);

    return _buildCallContextSection(
      icon: AppIcons.note,
      title: '本次会议备注',
      subtitle: isSharedMode
          ? '同步到 ${calls.length} 位会议成员'
          : '只保存到会议主记录：$primaryLabel',
      trailing: _buildCallNoteStatusBadge(
        _callNoteController.text.trim().isEmpty ? '未填写' : '已暂存',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_CallNoteMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<_CallNoteMode>(
                value: _CallNoteMode.customer,
                icon: Icon(AppIcons.person),
                label: Text('当前客户备注'),
              ),
              ButtonSegment<_CallNoteMode>(
                value: _CallNoteMode.conference,
                icon: Icon(AppIcons.contacts),
                label: Text('会议共享备注'),
              ),
            ],
            selected: {_callNoteMode},
            onSelectionChanged: (selection) {
              _setCallNoteMode(selection.first);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _callNoteController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              if (_callNoteMode == _CallNoteMode.conference) {
                service.setSharedConferenceNote(callIds, value);
              } else {
                service.setCallNote(primary.callId, value);
              }
              _refreshCallNoteState();
            },
            decoration: InputDecoration(
              hintText: isSharedMode
                  ? '记录会议共同结论，会保存到每位会议成员的通话记录'
                  : '记录当前客户重点，只保存到会议主记录',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallNoteStatusBadge(String label) {
    final filled = label != '未填写';
    final color = filled ? _brandGreen : _textSecondary;
    return Tooltip(
      message: filled ? '备注已暂存在当前通话，挂断后写入通话记录' : '填写后会暂存，挂断后写入通话记录',
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: filled ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(_radiusXs),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filled ? AppIcons.save : AppIcons.note, size: _iconXs),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncCallNoteController(CallInfo call, PjsipService service) {
    final key = 'call:${call.callId}';
    if (_callNoteControllerKey == key) return;
    _callNoteControllerKey = key;
    final note = service.callNote(call.callId);
    _callNoteController.value = TextEditingValue(
      text: note,
      selection: TextSelection.collapsed(offset: note.length),
    );
  }

  void _syncConferenceNoteController(
    List<CallInfo> calls,
    CallInfo primary,
    PjsipService service,
  ) {
    final callIds = calls.map((call) => call.callId).toList()..sort();
    final key = _callNoteMode == _CallNoteMode.conference
        ? 'conference:${callIds.join(',')}'
        : 'call:${primary.callId}';
    if (_callNoteControllerKey == key) return;
    _callNoteControllerKey = key;
    final note = _callNoteMode == _CallNoteMode.conference
        ? service.sharedConferenceNote(callIds)
        : service.callNote(primary.callId);
    _callNoteController.value = TextEditingValue(
      text: note,
      selection: TextSelection.collapsed(offset: note.length),
    );
  }

  Widget _buildCallCustomerCard(
    ContactEntry contact,
    ContactPhoneEntry? phone,
    String contextLabel,
  ) {
    final organization = contact.organizationLabel;
    final remark = contact.remark.trim();
    return _buildCallContextSection(
      icon: AppIcons.person,
      title: '当前客户',
      subtitle: contextLabel,
      trailing: TextButton.icon(
        onPressed: () => _openCallContact(contact),
        icon: const Icon(AppIcons.next),
        label: const Text('详情'),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: contact.isFavorite ? _brandGreen : _hoverPanel,
                foregroundColor: contact.isFavorite
                    ? Colors.white
                    : _textPrimary,
                child: Text(contact.initials),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTooltipText(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      phone == null
                          ? contact.number
                          : '${phone.label} · ${phone.number}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (contact.isFavorite)
                _buildCallMetaStrip(
                  icon: AppIcons.favorite,
                  label: '重点客户',
                  color: _brandGreen,
                ),
              if (organization != '未设置组织')
                _buildCallMetaStrip(
                  icon: AppIcons.organization,
                  label: organization,
                ),
              if (remark.isNotEmpty)
                _buildCallMetaStrip(icon: AppIcons.note, label: remark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownCallCustomerCard(String number, String contextLabel) {
    return _buildCallContextSection(
      icon: AppIcons.person,
      title: '当前号码',
      subtitle: contextLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _hoverPanel,
                foregroundColor: _textSecondary,
                child: Text(number.isEmpty ? '?' : number.characters.first),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '未匹配联系人',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      number.isEmpty ? '未知号码' : number,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: number.isEmpty
                ? null
                : () => unawaited(_showContactDialog(initialNumber: number)),
            icon: const Icon(AppIcons.contactAdd),
            label: const Text('添加到联系人'),
          ),
        ],
      ),
    );
  }

  Widget _buildCallRecentHistorySection(
    ContactEntry? contact,
    String number,
    String contextLabel,
  ) {
    return _buildCallContextSection(
      icon: AppIcons.history,
      title: '最近通话',
      subtitle: contextLabel,
      child: _isRunningWidgetTest
          ? _buildCallContextEmpty('暂无通话记录')
          : StreamBuilder<List<CallHistoryEntry>>(
              stream: _watchCallContextHistory(
                contact: contact,
                number: number,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final entries = snapshot.data ?? const <CallHistoryEntry>[];
                if (entries.isEmpty) {
                  return _buildCallContextEmpty('暂无通话记录');
                }

                return Column(
                  children: [
                    for (var index = 0; index < entries.length; index++) ...[
                      _buildCallContextHistoryRow(entries[index]),
                      if (index != entries.length - 1) const Divider(height: 1),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCallContextSection({
    required IconData icon,
    required String title,
    required Widget child,
    String? subtitle,
    Widget? trailing,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        _buildTooltipText(
                          subtitle!.trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  String _callContextTargetLabel(CallInfo call, _CallContactMatch? match) {
    final contact = match?.contact;
    final number = match?.phone.number ?? _callDisplayNumber(call);
    if (contact == null) {
      return number.isEmpty ? _displayRemote(call.remoteUri) : number;
    }
    final contactName = contact.name.trim();
    if (number.trim().isEmpty) return contactName;
    return '$contactName · $number';
  }

  Widget _buildCallContextEmpty(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCallContextHistoryRow(CallHistoryEntry entry) {
    final item = _persistedHistoryItem(entry);
    final color = _historyItemColor(item);
    final timeLabel = _formatCallContextHistoryTime(item.startedAt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildCallContextHistoryIcon(item, color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipText(
                  '${item.direction.label} · ${item.statusLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                _buildTooltipText(
                  '$timeLabel · ${_formatHistoryDuration(item)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsIdleRecentRow(
    CallHistoryEntry entry,
    PjsipService service,
  ) {
    final item = _persistedHistoryItem(entry);
    final color = _historyItemColor(item);
    final title = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : item.phoneNumber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildCallContextHistoryIcon(item, color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipText(
                  title.isEmpty ? item.remoteUri : title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                _buildTooltipText(
                  '${item.statusLabel} · ${_formatCallContextHistoryTime(item.startedAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: item.phoneNumber.trim().isEmpty
                ? '没有可回拨号码'
                : '回拨 ${item.phoneNumber}',
            onPressed: item.phoneNumber.trim().isEmpty
                ? null
                : () => _callHistoryItem(item, service),
            icon: const Icon(AppIcons.call),
            color: _callGreen,
            style: IconButton.styleFrom(
              backgroundColor: _panelBackground,
              hoverColor: _callGreen.withValues(alpha: 0.08),
              highlightColor: _callGreen.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallContextHistoryIcon(_HistoryItem item, Color color) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Icon(
        item.direction == CallHistoryDirection.inbound
            ? AppIcons.incoming
            : AppIcons.outgoing,
        size: _iconSm,
        color: color,
      ),
    );
  }

  Stream<List<CallHistoryEntry>> _watchCallsIdleRecentHistory() {
    return _callsIdleRecentHistoryStream ??= ref
        .read(callHistoryDatabaseProvider)
        .watchRecent(limit: 5);
  }

  Stream<List<CallHistoryEntry>> _watchCallContextHistory({
    required ContactEntry? contact,
    required String number,
  }) {
    final phoneNumbers =
        contact?.phoneEntries.map((phone) => phone.number).toList() ??
        const <String>[];
    final phoneSignature = contact == null
        ? normalizeContactPhoneNumber(number)
        : phoneNumbers.join('|');
    if (_callContextHistoryStream == null ||
        _callContextHistoryContactId != contact?.id ||
        _callContextHistoryPhoneNumber != phoneSignature) {
      _callContextHistoryContactId = contact?.id;
      _callContextHistoryPhoneNumber = phoneSignature;
      final database = ref.read(callHistoryDatabaseProvider);
      _callContextHistoryStream = contact == null
          ? database.watchRecent(keyword: phoneSignature, limit: 3)
          : database.watchRecentForContact(
              contactId: contact.id,
              phoneNumber: contact.number,
              phoneNumbers: phoneNumbers,
              limit: 3,
            );
    }
    return _callContextHistoryStream!;
  }

  String _formatCallContextHistoryTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return DateFormat('HH:mm').format(time);
    if (diff == 1) return '昨天 ${DateFormat('HH:mm').format(time)}';
    return DateFormat('M/d HH:mm').format(time);
  }

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
    final statusColor = _callStatusColor(call);
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
                            if (pendingLabel != null) ...[
                              const SizedBox(width: 6),
                              _buildCallTinyBadge(
                                pendingLabel,
                                Colors.orange.shade700,
                              ),
                            ],
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
                              _callStatusIcon(call),
                              size: _iconXs,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              call.isConnected
                                  ? call.durationLabel
                                  : _plainCallStatusLabel(call),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: call.isConnected
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
              if (call.isConnected && (isActive || isConferenceMember)) ...[
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
                        label: call.isOnHold ? '恢复' : '保持',
                        active: call.isOnHold,
                        activeColor: Colors.orange.shade700,
                        onPressed: hasPendingOperation || isCoolingDown
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

class _CallContactMatch {
  const _CallContactMatch({required this.contact, required this.phone});

  final ContactEntry contact;
  final ContactPhoneEntry phone;
}

class _DialpadAvailabilityStatus {
  const _DialpadAvailabilityStatus(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

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
        iconSize: 24,
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color.computeLuminance() > 0.45
              ? Colors.black87
              : Colors.white,
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
