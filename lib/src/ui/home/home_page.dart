part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

enum _CallNoteMode { customer, conference }

const Duration _conferenceActionCooldownDuration = Duration(milliseconds: 1500);
const Duration _dialpadKeySoundPageWarmupDelay = Duration(seconds: 3);
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
  final Set<String> _hoveredContactCallButtonIds = <String>{};
  final Set<String> _focusedContactCallButtonIds = <String>{};
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

  @override
  void initState() {
    super.initState();
    _lastDialpadValue = _numberController.text;
    _numberController.addListener(_handleNumberControllerChanged);
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
}
