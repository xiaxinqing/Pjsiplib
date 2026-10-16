part of '../../../main.dart';

class _StorageSettingsPage extends ConsumerStatefulWidget {
  const _StorageSettingsPage({required this.onOpenRecordings});
  final VoidCallback onOpenRecordings;

  @override
  ConsumerState<_StorageSettingsPage> createState() =>
      _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<_StorageSettingsPage> {
  StorageSettings? _settings;
  bool _busy = false;
  bool _failed = false;
  String? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final settings = await ref.read(storageManagerProvider).readSettings();
      if (mounted) setState(() => _settings = settings);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeDays(bool history, int value) async {
    final currentDays = history
        ? _settings!.historyDays
        : _settings!.recordingDays;
    final days = value == -1 ? await _askCustomDays(currentDays) : value;
    if (days == null || !mounted) return;
    final old = _settings!;
    final updated = StorageSettings(
      historyDays: history ? days : old.historyDays,
      recordingDays: history ? old.recordingDays : days,
    );
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      await ref.read(storageManagerProvider).saveSettings(updated);
      if (mounted) setState(() => _settings = updated);
    } catch (_) {
      if (mounted) ToastUtil.showError(context.l10n.storageOperationFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<int?> _askCustomDays(int currentDays) {
    // 再次修改时带上原来的天数，不用用户重新输入一遍。
    var input = currentDays > 0 ? '$currentDays' : '';
    final formKey = GlobalKey<FormState>();
    return showDialog<int>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          scrollable: true,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actionsOverflowButtonSpacing: 8,
          title: Text(l10n.storageCustomDays),
          // 给输入区留够宽度，别让弹窗跟着这一行短文案缩成小方块。
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: TextFormField(
                initialValue: input,
                autofocus: true,
                onChanged: (value) => input = value,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.storageDaysLabel,
                  helperText: l10n.storageDaysHelp,
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  final days = int.tryParse(value ?? '');
                  return days == null ||
                          days < 1 ||
                          !StorageSettings.validDays(days)
                      ? l10n.storageDaysHelp
                      : null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, int.parse(input));
                }
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cleanNow() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final storage = ref.read(storageManagerProvider);
      final plan = await storage.findExpired(_settings!);
      if (!mounted) return;
      if (plan.isEmpty) {
        setState(() => _result = context.l10n.storageNothingExpired);
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.storageCleanNow),
          content: Text(
            context.l10n.storageCleanConfirm(
              plan.historyIds.length,
              plan.recordings.length,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.storageCleanNow),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final phone = ref.read(pjsipServiceProvider.notifier);
      final result = await storage.cleanExpired(
        plan,
        isPlaying: phone.isRecordingPlaying,
      );

      if (mounted) {
        setState(
          () => _result = context.l10n.storageCleanResult(
            result.historyCount,
            result.recordingCount,
            result.failedCount,
          ),
        );
      }
    } catch (_) {
      if (mounted) ToastUtil.showError(context.l10n.storageOperationFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _daysChoice(bool history) {
    final days = history ? _settings!.historyDays : _settings!.recordingDays;
    final choices = {0, 30, 90, 180, 365, days}.toList()..sort();
    final l10n = context.l10n;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
    String label(int value) =>
        value == 0 ? l10n.storageForever : l10n.storageKeepDays(value);

    // 和语言选择用同一种小菜单，按钮不再撑满整行。
    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(_panelBackground),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(10),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: 0.14),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusSm),
            side: const BorderSide(color: _softBorder),
          ),
        ),
      ),
      menuChildren: [
        for (final value in choices)
          MenuItemButton(
            onPressed: _busy ? null : () => _changeDays(history, value),
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(200, 38)),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            child: SizedBox(
              width: 176,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label(value),
                      style: textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: _iconSm,
                    child: value == days
                        ? const Icon(AppIcons.check, size: _iconSm)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        const Divider(height: 9, indent: 8, endIndent: 8),
        MenuItemButton(
          onPressed: _busy ? null : () => _changeDays(history, -1),
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(200, 38)),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          child: Text(l10n.storageCustomDays, style: textStyle),
        ),
      ],
      builder: (context, controller, child) => SizedBox(
        width: 200,
        child: OutlinedButton(
          key: ValueKey(history ? 'historyDays' : 'recordingDays'),
          onPressed: _busy
              ? null
              : () {
                  controller.isOpen ? controller.close() : controller.open();
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: _textPrimary,
            backgroundColor: _subtlePanel,
            minimumSize: const Size(200, 38),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: _softBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            textStyle: textStyle,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label(days),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(AppIcons.chevronDown, size: _iconSm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
      Material(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );

  Widget _rowText(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: _textSecondary),
      ),
    ],
  );

  Widget _daysRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool history,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final description = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: _iconMd, color: _textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(child: _rowText(title, subtitle)),
            ],
          );
          // 窗口窄或字体放大时，按钮换到下一行，别把说明挤成一小条。
          if (constraints.maxWidth < 440 ||
              MediaQuery.textScalerOf(context).scale(14) > 18) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                description,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _daysChoice(history),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: description),
              const SizedBox(width: 20),
              _daysChoice(history),
            ],
          );
        },
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            icon,
            size: _iconMd,
            color: onTap == null ? _softBorder : _textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(child: _rowText(title, subtitle)),
          const SizedBox(width: 16),
          Icon(
            AppIcons.next,
            size: _iconSm,
            color: onTap == null ? _softBorder : _textSecondary,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.storageOperationFailed),
            TextButton(
              onPressed: _busy ? null : _load,
              child: Text(l10n.settingsStartupRetry),
            ),
          ],
        ),
      );
    }
    if (_settings == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(l10n.storageRetention, [
            _daysRow(
              icon: AppIcons.history,
              title: l10n.navCallHistory,
              subtitle: l10n.storageHistoryHint,
              history: true,
            ),
            const Divider(height: 1, indent: 44, endIndent: 14),
            _daysRow(
              icon: AppIcons.audio,
              title: l10n.storageLocalRecordings,
              subtitle: l10n.storageRecordingHint,
              history: false,
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4),
                  child: Text(
                    l10n.storageCleanupNote,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                ),
              ),
              Tooltip(
                message: l10n.storageRules,
                triggerMode: TooltipTriggerMode.tap,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    AppIcons.info,
                    size: _iconSm,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _section(l10n.storageDataManagement, [
            _actionRow(
              icon: AppIcons.audio,
              title: l10n.storageViewRecordings,
              subtitle: l10n.storageRecordingsHint,
              onTap: widget.onOpenRecordings,
            ),
            const Divider(height: 1, indent: 44, endIndent: 14),
            _actionRow(
              icon: AppIcons.delete,
              title: l10n.storageCleanNow,
              subtitle: l10n.storageCleanHint,
              onTap: _busy ? null : _cleanNow,
            ),
          ]),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(),
            ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_result!),
            ),
        ],
      ),
    );
  }
}

