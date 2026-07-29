part of '../../../../main.dart';

/// 当前通话协调方法：集中处理来电切页、主舞台焦点、DTMF、操作中状态和会议冷却。
extension _HomeCallCoordinator on _MyHomePageState {
  /// 监听 PJSIP 状态变化，处理来电提醒、通话焦点和操作中状态同步。
  void _handleCallWindowAttention(PjsipUIState? previous, PjsipUIState next) {
    _syncSelectedOutgoingAccount(next);
    _syncPendingCallOperations(previous, next);
    _syncFocusedCallAfterStateChange(next);
    _syncConferenceActionCooldown(next);

    final previousIncomingIds = previous?._ringingCallIds ?? const <int>{};
    final nextIncomingIds = next._ringingCallIds;
    final newIncomingIds = nextIncomingIds.difference(previousIncomingIds);
    final hasNewIncomingCall = newIncomingIds.isNotEmpty;

    if (hasNewIncomingCall) {
      _showIncomingCallSurface(newIncomingIds.reduce(math.min));
      _windowController.notifyIncomingCall(
        incomingCallCount: nextIncomingIds.length,
      );
      return;
    }

    if (previousIncomingIds.isNotEmpty && nextIncomingIds.isEmpty) {
      _windowController.clearIncomingCallAttention();
    }
  }

  /// 新来电时关闭普通弹窗并切到当前通话页，把新来电放到主舞台。
  void _showIncomingCallSurface(int callId) {
    if (!mounted) return;

    // 来电优先级高于普通设置/编辑弹窗：先关闭所有弹窗，再显示来电页面。
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);

