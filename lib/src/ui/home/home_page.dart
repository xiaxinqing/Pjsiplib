part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

enum _CallNoteMode { customer, conference }

const Duration _conferenceActionCooldownDuration = Duration(milliseconds: 1500);

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
  final FocusNode _numberFocusNode = FocusNode();
  final TextEditingController _contactSearchController =
      TextEditingController();
  final TextEditingController _historySearchController =
      TextEditingController();
  final TextEditingController _callNoteController = TextEditingController();
  final Set<String> _selectedContactIds = <String>{};
  final Set<String> _hoveredContactCallButtonIds = <String>{};
  final Set<String> _focusedContactCallButtonIds = <String>{};
  String? _selectedContactDetailId;
  String? _contactDetailHistoryContactId;
  String _contactDetailHistoryPhoneNumber = '';
  Stream<List<CallHistoryEntry>>? _contactDetailHistoryStream;
  String? _callContextHistoryContactId;
  String _callContextHistoryPhoneNumber = '';
  Stream<List<CallHistoryEntry>>? _callContextHistoryStream;
  Stream<List<CallHistoryEntry>>? _callsIdleRecentHistoryStream;
  _WorkspaceSection _section = _WorkspaceSection.dialpad;
  CallHistoryDirection? _historyDirectionFilter;
  _HistoryDateFilter _historyDateFilter = _HistoryDateFilter.all;
  Stream<List<CallHistoryEntry>>? _historyEntriesStream;
  String _historyStreamKeyword = '';
  CallHistoryDirection? _historyStreamDirectionFilter;
  _HistoryDateFilter _historyStreamDateFilter = _HistoryDateFilter.all;
  int _historyVisibleLimit = _historyPageSize;
  int _historyStreamVisibleLimit = _historyPageSize;
  Stream<List<CallHistoryEntry>>? _dialpadRecentHistoryStream;
  int? _focusedCallDetailId;
  String? _selectedHistoryItemKey;
  int? _selectedOutgoingAccountId;
  int _settingsTabIndex = 0;
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;
  late String _lastDialpadValue;
  bool _normalizingDialpadNumber = false;
  String? _activeDialpadKey;
  String? _hoveredDialpadKey;
  Timer? _dialpadKeyFeedbackTimer;
  String? _callNoteControllerKey;
  _CallNoteMode _callNoteMode = _CallNoteMode.customer;
  final Map<int, String> _pendingCallOperations = <int, String>{};
  final Map<int, Timer> _pendingCallOperationTimers = <int, Timer>{};
  Timer? _conferenceActionCooldownTimer;
  bool _conferenceActionCoolingDown = false;

  @override
  void initState() {
    super.initState();
    _lastDialpadValue = _numberController.text;
    _numberController.addListener(_handleNumberControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isRunningWidgetTest) return;
      unawaited(_warmUpHistoryDatabase());
    });
  }

  @override
  void dispose() {
    _dialpadKeyFeedbackTimer?.cancel();
    _conferenceActionCooldownTimer?.cancel();
    for (final timer in _pendingCallOperationTimers.values) {
      timer.cancel();
    }
    _numberController.removeListener(_handleNumberControllerChanged);
    _numberFocusNode.dispose();
    _contactSearchController.dispose();
    _historySearchController.dispose();
    _callNoteController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _setActiveDialpadKey(String? key) {
    if (!mounted) return;
    setState(() => _activeDialpadKey = key);
  }

  void _setHoveredDialpadKey(String? key) {
    if (!mounted || _hoveredDialpadKey == key) return;
    setState(() => _hoveredDialpadKey = key);
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
    _syncPendingCallOperations(previous, next);
    _syncFocusedCallAfterStateChange(next);
    _syncConferenceActionCooldown(next);

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
    _focusCallDetail(callId);
    _setPendingCallOperation(callId, '正在接听');
    service.answerCall(callId);
  }

  void _rejectCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    _setPendingCallOperation(callId, '正在拒接');
    service.rejectCall(callId);
  }

  void _hangupCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    _setPendingCallOperation(callId, '正在挂断');
    service.hangupCall(callId);
  }

  void _selectSection(_WorkspaceSection section) {
    setState(() => _section = section);
  }

  void _toggleInCallDialpad() {
    setState(() => _showInCallDialpad = !_showInCallDialpad);
  }

  void _setCallNoteMode(_CallNoteMode mode) {
    setState(() {
      _callNoteMode = mode;
      _callNoteControllerKey = null;
    });
  }

  void _focusCallDetail(int callId) {
    if (_focusedCallDetailId == callId) return;
    setState(() => _focusedCallDetailId = callId);
  }

  void _runCallActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _focusCallDetail(callId);
    _setPendingCallOperation(callId, pendingLabel);
    action();
  }

  void _runConferenceActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _startMediaBridgeActionCooldown();
    _runCallActionAndFocus(callId, pendingLabel, action);
  }

  void _runConferenceAction(VoidCallback action) {
    _startMediaBridgeActionCooldown();
    action();
  }

  bool get _isConferenceActionCoolingDown => _conferenceActionCoolingDown;
  bool get _isMediaBridgeActionCoolingDown => _conferenceActionCoolingDown;

  void _runMediaBridgeActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _startMediaBridgeActionCooldown();
    _runCallActionAndFocus(callId, pendingLabel, action);
  }

  void _startMediaBridgeActionCooldown() {
    _conferenceActionCooldownTimer?.cancel();
    setState(() => _conferenceActionCoolingDown = true);
    _conferenceActionCooldownTimer = Timer(
      _conferenceActionCooldownDuration,
      _clearConferenceActionCooldown,
    );
  }

  void _clearConferenceActionCooldown() {
    _conferenceActionCooldownTimer?.cancel();
    _conferenceActionCooldownTimer = null;
    if (!_conferenceActionCoolingDown || !mounted) return;
    setState(() => _conferenceActionCoolingDown = false);
  }

  void _syncConferenceActionCooldown(PjsipUIState state) {
    if (!_conferenceActionCoolingDown) return;
    final hasConferenceRelevantCalls =
        state.hasConference ||
        state.calls.values.where((call) => call.isConnected).length >= 2;
    if (hasConferenceRelevantCalls) return;
    _clearConferenceActionCooldown();
  }

  String? _callOperationLabel(int callId) => _pendingCallOperations[callId];

  bool _hasPendingCallOperation(int callId) {
    return _pendingCallOperations.containsKey(callId);
  }

  void _setPendingCallOperation(int callId, String label) {
    _pendingCallOperationTimers.remove(callId)?.cancel();
    setState(() {
      _pendingCallOperations[callId] = label;
    });
    _pendingCallOperationTimers[callId] = Timer(const Duration(seconds: 4), () {
      _clearPendingCallOperation(callId);
    });
  }

  void _clearPendingCallOperation(int callId) {
    final hadOperation = _pendingCallOperations.containsKey(callId);
    _pendingCallOperationTimers.remove(callId)?.cancel();
    if (!hadOperation || !mounted) return;
    setState(() {
      _pendingCallOperations.remove(callId);
    });
  }

  void _syncPendingCallOperations(PjsipUIState? previous, PjsipUIState next) {
    if (_pendingCallOperations.isEmpty) return;
    final finished = <int>[];
    for (final entry in _pendingCallOperations.entries) {
      final call = next.calls[entry.key];
      if (call == null) {
        finished.add(entry.key);
        continue;
      }
      final label = entry.value;
      if (label == '正在接听' && !call.isIncoming) {
        finished.add(entry.key);
      } else if (label == '正在保持' && call.isOnHold) {
        finished.add(entry.key);
      } else if (label == '正在恢复' && call.isConnected && !call.isOnHold) {
        finished.add(entry.key);
      } else if (label == '正在拆分' && !next.isInConference(entry.key)) {
        finished.add(entry.key);
      } else if (label == '正在合并' && next.isInConference(entry.key)) {
        finished.add(entry.key);
      } else if (previous?.calls[entry.key] != call &&
          (label == '正在拒接' || label == '正在挂断')) {
        finished.add(entry.key);
      }
    }
    if (finished.isEmpty || !mounted) return;
    setState(() {
      for (final callId in finished) {
        _pendingCallOperationTimers.remove(callId)?.cancel();
        _pendingCallOperations.remove(callId);
      }
    });
  }

  void _syncFocusedCallAfterStateChange(PjsipUIState state) {
    final focusedId = _focusedCallDetailId;
    if (focusedId == null || state.calls.containsKey(focusedId)) return;
    if (!mounted) return;
    setState(() => _focusedCallDetailId = null);
  }

  void _refreshCallNoteState() {
    if (!mounted) return;
    setState(() {});
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
