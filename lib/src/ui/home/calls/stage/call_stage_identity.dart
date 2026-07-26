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
    final displayName = contact?.name ?? _displayRemote(call.remoteUri);
    final displayNumber = contact == null
        ? null
        : contactMatch?.phone.number ?? _callDisplayNumber(call);
    final quality = _callQualityView(call, account);
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
              icon: quality.icon,
              label: quality.compactLabel,
              color: quality.color,
              tooltip: quality.tooltip,
            ),
            if (contact?.isFavorite == true)
              _buildCallIconBadge(
                icon: AppIcons.favorite,
                color: _brandGreen,
                tooltip: '重点客户',
              ),
          ],
        ),
      ],
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
    return call.statusLabel
        .replaceAll('⏸ ', '')
        .replaceAll('📲 ', '')
        .replaceAll('🔔 ', '')
        .replaceAll('📳 ', '')
        .replaceAll('🔗 ', '')
        .replaceAll('📞 ', '')
        .replaceAll('🔚 ', '');
  }

  _LiveCallVisualState _liveCallVisualState(
    CallInfo call,
    PjsipUIState uiState,
    String? pendingLabel,
  ) {
    if (pendingLabel != null) {
      final color = pendingLabel.contains('挂断') || pendingLabel.contains('拒接')
          ? _dangerRed
          : pendingLabel.contains('接听')
          ? _callGreen
          : Colors.orange.shade700;
      return _LiveCallVisualState(
        label: pendingLabel,
        detail: pendingLabel,
        icon: pendingLabel.contains('转接')
            ? AppIcons.route
            : pendingLabel.contains('接听')
            ? AppIcons.call
            : AppIcons.activity,
        color: color,
        emphasizeDetail: true,
      );
    }
    if (call.isIncoming && !call.isConnected) {
      return const _LiveCallVisualState(
        label: '来电',
        detail: '等待接听',
        icon: AppIcons.incoming,
        color: _callGreen,
        emphasizeDetail: true,
      );
    }
    if (uiState.isInConference(call.callId)) {
      final paused = uiState.isConferencePaused;
      return _LiveCallVisualState(
        label: paused ? '会议暂停' : '会议中',
        detail: paused ? '会议已暂停' : call.durationLabel,
        icon: paused ? AppIcons.pause : AppIcons.contacts,
        color: paused ? Colors.orange.shade700 : _callGreen,
        emphasizeDetail: paused,
      );
    }
    if (call.isOnHold) {
      return _LiveCallVisualState(
        label: '保持中',
        detail: '本机保持 · ${call.durationLabel}',
        icon: AppIcons.pause,
        color: Colors.orange.shade700,
        emphasizeDetail: true,
      );
    }
    if (call.isRemoteOnHold) {
      return _LiveCallVisualState(
        label: '对方保持',
        detail: '对方保持 · ${call.durationLabel}',
        icon: AppIcons.pause,
        color: Colors.orange.shade700,
        emphasizeDetail: true,
      );
    }
    if (call.isConnected) {
      return _LiveCallVisualState(
        label: '通话中',
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
    final mediaLabel = switch (mediaStatus) {
      1 => '媒体已连接',
      2 => '本地保持',
      3 => '对方保持',
      4 => '媒体异常',
      0 => call.isConnected ? '媒体未建立' : '媒体待建立',
      null => call.isConnected ? '媒体未确认' : '媒体待建立',
      _ => '媒体状态 $mediaStatus',
    };

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

    final signalingLabel = account?.transport.label ?? '信令未知';
    final signalingSecure = account?.transport.isSecure == true;
    final configuredMode = account?.mediaSecurity.mode;
    final actualSrtp = call.mediaSecurity?.hasSrtpTransport;
    final mediaSecurityLabel = switch (actualSrtp) {
      true => configuredMode?.usesSrtp == true ? configuredMode!.label : 'SRTP',
      false => 'RTP',
      null =>
        configuredMode?.usesSrtp == true ? '${configuredMode!.label}配置' : 'RTP',
    };
    final stack = call.mediaSecurity?.transportStack ?? const <String>[];
    final secureVerified = signalingSecure && actualSrtp == true;
    final icon = secureVerified ? AppIcons.security : AppIcons.activity;
    final label = '$mediaLabel · $signalingLabel · $mediaSecurityLabel';
    final compactLabel = mediaReady
        ? '$signalingLabel · $mediaSecurityLabel'
        : mediaLabel;
    final tooltip = [
      '媒体：$mediaLabel',
      '信令：$signalingLabel${signalingSecure ? '（TLS 加密）' : ''}',
      '媒体加密：$mediaSecurityLabel${actualSrtp == true
          ? '（SRTP 已协商）'
          : actualSrtp == false
          ? '（未检测到 SRTP）'
          : '（等待媒体协商）'}',
      if (stack.isNotEmpty) 'Transport：${stack.join(' / ')}',
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
