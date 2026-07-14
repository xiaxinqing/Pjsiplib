import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'src/services/pjsip_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xff2f6fed),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'VoIP Desk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: base.copyWith(
          surface: Colors.white,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xfff8fafc),
          surfaceContainer: const Color(0xfff1f4f8),
          surfaceContainerHigh: const Color(0xffe8edf4),
        ),
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

enum _WorkspaceSection { dialpad, calls, contacts, history }

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
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
  _WorkspaceSection _section = _WorkspaceSection.dialpad;
  bool _showInCallDialpad = false;
  bool _showDiagnosticLogs = true;
  bool _hidePassword = true;

  @override
  void dispose() {
    _numberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(pjsipServiceProvider);
    final service = ref.read(pjsipServiceProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildSettingsDrawer(uiState, service),
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(uiState),
            const VerticalDivider(width: 1),
            Expanded(child: _buildWorkspace(uiState, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(PjsipUIState uiState) {
    return Container(
      width: 236,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_in_talk, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'VoIP Desk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildConnectionPill(uiState),
          const SizedBox(height: 18),
          _buildNavItem(
            icon: Icons.dialpad,
            label: '拨号',
            section: _WorkspaceSection.dialpad,
          ),
          _buildNavItem(
            icon: Icons.call,
            label: '当前通话',
            section: _WorkspaceSection.calls,
            badge: uiState.calls.isEmpty ? null : '${uiState.calls.length}',
          ),
          _buildNavItem(
            icon: Icons.contacts,
            label: '联系人',
            section: _WorkspaceSection.contacts,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: '通话记录',
            section: _WorkspaceSection.history,
          ),
          const Spacer(),
          _buildAudioMiniStatus(uiState),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.settings),
            label: const Text('设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPill(PjsipUIState uiState) {
    final isRegistered = uiState.accId != -1;
    final color = !uiState.isNetworkAvailable
        ? Colors.orange.shade700
        : isRegistered
        ? Colors.green.shade600
        : Theme.of(context).colorScheme.outline;
    final label = !uiState.isNetworkAvailable
        ? '网络不可用'
        : isRegistered
        ? '电话服务已连接'
        : uiState.isInitialized
        ? '等待账号连接'
        : '未连接';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required _WorkspaceSection section,
    String? badge,
  }) {
    final selected = _section == section;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _section = section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 20, color: selected ? colors.primary : null),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMiniStatus(PjsipUIState uiState) {
    final mic = _deviceLabelById(
      uiState.captureDevices,
      uiState.selectedCaptureDeviceId,
    );
    final speaker = _deviceLabelById(
      uiState.playbackDevices,
      uiState.selectedPlaybackDeviceId,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTinyDeviceLine(Icons.mic, mic),
          const SizedBox(height: 8),
          _buildTinyDeviceLine(Icons.volume_up, speaker),
        ],
      ),
    );
  }

  Widget _buildTinyDeviceLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildWorkspace(PjsipUIState uiState, PjsipService service) {
    return Column(
      children: [
        _buildTopBar(uiState, service),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (_section) {
              _WorkspaceSection.dialpad => _buildDialpadPage(uiState, service),
              _WorkspaceSection.calls => _buildCallsPage(uiState, service),
              _WorkspaceSection.contacts => _buildContactsPage(
                uiState,
                service,
              ),
              _WorkspaceSection.history => _buildHistoryPage(uiState, service),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(PjsipUIState uiState, PjsipService service) {
    final title = switch (_section) {
      _WorkspaceSection.dialpad => '拨号',
      _WorkspaceSection.calls => '当前通话',
      _WorkspaceSection.contacts => '联系人',
      _WorkspaceSection.history => '通话记录',
    };
    final subtitle = _statusSubtitle(uiState);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _buildHeaderAction(uiState, service),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '设置',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(PjsipUIState uiState, PjsipService service) {
    if (uiState.accId != -1) {
      return FilledButton.tonalIcon(
        onPressed: uiState.isInitialized ? service.stop : null,
        icon: const Icon(Icons.power_settings_new),
        label: const Text('断开'),
      );
    }
    return FilledButton.icon(
      onPressed: uiState.isNetworkAvailable
          ? () => service.register(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              host: _hostController.text.trim(),
            )
          : null,
      icon: const Icon(Icons.login),
      label: const Text('连接'),
    );
  }

  String _statusSubtitle(PjsipUIState uiState) {
    if (!uiState.isNetworkAvailable) return '当前网络不可用';
    if (uiState.accId != -1) return '已连接到 ${uiState.host}';
    if (uiState.isInitialized) return '引擎已就绪，账号尚未连接';
    return '连接电话服务后即可发起和接听通话';
  }

  Widget _buildDialpadPage(PjsipUIState uiState, PjsipService service) {
    final canCall =
        uiState.accId != -1 &&
        uiState.calls.length < 4 &&
        !uiState.hasConference;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _buildDialpadCard(uiState, service, canCall),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _buildLiveCallsPanel(uiState, service)),
      ],
    );
  }

  Widget _buildDialpadCard(
    PjsipUIState uiState,
    PjsipService service,
    bool canCall,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _numberController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                hintText: '输入号码',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: '清空',
                  onPressed: () => _numberController.clear(),
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _callNumberIfPossible(canCall, service),
            ),
            const SizedBox(height: 18),
            _buildNumberPad(),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: canCall
                    ? () => _callNumberIfPossible(canCall, service)
                    : null,
                icon: const Icon(Icons.call),
                label: const Text('呼叫'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return OutlinedButton(
          onPressed: () {
            final value = _numberController.text;
            final selection = _numberController.selection;
            final start = selection.start < 0 ? value.length : selection.start;
            final end = selection.end < 0 ? value.length : selection.end;
            _numberController.value = TextEditingValue(
              text: value.replaceRange(start, end, key),
              selection: TextSelection.collapsed(offset: start + 1),
            );
          },
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }

  void _callNumberIfPossible(bool canCall, PjsipService service) {
    final number = _numberController.text.trim();
    if (!canCall || number.isEmpty) return;
    service.makeCall(number);
    setState(() => _section = _WorkspaceSection.calls);
  }

  Widget _buildCallsPage(PjsipUIState uiState, PjsipService service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: _buildPrimaryCallStage(uiState, service)),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _buildLiveCallsPanel(uiState, service)),
      ],
    );
  }

  Widget _buildPrimaryCallStage(PjsipUIState uiState, PjsipService service) {
    final primary = _primaryCall(uiState);
    if (primary == null) {
      return _buildEmptyState(
        icon: Icons.call,
        title: '暂无通话',
        action: FilledButton.icon(
          onPressed: () => setState(() => _section = _WorkspaceSection.dialpad),
          icon: const Icon(Icons.dialpad),
          label: const Text('去拨号'),
        ),
      );
    }

    final isConferenceMember = uiState.isInConference(primary.callId);
    final isConferencePaused = uiState.isConferencePaused;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _avatarText(primary.remoteUri),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _displayRemote(primary.remoteUri),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              primary.statusLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (primary.isConnected)
              Text(
                primary.durationLabel,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              )
            else
              const SizedBox(height: 50),
            const SizedBox(height: 20),
            if (isConferenceMember)
              Chip(
                avatar: Icon(isConferencePaused ? Icons.pause : Icons.groups),
                label: Text(isConferencePaused ? '会议已暂停' : '三方通话'),
              ),
            const SizedBox(height: 22),
            _buildPrimaryCallControls(primary, uiState, service),
            if (_showInCallDialpad && primary.isConnected) ...[
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: _buildDtmfPad(primary, service),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCallControls(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isConferenceMember = uiState.isInConference(call.callId);
    final controls = <Widget>[];

    if (call.isIncoming && !call.isConnected) {
      controls.addAll([
        _roundCallButton(
          icon: Icons.call,
          label: '接听',
          color: Colors.green.shade600,
          onPressed: () => service.answerCall(call.callId),
        ),
        _roundCallButton(
          icon: Icons.call_end,
          label: '拒接',
          color: Colors.red.shade600,
          onPressed: () => service.rejectCall(call.callId),
        ),
      ]);
    } else {
      controls.addAll([
        _roundCallButton(
          icon: uiState.isMicrophoneMuted ? Icons.mic_off : Icons.mic,
          label: uiState.isMicrophoneMuted ? '取消静音' : '静音',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () =>
              service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
        ),
        _roundCallButton(
          icon: Icons.dialpad,
          label: '键盘',
          color: _showInCallDialpad
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected
              ? () => setState(() => _showInCallDialpad = !_showInCallDialpad)
              : null,
        ),
        _roundCallButton(
          icon: call.isOnHold ? Icons.play_arrow : Icons.pause,
          label: call.isOnHold ? '恢复' : '保持',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: call.isConnected && !isConferenceMember
              ? () => call.isOnHold
                    ? service.unholdCall(call.callId)
                    : service.holdCall(call.callId)
              : null,
        ),
        _roundCallButton(
          icon: Icons.tune,
          label: '音频',
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        _roundCallButton(
          icon: Icons.call_end,
          label: '挂断',
          color: Colors.red.shade600,
          onPressed: () => service.hangupCall(call.callId),
        ),
      ]);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: controls,
    );
  }

  Widget _buildDtmfPad(CallInfo call, PjsipService service) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return FilledButton.tonal(
          onPressed: () => service.sendDtmf(call.callId, key),
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }

  Widget _roundCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: 26,
            style: IconButton.styleFrom(
              backgroundColor: color,
              foregroundColor: color.computeLuminance() > 0.45
                  ? Colors.black87
                  : Colors.white,
              disabledBackgroundColor: Theme.of(context).disabledColor,
              minimumSize: const Size(58, 58),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLiveCallsPanel(PjsipUIState uiState, PjsipService service) {
    final calls = uiState.calls.values.toList();
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.call, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '当前通话',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (uiState.isConferencePaused)
                  TextButton.icon(
                    onPressed: service.resumeConference,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('恢复会议'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: calls.isEmpty
                  ? Center(
                      child: Text(
                        '没有活动通话',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: calls.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _buildCallListTile(calls[index], uiState, service),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallListTile(
    CallInfo call,
    PjsipUIState uiState,
    PjsipService service,
  ) {
    final isActive = uiState.activeCallId == call.callId;
    final isConferenceMember = uiState.isInConference(call.callId);
    final canMergeWithActive =
        !uiState.hasConference &&
        call.isConnected &&
        !call.isRemoteOnHold &&
        uiState.activeCallId != null &&
        uiState.activeCallId != call.callId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive || isConferenceMember
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(_avatarText(call.remoteUri)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayRemote(call.remoteUri),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.isConnected ? call.durationLabel : call.statusLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isConferenceMember)
                const Icon(Icons.groups, size: 18)
              else if (isActive)
                const Icon(Icons.graphic_eq, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (call.isIncoming && !call.isConnected) ...[
                FilledButton.tonalIcon(
                  onPressed: () => service.answerCall(call.callId),
                  icon: const Icon(Icons.call),
                  label: const Text('接听'),
                ),
                OutlinedButton.icon(
                  onPressed: () => service.rejectCall(call.callId),
                  icon: const Icon(Icons.call_end),
                  label: const Text('拒接'),
                ),
              ],
              if (call.isConnected && !isConferenceMember)
                OutlinedButton.icon(
                  onPressed: () => call.isOnHold
                      ? service.unholdCall(call.callId)
                      : service.holdCall(call.callId),
                  icon: Icon(call.isOnHold ? Icons.play_arrow : Icons.pause),
                  label: Text(call.isOnHold ? '恢复' : '保持'),
                ),
              if (canMergeWithActive)
                OutlinedButton.icon(
                  onPressed: () => service.mergeWithActiveCall(call.callId),
                  icon: const Icon(Icons.groups),
                  label: const Text('合并'),
                ),
              if (isConferenceMember && !uiState.isConferencePaused)
                OutlinedButton.icon(
                  onPressed: () => service.splitConference(call.callId),
                  icon: const Icon(Icons.call_split),
                  label: const Text('拆分'),
                ),
              FilledButton.tonalIcon(
                onPressed: () => service.hangupCall(call.callId),
                icon: const Icon(Icons.call_end),
                label: const Text('挂断'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactsPage(PjsipUIState uiState, PjsipService service) {
    final contacts = const [
      ('6529', '前台'),
      ('6530', '客服一组'),
      ('6531', '客服二组'),
      ('6532', '技术支持'),
    ];
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: contacts.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final (number, name) = contacts[index];
          return ListTile(
            leading: CircleAvatar(child: Text(name.characters.first)),
            title: Text(name),
            subtitle: Text(number),
            trailing: IconButton.filledTonal(
              tooltip: '呼叫',
              onPressed: uiState.accId == -1
                  ? null
                  : () {
                      _numberController.text = number;
                      service.makeCall(number);
                      setState(() => _section = _WorkspaceSection.calls);
                    },
              icon: const Icon(Icons.call),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryPage(PjsipUIState uiState, PjsipService service) {
    final recent = uiState.logs
        .where(
          (log) => log.message.contains('拨打') || log.message.contains('来电'),
        )
        .toList()
        .reversed
        .take(12)
        .toList();

    if (recent.isEmpty) {
      return _buildEmptyState(icon: Icons.history, title: '暂无通话记录');
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: recent.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = recent[index];
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(
              item.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(item.time)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    Widget? action,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (action != null) ...[const SizedBox(height: 18), action],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDrawer(PjsipUIState uiState, PjsipService service) {
    return Drawer(
      width: 460,
      child: SafeArea(
        child: DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.account_circle), text: '账号'),
                  Tab(icon: Icon(Icons.headphones), text: '音频'),
                  Tab(icon: Icon(Icons.call), text: '通话'),
                  Tab(icon: Icon(Icons.bug_report), text: '诊断'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAccountSettingsTab(uiState, service),
                    _buildAudioSettingsTab(uiState, service),
                    _buildCallSettingsTab(uiState, service),
                    _buildDiagnosticsTab(uiState, service),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '连接',
          icon: Icons.cloud_done,
          children: [
            _buildConnectionPill(uiState),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '账号',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? '显示密码' : '隐藏密码',
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: '服务器',
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: uiState.isNetworkAvailable
                        ? () => service.register(
                            username: _usernameController.text.trim(),
                            password: _passwordController.text,
                            host: _hostController.text.trim(),
                          )
                        : null,
                    icon: const Icon(Icons.login),
                    label: Text(uiState.accId == -1 ? '连接' : '重新连接'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: uiState.isInitialized ? service.stop : null,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('断开'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioSettingsTab(PjsipUIState uiState, PjsipService service) {
    if (!uiState.isInitialized) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => service.register(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            host: _hostController.text.trim(),
          ),
          icon: const Icon(Icons.login),
          label: const Text('连接电话服务'),
        ),
      );
    }

    final micLevel = (uiState.microphoneLevel / 255.0).clamp(0.0, 1.0);
    final speakerLevel = (uiState.speakerLevel / 255.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '设备',
          icon: Icons.devices,
          children: [_buildAudioDevicePanel(uiState, service)],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '测试',
          icon: Icons.graphic_eq,
          children: [
            _buildLevelTile(
              icon: Icons.mic,
              label: '麦克风输入',
              value: micLevel,
              muted: uiState.isMicrophoneMuted,
            ),
            const SizedBox(height: 12),
            _buildLevelTile(
              icon: Icons.volume_up,
              label: '扬声器输出',
              value: speakerLevel,
              muted: uiState.isSpeakerMuted,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => service.setMicrophoneTesting(
                    !uiState.isMicrophoneTesting,
                  ),
                  icon: Icon(
                    uiState.isMicrophoneTesting ? Icons.stop : Icons.mic,
                  ),
                  label: Text(
                    uiState.isMicrophoneTesting ? '停止麦克风测试' : '开始麦克风测试',
                  ),
                ),
                FilledButton.icon(
                  onPressed: uiState.isSpeakerTesting
                      ? null
                      : service.testSpeakerOutput,
                  icon: const Icon(Icons.volume_up),
                  label: Text(uiState.isSpeakerTesting ? '播放中' : '测试扬声器'),
                ),
                OutlinedButton.icon(
                  onPressed: service.repairAudioPath,
                  icon: const Icon(Icons.healing),
                  label: const Text('修复音频'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '策略',
          icon: Icons.auto_mode,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.audioDeviceMode == PjsipAudioDeviceMode.automatic,
              onChanged: service.setAutomaticAudioDeviceSelection,
              secondary: const Icon(Icons.auto_mode),
              title: const Text('自动选择设备'),
              subtitle: const Text('优先耳机/蓝牙设备'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(Icons.sync),
              title: const Text('通话中自动切换'),
              subtitle: const Text('耳机插拔时恢复音频路径'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallSettingsTab(PjsipUIState uiState, PjsipService service) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(
          title: '通话控制',
          icon: Icons.call,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups),
              title: const Text('最大同时通话'),
              trailing: const Text('4 路'),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dialpad),
              title: const Text('DTMF 方式'),
              trailing: const Text('RFC2833'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: uiState.allowInCallAudioDeviceSwitch,
              onChanged: service.setAllowInCallAudioDeviceSwitch,
              secondary: const Icon(Icons.headset_mic),
              title: const Text('通话中跟随耳机切换'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: '快捷操作',
          icon: Icons.bolt,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.mic_off),
              title: const Text('默认静音状态'),
              trailing: const Text('关闭'),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.call_merge),
              title: const Text('会议通话'),
              trailing: Text(uiState.hasConference ? '进行中' : '可用'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioDevicePanel(PjsipUIState uiState, PjsipService service) {
    final captureValue =
        uiState.captureDevices.any(
          (device) => device.id == uiState.selectedCaptureDeviceId,
        )
        ? uiState.selectedCaptureDeviceId
        : null;
    final playbackValue =
        uiState.playbackDevices.any(
          (device) => device.id == uiState.selectedPlaybackDeviceId,
        )
        ? uiState.selectedPlaybackDeviceId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                uiState.audioDeviceStatus,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            OutlinedButton.icon(
              onPressed: service.refreshAudioDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<PjsipAudioDeviceMode>(
          segments: const [
            ButtonSegment(
              value: PjsipAudioDeviceMode.automatic,
              icon: Icon(Icons.auto_mode),
              label: Text('自动'),
            ),
            ButtonSegment(
              value: PjsipAudioDeviceMode.manual,
              icon: Icon(Icons.tune),
              label: Text('手动'),
            ),
          ],
          selected: {uiState.audioDeviceMode},
          onSelectionChanged: (values) {
            service.setAutomaticAudioDeviceSelection(
              values.first == PjsipAudioDeviceMode.automatic,
            );
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: captureValue,
          decoration: const InputDecoration(
            labelText: '麦克风',
            prefixIcon: Icon(Icons.mic),
          ),
          items: uiState.captureDevices
              .map(
                (device) => DropdownMenuItem<int>(
                  value: device.id,
                  child: Text(device.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) service.setAudioDevices(captureDeviceId: value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: playbackValue,
          decoration: const InputDecoration(
            labelText: '扬声器',
            prefixIcon: Icon(Icons.volume_up),
          ),
          items: uiState.playbackDevices
              .map(
                (device) => DropdownMenuItem<int>(
                  value: device.id,
                  child: Text(device.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) service.setAudioDevices(playbackDeviceId: value);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: () =>
                  service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
              icon: Icon(uiState.isMicrophoneMuted ? Icons.mic_off : Icons.mic),
              label: Text(uiState.isMicrophoneMuted ? '取消静音' : '麦克风静音'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => service.setSpeakerMuted(!uiState.isSpeakerMuted),
              icon: Icon(
                uiState.isSpeakerMuted ? Icons.volume_off : Icons.volume_up,
              ),
              label: Text(uiState.isSpeakerMuted ? '取消静音' : '扬声器静音'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required IconData icon,
    required String label,
    required double value,
    required bool muted,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        SizedBox(width: 86, child: Text(label)),
        Expanded(child: LinearProgressIndicator(value: muted ? 0 : value)),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          child: Text(
            muted ? '静音' : '${(value * 100).round()}%',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsTab(PjsipUIState uiState, PjsipService service) {
    return Column(
      children: [
        SwitchListTile(
          value: _showDiagnosticLogs,
          onChanged: (value) => setState(() => _showDiagnosticLogs = value),
          secondary: const Icon(Icons.receipt_long),
          title: const Text('显示日志'),
          subtitle: const Text('设备、注册、通话事件'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: uiState.isInitialized
                    ? service.refreshAudioDevices
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新设备'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: uiState.logs.isEmpty ? null : service.clearLogs,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('清空日志'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _showDiagnosticLogs
              ? _buildLogList(uiState)
              : const Center(child: Text('日志已隐藏')),
        ),
      ],
    );
  }

  Widget _buildLogList(PjsipUIState uiState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: uiState.logs.length,
        itemBuilder: (context, index) {
          final log = uiState.logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '[${DateFormat('HH:mm:ss').format(log.time)}] ${log.message}',
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  CallInfo? _primaryCall(PjsipUIState uiState) {
    if (uiState.activeCall != null) return uiState.activeCall;
    for (final call in uiState.calls.values) {
      if (call.isIncoming) return call;
    }
    return uiState.calls.values.isEmpty ? null : uiState.calls.values.first;
  }

  String _deviceLabelById(List<PjsipAudioDevice> devices, int? id) {
    if (id == null) return '未选择';
    for (final device in devices) {
      if (device.id == id) return device.name;
    }
    return '设备不可用';
  }

  String _displayRemote(String remoteUri) {
    final sipIndex = remoteUri.indexOf('sip:');
    var value = sipIndex >= 0 ? remoteUri.substring(sipIndex + 4) : remoteUri;
    final atIndex = value.indexOf('@');
    if (atIndex > 0) value = value.substring(0, atIndex);
    final semicolonIndex = value.indexOf(';');
    if (semicolonIndex > 0) value = value.substring(0, semicolonIndex);
    return value.replaceAll('<', '').replaceAll('>', '');
  }

  String _avatarText(String remoteUri) {
    final value = _displayRemote(remoteUri).trim();
    if (value.isEmpty) return '?';
    return value.characters.first.toUpperCase();
  }
}
