part of '../../../../../main.dart';

/// 通话中 DTMF 面板：负责轻量数字键盘和 DTMF 发送反馈。
extension _CallStageDtmf on _MyHomePageState {
  Widget _buildCallControlsWithDtmfPad(
    CallInfo call,
    PjsipService service,
    Widget controls,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _showInCallDialpad && call.isConnected
              ? Padding(
                  key: ValueKey<int>(call.callId),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildDtmfPanel(call, service),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        controls,
      ],
    );
  }

  Widget _buildDtmfPanel(CallInfo call, PjsipService service) {
    final preview = _dtmfPadCallId == call.callId && _dtmfSentPreview.isNotEmpty
        ? _dtmfSentPreview
        : '等待输入';
    final statusText = _dtmfPadCallId == call.callId ? _dtmfStatusText : null;
    final statusColor = _dtmfSendFailed ? _dangerRed : _textSecondary;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 328),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _panelBackground,
          borderRadius: BorderRadius.circular(_radiusSm),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(AppIcons.dialpad, size: _iconSm, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DTMF 键盘',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭键盘',
                    visualDensity: VisualDensity.compact,
                    onPressed: _toggleInCallDialpad,
                    icon: const Icon(AppIcons.close, size: _iconSm),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _subtlePanel,
                  borderRadius: BorderRadius.circular(_radiusXs),
                ),
                child: Text(
                  preview,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: preview == '等待输入' ? _textSecondary : _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (statusText != null) ...[
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _dtmfSendFailed ? AppIcons.info : AppIcons.check,
                      size: _iconXs,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _buildDtmfPad(call, service),
            ],
          ),
        ),
      ),
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
          onPressed: () => _sendInCallDtmf(service, call, key),
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
}
