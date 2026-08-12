part of '../../../main.dart';

/// 首页主工作区当前展示的业务页面。
///
/// 侧边栏、托盘菜单及呼叫跳转都通过该枚举切换中央内容区
enum _WorkspaceSection { dialpad, calls, contacts, history }

/// 当前通话页的备注写入范围。
///
/// [customer] 只更新主接客户 当前客户对应的通话备注；[conference] 将同一份备注
/// 作为会议共享备注同步给当前会议成员，供会议拆分、合并及通话记录保存使用。
enum _CallNoteMode { customer, conference }

/// 当前通话正在执行的操作类型。
///
/// 业务状态使用枚举保存，界面展示通过本地化资源转换，避免通过文案反推操作逻辑。
enum _CallOperationType {
  answer,
  reject,
  hangup,
  hold,
  resume,
  split,
  merge,
  transfer,
}

extension _CallOperationTypeLabel on _CallOperationType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case _CallOperationType.answer:
        return l10n.activeCallOperationAnswering;
      case _CallOperationType.reject:
        return l10n.activeCallOperationRejecting;
      case _CallOperationType.hangup:
        return l10n.activeCallOperationEnding;
      case _CallOperationType.hold:
        return l10n.activeCallOperationHolding;
      case _CallOperationType.resume:
        return l10n.activeCallOperationResuming;
      case _CallOperationType.split:
        return l10n.activeCallOperationSplitting;
      case _CallOperationType.merge:
        return l10n.activeCallOperationMerging;
      case _CallOperationType.transfer:
        return l10n.activeCallOperationTransferring;
    }
  }
}

