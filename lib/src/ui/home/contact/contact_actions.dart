part of '../../../../main.dart';

/// 联系人动作层：负责呼叫确认、新增编辑保存、重复号码和删除确认。
extension _ContactActions on _MyHomePageState {
  Future<void> _callContact(
    PjsipUIState uiState,
    PjsipService service,
    ContactEntry contact,
  ) async {
    final unavailableMessage = _contactCallUnavailableMessage(uiState, contact);
    if (unavailableMessage != null) {
      ToastUtil.showWarning(unavailableMessage);
      return;
    }

    final account = _preferredContactCallAccount(uiState);
    if (account == null) {
      ToastUtil.showWarning(context.l10n.contactNoAvailableDialLine);
      return;
    }

    final number = await _showCallContactConfirm(contact, account);
    if (number == null || !mounted) return;

    _numberController.text = number;
    _selectedOutgoingAccountId = account.accId;
    service.makeCallFromAccount(number, account.accId);
    _selectSection(_WorkspaceSection.calls);
  }

  String? _contactCallUnavailableMessage(
    PjsipUIState uiState,
    ContactEntry contact,
  ) {
    if (contact.number.trim().isEmpty) {
      return context.l10n.contactNoCallableNumber;
    }
    if (uiState.accounts.isEmpty) return context.l10n.contactAddLineFirst;
    if (!uiState.isNetworkAvailable) {
      return context.l10n.contactNetworkUnavailable;
    }
    if (uiState.hasConference) {
      return context.l10n.contactConferenceCallBlocked;
    }
    if (uiState.calls.length >= 4) {
      return context.l10n.contactCallLimitReached;
    }
    if (_preferredContactCallAccount(uiState) == null) {
      return context.l10n.contactNoAvailableDialLine;
    }
    return null;
  }

  SipAccountInfo? _preferredContactCallAccount(PjsipUIState uiState) {
    final selectedId = _selectedOutgoingAccountId;
    if (selectedId != null) {
      final selected = uiState.accounts[selectedId];
      if (selected?.isRegistered == true) return selected;
    }
    return uiState.bestOutgoingAccount;
  }

