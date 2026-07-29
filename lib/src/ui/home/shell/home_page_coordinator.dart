part of '../../../../main.dart';

/// 首页级协调方法：负责工作区切换、默认外呼线路和调试面板显隐。
extension _HomePageCoordinator on _MyHomePageState {
  /// 切换首页工作区。
  void _selectSection(_WorkspaceSection section) {
    if (_section == section) return;
    _dialpadPageWarmupTimer?.cancel();
    _update(() => _section = section);
    if (section == _WorkspaceSection.dialpad) {
      _scheduleDialpadPageWarmup();
    }
  }

  /// 进入拨号页后延迟预热按键音路径，避免首次按键时才同步打开声卡。
  void _scheduleDialpadPageWarmup() {
    _dialpadPageWarmupTimer?.cancel();
    _dialpadPageWarmupTimer = Timer(_dialpadPageWarmupDelay, () {
      _dialpadPageWarmupTimer = null;
      if (!mounted || _section != _WorkspaceSection.dialpad) return;
      ref
          .read(pjsipServiceProvider.notifier)
          .prepareDialpadKeySound(keepAlive: _dialpadPageWarmupKeepAlive);
    });
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
