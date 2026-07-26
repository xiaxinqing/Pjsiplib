part of '../../../../main.dart';

/// 首页级协调方法：负责工作区切换、拨号盘按键状态、默认外呼线路和调试面板显隐。
extension _HomePageCoordinator on _MyHomePageState {
  /// 切换首页工作区，并在进入/离开拨号页时管理按键音资源热身。
  void _selectSection(_WorkspaceSection section) {
    final previous = _section;
    if (previous == section) return;
    _update(() => _section = section);
    final service = ref.read(pjsipServiceProvider.notifier);
    if (section == _WorkspaceSection.dialpad) {
      _scheduleDialpadKeySoundPageWarmup();
    } else if (previous == _WorkspaceSection.dialpad) {
      _dialpadKeySoundPageWarmupTimer?.cancel();
      service.releaseDialpadKeySoundSoon();
    }
  }

  /// 延迟预热拨号按键音，避免打开页面时立刻占用音频资源。
  void _scheduleDialpadKeySoundPageWarmup() {
    _dialpadKeySoundPageWarmupTimer?.cancel();
    _dialpadKeySoundPageWarmupTimer = Timer(
      _dialpadKeySoundPageWarmupDelay,
      () {
        _dialpadKeySoundPageWarmupTimer = null;
        if (!mounted || _section != _WorkspaceSection.dialpad) return;
        ref.read(pjsipServiceProvider.notifier).prepareDialpadKeySound();
      },
    );
  }

  /// 当电话服务或按键音设置变为可用时，重新安排拨号按键音预热。
  void _syncDialpadKeySoundWarmup(PjsipUIState? previous, PjsipUIState next) {
    if (_section != _WorkspaceSection.dialpad) return;
    if (!next.isInitialized || !next.dialpadKeySoundEnabled) return;
    final becameReady =
        previous == null ||
        !previous.isInitialized ||
        !previous.dialpadKeySoundEnabled;
    if (!becameReady) return;
    _scheduleDialpadKeySoundPageWarmup();
  }

  /// 根据账号注册状态同步默认外呼线路，避免选中已不可用账号。
  void _syncSelectedOutgoingAccount(PjsipUIState state) {
    if (state.accounts.isEmpty) {
      if (_selectedOutgoingAccountId != null) {
        _update(() => _selectedOutgoingAccountId = null);
      }
      return;
    }
    final nextId = state.bestOutgoingAccount?.accId;
    if (_selectedOutgoingAccountId == nextId) {
      return;
    }
    _update(() => _selectedOutgoingAccountId = nextId);
  }

  /// 用户手动选择拨号页外呼线路时记录当前账号。
  void _selectOutgoingAccount(int? accountId) {
    _update(() => _selectedOutgoingAccountId = accountId);
  }

  /// 控制诊断日志面板显示状态。
  void _setDiagnosticLogsVisible(bool value) {
    _update(() => _showDiagnosticLogs = value);
  }
}
