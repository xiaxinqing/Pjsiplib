part of '../../../../../main.dart';

/// 右侧上下文编排：负责客户信息、备注和最近通话卡片的组合。
extension _CallSideContext on _MyHomePageState {
  Widget _buildCallsIdleContext(PjsipService service) {
    if (_isRunningWidgetTest) {
      return Center(
        child: Text(
          context.l10n.activeCallNoActiveCalls,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SingleChildScrollView(child: _buildCallsIdleRecentSection(service));
  }

  Widget _buildCallCustomerContext(CallInfo call, PjsipService service) {
    final match = _callContactMatch(call);
    final contact = match?.contact;
    final number = match?.phone.number ?? _callDisplayNumber(call);
    final contextLabel = _callContextTargetLabel(call, match);

    // Keep this as a small composition layer; card internals live in
    // customer / note / history files so the right panel is easier to scan.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCallContextFollowerLabel(context.l10n.activeCallCustomerInfo),
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
        _buildCallContextFollowerLabel(
          context.l10n.activeCallConferenceCustomers,
        ),
        const SizedBox(height: 8),
        _buildCallContextSection(
          icon: AppIcons.contacts,
          title: context.l10n.activeCallConferenceCustomers,
          subtitle: context.l10n.activeCallConferenceCustomersDescription,
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

  Widget _buildCallContextFollowerLabel(String label) {
    return Row(
      children: [
        Icon(AppIcons.person, size: _iconXs, color: _textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: _buildTooltipText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
}
