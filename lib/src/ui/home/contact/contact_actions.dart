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
      ToastUtil.showWarning('没有可用外呼线路，请先注册线路');
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
    if (contact.number.trim().isEmpty) return '联系人没有可呼叫号码';
    if (uiState.accounts.isEmpty) return '请先添加电话线路';
    if (!uiState.isNetworkAvailable) return '当前网络不可用，暂不能外呼';
    if (uiState.hasConference) return '当前会议通话中，暂不能外呼联系人';
    if (uiState.calls.length >= 4) return '当前通话已达 4 路上限';
    if (_preferredContactCallAccount(uiState) == null) {
      return '没有可用外呼线路，请先注册线路';
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
    final organization = contact.organizationLabel.isEmpty
        ? '未填写'
        : contact.organizationLabel;
    final remark = contact.remark.trim().isEmpty ? '无' : contact.remark.trim();
    final phones = contact.phoneEntries;
    var selectedNumber = contact.number;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('确认呼叫'),
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
                            subtitle: Text(
                              phone.isPrimary
                                  ? '${phone.label} · 默认'
                                  : phone.label,
                            ),
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
                  label: '外呼线路',
                  value: '${account.displayName} · ${account.transportLabel}',
                ),
                if (remark != '无') ...[
                  const SizedBox(height: 12),
                  _buildCallConfirmRow(AppIcons.note, '备注', remark),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(selectedNumber),
              icon: const Icon(AppIcons.call),
              label: const Text('确认呼叫'),
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
      ToastUtil.showSuccess('联系人已创建');
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
    ToastUtil.showSuccess('联系人已更新');
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
        title: const Text('号码重复'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '号码 $conflictNumber 已属于现有联系人。',
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
                              '${conflict.phone.label} · $conflictNumber',
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
                '为避免通话归属混乱，联系人号码需要保持唯一。请查看已有联系人后再编辑。',
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
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(AppIcons.person),
            label: const Text('查看已有联系人'),
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
    ToastUtil.showSuccess('已定位到已有联系人');
  }

  Future<void> _confirmDeleteContact(ContactEntry contact) async {
    final confirmed = await _showDeleteContactsConfirm(
      title: '删除联系人',
      message: '确定删除 ${contact.name}？此操作不可撤销。',
      confirmLabel: '删除',
    );
    if (confirmed != true) return;
    ref.read(contactBookProvider.notifier).deleteContact(contact.id);
    _selectedContactIds.remove(contact.id);
    ToastUtil.showSuccess('联系人已删除');
  }

  Future<void> _confirmDeleteContacts(Set<String> ids) async {
    if (ids.isEmpty) return;
    final confirmed = await _showDeleteContactsConfirm(
      title: '批量删除',
      message: '确定删除已选的 ${ids.length} 位联系人？此操作不可撤销。',
      confirmLabel: '删除 ${ids.length} 位',
    );
    if (confirmed != true) return;
    ref.read(contactBookProvider.notifier).deleteContacts(ids);
    _clearSelectedContacts();
    ToastUtil.showSuccess('已删除 ${ids.length} 位联系人');
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
            child: const Text('取消'),
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