  Future<String?> _showCallContactConfirm(
    ContactEntry contact,
    SipAccountInfo account,
  ) {
    final organization = contact.hasOrganization
        ? contact.organizationLabel
        : context.l10n.contactNotProvided;
    final remark = contact.remark.trim();
    final phones = contact.phoneEntries;
    var selectedNumber = contact.number;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.contactConfirmCallTitle),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _subtlePanel,
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _buildContactAvatar(contact),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                organization,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _panelBackground,
                    borderRadius: BorderRadius.circular(_radiusSm),
                    border: Border.all(color: _softBorder),
                  ),
                  child: RadioGroup<String>(
                    groupValue: selectedNumber,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedNumber = value);
                    },
                    child: Column(
                      children: [
                        for (final phone in phones)
                          RadioListTile<String>(
                            value: phone.number,
                            title: Text(
                              phone.number,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                            subtitle: Text(_contactPhoneLabel(phone)),
                            secondary: const Icon(AppIcons.call),
                            dense: true,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildCallConfirmFocusCard(
                  icon: AppIcons.outgoing,
                  label: context.l10n.contactDialLine,
                  value: '${account.displayName} · ${account.transportLabel}',
                ),
                if (contact.hasRemark) ...[
                  const SizedBox(height: 12),
                  _buildCallConfirmRow(
                    AppIcons.note,
                    context.l10n.contactNotes,
                    remark,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(selectedNumber),
              icon: const Icon(AppIcons.call),
              label: Text(context.l10n.contactCall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallConfirmFocusCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: _iconMd, color: _textPrimary),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallConfirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: _iconSm, color: _textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 68,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddContactDialog() {
    return _showContactDialog();
  }

  Future<void> _showEditContactDialog(ContactEntry contact) {
    return _showContactDialog(contact: contact);
  }

  Future<void> _showContactDialog({
    ContactEntry? contact,
    String initialName = '',
    String initialNumber = '',
  }) async {
    final result = await showDialog<_ContactFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => _ContactEditorDialog(
        contact: contact,
        initialName: initialName,
        initialNumber: initialNumber,
      ),
    );
    if (result == null || !mounted) return;

    // 弹窗组件只负责收集输入；号码唯一性、写入本地存储和提示都集中在页面层处理。
    final contactState = ref.read(contactBookProvider);
    final conflict = contactState.findPhoneConflict(
      result.phones,
      excludingContactId: contact?.id,
    );
    if (conflict != null) {
      final shouldViewExisting = await _showContactDuplicateDialog(
        conflict: conflict,
      );
      if (!mounted) return;
      if (shouldViewExisting == true) {
        _openExistingContactFromConflict(conflict);
        return;
      }
      return;
    }

    final notifier = ref.read(contactBookProvider.notifier);
    if (contact == null) {
      notifier.addContact(
        name: result.name,
        number: result.number,
        phones: result.phones,
        company: result.company,
        department: result.department,
        remark: result.remark,
        isFavorite: result.isFavorite,
      );
      ToastUtil.showSuccess(context.l10n.contactCreatedToast);
      return;
    }

    notifier.updateContact(
      contact.copyWith(
        name: result.name,
        number: result.number,
        phones: result.phones,
        company: result.company,
        department: result.department,
        remark: result.remark,
        isFavorite: result.isFavorite,
      ),
    );
    ToastUtil.showSuccess(context.l10n.contactUpdatedToast);
  }

  Future<bool?> _showContactDuplicateDialog({
    required ContactPhoneConflict conflict,
  }) {
    final conflictNumber = conflict.phone.number;
    final target = conflict.contact;
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contactDuplicateTitle),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.contactDuplicateNumberMessage(conflictNumber),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _subtlePanel,
                  borderRadius: BorderRadius.circular(_radiusSm),
                  border: Border.all(color: _softBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildContactAvatar(target),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_contactPhoneLabel(conflict.phone)} · $conflictNumber',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _textSecondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.contactDuplicateExplanation,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.person),
            label: Text(context.l10n.contactViewExisting),
          ),
        ],
      ),
    );
  }

  void _openExistingContactFromConflict(ContactPhoneConflict conflict) {
    _contactSearchController.text = conflict.phone.number;
    _clearSelectedContacts();
    _selectContactDetail(conflict.contact.id);
    _selectSection(_WorkspaceSection.contacts);
    ToastUtil.showSuccess(context.l10n.contactExistingLocated);
  }

  Future<void> _confirmDeleteContact(ContactEntry contact) async {
    final confirmed = await _showDeleteContactsConfirm(
      title: context.l10n.contactDeleteTitle,
      message: context.l10n.contactDeleteQuestion(contact.name),
      confirmLabel: context.l10n.contactDelete,
    );
    if (confirmed != true) return;
    if (!mounted) return;
    ref.read(contactBookProvider.notifier).deleteContact(contact.id);
    _selectedContactIds.remove(contact.id);
    ToastUtil.showSuccess(context.l10n.contactDeletedToast);
  }

  Future<void> _confirmDeleteContacts(Set<String> ids) async {
    if (ids.isEmpty) return;
    final confirmed = await _showDeleteContactsConfirm(
      title: context.l10n.contactBulkDeleteTitle,
      message: context.l10n.contactBulkDeleteQuestion(ids.length),
      confirmLabel: context.l10n.contactBulkDeleteConfirm(ids.length),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    ref.read(contactBookProvider.notifier).deleteContacts(ids);
    _clearSelectedContacts();
    ToastUtil.showSuccess(context.l10n.contactBulkDeletedToast(ids.length));
  }

  Future<bool?> _showDeleteContactsConfirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.delete),
            label: Text(confirmLabel),
            style: FilledButton.styleFrom(backgroundColor: _dangerRed),
          ),
        ],
      ),
    );
  }
}
