part of '../../../../../main.dart';

/// 通话中 DTMF 浮层：负责键盘定位、关闭交互和发送反馈。
extension _CallStageDtmf on _MyHomePageState {
  Widget _buildInCallDialpadControl(CallInfo call) {
    return TapRegion(
      groupId: _inCallDialpadTapRegionGroup,
      child: CompositedTransformTarget(
        link: _inCallDialpadAnchor,
        child: _roundCallButton(
          icon: AppIcons.dialpad,
          label: context.l10n.activeCallKeypad,
          color: _showInCallDialpad
              ? _brandGreen
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected ? _toggleInCallDialpad : null,
        ),
      ),
    );
  }

  Widget _buildInCallDtmfOverlay(CallInfo call, PjsipService service) {
    final hasPreview =
        _dtmfPadCallId == call.callId && _dtmfSentPreview.isNotEmpty;
    return InCallDtmfPopover(
      anchorLink: _inCallDialpadAnchor,
      tapRegionGroupId: _inCallDialpadTapRegionGroup,
      title: context.l10n.activeCallDtmfTitle,
      closeTooltip: context.l10n.activeCallDtmfClose,
      previewText: hasPreview
          ? _dtmfSentPreview
          : context.l10n.activeCallDtmfWaiting,
      previewActive: hasPreview,
      statusText: _dtmfPadCallId == call.callId ? _dtmfStatusText : null,
      statusFailed: _dtmfSendFailed,
      onDismiss: _hideInCallDialpad,
      onDigitPressed: (digit) => _sendInCallDtmf(service, call, digit),
    );
  }
}
