part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

enum _CallNoteMode { customer, conference }

/// 记录联系人/通话记录从工作区切换到完整内容绘制完成的单次性能采样。
class _WorkspacePageLoadTrace {
  _WorkspacePageLoadTrace({required this.id, required this.section})
    : stopwatch = (Stopwatch()..start());

  final int id;
  final _WorkspaceSection section;
  final Stopwatch stopwatch;
  bool buildLogged = false;
  bool dataLogged = false;
  bool contentFrameScheduled = false;
  bool completed = false;
}

const Duration _conferenceActionCooldownDuration = Duration(milliseconds: 1500);
const Duration _dialpadPageWarmupDelay = Duration(milliseconds: 800);
const Duration _dialpadPageWarmupKeepAlive = Duration(seconds: 30);
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
  _HistoryCallFilter _historyCallFilter = _HistoryCallFilter.all;
  _HistoryDateFilter _historyDateFilter = _HistoryDateFilter.all;
  Stream<List<CallHistoryEntry>>? _historyEntriesStream;
  String _historyStreamKeyword = '';
  _HistoryCallFilter _historyStreamCallFilter = _HistoryCallFilter.all;
  _HistoryDateFilter _historyStreamDateFilter = _HistoryDateFilter.all;
  final List<CallHistoryEntry> _historyLoadedMoreEntries = <CallHistoryEntry>[];
  List<CallHistoryEntry> _historyCurrentPersistedEntries = <CallHistoryEntry>[];
  List<ContactEntry>? _historyContactIndexSource;
  Map<String, ContactEntry> _historyContactIndex =
      const <String, ContactEntry>{};
  bool _historyLoadingMore = false;
  bool _historyHasMoreAfterLoaded = false;
  String? _historyLoadMoreToken;
  Stream<int>? _unreadMissedCallCountStream;
  StreamSubscription<int>? _unreadMissedBadgeSubscription;
  Stream<List<CallHistoryEntry>>? _dialpadRecentHistoryStream;
  int? _focusedCallDetailId;
  String? _selectedHistoryItemKey;
  int? _selectedOutgoingAccountId;
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;
  bool _exportingDiagnosticLogs = false;
  late String _lastDialpadValue;
  bool _normalizingDialpadNumber = false;
  String? _activeDialpadKey;
  String? _hoveredDialpadKey;
  int? _dtmfPadCallId;
  String _dtmfSentPreview = '';
  String? _dtmfStatusText;
  bool _dtmfSendFailed = false;
  Timer? _dialpadKeyFeedbackTimer;
  Timer? _dialpadPageWarmupTimer;
  Timer? _contactFlashTimer;
  String? _callNoteControllerKey;
  _CallNoteMode _callNoteMode = _CallNoteMode.customer;
  final Map<int, String> _pendingCallOperations = <int, String>{};
  final Map<int, Timer> _pendingCallOperationTimers = <int, Timer>{};
  Timer? _conferenceActionCooldownTimer;
  bool _conferenceActionCoolingDown = false;
  bool _applicationRestarting = false;
  Future<void>? _applicationExitFuture;
  late final Future<PackageInfo> _packageInfoFuture;
  int _workspacePageLoadTraceSequence = 0;
  _WorkspacePageLoadTrace? _workspacePageLoadTrace;

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
      _bindUnreadMissedAppBadge();
      _scheduleDialpadPageWarmup();
    });
  }

  @override
  void dispose() {
    _dialpadKeyFeedbackTimer?.cancel();
    _dialpadPageWarmupTimer?.cancel();
    unawaited(_unreadMissedBadgeSubscription?.cancel());
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
      onExitApplication: _prepareForApplicationExit,
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
      onExitApplication: _prepareForApplicationExit,
      onIncomingRingtoneChanged: (enabled) {
        ref
            .read(pjsipServiceProvider.notifier)
            .setIncomingRingtoneEnabled(enabled);
      },
    );
  }

  Future<void> _prepareForApplicationExit() async {
    return _applicationExitFuture ??= _performApplicationExitPreparation();
  }

  Future<void> _performApplicationExitPreparation() async {
    try {
      await _unreadMissedBadgeSubscription?.cancel();
      _unreadMissedBadgeSubscription = null;
    } catch (_) {
      // 退出时取消角标订阅失败不影响应用关闭。
    }

    await ref.read(appShutdownCoordinatorProvider).shutdown();
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
    // restart_app 会终止当前进程。先复用正常退出流程，确保 PJSIP 回调停止，
    // 并等待已接收的通话记录写入完成；原生数据库连接由进程退出统一回收。
    await _prepareForApplicationExit();
    final accepted = await AppRestartController.instance.restartApplication();
    if (!accepted) {
      // 资源已完成关闭，重启失败后不能继续留在当前进程中操作已关闭的数据库。
      await AppTrayController.instance.exitApplication();
    }
  }
}
