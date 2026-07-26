part of '../../../../main.dart';

/// 联系人列表区：负责工具栏、批量选择、列表行和行内操作。
extension _ContactListSection on _MyHomePageState {
  /// 双栏模式下，列表区域达到该宽度后显示“更新时间”列。
  ///
  /// 单栏模式没有右侧详情挤占空间，更新时间默认展示；双栏模式再按列表实际宽度
  /// 做保护，避免列内容被挤得过窄。
  static const double _contactUpdatedAtInlineWidth = 520;

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
        final showUpdatedAtColumn =
            !showDetailInline ||
            constraints.maxWidth >= _contactUpdatedAtInlineWidth;
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
                    Expanded(
                      flex: 2,
                      child: Text(
                        '更新时间',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
}

/// 联系人行菜单动作：区分编辑和删除。
enum _ContactRowAction { edit, delete }
