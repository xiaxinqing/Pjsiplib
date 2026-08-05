part of '../../../../main.dart';

/// 首页级协调方法：负责工作区切换、默认外呼线路和调试面板显隐。
extension _HomePageCoordinator on _MyHomePageState {
  /// 切换首页工作区。
  void _selectSection(_WorkspaceSection section) {
    if (_section == section) return;
    _dialpadPageWarmupTimer?.cancel();
    _beginWorkspacePageLoadTrace(section);
    _update(() => _section = section);
    if (section == _WorkspaceSection.dialpad) {
      _scheduleDialpadPageWarmup();
    }
  }

  /// 从用户切换工作区时开始计时；当前只采样包含数据库内容的两个页面。
  void _beginWorkspacePageLoadTrace(_WorkspaceSection section) {
    /*    if (section != _WorkspaceSection.contacts &&
        section != _WorkspaceSection.history) {
      _workspacePageLoadTrace = null;
      return;
    }*/
    final trace = _WorkspacePageLoadTrace(
      id: ++_workspacePageLoadTraceSequence,
      section: section,
    );
    _workspacePageLoadTrace = trace;
    debugPrint(
      '⏱ 页面加载[${_workspacePageLoadTraceLabel(section)} #${trace.id}] '
      '点击菜单: 0ms',
    );
  }

  /// 记录页面构建入口，只记录当前切换过程中的第一次 build。
  void _traceWorkspacePageBuild(_WorkspaceSection section) {
    final trace = _workspacePageLoadTrace;
    if (trace == null ||
        trace.section != section ||
        trace.completed ||
        trace.buildLogged) {
      return;
    }
    trace.buildLogged = true;
    debugPrint(
      '⏱ 页面加载[${_workspacePageLoadTraceLabel(section)} #${trace.id}] '
      '开始构建: ${trace.stopwatch.elapsedMilliseconds}ms',
    );
  }

  /// 记录首批可展示数据，并在该帧绘制完成后输出用户感知的总加载耗时。
  void _traceWorkspacePageDataReady(
    _WorkspaceSection section, {
    required String summary,
  }) {
    final trace = _workspacePageLoadTrace;
    if (trace == null ||
        trace.section != section ||
        trace.completed ||
        trace.dataLogged) {
      return;
    }
    trace.dataLogged = true;
    debugPrint(
      '⏱ 页面加载[${_workspacePageLoadTraceLabel(section)} #${trace.id}] '
      '数据就绪: ${trace.stopwatch.elapsedMilliseconds}ms, $summary',
    );
    if (trace.contentFrameScheduled) return;
    trace.contentFrameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = _workspacePageLoadTrace;
      if (!mounted ||
          current == null ||
          current.id != trace.id ||
          current.completed) {
        return;
      }
      current
        ..completed = true
        ..stopwatch.stop();
      debugPrint(
        '⏱ 页面加载[${_workspacePageLoadTraceLabel(section)} #${trace.id}] '
        '内容首帧已绘制: ${trace.stopwatch.elapsedMilliseconds}ms',
      );
    });
  }

  String _workspacePageLoadTraceLabel(_WorkspaceSection section) {
    return switch (section) {
      _WorkspaceSection.contacts => '联系人',
      _WorkspaceSection.history => '通话记录',
      _WorkspaceSection.dialpad => '拨号',
      _WorkspaceSection.calls => '当前通话',
    };
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