    // 来电切页前清一下可能残留的拨号按键音路径，避免本地提示音抢占声卡。
    ref.read(pjsipServiceProvider.notifier).releaseDialpadKeySoundSoon();
    _update(() {
      _section = _WorkspaceSection.calls;
      _focusedCallDetailId = callId;
      _dtmfPadCallId = null;
      _dtmfSentPreview = '';
      _dtmfStatusText = null;
      _dtmfSendFailed = false;
    });
  }

  /// 接听指定通话，并让主舞台聚焦到该通话。
  void _answerCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    _focusCallDetail(callId);
    _setPendingCallOperation(callId, '正在接听');
    service.answerCall(callId);
  }

  /// 拒接指定通话，并记录短暂的操作中状态。
  void _rejectCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    _setPendingCallOperation(callId, '正在拒接');
    service.rejectCall(callId);
  }

  /// 挂断指定通话，并记录短暂的操作中状态。
  void _hangupCall(PjsipService service, int callId) {
    unawaited(_windowController.clearIncomingCallAttention());
    _setPendingCallOperation(callId, '正在挂断');
    service.hangupCall(callId);
  }

  /// 显示或收起通话中的 DTMF 小键盘。
  void _toggleInCallDialpad() {
    _update(() => _showInCallDialpad = !_showInCallDialpad);
  }

  /// 播放本地按键音并通过 PJSIP 向当前通话发送 DTMF。
  void _sendInCallDtmf(PjsipService service, CallInfo call, String digit) {
    service.playDialpadKeySound(digit);
    _update(() {
      if (_dtmfPadCallId != call.callId) {
        _dtmfPadCallId = call.callId;
        _dtmfSentPreview = '';
      }
      _dtmfSentPreview = '$_dtmfSentPreview$digit';
      if (_dtmfSentPreview.length > 18) {
        _dtmfSentPreview = _dtmfSentPreview.substring(
          _dtmfSentPreview.length - 18,
        );
      }
      _dtmfStatusText = '正在发送 $digit';
      _dtmfSendFailed = false;
    });
    unawaited(
      (() async {
        final sent = await service.sendDtmf(call.callId, digit);
        if (!mounted || _dtmfPadCallId != call.callId) return;
        _update(() {
          _dtmfStatusText = sent ? '已发送 $digit' : '发送失败 $digit';
          _dtmfSendFailed = !sent;
        });
      })(),
    );
  }

  /// 切换通话备注绑定方式：当前客户备注或会议备注。
  void _setCallNoteMode(_CallNoteMode mode) {
    _update(() {
      _callNoteMode = mode;
      _callNoteControllerKey = null;
    });
  }

  /// 切换主舞台当前查看的通话，并清理旧通话的 DTMF 临时状态。
  void _focusCallDetail(int callId) {
    if (_focusedCallDetailId == callId) return;
    _update(() {
      _focusedCallDetailId = callId;
      _dtmfPadCallId = null;
      _dtmfSentPreview = '';
      _dtmfStatusText = null;
      _dtmfSendFailed = false;
    });
  }

  /// 清空主舞台通话焦点，通常用于当前聚焦通话结束后回落到空态。
  void _clearFocusedCallDetail() {
    if (_focusedCallDetailId == null) return;
    _update(() => _focusedCallDetailId = null);
  }

  /// 先聚焦指定通话，再执行通话操作，保证用户看到自己操作的是哪一路。
  void _runCallActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _focusCallDetail(callId);
    _setPendingCallOperation(callId, pendingLabel);
    action();
  }

  /// 执行会议相关操作，并开启短暂冷却避免快速合并/拆分打断媒体桥。
  void _runConferenceActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _startMediaBridgeActionCooldown();
    _runCallActionAndFocus(callId, pendingLabel, action);
  }

  /// 执行不绑定单一路通话的会议操作，并开启媒体桥冷却。
  void _runConferenceAction(VoidCallback action) {
    _startMediaBridgeActionCooldown();
    action();
  }

  /// 当前会议操作是否处于冷却期，用于禁用容易连点的会议按钮。
  bool get _isConferenceActionCoolingDown => _conferenceActionCoolingDown;

  /// 当前媒体桥操作是否处于冷却期，与会议冷却共用同一把节流锁。
  bool get _isMediaBridgeActionCoolingDown => _conferenceActionCoolingDown;

  /// 执行需要重建媒体桥的单通话操作，并同步主舞台焦点。
  void _runMediaBridgeActionAndFocus(
    int callId,
    String pendingLabel,
    VoidCallback action,
  ) {
    _startMediaBridgeActionCooldown();
    _runCallActionAndFocus(callId, pendingLabel, action);
  }

  /// 启动媒体桥冷却定时器，降低快速保持/恢复/合并导致媒体断开的概率。
  void _startMediaBridgeActionCooldown() {
    _conferenceActionCooldownTimer?.cancel();
    _update(() => _conferenceActionCoolingDown = true);
    _conferenceActionCooldownTimer = Timer(
      _conferenceActionCooldownDuration,
      _clearConferenceActionCooldown,
    );
  }

  /// 清除媒体桥冷却状态，并取消未完成的冷却定时器。
  void _clearConferenceActionCooldown() {
    _conferenceActionCooldownTimer?.cancel();
    _conferenceActionCooldownTimer = null;
    if (!_conferenceActionCoolingDown || !mounted) return;
    _update(() => _conferenceActionCoolingDown = false);
  }

  /// 当会议或多路通话状态消失时，提前结束媒体桥冷却。
  void _syncConferenceActionCooldown(PjsipUIState state) {
    if (!_conferenceActionCoolingDown) return;
    final hasConferenceRelevantCalls =
        state.hasConference ||
        state.calls.values.where((call) => call.isConnected).length >= 2;
    if (hasConferenceRelevantCalls) return;
    _clearConferenceActionCooldown();
  }

  /// 返回指定通话当前展示的操作中标签。
  String? _callOperationLabel(int callId) => _pendingCallOperations[callId];

  /// 判断指定通话是否仍处在接听、挂断、保持等等待反馈状态。
  bool _hasPendingCallOperation(int callId) {
    return _pendingCallOperations.containsKey(callId);
  }

  /// 设置通话操作中的临时标签，并用超时兜底清理。
  void _setPendingCallOperation(int callId, String label) {
    _pendingCallOperationTimers.remove(callId)?.cancel();
    _update(() {
      _pendingCallOperations[callId] = label;
    });
    _pendingCallOperationTimers[callId] = Timer(const Duration(seconds: 4), () {
      _clearPendingCallOperation(callId);
    });
  }

  /// 清理指定通话的操作中状态和对应定时器。
  void _clearPendingCallOperation(int callId) {
    final hadOperation = _pendingCallOperations.containsKey(callId);
    _pendingCallOperationTimers.remove(callId)?.cancel();
    if (!hadOperation || !mounted) return;
    _update(() {
      _pendingCallOperations.remove(callId);
    });
  }

  /// 根据最新通话状态移除已经完成的操作中标签。
  void _syncPendingCallOperations(PjsipUIState? previous, PjsipUIState next) {
    if (_pendingCallOperations.isEmpty) return;
    final finished = <int>[];
    for (final entry in _pendingCallOperations.entries) {
      final call = next.calls[entry.key];
      if (call == null) {
        finished.add(entry.key);
        continue;
      }
      final label = entry.value;
      if (label == '正在接听' && !call.isIncoming) {
        finished.add(entry.key);
      } else if (label == '正在保持' && call.isOnHold) {
        finished.add(entry.key);
      } else if (label == '正在恢复' && call.isConnected && !call.isOnHold) {
        finished.add(entry.key);
      } else if (label == '正在拆分' && !next.isInConference(entry.key)) {
        finished.add(entry.key);
      } else if (label == '正在合并' && next.isInConference(entry.key)) {
        finished.add(entry.key);
      } else if (previous?.calls[entry.key] != call &&
          (label == '正在拒接' || label == '正在挂断')) {
        finished.add(entry.key);
      }
    }
    if (finished.isEmpty || !mounted) return;
    _update(() {
      for (final callId in finished) {
        _pendingCallOperationTimers.remove(callId)?.cancel();
        _pendingCallOperations.remove(callId);
      }
    });
  }

  /// 通话列表变化后校正主舞台焦点，避免显示已结束通话的详情。
  void _syncFocusedCallAfterStateChange(PjsipUIState state) {
    final focusedId = _focusedCallDetailId;
    if (state.calls.isEmpty && (_showInCallDialpad || _dtmfPadCallId != null)) {
      if (!mounted) return;
      _update(() {
        _showInCallDialpad = false;
        _dtmfPadCallId = null;
        _dtmfSentPreview = '';
        _dtmfStatusText = null;
        _dtmfSendFailed = false;
      });
      return;
    }
    if (focusedId == null || state.calls.containsKey(focusedId)) return;
    if (!mounted) return;
    _update(() {
      _focusedCallDetailId = null;
      _dtmfPadCallId = null;
      _dtmfSentPreview = '';
      _dtmfStatusText = null;
      _dtmfSendFailed = false;
    });
  }

  /// 触发通话备注区域刷新，让暂存状态和文本内容及时同步。
  void _refreshCallNoteState() {
    if (!mounted) return;
    _update(() {});
  }
}
