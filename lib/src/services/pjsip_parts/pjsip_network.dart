part of '../pjsip_service.dart';

/// 网络变化与 SIP 恢复策略。
///
/// 外部网络监听器只调用 [handleNetworkChanged]，不直接操作 PJSIP FFI。
/// 这里负责防抖、避免并发 IP Change，并根据引擎/账号状态选择正确恢复方式。
extension PjsipNetworkOperations on PjsipService {
  /// 启动 connectivity_plus 首次检测与持续监听。整个 PjsipService 生命周期
  /// 只启动一次；Provider 销毁时由 _cleanup() 取消订阅。
  Future<void> _startConnectivityMonitoring() async {
    if (_connectivityMonitorStarted || _isDisposed) return;
    _connectivityMonitorStarted = true;

    // 先订阅再查询当前状态，避免 checkConnectivity() 执行期间漏掉切换事件。
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityResults,
      onError: (Object error, StackTrace stackTrace) {
        if (_isDisposed) return;
        _addLog('❌ 网络监听异常: $error');
      },
    );

    try {
      final initial = await _connectivity.checkConnectivity();
      if (_isDisposed) return;
      _onConnectivityResults(initial);
    } catch (error) {
      if (_isDisposed) return;
      _addLog('❌ 获取初始网络状态失败: $error');
    }
  }

  /// 将 connectivity_plus 的多网络结果转换成 PJSIP 恢复事件。
  ///
  /// connectivity_plus 7 可能同时返回 Wi-Fi、VPN、Ethernet 等多个类型，所以
  /// 使用 Set 比较并去掉 none。首次检测只同步状态，不触发不必要的 IP Change。
  void _onConnectivityResults(List<ConnectivityResult> results) {
    if (_isDisposed) return;
    final currentTypes = results
        .where((result) => result != ConnectivityResult.none)
        .toSet();
    final previousTypes = _lastConnectivityTypes;

    // checkConnectivity 与 stream 可能几乎同时返回；完全相同的结果直接去重。
    if (previousTypes != null &&
        previousTypes.length == currentTypes.length &&
        previousTypes.containsAll(currentTypes)) {
      return;
    }
    _lastConnectivityTypes = currentTypes;

    final isAvailable = currentTypes.isNotEmpty;
    if (previousTypes == null) {
      _uiState = _uiState.copyWith(
        isNetworkAvailable: isAvailable,
        networkState: isAvailable
            ? PjsipNetworkState.idle
            : PjsipNetworkState.offline,
      );
      if (!isAvailable) _pendingIpChange = true;
      _addLog(
        isAvailable
            ? '🌐 初始网络可用: ${_networkTypeLabel(currentTypes)}'
            : '🌐 初始网络不可用',
      );
      return;
    }

    final previousAvailable = previousTypes.isNotEmpty;
    final interfaceChanged =
        previousAvailable && isAvailable && previousTypes != currentTypes;
    _addLog(
      '🌐 网络类型变化: ${_networkTypeLabel(previousTypes)} -> '
      '${_networkTypeLabel(currentTypes)}',
    );
    handleNetworkChanged(
      isAvailable: isAvailable,
      // 从离线恢复必然需要处理旧 Transport；在线网络类型切换也按 IP 变化处理。
      interfaceChanged: !previousAvailable || interfaceChanged,
    );
  }

  String _networkTypeLabel(Set<ConnectivityResult> types) {
    if (types.isEmpty) return 'none';
    return types.map((type) => type.name).join(',');
  }

  /// 通知 PJSIP 网络状态发生变化。
  ///
  /// [isAvailable] 应表示网络基本可用，而不仅是“存在 Wi-Fi 网卡”。
  /// [interfaceChanged] 表示 IP、默认路由、Wi-Fi/网线或 VPN 发生了变化。
  void handleNetworkChanged({
    required bool isAvailable,
    bool interfaceChanged = true,
    Duration debounce = const Duration(seconds: 2),
  }) {
    _networkChangeTimer?.cancel();

    if (!isAvailable) {
      // 离线时不反复 REGISTER，也不销毁 PJSUA；只记录待恢复。网络恢复后
      // 再统一执行 IP Change，可避免网络抖动期间创建多个账号或 Transport。
      _pendingIpChange = true;
      _uiState = _uiState.copyWith(
        isNetworkAvailable: false,
        networkState: PjsipNetworkState.offline,
      );
      _addLog('🌐 网络已断开，等待恢复后重新处理 SIP 注册');
      return;
    }

    _pendingIpChange = _pendingIpChange || interfaceChanged;
    _uiState = _uiState.copyWith(
      isNetworkAvailable: true,
      networkState: PjsipNetworkState.waitingForStableNetwork,
    );

    // 系统切换网络时通常会连续产生多次事件，等待网络稳定后只处理一次。
    _networkChangeTimer = Timer(debounce, _recoverAfterNetworkChange);
  }

  void _recoverAfterNetworkChange() {
    if (!_uiState.isNetworkAvailable) return;

    if (!_uiState.isInitialized) {
      // 引擎尚未初始化时无需调用 IP Change。登录流程取得 SIP 凭证后，正常
      // 执行 init + register 就会使用当前最新网络。
      _pendingIpChange = false;
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.idle);
      _addLog('🌐 网络已恢复；PJSIP 尚未初始化，等待正常登录注册流程');
      return;
    }

    if (_uiState.accounts.isEmpty) {
      // PJSUA 已启动但账号尚未添加，不能调用 acc_set_registration；由登录
      // 流程继续调用 register()。
      _pendingIpChange = false;
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.idle);
      _addLog('🌐 网络已恢复；SIP 账号尚未创建，等待 register()');
      return;
    }

    if (_ipChangeInProgress) {
      // 上一次 IP Change 尚未完成，保留 pending 标记；完成回调后再处理一次。
      _pendingIpChange = true;
      _addLog('🌐 IP Change 正在处理中，已合并本次网络变化');
      return;
    }

    if (_pendingIpChange) {
      _startIpChange();
    } else {
      retrySipRegistration();
    }
  }

  /// IP/路由未变化、只是 SIP 服务器短暂不可达时，可调用此方法重新 REGISTER。
  void retrySipRegistration() {
    if (!_uiState.isInitialized ||
        !_uiState.isNetworkAvailable ||
        _uiState.accounts.isEmpty) {
      return;
    }
    var failed = false;
    for (final account in _uiState.accounts.values) {
      if (!account.registrationEnabled) {
        _addLog('⏸ 跳过已暂停线路的自动重注册: ${account.lineLabel}');
        continue;
      }
      if (account.registrationStatus == 401 ||
          account.registrationStatus == 403) {
        _addLog('⚠️ 跳过认证失败线路的自动重注册: ${account.lineLabel}');
        continue;
      }
      final status = _bindings.pjsua_acc_set_registration(account.accId, 1);
      if (status == 0) {
        _addLog('🌐 SIP 重新注册请求已发送: acc=${account.accId}');
      } else {
        failed = true;
        _addLog('❌ SIP 重新注册失败: acc=${account.accId}, pj_status=$status');
      }
    }
    if (!failed) {
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.recovering);
    } else {
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.failed);
    }
  }

  void _startIpChange() {
    _pendingIpChange = false;
    _ipChangeInProgress = true;
    _ipChangeHadError = false;
    _uiState = _uiState.copyWith(networkState: PjsipNetworkState.recovering);

    final status = using((Arena arena) {
      final param = arena<pjsua_ip_change_param>();
      // 必须使用 PJSIP 默认值：默认会重启 Listener，并关闭失效的 TCP/TLS
      // Transport。直接使用全零结构会跳过这些关键恢复步骤。
      _bindings.pjsua_ip_change_param_default(param);
      return _bindings.pjsua_handle_ip_change(param);
    });

    if (status != 0) {
      _ipChangeInProgress = false;
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.failed);
      _addLog('❌ PJSIP 拒绝 IP Change 请求: pj_status=$status');
      return;
    }

    _addLog('🌐 PJSIP 已开始处理 IP/网络变化');
    _ipChangeTimeoutTimer?.cancel();
    _ipChangeTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_ipChangeInProgress) return;
      _ipChangeInProgress = false;
      _pendingIpChange = true;
      _uiState = _uiState.copyWith(networkState: PjsipNetworkState.failed);
      _addLog('❌ PJSIP IP Change 处理超时，可在网络稳定后重试');
    });
  }

  /// 由 on_ip_change_progress 转发。op/status 均为原生按值参数，不持有指针。
  void _handleIpChangeProgress(int op, int status) {
    if (status != 0) _ipChangeHadError = true;
    _addLog('🌐 IP Change 进度: op=$op, pj_status=$status');

    if (op != pjsua_ip_change_op.PJSUA_IP_CHANGE_OP_COMPLETED.value) return;

    _ipChangeTimeoutTimer?.cancel();
    _ipChangeInProgress = false;
    final succeeded = !_ipChangeHadError && status == 0;
    _uiState = _uiState.copyWith(
      networkState: succeeded
          ? PjsipNetworkState.idle
          : PjsipNetworkState.failed,
    );
    _addLog(succeeded ? '✅ SIP 网络恢复处理完成' : '❌ SIP 网络恢复未完全成功');

    // 处理期间如果又发生网络变化，等当前回调完全结束后再启动下一轮。
    if (_pendingIpChange && _uiState.isNetworkAvailable) {
      _networkChangeTimer?.cancel();
      _networkChangeTimer = Timer(
        const Duration(seconds: 2),
        _recoverAfterNetworkChange,
      );
    }
  }
}