extension _HomeStorage on _MyHomePageState {
  Future<void> _showLocalRecordings() async {
    // 直接订阅所有录音，不依赖通话记录；旧通话删掉后，这里照样能找到录音。
    final recordings = ref
        .read(callHistoryDatabaseProvider)
        .watchLocalRecordings();
    final phone = ref.read(pjsipServiceProvider.notifier);
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: 760,
            height: 560,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.storageViewRecordings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: context.l10n.settingsClose,
                        icon: const Icon(AppIcons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<List<CallRecording>>(
                      stream: recordings,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(context.l10n.storageOperationFailed),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final rows = snapshot.data!;
                        if (rows.isEmpty) {
                          return Center(
                            child: Text(context.l10n.storageNoRecordings),
                          );
                        }
                        return Consumer(
                          builder: (context, ref, _) {
                            final playingId = ref.watch(
                              pjsipServiceProvider.select(
                                (s) => s.playingRecordingId,
                              ),
                            );
                            return ListView.separated(
                              itemCount: rows.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, index) =>
                                  _buildHistoryRecordingRow(
                                    null,
                                    rows[index],
                                    index: index,
                                    playing: playingId == rows[index].id,
                                  ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } finally {
      // 这是试听窗口，关掉就停。关闭按钮、Esc、点空白处和来电收起窗口都走这里。
      phone.stopCallRecordingPlayback();
    }
  }
}
