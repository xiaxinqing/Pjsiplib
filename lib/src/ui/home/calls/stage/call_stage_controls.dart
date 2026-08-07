part of '../../../../../main.dart';

/// 主舞台操作区：负责静音、键盘、保持、转接、音频和挂断按钮。
extension _CallStageControls on _MyHomePageState {
  Widget _buildPrimaryCallControls(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isConferenceMember = uiState.isInConference(call.callId);
    final hasPendingOperation = _hasPendingCallOperation(call.callId);
    final isCoolingDown = _isMediaBridgeActionCoolingDown;
    final remoteMuted = uiState.remoteMutedCallIds.contains(call.callId);
    final controls = <Widget>[];

    if (call.isIncoming && !call.isConnected) {
      controls.addAll([
        _roundCallButton(
          icon: AppIcons.call,
          label: context.l10n.activeCallAnswer,
          color: _callGreen,
          emphasized: true,
          onPressed: hasPendingOperation
              ? null
              : () => _answerCall(service, call.callId),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: context.l10n.activeCallReject,
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
          onPressed: call.isConnected ? () => _toggleInCallDialpad() : null,
        ),
        _roundCallButton(
          icon: call.isOnHold ? AppIcons.play : AppIcons.pause,
          label: call.isOnHold
              ? context.l10n.activeCallResume
              : context.l10n.activeCallHold,
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
                        _CallOperationType.resume,
                        () => service.unholdCall(call.callId),
                      )
                    : _runMediaBridgeActionAndFocus(
                        call.callId,
                        _CallOperationType.hold,
                        () => service.holdCall(call.callId),
                      )
              : null,
        ),
        _roundCallButton(
          icon: AppIcons.route,
          label: context.l10n.activeCallTransfer,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed:
              call.isConnected && !isConferenceMember && !hasPendingOperation
              ? () => _showBlindTransferDialog(call, uiState, service)
              : null,
        ),
        if (call.isConnected && !isConferenceMember)
          _roundCallButton(
            icon: remoteMuted ? AppIcons.speaker : AppIcons.speakerOff,
            label: remoteMuted
                ? context.l10n.activeCallRestoreRemoteAudio
                : context.l10n.activeCallMuteRemoteAudio,
            color: remoteMuted
                ? Colors.orange.shade700
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            onPressed: () =>
                service.setRemoteAudioMuted(call.callId, !remoteMuted),
          ),
        _roundCallButton(
          icon: AppIcons.tune,
          label: context.l10n.activeCallAudio,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () => _openSettingsDrawer(tabIndex: _settingsAudioIndex),
        ),
        _roundCallButton(
          icon: AppIcons.callEnd,
          label: context.l10n.activeCallHangUp,
          color: _dangerRed,
          onPressed: hasPendingOperation
              ? null
              : () => _hangupCall(service, call.callId),
        ),
      ]);
    }

    final controlsWrap = Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: controls,
    );
    return _buildCallControlsWithDtmfPad(call, service, controlsWrap);
  }

  Future<void> _showBlindTransferDialog(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) async {
    final account = uiState.accountForCall(call);
    final participant = _callParticipantLabel(call);
    final contacts = ref.read(contactBookProvider).contacts;
    final destination = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => _BlindTransferDialog(
        participant: participant,
        lineLabel: account == null
            ? context.l10n.activeCallCurrentLineUnknown
            : '${account.lineLabel} · ${account.transportLabel}',
        exampleTarget: account == null
            ? context.l10n.activeCallTransferTargetHint
            : context.l10n.activeCallTransferTargetExample(account.host),
        contacts: contacts,
      ),
    );
    if (destination == null || destination.trim().isEmpty || !mounted) return;
    _focusCallDetail(call.callId);
    _setPendingCallOperation(call.callId, _CallOperationType.transfer);
    unawaited(
      (() async {
        final transferred = await service.blindTransferCall(
          call.callId,
          destination,
        );
        if (!mounted) return;
        _clearPendingCallOperation(call.callId);
        if (!transferred) return;
        _clearFocusedCallDetail();
      })(),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return Tooltip(message: label, child: button);
  }
}
