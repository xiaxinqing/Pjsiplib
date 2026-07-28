part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

enum _CallNoteMode { customer, conference }

const Duration _conferenceActionCooldownDuration = Duration(milliseconds: 1500);
const Duration _dialpadKeySoundPageWarmupDelay = Duration(
  milliseconds: 1200,
); //  自动连接声卡，防止卡顿
const double _contactListRowExtentEstimate = 62;

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final AppWindowController _windowController = AppWindowController();
  final TextEditingController _numberController = TextEditingController(
    text: '',
    // text: '6529',
  );
  final FocusNode _numberFocusNode = FocusNode();
  final TextEditingController _contactSearchController =
      TextEditingController();
  final TextEditingController _historySearchController =
      TextEditingController();
  final TextEditingController _callNoteController = TextEditingController();
  final ScrollController _contactListScrollController = ScrollController();
  final Set<String> _selectedContactIds = <String>{};
  String? _selectedContactDetailId;
  String? _flashingContactId;
  String? _pendingContactRevealId;
  String? _scheduledContactRevealId;
  int _contactFlashPhase = 0;
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
  int? _dtmfPadCallId;
  String _dtmfSentPreview = '';
  String? _dtmfStatusText;
  bool _dtmfSendFailed = false;
  Timer? _dialpadKeyFeedbackTimer;
  Timer? _dialpadKeySoundPageWarmupTimer;
  Timer? _contactFlashTimer;
  String? _callNoteControllerKey;
  _CallNoteMode _callNoteMode = _CallNoteMode.customer;
  final Map<int, String> _pendingCallOperations = <int, String>{};
  final Map<int, Timer> _pendingCallOperationTimers = <int, Timer>{};
  Timer? _conferenceActionCooldownTimer;
  bool _conferenceActionCoolingDown = false;
  bool _applicationRestarting = false;
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
    _lastDialpadValue = _numberController.text;
    _numberController.addListener(_handleNumberControllerChanged);
    unawaited(_windowController.attachCloseToTrayBehavior());
    _bindTrayActions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isRunningWidgetTest) return;
      unawaited(_warmUpHistoryDatabase());
      _scheduleDialpadKeySoundPageWarmup();
    });
  }

  @override
  void dispose() {
    _dialpadKeyFeedbackTimer?.cancel();
    _dialpadKeySoundPageWarmupTimer?.cancel();
    _contactFlashTimer?.cancel();
    _conferenceActionCooldownTimer?.cancel();
    for (final timer in _pendingCallOperationTimers.values) {
      timer.cancel();
    }
    _numberController.removeListener(_handleNumberControllerChanged);
    _numberFocusNode.dispose();
    _contactListScrollController.dispose();
    _contactSearchController.dispose();
    _historySearchController.dispose();
    _callNoteController.dispose();
    _numberController.dispose();
    _windowController.detachCloseToTrayBehavior();
    AppTrayController.instance.clearActions();
    AppDockMenuController.instance.clearActions();
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

  void _update(VoidCallback fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    ref.listen<PjsipUIState>(pjsipServiceProvider, _handleCallWindowAttention);

    final uiState = ref.watch(pjsipServiceProvider);
    final service = ref.read(pjsipServiceProvider.notifier);
    unawaited(_syncTrayMenu(uiState));

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

  void _bindTrayActions() {
    AppDockMenuController.instance.bindActions(
      onOpenSettings: () {
        if (!mounted) return;
        _openSettingsDrawer();
      },
      onOpenAbout: () {
        if (!mounted) return;
        _openSettingsDrawer(tabIndex: 4);
      },
      onRestartApplication: _confirmAndRestartApplication,
    );

    AppTrayController.instance.bindActions(
      onOpenCalls: () {
        if (!mounted) return;
        _selectSection(_WorkspaceSection.calls);
      },
      onOpenHistory: () {
        if (!mounted) return;
        _selectSection(_WorkspaceSection.history);
      },
      onOpenSettings: () {
        if (!mounted) return;
        _openSettingsDrawer();
      },
      onOpenAbout: () {
        if (!mounted) return;
        _openSettingsDrawer(tabIndex: 4);
      },
      onDisconnectAll: () async {
        if (!mounted) return;
        final uiState = ref.read(pjsipServiceProvider);
        final confirmed = await _confirmDisconnectAllAccounts(uiState);
        if (confirmed != true || !mounted) return;
        ref.read(pjsipServiceProvider.notifier).disconnectAllAccounts();
      },
      onRestartApplication: _confirmAndRestartApplication,
      onIncomingRingtoneChanged: (enabled) {
        ref
            .read(pjsipServiceProvider.notifier)
            .setIncomingRingtoneEnabled(enabled);
      },
    );
  }

  Future<void> _syncTrayMenu(PjsipUIState uiState) {
    final hasDisconnectableLine = uiState.accounts.values.any(
      (account) => account.registrationEnabled || account.isRegistered,
    );
    final canDisconnectAll =
        uiState.isInitialized && uiState.calls.isEmpty && hasDisconnectableLine;
    return AppTrayController.instance.updateMenu(
      connectedLines: uiState.registeredAccounts.length,
      totalLines: uiState.accounts.length,
      incomingRingtoneEnabled: uiState.incomingRingtoneEnabled,
      canDisconnectAll: canDisconnectAll,
      hasActiveCalls: uiState.calls.isNotEmpty,
    );
  }

  Future<void> _confirmAndRestartApplication() async {
    if (_applicationRestarting || !mounted) return;
    final uiState = ref.read(pjsipServiceProvider);
    final confirmed = await _confirmRestartApplication(uiState);
    if (confirmed != true || !mounted) return;

    _update(() => _applicationRestarting = true);
    final accepted = await AppRestartController.instance.restartApplication();
    if (!accepted && mounted) {
      _update(() => _applicationRestarting = false);
    }
  }
}
