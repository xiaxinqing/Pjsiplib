part of '../../../../../main.dart';

/// 主舞台身份区：负责联系人/号码头像、名称、号码和安全标签展示。
extension _CallStageIdentity on _MyHomePageState {
  Widget _buildPrimaryCallSummary(
    CallInfo call,
    SipAccountInfo? account, {
    _CallContactMatch? contactMatch,
    required bool isIncoming,
  }) {
    final contact = contactMatch?.contact;
    final identity = _callDisplayIdentity(call, contactMatch);
    final quality = _callQualityView(call, account);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCallIdentityLine(
          identity,
          primaryStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
          secondaryStyle:
              (Theme.of(context).textTheme.bodyLarge ?? const TextStyle())
                  .copyWith(color: _textSecondary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCallStatusPill(call),
            _buildCallMetaStrip(
              icon: quality.icon,
              label: quality.compactLabel,
              color: quality.color,
              tooltip: quality.tooltip,
            ),
            if (contact?.isFavorite == true)
              _buildCallIconBadge(
                icon: AppIcons.favorite,
                color: _brandGreen,
                tooltip: context.l10n.activeCallPriorityContact,
              ),
          ],
        ),
      ],
    );
  }

  _CallDisplayIdentity _callDisplayIdentity(
    CallInfo call, [
    _CallContactMatch? match,
  ]) {
    final number = (match?.phone.number ?? _callDisplayNumber(call)).trim();
    final contactName = match?.contact.name.trim() ?? '';

    if (contactName.isEmpty) {
      final fallback = number.isNotEmpty
          ? number
          : _displayRemote(call.remoteUri).trim();
      return _CallDisplayIdentity(
        primary: fallback.isEmpty ? call.remoteUri : fallback,
      );
    }

    final hasDistinctNumber =
        number.isNotEmpty && number.toLowerCase() != contactName.toLowerCase();
    return _CallDisplayIdentity(
      primary: contactName,
      secondary: hasDistinctNumber ? number : null,
    );
  }

  Widget _buildCallIdentityLine(
    _CallDisplayIdentity identity, {
    required TextStyle primaryStyle,
    required TextStyle secondaryStyle,
  }) {
    final secondary = identity.secondary;
    return Tooltip(
      message: identity.tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Text.rich(
        TextSpan(
          text: identity.primary,
          style: primaryStyle,
          children: secondary == null
              ? const <InlineSpan>[]
              : <InlineSpan>[
                  TextSpan(text: '  ·  $secondary', style: secondaryStyle),
                ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
    String? tooltip,
  }) {
    final foreground = color ?? _textSecondary;
    return Tooltip(
      message: tooltip ?? label,
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

  Widget _buildCallIconBadge({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(_radiusXs),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, size: _iconXs, color: color),
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
    return ActiveCallLocalizer.status(context.l10n, call);
  }

  _LiveCallVisualState _liveCallVisualState(
    CallInfo call,
    PjsipUIState uiState,
    _CallOperationType? pendingOperation,
  ) {
    if (pendingOperation != null) {
      final pendingLabel = pendingOperation.localizedLabel(context.l10n);
      final isDanger =
          pendingOperation == _CallOperationType.hangup ||
          pendingOperation == _CallOperationType.reject;
      final color = isDanger
          ? _dangerRed
          : pendingOperation == _CallOperationType.answer
          ? _callGreen
          : Colors.orange.shade700;
      return _LiveCallVisualState(
        label: pendingLabel,
        detail: pendingLabel,
        icon: pendingOperation == _CallOperationType.transfer
            ? AppIcons.route
            : pendingOperation == _CallOperationType.answer
            ? AppIcons.call
            : AppIcons.activity,
        color: color,
        emphasizeDetail: true,
      );
    }
    if (call.isIncoming && !call.isConnected) {
      return _LiveCallVisualState(
        label: context.l10n.activeCallStatusIncoming,
        detail: context.l10n.activeCallStatusWaitingAnswer,
        icon: AppIcons.incoming,
        color: _callGreen,
        emphasizeDetail: true,
      );
    }
    if (uiState.isInConference(call.callId)) {
      final paused = uiState.isConferencePaused;
      return _LiveCallVisualState(
        label: paused
            ? context.l10n.activeCallConferencePaused
            : context.l10n.activeCallConferenceInProgress,
        detail: paused
            ? context.l10n.activeCallConferencePaused
            : call.durationLabel,
        icon: paused ? AppIcons.pause : AppIcons.contacts,
        color: paused ? Colors.orange.shade700 : _callGreen,
        emphasizeDetail: paused,
      );
    }
    if (call.isOnHold) {
      return _LiveCallVisualState(
        label: context.l10n.activeCallStatusLocalHold,
        detail: context.l10n.activeCallHeldLocallyFor(call.durationLabel),
        icon: AppIcons.pause,
        color: Colors.orange.shade700,
        emphasizeDetail: true,
      );
    }
    if (call.isRemoteOnHold) {
      return _LiveCallVisualState(
        label: context.l10n.activeCallStatusRemoteHold,
        detail: context.l10n.activeCallHeldByRemoteFor(call.durationLabel),
        icon: AppIcons.pause,
        color: Colors.orange.shade700,
        emphasizeDetail: true,
      );
    }
    if (call.isConnected) {
      return _LiveCallVisualState(
        label: context.l10n.activeCallStatusInCall,
        detail: call.durationLabel,
        icon: AppIcons.activity,
        color: _callGreen,
      );
    }
    return _LiveCallVisualState(
      label: _plainCallStatusLabel(call),
      detail: _plainCallStatusLabel(call),
      icon: AppIcons.outgoing,
      color: _brandGreen,
      emphasizeDetail: true,
    );
  }

  _CallQualityView _callQualityView(CallInfo call, SipAccountInfo? account) {
    final mediaStatus = call.mediaStatus;
    final mediaLabel = ActiveCallLocalizer.mediaStatus(context.l10n, call);

    final mediaReady = mediaStatus == 1;
    final mediaProblem =
        call.isConnected && (mediaStatus == 0 || mediaStatus == 4);
    final mediaPending =
        mediaStatus == null || (!call.isConnected && mediaStatus == 0);
    final mediaColor = mediaProblem
        ? _dangerRed
        : mediaReady
        ? _callGreen
        : mediaPending
        ? _textSecondary
        : Colors.orange.shade700;

    final signalingLabel =
        account?.transport.label ?? context.l10n.activeCallSignalingUnknown;
    final signalingSecure = account?.transport.isSecure == true;
    final configuredMode = account?.mediaSecurity.mode;
    final actualSrtp = call.mediaSecurity?.hasSrtpTransport;
    final mediaSecurityLabel = switch (actualSrtp) {
      true => configuredMode?.usesSrtp == true ? configuredMode!.label : 'SRTP',
      false => 'RTP',
      null =>
        configuredMode?.usesSrtp == true
            ? context.l10n.activeCallConfiguredMode(configuredMode!.label)
            : 'RTP',
    };
    final stack = call.mediaSecurity?.transportStack ?? const <String>[];
    final securityLabel = ActiveCallLocalizer.securityStatus(
      context.l10n,
      signalingEncrypted: signalingSecure,
      audioEncrypted: actualSrtp,
      encryptionConfigured: configuredMode?.usesSrtp == true,
    );
    final icon = mediaReady
        ? actualSrtp == true
              ? AppIcons.security
              : AppIcons.call
        : AppIcons.activity;
    final label = mediaReady ? securityLabel : mediaLabel;
    final compactLabel = mediaReady ? securityLabel : mediaLabel;
    final signalingValue = signalingSecure
        ? context.l10n.activeCallValueDetail(
            signalingLabel,
            context.l10n.activeCallTlsEncrypted,
          )
        : signalingLabel;
    final mediaSecurityDetail = actualSrtp == true
        ? context.l10n.activeCallSrtpNegotiated
        : actualSrtp == false
        ? context.l10n.activeCallSrtpNotDetected
        : context.l10n.activeCallMediaNegotiating;
    final tooltip = [
      context.l10n.activeCallLabeledValue(
        context.l10n.activeCallMedia,
        mediaLabel,
      ),
      context.l10n.activeCallLabeledValue(
        context.l10n.activeCallSignaling,
        signalingValue,
      ),
      context.l10n.activeCallLabeledValue(
        context.l10n.activeCallMediaEncryption,
        context.l10n.activeCallValueDetail(
          mediaSecurityLabel,
          mediaSecurityDetail,
        ),
      ),
      if (stack.isNotEmpty)
        context.l10n.activeCallLabeledValue(
          context.l10n.activeCallTransport,
          stack.join(' / '),
        ),
    ].join('\n');

    return _CallQualityView(
      label: label,
      compactLabel: compactLabel,
      tooltip: tooltip,
      color: mediaColor,
      icon: icon,
    );
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
    unawaited(
      _showContactPreviewDialog(
        contact: contact,
        showOpenContactPageAction: true,
      ),
    );
  }
}
