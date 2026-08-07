part of '../../../../main.dart';

/// 通话记录详情：负责右侧详情、详情弹窗、备注展示和备注编辑。
extension _HistoryDetail on _MyHomePageState {
  Widget _buildHistorySummary(
    _HistoryItem item, {
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.direction == CallHistoryDirection.inbound
                      ? AppIcons.incoming
                      : AppIcons.outgoing,
                  color: _historyItemColor(item),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName?.trim().isNotEmpty == true
                            ? item.displayName!.trim()
                            : item.phoneNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.historySwitchDetailHint,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHistoryContactAction(item),
            const SizedBox(height: 18),
            if (item.hasDeletedContactSnapshot)
              _buildHistoryDetailLine(
                context.l10n.historyFieldContact,
                context.l10n.historyContactDeleted,
              ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldNumber,
              item.phoneNumber,
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldDirection,
              CallHistoryLocalizer.direction(context.l10n, item.direction),
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldStatus,
              _historyListStatusLabel(item),
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldLine,
              item.accountLabel ?? context.l10n.historyUnknownLine,
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldCalledAt,
              _formatHistoryDateTime(item.startedAt),
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldAnsweredAt,
              item.answeredAt == null
                  ? context.l10n.historyNotAnswered
                  : _formatHistoryDateTime(item.answeredAt!),
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldEndedAt,
              item.endedAt == null
                  ? context.l10n.historyInProgress
                  : _formatHistoryDateTime(item.endedAt!),
            ),
            _buildHistoryDetailLine(
              context.l10n.historyFieldDuration,
              _formatHistoryDuration(item),
            ),
            if (_historyEndReasonText(item)?.isNotEmpty == true)
              _shouldHighlightHistoryEndReason(item)
                  ? _buildHistoryEndReasonNotice(item)
                  : _buildHistoryDetailLine(
                      context.l10n.historyFieldEndReason,
                      _historyEndReasonText(item)!,
                    ),
            if (item.hasCallStats) ...[
              const SizedBox(height: 2),
              _buildHistoryStatsCard(item),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 2),
            _buildHistoryNoteArea(item),
          ],
        ),
      ),
    );
  }

  String _formatHistoryDateTime(DateTime time) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).add_jms().format(time);
  }

  bool _shouldHighlightHistoryEndReason(_HistoryItem item) {
    return item.status == CallHistoryStatus.failed ||
        item.status == CallHistoryStatus.rejected ||
        item.status == CallHistoryStatus.missed;
  }

  Widget _buildHistoryEndReasonNotice(_HistoryItem item) {
    final color = _historyItemColor(item);
    final reason = _historyEndReasonText(item) ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(_radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.info, size: _iconSm, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _historyListStatusLabel(item),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryStatsCard(_HistoryItem item) {
    final stats = _historyStats(item);
    if (stats.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.activity, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.historyStatsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stat in stats)
                  _HistoryStatPill(label: stat.$1, value: stat.$2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _historyStats(_HistoryItem item) {
    final stats = <(String, String)>[];
    if (item.direction == CallHistoryDirection.outbound &&
        item.timeToRingingMs != null) {
      stats.add((
        context.l10n.historyMetricDialToRing,
        _formatHistoryMetricMs(item.timeToRingingMs!),
      ));
    }
    if (item.ringingToAnswerMs != null) {
      stats.add((
        item.answeredAt == null
            ? context.l10n.historyMetricRingingDuration
            : context.l10n.historyMetricRingToAnswer,
        _formatHistoryMetricMs(item.ringingToAnswerMs!),
      ));
    }
    if (item.answerToMediaMs != null) {
      stats.add((
        context.l10n.historyMetricMediaReady,
        _formatHistoryMetricMs(item.answerToMediaMs!),
      ));
    }
    if (item.holdCount > 0) {
      stats.add((
        context.l10n.historyMetricHoldCount,
        context.l10n.historyTimes(item.holdCount),
      ));
    }
    if (item.holdSeconds > 0) {
      stats.add((
        context.l10n.historyMetricHoldDuration,
        _formatHistoryMetricSeconds(item.holdSeconds),
      ));
    }
    return stats;
  }

  String _formatHistoryMetricMs(int milliseconds) {
    if (milliseconds < 300) return context.l10n.historyImmediate;
    if (milliseconds < 1000) return '${milliseconds}ms';
    if (milliseconds < 10000) {
      return context.l10n.historySeconds(
        (milliseconds / 1000).toStringAsFixed(1),
      );
    }
    return _formatHistoryMetricSeconds((milliseconds / 1000).round());
  }

  String _formatHistoryMetricSeconds(int seconds) {
    if (seconds < 60) return context.l10n.historySeconds('$seconds');
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoryNoteArea(_HistoryItem item) {
    final note = _historyNoteText(item);
    if (note == null) {
      if (!item.canEditNote) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _showEditHistoryNoteDialog(item),
          icon: const Icon(AppIcons.note),
          label: Text(context.l10n.historyAddNote),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _softBorder),
          ),
        ),
      );
    }
    return _buildHistoryNoteCard(item, note);
  }

  Widget _buildHistoryNoteCard(_HistoryItem item, String note) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.note, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.historyNote,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (item.canEditNote)
                  IconButton(
                    tooltip: context.l10n.historyEditNote,
                    onPressed: () => _showEditHistoryNoteDialog(item),
                    icon: const Icon(AppIcons.edit),
                    iconSize: _iconSm,
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditHistoryNoteDialog(_HistoryItem item) {
    final databaseId = item.databaseId;
    if (databaseId == null) return Future<void>.value();
    final controller = TextEditingController(
      text: _historyNoteText(item) ?? '',
    );
    final noteSaveError = context.l10n.historyNoteSaveError;
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.historyEditNoteTitle),
          content: SizedBox(
            width: 460,
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 5,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: context.l10n.historyNoteHint,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(callHistoryDatabaseProvider)
                      .updateEntryNote(databaseId, controller.text);
                } catch (error, stackTrace) {
                  debugPrint('Update call history note failed: $error');
                  debugPrint('$stackTrace');
                  ToastUtil.showError(noteSaveError);
                }
              },
              icon: const Icon(AppIcons.save),
              label: Text(context.l10n.commonSave),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildHistoryDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStatusChip(_HistoryItem item) {
    final color = _historyItemColor(item);
    final label = _historyListStatusLabel(item);
    final reason = _historyEndReasonText(item);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Tooltip(
      message: reason == null || reason.isEmpty ? label : reason,
      waitDuration: const Duration(milliseconds: 350),
      child: chip,
    );
  }

  Future<void> _showHistoryDetail(_HistoryItem item, PjsipService service) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 18, 14, 0),
          title: Row(
            children: [
              Expanded(child: Text(context.l10n.historyDetailTitle)),
              IconButton(
                tooltip: context.l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(AppIcons.close),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.min(560, size.width - 80),
              maxWidth: math.min(680, size.width - 80),
              maxHeight: size.height * 0.74,
            ),
            child: _buildHistorySummary(item, padding: EdgeInsets.zero),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.commonClose),
            ),
            FilledButton.icon(
              onPressed: item.isLive || item.phoneNumber.trim().isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _callHistoryItem(item, service);
                    },
              icon: const Icon(AppIcons.call),
              label: Text(context.l10n.historyCallBack),
            ),
            FilledButton.tonalIcon(
              onPressed: item.phoneNumber.trim().isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _handleHistoryContactAction(item);
                    },
              icon: Icon(
                item.hasCurrentContact ? AppIcons.person : AppIcons.contactAdd,
              ),
              label: Text(
                item.hasCurrentContact
                    ? context.l10n.historyViewContact
                    : item.hasDeletedContactSnapshot
                    ? context.l10n.historyReAddContact
                    : context.l10n.historyAddContact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryStatPill extends StatelessWidget {
  const _HistoryStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: _textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
