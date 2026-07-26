part of '../../../../../main.dart';

/// 右侧最近通话卡片：负责空闲和当前客户相关的最近通话展示。
extension _CallSideHistoryCards on _MyHomePageState {
  Widget _buildCallsIdleRecentSection(PjsipService service) {
    return _buildCallContextSection(
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
}
