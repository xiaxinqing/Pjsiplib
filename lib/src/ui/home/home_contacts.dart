part of '../../../main.dart';

/// 联系人页入口：负责联系人数据过滤、响应式布局，以及列表/详情区域编排。
extension _HomeContacts on _MyHomePageState {
  /// 联系人页达到该宽度后展示右侧详情。
  ///
  /// 详情区是联系人页的核心阅读区域，断点不宜太靠后；列表会在自身宽度不足时
  /// 隐藏“更新时间”列，所以这里可以比之前更早进入双栏。
  static const double _contactDetailPaneBreakpoint = 780;

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
        final compact = constraints.maxWidth < _contactDetailPaneBreakpoint;
        final showDetailPane =
            constraints.maxWidth >= _contactDetailPaneBreakpoint;
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
                        flex: 6,
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

  List<ContactEntry> _filteredContacts(ContactBookState state) {
    final keyword = _contactSearchController.text;
    return state.contacts.where((contact) => contact.matches(keyword)).toList();
  }

  String _formatContactTime(DateTime? value) {
    if (value == null) return '--';
    return DateFormat('MM-dd HH:mm').format(value);
  }
}
