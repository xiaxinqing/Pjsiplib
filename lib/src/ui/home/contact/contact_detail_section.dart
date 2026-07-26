part of '../../../../main.dart';

/// 联系人详情区：负责详情面板、最近通话、预览弹窗和定位联系人。
extension _ContactDetailSection on _MyHomePageState {
  Widget _buildContactDetailEmpty() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Center(
        child: Text(
          '选择联系人查看详情',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _textSecondary),
        ),
      ),
    );
  }

  Widget _buildContactDetailPane(
    PjsipUIState uiState,
    PjsipService service,
    ContactEntry contact,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildContactDetailBody(contact),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _callContact(uiState, service, contact),
                    icon: const Icon(AppIcons.call),
                    label: const Text('呼叫'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '编辑',
                  onPressed: () => _showEditContactDialog(contact),
                  icon: const Icon(AppIcons.edit),
                ),
                IconButton(
                  tooltip: '删除',
                  onPressed: () => _confirmDeleteContact(contact),
                  icon: const Icon(AppIcons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailBody(ContactEntry contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContactDetailContent(contact),
        const SizedBox(height: 16),
        _buildContactRecentHistory(contact),
      ],
    );
  }

  Widget _buildContactDetailContent(ContactEntry contact) {
    final remark = contact.remark.trim();
    final company = contact.company.trim();
    final department = contact.department.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: contact.isFavorite
                  ? _brandGreen
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              foregroundColor: contact.isFavorite ? Colors.white : _textPrimary,
              child: Text(
                contact.initials,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                    contact.organizationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                ],
              ),
            ),
            if (contact.isFavorite) ...[
              const SizedBox(width: 8),
              _buildContactDetailChip('重点'),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _buildContactDetailFocusCard(
          icon: AppIcons.call,
          label: '默认号码',
          value: contact.number,
        ),
        if (contact.phoneEntries.length > 1) ...[
          const SizedBox(height: 12),
          _buildContactPhoneList(contact),
        ],
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: _subtlePanel,
            borderRadius: BorderRadius.circular(_radiusSm),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                _buildContactDetailLine(
                  '公司',
                  company.isEmpty ? '未填写' : company,
                ),
                _buildContactDetailLine(
                  '部门',
                  department.isEmpty ? '未填写' : department,
                ),
                _buildContactDetailLine(
                  '创建',
                  _formatContactTime(contact.createdAt),
                ),
                _buildContactDetailLine(
                  '更新',
                  _formatContactTime(contact.updatedAt ?? contact.createdAt),
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        if (remark.isNotEmpty) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: _subtlePanel,
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '备注',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(remark, maxLines: 5, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContactDetailFocusCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _buildContactPhoneList(ContactEntry contact) {
    final phones = contact.phoneEntries;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            for (var index = 0; index < phones.length; index++) ...[
              _buildContactPhoneLine(phones[index]),
              if (index != phones.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactPhoneLine(ContactPhoneEntry phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              phone.isPrimary ? '${phone.label} · 默认' : phone.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              phone.number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _brandGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _brandGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildContactDetailLine(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRecentHistory(ContactEntry contact) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(AppIcons.history, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Text(
                  '最近通话',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<CallHistoryEntry>>(
              stream: _watchContactDetailHistory(contact),
              builder: (context, snapshot) {
                final entries = snapshot.data ?? const <CallHistoryEntry>[];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '暂无通话记录',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var index = 0; index < entries.length; index++) ...[
                      _buildContactRecentHistoryRow(entries[index]),
                      if (index != entries.length - 1) const Divider(height: 1),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<CallHistoryEntry>> _watchContactDetailHistory(
    ContactEntry contact,
  ) {
    final phoneNumbers = contact.phoneEntries.map((phone) => phone.number);
    final phoneSignature = phoneNumbers.join('|');
    if (_contactDetailHistoryStream == null ||
        _contactDetailHistoryContactId != contact.id ||
        _contactDetailHistoryPhoneNumber != phoneSignature) {
      _contactDetailHistoryContactId = contact.id;
      _contactDetailHistoryPhoneNumber = phoneSignature;
      _contactDetailHistoryStream = ref
          .read(callHistoryDatabaseProvider)
          .watchRecentForContact(
            contactId: contact.id,
            phoneNumber: contact.number,
            phoneNumbers: phoneNumbers,
            limit: 5,
          );
    }
    return _contactDetailHistoryStream!;
  }

  Widget _buildContactRecentHistoryRow(CallHistoryEntry entry) {
    final item = _persistedHistoryItem(entry);
    final color = _historyItemColor(item);
    final timeLabel = DateFormat('M月d日 HH:mm').format(item.startedAt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
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
                Text(
                  item.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatHistoryDuration(item),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContactDetailDialog(
    PjsipUIState uiState,
    PjsipService service,
    ContactEntry contact,
  ) {
    return _showContactPreviewDialog(
      contact: contact,
      uiState: uiState,
      service: service,
      showCallAction: true,
    );
  }

  Future<void> _showContactPreviewDialog({
    required ContactEntry contact,
    PjsipUIState? uiState,
    PjsipService? service,
    bool showCallAction = false,
    bool showOpenContactPageAction = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _ContactPreviewDialog(
        body: _buildContactDetailBody(contact),
        onEdit: () {
          Navigator.of(dialogContext).pop();
          unawaited(_showEditContactDialog(contact));
        },
        onCall: showCallAction && uiState != null && service != null
            ? () {
                Navigator.of(dialogContext).pop();
                _callContact(uiState, service, contact);
              }
            : null,
        onOpenContactPage: showOpenContactPageAction
            ? () {
                Navigator.of(dialogContext).pop();
                _openContactPageAndReveal(contact);
              }
            : null,
      ),
    );
  }

  void _openContactPageAndReveal(ContactEntry contact) {
    _selectContactDetail(contact.id);
    _selectSection(_WorkspaceSection.contacts);
    _revealContactRow(contact.id);
  }
}
