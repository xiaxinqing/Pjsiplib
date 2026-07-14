part of '../../main.dart';

extension _HomeWorkspace on _MyHomePageState {
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
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _appBackground,
        border: Border(bottom: BorderSide(color: _softBorder)),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
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
      style: FilledButton.styleFrom(backgroundColor: _textPrimary),
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
      color: _panelBackground,
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
                  backgroundColor: _callGreen,
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
    _selectSection(_WorkspaceSection.calls);
  }
}
