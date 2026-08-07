part of '../../../../../main.dart';

/// 右侧通话面板：负责通话列表、会议分组和右侧上下文区域编排。
extension _HomeCallSidePanel on _MyHomePageState {
  Widget _buildLiveCallsPanel(
    PjsipUIState uiState,
    PjsipService service, {
    Widget? emptyContent,
  }) {
    final calls = _sortedLiveCalls(uiState.calls.values);
    final conferenceCalls = _conferenceCalls(uiState);
    final focusedCall = _primaryCall(uiState);
    final standaloneCalls = calls
        .where((call) => !uiState.isInConference(call.callId))
        .toList();
    final hasStandaloneIncoming = standaloneCalls.any(
      (call) => call.isIncoming && !call.isConnected,
    );
    final panelTitle = uiState.hasConference
        ? context.l10n.activeCallPanelConferenceMembers
        : context.l10n.activeCallPanelCurrentCalls;
    final panelCount = uiState.hasConference
        ? context.l10n.activeCallPanelCount(
            conferenceCalls.length,
            calls.length,
          )
        : context.l10n.activeCallPanelCount(calls.length, 4);
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
                    label: Text(context.l10n.activeCallResumeConference),
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
                              uiState.isConferencePaused
                                  ? context.l10n.activeCallConferencePaused
                                  : context.l10n.activeCallConferenceInProgress,
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
                                hasStandaloneIncoming
                                    ? context
                                          .l10n
                                          .activeCallNewIncomingAndOthers
                                    : context.l10n.activeCallOtherCalls,
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
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: _softBorder),
                          const SizedBox(height: 14),
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

  List<CallInfo> _sortedLiveCalls(Iterable<CallInfo> calls) {
    final result = calls.toList();
    result.sort((a, b) {
      final createdAt = a.startedAt.compareTo(b.startedAt);
      if (createdAt != 0) return createdAt;
      return a.callId.compareTo(b.callId);
    });
    return result;
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
}