/// 系人/通话记录从工作区切换到完整内容绘制完成的性能分析。
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
  // 窗口与基础输入控制器。
  final AppWindowController _windowController = AppWindowController();
  final TextEditingController _numberController = TextEditingController(
    text: '',
    // text: '6529',
  );
  final FocusNode _numberFocusNode = FocusNode();

  // 联系人和通话记录的搜索输入；由各自工作区复用并在页面切换后保留内容。
  final TextEditingController _contactSearchController =
      TextEditingController();
  final TextEditingController _historySearchController =
      TextEditingController();

  // 当前通话/会议共享备注的编辑控制器。
  final TextEditingController _callNoteController = TextEditingController();

  // 联系人列表的选择、详情定位及短暂闪烁提示状态。
  final ScrollController _contactListScrollController = ScrollController();

  final Set<String> _selectedContactIds = <String>{};
  String? _selectedContactDetailId;
  String? _flashingContactId;

  // 数据尚未加载时先记录待定位联系人，数据就绪后再滚动到对应行。
  String? _pendingContactRevealId;

  // 防止同一联系人在一帧内被重复安排滚动定位。
  String? _scheduledContactRevealId;
  int _contactFlashPhase = 0;

  // 联系人详情中的历史记录流缓存；联系人或号码未变化时不重新创建查询流。
  String? _contactDetailHistoryContactId;
  String _contactDetailHistoryPhoneNumber = '';
  Stream<List<CallHistoryEntry>>? _contactDetailHistoryStream;

  // 当前通话右侧客户上下文中的历史记录流缓存。
  String? _callContextHistoryContactId;
  String _callContextHistoryPhoneNumber = '';
  Stream<List<CallHistoryEntry>>? _callContextHistoryStream;

  // 当前无通话时，右侧区域展示的最近通话记录流。
  Stream<List<CallHistoryEntry>>? _callsIdleRecentHistoryStream;

  // 首页导航与通话记录筛选状态。
  _WorkspaceSection _section = _WorkspaceSection.dialpad;
  _HistoryCallFilter _historyCallFilter = _HistoryCallFilter.all;
  _HistoryDateFilter _historyDateFilter = _HistoryDateFilter.all;

  // 当前筛选条件对应的首屏历史记录流及其缓存键。
  Stream<List<CallHistoryEntry>>? _historyEntriesStream;
  String _historyStreamKeyword = '';
  _HistoryCallFilter _historyStreamCallFilter = _HistoryCallFilter.all;
  _HistoryDateFilter _historyStreamDateFilter = _HistoryDateFilter.all;

  // “加载更多”追加的数据和分页状态；首屏流更新时会与追加数据合并展示。
  final List<CallHistoryEntry> _historyLoadedMoreEntries = <CallHistoryEntry>[];
  List<CallHistoryEntry> _historyCurrentPersistedEntries = <CallHistoryEntry>[];
  bool _historyLoadingMore = false;
  bool _historyHasMoreAfterLoaded = false;
  String? _historyLoadMoreToken;

  // 通话记录关联联系人时使用的号码索引，源列表未变化时直接复用 Map。
  List<ContactEntry>? _historyContactIndexSource;
  Map<String, ContactEntry> _historyContactIndex =
      const <String, ContactEntry>{};

  // 未读未接来电数量同时驱动侧边栏和系统应用角标。
  Stream<int>? _unreadMissedCallCountStream;
  StreamSubscription<int>? _unreadMissedBadgeSubscription;

  // 拨号页右侧“最近通话”的查询流缓存。
  Stream<List<CallHistoryEntry>>? _dialpadRecentHistoryStream;

  // 当前通话和历史记录详情的选中状态。
  int? _focusedCallDetailId;
  String? _selectedHistoryItemKey;

  // 拨号页用户显式选择的外呼线路；为空时由服务使用默认线路。
  int? _selectedOutgoingAccountId;

  // 通话中软键盘及诊断页的局部界面状态。
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;
  bool _exportingDiagnosticLogs = false;

  // DTMF 键盘使用独立浮层，避免展开时推动主舞台内容和操作按钮。
  final OverlayPortalController _inCallDialpadOverlayController =
      OverlayPortalController(debugLabel: 'in-call-dtmf');
  final Object _inCallDialpadTapRegionGroup = Object();

  // 拨号输入清洗、鼠标反馈和键盘联动状态。
  late String _lastDialpadValue;
  bool _normalizingDialpadNumber = false;
  String? _activeDialpadKey;
  String? _hoveredDialpadKey;

  // DTMF 浮层当前绑定的通话及最近发送结果。
  int? _dtmfPadCallId;
  String _dtmfSentPreview = '';
  String? _dtmfStatusText;
  bool _dtmfSendFailed = false;

  // 拨号反馈、声卡预热和联系人闪烁使用的短生命周期定时器。
  Timer? _dialpadKeyFeedbackTimer;
  Timer? _dialpadPageWarmupTimer;
  Timer? _contactFlashTimer;

  // 备注控制器当前绑定的 call/conference 键，避免 build 时覆盖用户输入。
  String? _callNoteControllerKey;
  _CallNoteMode _callNoteMode = _CallNoteMode.customer;

  // 每路通话正在执行的异步操作及超时清理定时器，用于禁用重复点击并展示状态。
  final Map<int, _CallOperationType> _pendingCallOperations =
      <int, _CallOperationType>{};
  final Map<int, Timer> _pendingCallOperationTimers = <int, Timer>{};

  // 合并、拆分和保持操作共用的短暂冷却状态，避免快速操作底层媒体桥。
  Timer? _conferenceActionCooldownTimer;
  bool _conferenceActionCoolingDown = false;

  // 应用重启/退出的幂等状态，防止系统菜单和托盘同时触发重复清理。
  bool _applicationRestarting = false;
  Future<void>? _applicationExitFuture;

  // 关于页使用的应用版本信息，只在首页生命周期内读取一次。
  late final Future<PackageInfo> _packageInfoFuture;

  // 联系人和通话记录页面的首帧性能采样状态。
  int _workspacePageLoadTraceSequence = 0;
  _WorkspacePageLoadTrace? _workspacePageLoadTrace;

  @override
  void initState() {
    super.initState();
    // 读取应用版本信息。
    _packageInfoFuture = PackageInfo.fromPlatform();
    // 监听拨号输入框变化。
    _lastDialpadValue = _numberController.text;
    _numberController.addListener(_handleNumberControllerChanged);
    // 关闭到托盘。
    unawaited(_windowController.attachCloseToTrayBehavior());
    // 绑定托盘和 Dock 菜单事件。
    _bindTrayActions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isRunningWidgetTest) return;
      // 通话记录数据库
      unawaited(_warmUpHistoryDatabase());
      // 监听未读未接来电数量
      _bindUnreadMissedAppBadge();
      // 拨号按键音预热
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
    unawaited(
      AppDockMenuController.instance.updateMenuLabels(
        AppDockMenuLabels.localized(context.l10n),
      ),
    );

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
        _openSettingsDrawer(tabIndex: _settingsAboutIndex);
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
        _openSettingsDrawer(tabIndex: _settingsAboutIndex);
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
      labels: AppTrayMenuLabels.localized(context.l10n),
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
