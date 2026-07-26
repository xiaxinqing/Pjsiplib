part of '../../../main.dart';

extension _HomeContacts on _MyHomePageState {
  Widget _buildContactsPage(PjsipUIState uiState, PjsipService service) {
    final contactState = ref.watch(contactBookProvider);
    final contacts = _filteredContacts(contactState);
    _schedulePendingContactReveal(contactState, contacts);
    final validSelectedIds = contactState.contacts
        .where((contact) => _selectedContactIds.contains(contact.id))
        .map((contact) => contact.id)
        .toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 860;
        final showDetailPane = constraints.maxWidth >= 920;
        final detailContact = _selectedContactDetail(contacts);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _panelBackground,
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildContactsToolbar(contactState, contacts, compact: compact),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _panelBackground,
                            borderRadius: BorderRadius.circular(_radiusSm),
                            border: Border.all(color: _softBorder),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_radiusSm),
                            child: contactState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : contacts.isEmpty
                                ? _buildContactsEmpty(contactState)
                                : _buildContactsTable(
                                    uiState,
                                    service,
                                    contacts,
                                    validSelectedIds,
                                    showDetailInline: showDetailPane,
                                    selectedDetailId: detailContact?.id,
                                  ),
                          ),
                        ),
                      ),
                      if (showDetailPane) ...[
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: detailContact == null
                              ? _buildContactDetailEmpty()
                              : _buildContactDetailPane(
                                  uiState,
                                  service,
                                  detailContact,
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ContactEntry? _selectedContactDetail(List<ContactEntry> contacts) {
    if (contacts.isEmpty) return null;
    final selectedId = _selectedContactDetailId;
    if (selectedId != null) {
      for (final contact in contacts) {
        if (contact.id == selectedId) return contact;
      }
    }
    return contacts.first;
  }

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

  List<ContactEntry> _filteredContacts(ContactBookState state) {
    final keyword = _contactSearchController.text;
    return state.contacts.where((contact) => contact.matches(keyword)).toList();
  }

  Widget _buildContactsSelectionBar(
    Set<String> validSelectedIds,
    int totalVisibleCount,
  ) {
    final selectedCount = validSelectedIds.length;
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: _subtlePanel,
        border: Border(bottom: BorderSide(color: _softBorder, width: 0.7)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.confirm, size: _iconSm, color: _textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '已选择 $selectedCount / $totalVisibleCount',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton.icon(
            onPressed: _clearSelectedContacts,
            icon: const Icon(AppIcons.close),
            label: const Text('取消选择'),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () => _confirmDeleteContacts(validSelectedIds),
            icon: const Icon(AppIcons.delete),
            label: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: _dangerRed),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsToolbar(
    ContactBookState state,
    List<ContactEntry> filteredContacts, {
    required bool compact,
  }) {
    final searchField = TextField(
      controller: _contactSearchController,
      onChanged: (_) => _refreshContactSearch(),
      decoration: InputDecoration(
        hintText: '搜索姓名、号码、组织或备注',
        prefixIcon: const Icon(AppIcons.search),
        suffixIcon: _contactSearchController.text.trim().isEmpty
            ? null
            : IconButton(
                tooltip: '清空搜索',
                onPressed: _clearContactSearch,
                icon: const Icon(AppIcons.close),
              ),
      ),
    );

    return Row(
      children: [
        Flexible(
          flex: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, minWidth: 220),
            child: searchField,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  _contactCountLabel(state, filteredContacts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ),
              if (state.errorMessage != null && !compact) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    state.errorMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: _showAddContactDialog,
          icon: const Icon(AppIcons.contactAdd),
          label: const Text('新建联系人'),
          style: FilledButton.styleFrom(backgroundColor: _textPrimary),
        ),
      ],
    );
  }

  String _contactCountLabel(
    ContactBookState state,
    List<ContactEntry> filteredContacts,
  ) {
    final total = state.contacts.length;
    final visible = filteredContacts.length;
    if (_contactSearchController.text.trim().isNotEmpty || visible != total) {
      return '当前 $visible / 共 $total 位';
    }
    return '共 $total 位联系人';
  }

  Widget _buildContactsEmpty(ContactBookState state) {
    final hasKeyword = _contactSearchController.text.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasKeyword ? AppIcons.search : AppIcons.contacts,
            size: 46,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            hasKeyword ? '没有匹配的联系人' : '暂无联系人',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            hasKeyword ? '换个关键词再查找' : '创建第一位联系人后即可快速外呼',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: hasKeyword ? _clearContactSearch : _showAddContactDialog,
            icon: Icon(hasKeyword ? AppIcons.refresh : AppIcons.contactAdd),
            label: Text(hasKeyword ? '重置搜索' : '新建联系人'),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsTable(
    PjsipUIState uiState,
    PjsipService service,
    List<ContactEntry> contacts,
    Set<String> validSelectedIds, {
    required bool showDetailInline,
    required String? selectedDetailId,
  }) {
    final selectedVisibleCount = contacts
        .where((contact) => validSelectedIds.contains(contact.id))
        .length;
    final selectAllValue = selectedVisibleCount == 0
        ? false
        : selectedVisibleCount == contacts.length
        ? true
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showUpdatedAtColumn = constraints.maxWidth >= 760;
        return Column(
          children: [
            _buildContactsSelectionBar(validSelectedIds, contacts.length),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: _panelBackground,
                border: Border(
                  bottom: BorderSide(color: _softBorder, width: 0.7),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    tristate: true,
                    value: selectAllValue,
                    onChanged: (_) => _toggleVisibleContacts(
                      contacts,
                      selectedVisibleCount != contacts.length,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        const SizedBox(width: 34),
                        const SizedBox(width: 11),
                        Text(
                          '联系人',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      '组织',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (showUpdatedAtColumn)
                    const Expanded(
                      flex: 2,
                      child: Text(
                        '更新时间',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(
                    width: 138,
                    child: Text(
                      '操作',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _contactListScrollController,
                itemCount: contacts.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 56, endIndent: 12),
                itemBuilder: (context, index) => _buildContactRow(
                  uiState,
                  service,
                  contacts[index],
                  selected: validSelectedIds.contains(contacts[index].id),
                  showUpdatedAtColumn: showUpdatedAtColumn,
                  showDetailInline: showDetailInline,
                  selectedDetailId: selectedDetailId,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactRow(
    PjsipUIState uiState,
    PjsipService service,
    ContactEntry contact, {
    required bool selected,
    required bool showUpdatedAtColumn,
    required bool showDetailInline,
    required String? selectedDetailId,
  }) {
    final detailSelected = showDetailInline && selectedDetailId == contact.id;
    final baseColor = selected || detailSelected
        ? _brandGreen.withValues(alpha: 0.06)
        : _panelBackground;
    final shouldFlash = _flashingContactId == contact.id;
    final rowColor = shouldFlash && _contactFlashPhase.isEven
        ? _brandGreen.withValues(alpha: 0.16)
        : baseColor;
    final callButtonActive =
        _hoveredContactCallButtonIds.contains(contact.id) ||
        _focusedContactCallButtonIds.contains(contact.id);
    return Material(
      color: rowColor,
      child: InkWell(
        hoverColor: _subtlePanel,
        onHover: showDetailInline
            ? (hovering) {
                if (hovering) _selectContactDetail(contact.id);
              }
            : null,
        onTap: () {
          if (showDetailInline) {
            _selectContactDetail(contact.id);
          } else {
            _showContactDetailDialog(uiState, service, contact);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (value) =>
                    _setSelectedContact(contact.id, value ?? false),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    _buildContactAvatar(contact),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTooltipText(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          _buildTooltipText(
                            contact.number,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
              Expanded(
                flex: 3,
                child: _buildTooltipText(
                  contact.organizationLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _textSecondary),
                ),
              ),
              if (showUpdatedAtColumn)
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatContactTime(contact.updatedAt ?? contact.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SizedBox(
                width: 138,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: contact.isFavorite ? '取消重点' : '设为重点',
                      onPressed: () => ref
                          .read(contactBookProvider.notifier)
                          .toggleFavorite(contact.id),
                      icon: Icon(
                        contact.isFavorite
                            ? Icons.star_rounded
                            : AppIcons.favorite,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: contact.isFavorite
                            ? _brandGreen
                            : _subtlePanel,
                        foregroundColor: contact.isFavorite
                            ? Colors.white
                            : _textSecondary,
                        hoverColor: contact.isFavorite
                            ? _brandGreen
                            : _hoverPanel,
                      ),
                    ),
                    _buildContactCallButton(
                      uiState,
                      service,
                      contact,
                      active: callButtonActive,
                    ),
                    PopupMenuButton<_ContactRowAction>(
                      tooltip: '更多操作',
                      onSelected: (action) =>
                          _handleContactAction(action, contact),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ContactRowAction.edit,
                          child: ListTile(
                            dense: true,
                            leading: Icon(AppIcons.edit),
                            title: Text('编辑'),
                          ),
                        ),
                        PopupMenuItem(
                          value: _ContactRowAction.delete,
                          child: ListTile(
                            dense: true,
                            leading: Icon(AppIcons.delete),
                            title: Text('删除'),
                          ),
                        ),
                      ],
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

  Widget _buildContactCallButton(
    PjsipUIState uiState,
    PjsipService service,
    ContactEntry contact, {
    required bool active,
  }) {
    return Tooltip(
      message: '呼叫',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (hovered) =>
            _setContactCallButtonHovered(contact.id, hovered),
        onShowFocusHighlight: (focused) =>
            _setContactCallButtonFocused(contact.id, focused),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _callContact(uiState, service, contact),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? _callGreen : _subtlePanel,
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            child: Icon(
              AppIcons.call,
              size: _iconMd,
              color: active ? Colors.white : _textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactAvatar(ContactEntry contact) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: contact.isFavorite
          ? _brandGreen
          : Theme.of(context).colorScheme.surfaceContainerHigh,
      foregroundColor: contact.isFavorite ? Colors.white : _textPrimary,
      child: Text(
        contact.initials,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _toggleVisibleContacts(List<ContactEntry> contacts, bool selected) {
    _setVisibleContactsSelected(
      contacts.map((contact) => contact.id),
      selected,
    );
  }

  void _handleContactAction(_ContactRowAction action, ContactEntry contact) {
    switch (action) {
      case _ContactRowAction.edit:
        _showEditContactDialog(contact);
      case _ContactRowAction.delete:
        _confirmDeleteContact(contact);
    }
  }

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

  String _formatContactTime(DateTime? value) {
    if (value == null) return '--';
    return DateFormat('MM-dd HH:mm').format(value);
  }
}

enum _ContactRowAction { edit, delete }
