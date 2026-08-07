part of '../../../../main.dart';

/// 拨号页右侧空状态：负责外呼可用性、容量概览和最近通话入口。
extension _DialpadStandbyPanel on _MyHomePageState {
  Widget _buildDialpadStandbyPanel(
    PjsipUIState uiState,
    PjsipService service,
    bool canCall,
  ) {
    final l10n = context.l10n;
    final account = _selectedOutgoingAccountId == null
        ? uiState.bestOutgoingAccount
        : uiState.accounts[_selectedOutgoingAccountId];
    final isUsingFallback =
        uiState.isUsingFallbackOutgoingAccount &&
        account?.accId == uiState.bestOutgoingAccount?.accId;
    final status = _dialpadAvailabilityStatus(uiState, account, canCall);
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentMaxWidth = constraints.maxWidth >= 720 ? 520.0 : 420.0;
        final topInset = constraints.maxHeight < 620 ? 28.0 : 64.0;
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topInset),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    canCall ? AppIcons.call : AppIcons.info,
                    size: 42,
                    color: canCall ? _callGreen : _textSecondary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    status.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _subtlePanel,
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _buildDialpadStandbyLine(
                            AppIcons.outgoing,
                            isUsingFallback
                                ? l10n.dialCurrentOutgoingLine
                                : l10n.dialDefaultOutgoingLine,
                            account == null
                                ? l10n.dialNoAvailableLine
                                : '${account.displayName} · ${account.transportLabel}',
                          ),
                          const SizedBox(height: 10),
                          _buildDialpadStandbyLine(
                            AppIcons.calls,
                            l10n.dialCallCapacity,
                            l10n.dialCallCapacityValue(uiState.calls.length, 4),
                          ),
                          const SizedBox(height: 10),
                          _buildDialpadStandbyLine(
                            AppIcons.network,
                            l10n.dialNetwork,
                            uiState.isNetworkAvailable
                                ? l10n.commonAvailable
                                : l10n.commonUnavailable,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDialpadRecentCalls(service),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialpadRecentCalls(PjsipService service) {
    if (_isRunningWidgetTest) {
      return _buildDialpadRecentCallsShell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            context.l10n.dialNoRecentCalls,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _textSecondary),
          ),
        ),
      );
    }

    return _buildDialpadRecentCallsShell(
      child: StreamBuilder<List<CallHistoryEntry>>(
        stream: _watchDialpadRecentHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final entries = snapshot.data ?? const <CallHistoryEntry>[];
          if (entries.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                context.l10n.dialNoRecentCalls,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            );
          }

          return Column(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                _buildDialpadRecentCallRow(
                  _persistedHistoryItem(entries[index]),
                  service,
                ),
                if (index != entries.length - 1) const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialpadRecentCallsShell({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(AppIcons.history, size: _iconSm),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.dialRecentCalls,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectSection(_WorkspaceSection.history),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(context.l10n.commonAll),
                ),
              ],
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }

  Stream<List<CallHistoryEntry>> _watchDialpadRecentHistory() {
    return _dialpadRecentHistoryStream ??= ref
        .read(callHistoryDatabaseProvider)
        .watchRecent(limit: 3);
  }

  Widget _buildDialpadRecentCallRow(_HistoryItem item, PjsipService service) {
    final color = _historyItemColor(item);
    final title = _dialpadRecentCallTitle(item);
    final number = item.phoneNumber.trim();
    final lineLabel = item.accountLabel?.trim();
    final shouldShowNumber = number.isNotEmpty && title != number;
    final statusLabel = [
      CallHistoryLocalizer.direction(context.l10n, item.direction),
      _historyListStatusLabel(item),
      _formatDialpadRecentCallTime(item.startedAt),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
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
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (shouldShowNumber) ...[
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    number,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                _buildTooltipText(
                  statusLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
                if (lineLabel != null && lineLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    lineLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textSecondary.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: number.isEmpty
                ? context.l10n.dialNoCallbackNumber
                : context.l10n.dialCallbackNumber(number),
            child: IconButton(
              onPressed: number.isEmpty
                  ? null
                  : () => _callHistoryItem(item, service),
              icon: const Icon(AppIcons.call),
              color: _callGreen,
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                disabledBackgroundColor: _panelBackground,
                disabledForegroundColor: _textSecondary.withValues(alpha: 0.5),
                foregroundColor: _callGreen,
                hoverColor: _callGreen.withValues(alpha: 0.08),
                highlightColor: _callGreen.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dialpadRecentCallTitle(_HistoryItem item) {
    final displayName = item.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final phoneNumber = item.phoneNumber.trim();
    if (phoneNumber.isNotEmpty) return phoneNumber;
    return _displayRemote(item.remoteUri);
  }

  String _formatDialpadRecentCallTime(DateTime time) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return DateFormat('HH:mm').format(time);
    if (diff == 1) {
      return l10n.dialYesterdayAt(DateFormat('HH:mm').format(time));
    }
    if (diff < 7) {
      final weekdays = [
        l10n.weekdayMonday,
        l10n.weekdayTuesday,
        l10n.weekdayWednesday,
        l10n.weekdayThursday,
        l10n.weekdayFriday,
        l10n.weekdaySaturday,
        l10n.weekdaySunday,
      ];
      return '${weekdays[time.weekday - 1]} ${DateFormat('HH:mm').format(time)}';
    }
    return DateFormat('M/d HH:mm').format(time);
  }
}
