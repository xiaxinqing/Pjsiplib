part of '../../../../main.dart';

/// 拨号页主布局：负责左侧拨号卡和右侧通话面板的组合与快捷键绑定。
extension _DialpadPage on _MyHomePageState {
  Widget _buildDialpadPage(PjsipUIState uiState, PjsipService service) {
    _traceWorkspacePageBuild(_WorkspaceSection.dialpad);
    final selectedAccount = _outgoingAccountForDialing(uiState);
    final selectedAccountId = selectedAccount?.accId;
    // 临时只限制容量，网络和注册结果交给原生呼叫返回。
    final canCall =
        selectedAccount != null &&
        uiState.pendingDial == null &&
        uiState.calls.length < 4;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dialpadWidth = math.min(
          420.0,
          math.max(360.0, constraints.maxWidth * 0.42),
        );
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                _clearDialpadNumber(),
            const SingleActivator(LogicalKeyboardKey.numpadEnter): () =>
                _callNumberIfPossible(canCall, service, selectedAccountId),
            const SingleActivator(LogicalKeyboardKey.equal, shift: true): () =>
                _insertDialpadKey('+'),
            const SingleActivator(LogicalKeyboardKey.add): () =>
                _insertDialpadKey('+'),
            const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
                _insertDialpadKey('+'),
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: dialpadWidth,
                child: _buildDialpadCard(
                  uiState,
                  service,
                  canCall,
                  selectedAccountId,
                  selectedAccount,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildLiveCallsPanel(
                  uiState,
                  service,
                  emptyContent: _buildDialpadStandbyPanel(
                    uiState,
                    service,
                    canCall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
