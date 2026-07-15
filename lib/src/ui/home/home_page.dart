part of '../../../main.dart';

enum _WorkspaceSection { dialpad, calls, contacts, history }

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with SingleTickerProviderStateMixin {
  final AppWindowController _windowController = AppWindowController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _numberController = TextEditingController(
    text: '6529',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: '6523',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'veserve888',
  );
  final TextEditingController _hostController = TextEditingController(
    text: '139.59.100.15',
  );
  late final TabController _settingsTabController;
  Timer? _settingsPrewarmTimer;
  _WorkspaceSection _section = _WorkspaceSection.dialpad;
  int? _selectedOutgoingAccountId;
  int _settingsTabIndex = 0;
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;
  bool _hidePassword = true;
  bool _settingsPrewarmVisible = false;
  SipTransport _selectedLineTransport = SipTransport.udp;

  @override
  void initState() {
    super.initState();
    _settingsTabController = TabController(length: 4, vsync: this)
      ..addListener(_handleSettingsTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsPrewarmTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _settingsPrewarmVisible = true);
      });
    });
  }

  @override
  void dispose() {
    _settingsPrewarmTimer?.cancel();
    _settingsTabController
      ..removeListener(_handleSettingsTabChanged)
      ..dispose();
    _numberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PjsipUIState>(pjsipServiceProvider, _handleCallWindowAttention);

    final uiState = ref.watch(pjsipServiceProvider);
    final service = ref.read(pjsipServiceProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildSettingsDrawer(uiState, service),
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
          if (_settingsPrewarmVisible)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildSettingsPrewarm(uiState, service),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsPrewarm(PjsipUIState uiState, PjsipService service) {
    return Offstage(
      offstage: true,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: TickerMode(
            enabled: false,
            child: SizedBox(
              width: 460,
              child: _buildSettingsDrawer(uiState, service),
            ),
          ),
        ),
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

  void _registerLine(PjsipService service) {
    final username = _usernameController.text.trim();
    final host = _hostController.text.trim();
    if (username.isEmpty || host.isEmpty) return;
    service.register(
      username: username,
      password: _passwordController.text,
      host: host,
      transport: _selectedLineTransport,
    );
    _usernameController.clear();
    _passwordController.clear();
  }

  void _selectSection(_WorkspaceSection section) {
    setState(() => _section = section);
  }

  void _toggleInCallDialpad() {
    setState(() => _showInCallDialpad = !_showInCallDialpad);
  }

  void _togglePasswordVisibility() {
    setState(() => _hidePassword = !_hidePassword);
  }

  void _selectLineTransport(SipTransport transport) {
    setState(() => _selectedLineTransport = transport);
  }

  void _setDiagnosticLogsVisible(bool value) {
    setState(() => _showDiagnosticLogs = value);
  }

  void _selectOutgoingAccount(int? accountId) {
    setState(() => _selectedOutgoingAccountId = accountId);
  }

  void _openSettingsDrawer({int tabIndex = 0}) {
    if (_settingsTabController.index != tabIndex) {
      _settingsTabController.index = tabIndex;
    }
    if (_settingsTabIndex != tabIndex) {
      setState(() => _settingsTabIndex = tabIndex);
    }
    if (_settingsPrewarmVisible) {
      setState(() => _settingsPrewarmVisible = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scaffoldKey.currentState?.openEndDrawer();
      });
      return;
    }
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _handleSettingsTabChanged() {
    if (_settingsTabController.indexIsChanging) return;
    final nextIndex = _settingsTabController.index;
    if (_settingsTabIndex == nextIndex) return;
    setState(() => _settingsTabIndex = nextIndex);
  }
}
