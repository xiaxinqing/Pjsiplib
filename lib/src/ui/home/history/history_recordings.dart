part of '../../../../main.dart';

extension _HistoryRecordings on _MyHomePageState {
  Widget _buildHistoryRecordings(_HistoryItem item) {
    final historyId = item.databaseId;
    if (historyId == null) return const SizedBox.shrink();
    return StreamBuilder<List<CallRecording>>(
      stream: ref
          .read(callHistoryDatabaseProvider)
          .watchRecordingsForHistory(historyId),
      builder: (context, snapshot) {
        final recordings = snapshot.data ?? const <CallRecording>[];
        if (recordings.isEmpty) return const SizedBox.shrink();
        // 通话记录在窄窗口中会放入独立 Dialog。Dialog 不会随外层主页
        // 重建，因此由录音卡片自身订阅播放状态，保证 Windows 弹窗中也能
        // 即时切换“播放中”和播放/停止图标。
        return Consumer(
          builder: (context, ref, _) {
            final playingRecordingId = ref.watch(
              pjsipServiceProvider.select((state) => state.playingRecordingId),
            );
            return DecoratedBox(
              decoration: BoxDecoration(
                color: _subtlePanel,
                borderRadius: BorderRadius.circular(_radiusSm),
                border: Border.all(color: _softBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(AppIcons.audio, size: _iconMd),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.historyRecordingTitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var index = 0; index < recordings.length; index++) ...[
                      _buildHistoryRecordingRow(
                        item,
                        recordings[index],
                        index: index,
                        playing: playingRecordingId == recordings[index].id,
                      ),
                      if (index != recordings.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryRecordingRow(
    _HistoryItem item,
    CallRecording recording, {
    required int index,
    required bool playing,
  }) {
    final status = CallRecordingStatus.fromStorage(recording.status);
    final available =
        status != CallRecordingStatus.failed && recording.fileSizeBytes > 44;
    final statusColor = switch (status) {
      CallRecordingStatus.completed => _brandGreen,
      CallRecordingStatus.interrupted => Colors.orange.shade700,
      CallRecordingStatus.recording => _dangerRed,
      CallRecordingStatus.failed => _dangerRed,
    };
    final statusLabel = playing
        ? context.l10n.historyRecordingPlaying
        : switch (status) {
            CallRecordingStatus.completed =>
              context.l10n.historyRecordingCompleted,
            CallRecordingStatus.interrupted =>
              context.l10n.historyRecordingInterrupted,
            CallRecordingStatus.recording => context.l10n.activeCallRecording,
            CallRecordingStatus.failed => context.l10n.historyRecordingFailed,
          };
    final details = [
      DateFormat.Hms(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(recording.startedAt),
      _formatRecordingDuration(recording.durationMs),
      _formatRecordingFileSize(recording.fileSizeBytes),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.historyRecordingSegment(index + 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    if (recording.kind ==
                        CallRecordingKind.conference.storageKey) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _brandGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          context.l10n.historyConferenceRecording,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: _brandGreen,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: playing
                ? context.l10n.historyRecordingStop
                : context.l10n.historyRecordingPlay,
            onPressed: available
                ? () => _toggleHistoryRecordingPlayback(recording)
                : null,
            icon: Icon(playing ? AppIcons.stop : AppIcons.play),
          ),
          PopupMenuButton<_RecordingAction>(
            tooltip: context.l10n.contactsMoreActions,
            onSelected: (action) =>
                _handleHistoryRecordingAction(item, recording, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _RecordingAction.export,
                enabled: available,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.export),
                  title: Text(context.l10n.historyRecordingExport),
                ),
              ),
              PopupMenuItem(
                value: _RecordingAction.reveal,
                enabled: available,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.search),
                  title: Text(context.l10n.historyRecordingReveal),
                ),
              ),
              PopupMenuItem(
                value: _RecordingAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.delete, color: _dangerRed),
                  title: Text(
                    context.l10n.historyRecordingDelete,
                    style: const TextStyle(color: _dangerRed),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHistoryRecordingPlayback(CallRecording recording) async {
    final result = await ref
        .read(pjsipServiceProvider.notifier)
        .toggleCallRecordingPlayback(recording);
    if (!mounted) return;
    switch (result) {
      case CallRecordingPlaybackResult.activeCall:
        ToastUtil.showWarning(context.l10n.historyRecordingPlaybackDuringCall);
        return;
      case CallRecordingPlaybackResult.fileMissing:
        ToastUtil.showWarning(context.l10n.historyRecordingFileMissing);
        return;
      case CallRecordingPlaybackResult.engineUnavailable ||
          CallRecordingPlaybackResult.failed:
        ToastUtil.showError(context.l10n.historyRecordingPlaybackFailed);
        return;
      case CallRecordingPlaybackResult.started ||
          CallRecordingPlaybackResult.stopped:
        return;
    }
  }

  Future<void> _handleHistoryRecordingAction(
    _HistoryItem item,
    CallRecording recording,
    _RecordingAction action,
  ) async {
    final service = ref.read(pjsipServiceProvider.notifier);
    switch (action) {
      case _RecordingAction.export:
        final target = item.displayName?.trim().isNotEmpty == true
            ? item.displayName!.trim()
            : item.phoneNumber;
        final safeTarget = target.replaceAll(RegExp(r'[^\w\-]+'), '_');
        await service.exportCallRecording(
          recording,
          suggestedName:
              '${DateFormat('yyyyMMdd-HHmmss').format(recording.startedAt)}-$safeTarget.wav',
        );
        return;
      case _RecordingAction.reveal:
        final revealed = await service.revealCallRecording(recording);
        if (!revealed && mounted) {
          ToastUtil.showWarning(context.l10n.historyRecordingRevealFailed);
        }
        return;
      case _RecordingAction.delete:
        await _confirmDeleteHistoryRecording(recording);
        return;
    }
  }

  Future<void> _confirmDeleteHistoryRecording(CallRecording recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) => AlertDialog(
        title: Text(context.l10n.historyRecordingDeleteTitle),
        content: Text(context.l10n.historyRecordingDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
            icon: const Icon(AppIcons.delete),
            label: Text(context.l10n.historyRecordingDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(pjsipServiceProvider.notifier)
          .deleteCallRecording(recording);
    } catch (error) {
      if (mounted) {
        ToastUtil.showError(context.l10n.historyRecordingDeleteFailed);
      }
    }
  }

  String _formatRecordingDuration(int durationMs) {
    final seconds = (durationMs ~/ 1000).clamp(0, 1 << 31);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatRecordingFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kib = bytes / 1024;
    if (kib < 1024) return '${kib.toStringAsFixed(1)} KB';
    return '${(kib / 1024).toStringAsFixed(1)} MB';
  }
}

enum _RecordingAction { export, reveal, delete }
