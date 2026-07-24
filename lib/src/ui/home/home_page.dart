part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final AppWindowController _windowController = AppWindowController();
  final TextEditingController _numberController = TextEditingController(
    text: '6529',
  );
  final TextEditingController _contactSearchController =
      TextEditingController();
  final TextEditingController _historySearchController =
      TextEditingController();
  final Set<String> _selectedContactIds = <String>{};
  final Set<String> _hoveredContactCallButtonIds = <String>{};
  final Set<String> _focusedContactCallButtonIds = <String>{};
  String? _selectedContactDetailId;
  String? _contactDetailHistoryContactId;
  String _contactDetailHistoryPhoneNumber = '';
  Stream<List<CallHistoryEntry>>? _contactDetailHistoryStream;
  _WorkspaceSection _section = _WorkspaceSection.dialpad;
  CallHistoryDirection? _historyDirectionFilter;
  _HistoryDateFilter _historyDateFilter = _HistoryDateFilter.all;
  Stream<List<CallHistoryEntry>>? _historyEntriesStream;
  String _historyStreamKeyword = '';
  CallHistoryDirection? _historyStreamDirectionFilter;
  _HistoryDateFilter _historyStreamDateFilter = _HistoryDateFilter.all;
  int _historyVisibleLimit = _historyPageSize;
  int _historyStreamVisibleLimit = _historyPageSize;
  String? _selectedHistoryItemKey;
  int? _selectedOutgoingAccountId;
  int _settingsTabIndex = 0;
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isRunningWidgetTest) return;
      unawaited(_warmUpHistoryDatabase());
    });
  }

  @override
  void dispose() {
    _contactSearchController.dispose();
    _historySearchController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _warmUpHistoryDatabase() async {
    try {
      await ref.read(callHistoryDatabaseProvider).warmUp();
    } catch (_) {
      // 预热失败不影响用户后续进入通话记录，真正页面查询仍会重试。
    }
  }

  bool get _isRunningWidgetTest {
    var isTest = false;
    assert(() {
      isTest = WidgetsBinding.instance.runtimeType.toString().contains(
        'TestWidgetsFlutterBinding',
      );
      return true;
    }());
    return isTest;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PjsipUIState>(pjsipServiceProvider, _handleCallWindowAttention);

    final uiState = ref.watch(pjsipServiceProvider);
    final service = ref.read(pjsipServiceProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              children: [
                _buildSidebar(uiState, service),
                const VerticalDivider(width: 1, color: _softBorder),
                Expanded(child: _buildWorkspace(uiState, service)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleCallWindowAttention(PjsipUIState? previous, PjsipUIState next) {
    _syncSelectedOutgoingAccount(next);

    final previousIncomingIds = previous?._ringingCallIds ?? const <int>{};
    final nextIncomingIds = next._ringingCallIds;
    final hasNewIncomingCall = nextIncomingIds
        .difference(previousIncomingIds)
        .isNotEmpty;

    if (hasNewIncomingCall) {
      if (mounted && _section != _WorkspaceSection.calls) {
        setState(() => _section = _WorkspaceSection.calls);
      }
      _windowController.notifyIncomingCall(
        incomingCallCount: nextIncomingIds.length,
      );
      return;
    }

    if (previousIncomingIds.isNotEmpty && nextIncomingIds.isEmpty) {
      _windowController.clearIncomingCallAttention();
    }
  }

  void _syncSelectedOutgoingAccount(PjsipUIState state) {
    if (state.accounts.isEmpty) {
      if (_selectedOutgoingAccountId != null) {
        setState(() => _selectedOutgoingAccountId = null);
      }
      return;
    }
    final nextId = state.bestOutgoingAccount?.accId;
    if (_selectedOutgoingAccountId == nextId) {
      return;
    }
    setState(() => _selectedOutgoingAccountId = nextId);
  }

  void _answerCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    service.answerCall(callId);
  }

  void _rejectCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    service.rejectCall(callId);
  }

  void _hangupCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    service.hangupCall(callId);
  }

  void _selectSection(_WorkspaceSection section) {
    setState(() => _section = section);
  }

  void _toggleInCallDialpad() {
    setState(() => _showInCallDialpad = !_showInCallDialpad);
  }

  void _setDiagnosticLogsVisible(bool value) {
    setState(() => _showDiagnosticLogs = value);
  }

  void _selectOutgoingAccount(int? accountId) {
    setState(() => _selectedOutgoingAccountId = accountId);
  }

  void _setSelectedContact(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedContactIds.add(id);
      } else {
        _selectedContactIds.remove(id);
      }
    });
  }

  void _setVisibleContactsSelected(Iterable<String> ids, bool selected) {
    setState(() {
      if (selected) {
        _selectedContactIds.addAll(ids);
      } else {
        _selectedContactIds.removeAll(ids.toSet());
      }
    });
  }

  void _clearSelectedContacts() {
    if (_selectedContactIds.isEmpty) return;
    setState(_selectedContactIds.clear);
  }

  void _refreshContactSearch() {
    setState(() {});
  }

  void _clearContactSearch() {
    _contactSearchController.clear();
    setState(() {});
  }

  void _setContactCallButtonHovered(String id, bool hovered) {
    if (!mounted) return;
    setState(() {
      if (hovered) {
        _hoveredContactCallButtonIds.add(id);
      } else {
        _hoveredContactCallButtonIds.remove(id);
      }
    });
  }

  void _setContactCallButtonFocused(String id, bool focused) {
    if (!mounted) return;
    setState(() {
      if (focused) {
        _focusedContactCallButtonIds.add(id);
      } else {
        _focusedContactCallButtonIds.remove(id);
      }
    });
  }

  void _selectContactDetail(String id) {
    if (_selectedContactDetailId == id) return;
    setState(() => _selectedContactDetailId = id);
  }

  void _refreshHistorySearch() {
    setState(_resetHistoryPagination);
  }

  void _clearHistorySearch() {
    _historySearchController.clear();
    setState(_resetHistoryPagination);
  }

  void _setHistoryDirectionFilter(CallHistoryDirection? direction) {
    setState(() {
      _historyDirectionFilter = direction;
      _resetHistoryPagination();
    });
  }

  void _setHistoryDateFilter(_HistoryDateFilter filter) {
    setState(() {
      _historyDateFilter = filter;
      _resetHistoryPagination();
    });
  }

  void _selectHistoryItem(String key) {
    if (_selectedHistoryItemKey == key) return;
    setState(() => _selectedHistoryItemKey = key);
  }

  void _loadMoreHistoryEntries() {
    setState(() => _historyVisibleLimit += _historyPageSize);
  }

  void _resetHistoryPagination() {
    _historyVisibleLimit = _historyPageSize;
    _selectedHistoryItemKey = null;
  }

  Future<void> _showAddAccountDialog(
    PjsipUIState uiState,
    PjsipService service,
  ) {
    return _showAccountDialog(uiState, service);
  }

  Future<void> _showEditAccountDialog(
    PjsipUIState uiState,
    PjsipService service,
    SipAccountInfo account,
  ) {
    return _showAccountDialog(uiState, service, account: account);
  }

  Future<void> _showAccountDialog(
    PjsipUIState uiState,
    PjsipService service, {
    SipAccountInfo? account,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => AddAccountDialog(
        service: service,
        isNetworkAvailable: uiState.isNetworkAvailable,
        account: account,
      ),
    );
  }

  void _openSettingsDrawer({int tabIndex = 0}) {
    if (_settingsTabIndex != tabIndex) {
      setState(() => _settingsTabIndex = tabIndex);
    }
    var selectedIndex = tabIndex;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final uiState = ref.watch(pjsipServiceProvider);
            final service = ref.read(pjsipServiceProvider.notifier);
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return _buildSettingsDialog(
                  uiState,
                  service,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    setDialogState(() => selectedIndex = index);
                    if (_settingsTabIndex != index && mounted) {
                      setState(() => _settingsTabIndex = index);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
