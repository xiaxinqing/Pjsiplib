part of '../../../../../main.dart';

/// 右侧备注卡片：负责单通话备注、会议备注和备注输入状态同步。
extension _CallSideNoteCards on _MyHomePageState {
  Widget _buildCallNoteSection(
    CallInfo call,
    PjsipService service,
    String contextLabel, {
    String? title,
  }) {
    _syncCallNoteController(call, service);
    return _buildCallContextSection(
      icon: AppIcons.note,
      title: title ?? context.l10n.activeCallCurrentNote,
      subtitle: contextLabel,
      trailing: _buildCallNoteStatusBadge(
        _callNoteController.text.trim().isNotEmpty,
      ),
      child: TextField(
        controller: _callNoteController,
        minLines: 3,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        onChanged: (value) {
          service.setCallNote(call.callId, value);
          _refreshCallNoteState();
        },
        decoration: _callNoteInputDecoration(context.l10n.activeCallNoteHint),
      ),
    );
  }

  Widget _buildConferenceNoteSection(
    List<CallInfo> calls,
    CallInfo primary,
    PjsipService service,
    String primaryLabel,
  ) {
    final callIds = calls.map((call) => call.callId).toSet();
    final isSharedMode = _callNoteMode == _CallNoteMode.conference;
    _syncConferenceNoteController(calls, primary, service);

    return _buildCallContextSection(
      icon: AppIcons.note,
      title: context.l10n.activeCallConferenceNote,
      subtitle: isSharedMode
          ? context.l10n.activeCallNoteSyncMembers(calls.length)
          : context.l10n.activeCallNoteSavePrimary(primaryLabel),
      trailing: _buildCallNoteStatusBadge(
        _callNoteController.text.trim().isNotEmpty,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_CallNoteMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment<_CallNoteMode>(
                value: _CallNoteMode.customer,
                icon: const Icon(AppIcons.person),
                label: Text(context.l10n.activeCallCustomerNote),
              ),
              ButtonSegment<_CallNoteMode>(
                value: _CallNoteMode.conference,
                icon: const Icon(AppIcons.contacts),
                label: Text(context.l10n.activeCallSharedConferenceNote),
              ),
            ],
            selected: {_callNoteMode},
            onSelectionChanged: (selection) {
              _setCallNoteMode(selection.first);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _callNoteController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              // Conference notes can either follow the primary customer only or
              // be copied to every member record; keep that decision local here.
              if (_callNoteMode == _CallNoteMode.conference) {
                service.setSharedConferenceNote(callIds, value);
              } else {
                service.setCallNote(primary.callId, value);
              }
              _refreshCallNoteState();
            },
            decoration: _callNoteInputDecoration(
              isSharedMode
                  ? context.l10n.activeCallSharedNoteHint
                  : context.l10n.activeCallCustomerNoteHint,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _callNoteInputDecoration(String hintText) {
    final borderRadius = BorderRadius.circular(_radiusSm);
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: _panelBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _softBorder, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: _brandGreen.withValues(alpha: 0.52),
          width: 1.1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    );
  }

  Widget _buildCallNoteStatusBadge(bool filled) {
    final label = filled
        ? context.l10n.activeCallNoteStaged
        : context.l10n.activeCallNoteEmpty;
    final color = filled ? _brandGreen : _textSecondary;
    return Tooltip(
      message: filled
          ? context.l10n.activeCallNoteStagedTooltip
          : context.l10n.activeCallNoteEmptyTooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: filled ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(_radiusXs),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filled ? AppIcons.save : AppIcons.note,
              size: _iconXs,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncCallNoteController(CallInfo call, PjsipService service) {
    final key = 'call:${call.callId}';
    if (_callNoteControllerKey == key) return;
    _callNoteControllerKey = key;
    final note = service.callNote(call.callId);
    _callNoteController.value = TextEditingValue(
      text: note,
      selection: TextSelection.collapsed(offset: note.length),
    );
  }

  void _syncConferenceNoteController(
    List<CallInfo> calls,
    CallInfo primary,
    PjsipService service,
  ) {
    final callIds = calls.map((call) => call.callId).toList()..sort();
    final key = _callNoteMode == _CallNoteMode.conference
        ? 'conference:${callIds.join(',')}'
        : 'call:${primary.callId}';
    if (_callNoteControllerKey == key) return;
    _callNoteControllerKey = key;
    final note = _callNoteMode == _CallNoteMode.conference
        ? service.sharedConferenceNote(callIds)
        : service.callNote(primary.callId);
    _callNoteController.value = TextEditingValue(
      text: note,
      selection: TextSelection.collapsed(offset: note.length),
    );
  }
}
