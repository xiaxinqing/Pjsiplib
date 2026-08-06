part of '../pjsip_service.dart';

/// 单路、多路及三方会议的通话控制与音频桥管理。
extension PjsipCallOperations on PjsipService {
  static const Duration _hangupAfterCallControlGuard = Duration(
    milliseconds: 650,
  );
  static const Duration _hangupLocalCleanupDelay = Duration(seconds: 2);

  String callNote(int callId) => _callNotes[callId] ?? '';

  String sharedConferenceNote(Iterable<int> callIds) {
    final notes = <String>[];
    for (final callId in callIds) {
      final note = _sharedConferenceNotes[callId]?.trim();
      if (note == null || note.isEmpty || notes.contains(note)) continue;
      notes.add(note);
    }
    return notes.join('\n\n');
  }

  void setCallNote(int callId, String note) {
    if (!_uiState.calls.containsKey(callId)) return;
    final value = note.trim();
    if (value.isEmpty) {
      _callNotes.remove(callId);
    } else {
      _callNotes[callId] = value;
    }
  }

  void setSharedConferenceNote(Iterable<int> callIds, String note) {
    final activeCallIds = callIds
        .where((callId) => _uiState.calls.containsKey(callId))
        .toSet();
    final value = note.trim();
    for (final callId in activeCallIds) {
      if (value.isEmpty) {
        _sharedConferenceNotes.remove(callId);
      } else {
        _sharedConferenceNotes[callId] = value;
      }
    }
  }

  void _syncSharedConferenceNoteAcross(Iterable<int> callIds) {
    final activeCallIds = callIds
        .where((callId) => _uiState.calls.containsKey(callId))
        .toSet();
    final note = sharedConferenceNote(activeCallIds).trim();
    if (note.isEmpty) return;
    for (final callId in activeCallIds) {
      _sharedConferenceNotes[callId] = note;
    }
  }

  Future<void> makeCall(String number) async {
    // 默认线路掉线时仅临时使用其他在线线路，不修改用户保存的默认线路。
    return makeCallFromAccount(number, _uiState.bestOutgoingAccount?.accId);
  }

  Future<void> makeCallFromAccount(String number, int? accountId) async {
    if (!_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，无法发起呼叫');
      return;
    }
    if (_warnIfOutgoingMediaRecoveryActive()) return;
    final duplicatedCall = _findOngoingCallForDialNumber(number);
    if (duplicatedCall != null) {
      final duplicatedNumber = _extractPhoneNumber(duplicatedCall.remoteUri);
      final message = duplicatedNumber.isEmpty
          ? '该号码已有通话，请先处理当前通话'
          : '$duplicatedNumber 已在当前通话中，请先处理当前通话';
      ToastUtil.showWarning(message);
      _addLog(
        '⚠️ 拦截重复呼叫: target=$number, '
        'existingCall=${duplicatedCall.callId}, state=${duplicatedCall.state}',
      );
      return;
    }
    final account = accountId == null ? null : _uiState.accounts[accountId];
    if (account == null) {
      _addLog('❌ 请先选择可用线路');
      return;
    }
    if (!account.isRegistered) {
      _addLog('❌ 线路尚未注册成功，不能外呼: ${account.lineLabel}');
      return;
    }
    if (_uiState.calls.length >= 4) {
      _addLog('❌ 已达到当前最大通话数（4 路）');
      return;
    }
    if (_uiState.hasConference) {
      _addLog('❌ 请先拆分当前三方通话，再发起新的呼叫');
      return;
    }
    final pendingOutboundCall = _pendingOutboundCall;
    if (pendingOutboundCall != null) {
      final pendingNumber = _extractPhoneNumber(pendingOutboundCall.remoteUri);
      final message = pendingNumber.isEmpty
          ? '已有呼叫正在进行，请先挂断后再拨打'
          : '正在呼叫 $pendingNumber，请先挂断后再拨打';
      ToastUtil.showWarning(message);
      _addLog('⚠️ $message');
      return;
    }
    // 开启自动保持时，发起新通话也遵循“单路激活”规则。
    if (!await _holdActiveCallExcept(-1)) return;
    using((Arena arena) {
      // 外呼必须和线路注册使用同一种传输协议，避免 dialog 中的 INVITE/BYE
      // 被 PBX 按不同 transport 路由，导致对端挂断本端收不到。
      final targetUri =
          'sip:$number@${account.host};transport=${account.transport.uriParam}';
      final dstUri = targetUri.toNativeUtf8(allocator: arena);
      final pjUri = arena<pj_str_t>();
      final pCallId = arena<pjsua_call_id>();
      final callSetting = arena<pjsua_call_setting>();
      _bindings.pjsua_call_setting_default(callSetting);
      // 当前产品只需要一路语音。PJSIP 2.17 默认还会 offer 视频和实时文本，
      // 即使最终未启用也会扩大 SDP，并可能触发 UDP -> TCP 自动切换。
      callSetting.ref.aud_cnt = 1;
      callSetting.ref.vid_cnt = 0;
      callSetting.ref.txt_cnt = 0;

      // Enable SRTP for TLS accounts
      if (account.transport == SipTransport.tls) {
        callSetting.ref.req_keyframe_method = 0; // Placeholder for future use
      }
      _pjStr(pjUri.ref, dstUri);
      _addLog(
        '➡️ 发起 INVITE: $targetUri, acc=${account.accId}, transport=${account.transport.label}',
      );
      final status = _bindings.pjsua_call_make_call(
        account.accId,
        pjUri,
        callSetting,
        ffi.nullptr,
        ffi.nullptr,
        pCallId,
      );
      if (status == 0) {
        final callId = pCallId.value;
        _putCall(
          CallInfo(
            callId: callId,
            state: pjsip_inv_state.PJSIP_INV_STATE_CALLING.value,
            remoteUri: targetUri,
            accountId: account.accId,
            direction: PjsipCallDirection.outbound,
            startedAt: DateTime.now(),
          ),
          makeActive: true,
        );
        _addLog('拨打请求已接受: number=$number, call=$callId');
      } else {
        _addLog('❌ 拨打失败: number=$number, pj_status=$status');
      }
    });
  }

  Future<void> answerCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isIncoming) return;
    final pendingOutboundCallIds = _pendingOutboundCallsExcept(
      callId,
    ).map((call) => call.callId).toList();
    if (pendingOutboundCallIds.isNotEmpty) {
      _stopOutgoingRingback();
    }
    if (!await _holdActiveCallExcept(callId)) return;
    final status = _bindings.pjsua_call_answer(
      callId,
      200,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _uiState = _uiState.copyWith(activeCallId: callId);
      _stopIncomingRingtone();
      _schedulePendingOutboundCancelAfterAnswer(pendingOutboundCallIds);
      _addLog('✅ 已接听电话: call=$callId');
    } else {
      _syncCallProgressSounds();
      _addLog('❌ 接听失败: $status');
    }
  }

  bool _isPendingOutboundCall(CallInfo call) {
    if (call.direction != PjsipCallDirection.outbound || call.isConnected) {
      return false;
    }
    return call.state == pjsip_inv_state.PJSIP_INV_STATE_CALLING.value ||
        call.state == pjsip_inv_state.PJSIP_INV_STATE_EARLY.value ||
        call.state == pjsip_inv_state.PJSIP_INV_STATE_CONNECTING.value;
  }

  CallInfo? get _pendingOutboundCall {
    for (final call in _uiState.calls.values) {
      if (_isPendingOutboundCall(call)) return call;
    }
    return null;
  }

  List<CallInfo> _pendingOutboundCallsExcept(int excludedCallId) {
    return _uiState.calls.values
        .where((call) => call.callId != excludedCallId)
        .where(_isPendingOutboundCall)
        .toList();
  }

  void _schedulePendingOutboundCancelAfterAnswer(List<int> callIds) {
    if (callIds.isEmpty) return;
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (_isDisposed || !_uiState.isInitialized) return;
      final pendingOutboundCalls = callIds
          .map((callId) => _uiState.calls[callId])
          .whereType<CallInfo>()
          .where(_isPendingOutboundCall)
          .toList();
      _cancelPendingOutboundCalls(pendingOutboundCalls);
    });
  }

  void _cancelPendingOutboundCalls(List<CallInfo> pendingOutboundCalls) {
    if (pendingOutboundCalls.isEmpty) return;

    _stopOutgoingRingback();
    for (final call in pendingOutboundCalls) {
      _locallyEndedCallIds.add(call.callId);
      if (_bindings.pjsua_call_is_active(call.callId) == 0) {
        _addLog('🚫 接听来电前清理已失效外呼: call=${call.callId}');
        _removeCall(call.callId, hangupReason: 'incoming answer cancel');
        continue;
      }
      final status = _bindings.pjsua_call_hangup(
        call.callId,
        0,
        ffi.nullptr,
        ffi.nullptr,
      );
      if (status == 0) {
        _addLog(
          '🚫 接听来电前已取消未接通外呼: call=${call.callId}, remote=${call.remoteUri}',
        );
      } else {
        _addLog('⚠️ 取消未接通外呼失败: call=${call.callId}, pj_status=$status');
      }
    }
  }

  void _scheduleBackgroundConfirmedHoldIfNeeded(int callId) {
    // 这条延迟兜底只属于“单路激活”策略。关闭自动保持后，多路普通通话
    // 可以同时接入本机音频，不能再把稍晚确认的通话误判为后台通话。
    if (!_uiState.autoHoldOtherCalls) return;
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected || call.isOnHold) return;
    if (_uiState.activeCallId == callId) return;
    if (_backgroundHoldScheduledCallIds.contains(callId)) return;

    _backgroundHoldScheduledCallIds.add(callId);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      _backgroundHoldScheduledCallIds.remove(callId);
      if (_isDisposed || !_uiState.isInitialized) return;
      _holdBackgroundConfirmedCallIfNeeded(callId);
    });
  }

  void _holdBackgroundConfirmedCallIfNeeded(int callId) {
    // 定时等待期间用户可能关闭自动保持，因此执行前必须再次检查策略。
    if (!_uiState.autoHoldOtherCalls) return;
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected || call.isOnHold) return;
    if (_uiState.activeCallId == callId) return;
    if (call.mediaStatus !=
        pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value) {
      return;
    }

    final activeId = _uiState.activeCallId;
    final active = activeId == null ? null : _uiState.calls[activeId];
    if (active == null || !active.isConnected) return;

    _markCallControlOperation(callId);
    final status = _bindings.pjsua_call_set_hold(callId, ffi.nullptr);
    if (status == 0) {
      _putCall(call.copyWith(isOnHold: true));
      _addLog('⏸ 后台通话接通，已自动保持: call=$callId');
    } else {
      _addLog('⚠️ 后台通话自动保持失败: call=$callId, pj_status=$status');
    }
  }

  Future<void> rejectCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isIncoming) return;
    final status = _bindings.pjsua_call_answer(
      callId,
      486,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _locallyEndedCallIds.add(callId);
      _stopIncomingRingtone();
      _addLog('🚫 已拒绝来电: call=$callId');
    } else {
      _addLog('❌ 拒绝来电失败: call=$callId, pj_status=$status');
    }
  }

  Future<void> hangupCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null) return;
    if (_hangupRequestedCallIds.contains(callId)) {
      _addLog('⏳ 该通话已提交挂断请求: call=$callId');
      return;
    }
    if (_scheduleHangupAfterControlSettles(callId)) return;
    // 延迟到达的 DISCONNECTED microtask 可能尚未清除本地记录，此时
    // callId 可能已失效。对死 id 调 hangup 无害但没意义，直接清理本地状态。
    if (_bindings.pjsua_call_is_active(call.callId) == 0) {
      _addLog('通话已不活跃，清理本地状态: call=${call.callId}');
      _removeCall(callId);
      return;
    }
    _hangupRequestedCallIds.add(call.callId);
    _disconnectCallFromSoundBeforeHangup(call.callId);
    _addLog(
      '⏹ 本地用户请求挂断: call=${call.callId}, '
      'remote=${call.remoteUri}, state=${call.state}',
    );
    _locallyEndedCallIds.add(call.callId);
    final status = _bindings.pjsua_call_hangup(
      call.callId,
      0,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _playCallEndedSound(call);
      _scheduleLocalHangupCleanup(call);
      _addLog('挂断 API 调用成功，等待 PJSIP DISCONNECTED 回调: call=${call.callId}');
    } else {
      _hangupRequestedCallIds.remove(call.callId);
      _addLog('❌ 挂断失败: call=${call.callId}, pj_status=$status');
    }
  }

  Future<void> holdCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) return;
    _markCallControlOperation(callId);
    _addLog('⏹ 请求暂停通话: call=${call.callId}');
    // pjsua_call_set_hold 发起 re-INVITE 将媒体置为 sendonly/inactive
    final status = _bindings.pjsua_call_set_hold(call.callId, ffi.nullptr);
    if (status != 0) {
      _addLog('❌ 暂停失败: call=${call.callId}, pj_status=$status');
    } else {
      _putCall(call.copyWith(isOnHold: true));
      if (_uiState.activeCallId == callId) {
        _uiState = _uiState.copyWith(activeCallId: null);
      }
    }
  }

  Future<void> unholdCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) return;
    if (!await _holdActiveCallExcept(callId)) return;
    _markCallControlOperation(callId);
    _addLog('▶️ 请求恢复通话: call=${call.callId}');
    // pjsua_call_reinvite(callId, 1, ...) 发起 re-INVITE 恢复媒体 sendrecv
    final status = _bindings.pjsua_call_reinvite(call.callId, 1, ffi.nullptr);
    if (status != 0) {
      _addLog('❌ 恢复失败: call=${call.callId}, pj_status=$status');
    } else {
      _putCall(call.copyWith(isOnHold: false), makeActive: true);
    }
  }

  void _markCallControlOperation(int callId) {
    _lastCallControlOperationAt[callId] = DateTime.now();
  }

  bool _scheduleHangupAfterControlSettles(int callId) {
    final lastControlAt = _lastCallControlOperationAt[callId];
    if (lastControlAt == null) return false;

    final elapsed = DateTime.now().difference(lastControlAt);
    if (elapsed >= _hangupAfterCallControlGuard) return false;

    // hold / unhold 都是 re-INVITE，PJSIP 和对端需要一点时间把媒体状态
    // 从旧 SDP 切到新 SDP。紧跟着 hangup 偶发会让 BYE/媒体桥清理和 re-INVITE
    // 交错，表现为对端仍停在 hold 或本地 call 残留。这里宁可晚几百毫秒挂断，
    // 也不要把两个 SIP 会话控制动作压到同一瞬间。
    if (_delayedHangupTimers.containsKey(callId)) return true;
    final delay = _hangupAfterCallControlGuard - elapsed;
    _addLog('⏳ 刚执行保持/恢复，延迟 ${delay.inMilliseconds}ms 后挂断: call=$callId');
    _delayedHangupTimers[callId] = Timer(delay, () {
      _delayedHangupTimers.remove(callId);
      if (_isDisposed || !_uiState.calls.containsKey(callId)) return;
      unawaited(hangupCall(callId));
    });
    return true;
  }

  void _scheduleLocalHangupCleanup(CallInfo call) {
    _hangupCleanupTimers.remove(call.callId)?.cancel();
    _hangupCleanupTimers[call.callId] = Timer(_hangupLocalCleanupDelay, () {
      _hangupCleanupTimers.remove(call.callId);
      if (_isDisposed || !_uiState.calls.containsKey(call.callId)) return;

      // 正常路径由 DISCONNECTED 回调移除通话。若回调迟迟未到，
      // 这里只清理本地 UI，不再重复调用 pjsua_call_hangup。
      _locallyReleasedCallIds.add(call.callId);
      final stillActive = _bindings.pjsua_call_is_active(call.callId) != 0;
      if (stillActive) {
        _addLog('⚠️ 挂断回调等待超时，底层仍报告活跃，仅清理本地界面: call=${call.callId}');
      } else {
        _addLog('⚠️ 挂断回调等待超时，底层已不活跃，清理本地界面: call=${call.callId}');
      }
      _removeCall(call.callId, hangupReason: 'local hangup timeout');
      unawaited(
        Future<void>.delayed(const Duration(seconds: 30), () {
          _locallyReleasedCallIds.remove(call.callId);
        }),
      );
    });
  }

  void _hangupNativeCallsIfUiIdle(String reason) {
    if (!_uiState.isInitialized || _uiState.calls.isNotEmpty) return;
    final nativeCallCount = _bindings.pjsua_call_get_count();
    if (nativeCallCount <= 0) return;

    _addLog('🧹 $reason：native 仍有 $nativeCallCount 路通话残留，执行 hangup_all');
    _bindings.pjsua_call_hangup_all();
    _mediaConnectedCalls.clear();
    _backgroundHoldScheduledCallIds.clear();
    _lastCallControlOperationAt.clear();
    _releaseSoundDeviceIfIdle('$reason 清理 native 残留');
  }

  void _logEarlyOutboundDisconnectWithoutAutoRecovery(
    CallInfo? call, {
    required int sipStatusCode,
    required String sipStatusText,
  }) {
    if (call == null) return;
    if (call.direction != PjsipCallDirection.outbound) return;
    if (call.connectedAt != null) return;
    if (_locallyEndedCallIds.contains(call.callId)) return;

    final age = DateTime.now().difference(call.startedAt);
    if (age > const Duration(seconds: 5)) return;

    final nativeCallCount = _bindings.pjsua_call_get_count();
    _addLog(
      '🌐 外呼快速断开，暂不自动重连: call=${call.callId}, '
      'age=${age.inMilliseconds}ms, sip=$sipStatusCode'
      '${sipStatusText.isEmpty ? '' : ' ($sipStatusText)'}, '
      'nativeCalls=$nativeCallCount\n'
      '说明: ICE/STUN 失败后自动 IP Change 容易形成“拨号失败 -> 重连 -> 再失败”循环，'
      '这里先只记录诊断日志，交给网络变化/手动重连处理。',
    );
  }

  /// 通话中发送 DTMF 按键。
  ///
  /// DTMF 是用户在 IVR 菜单里按 1/2/3、输入分机号时用到的“电话按键音”。
  /// 这里使用 PJSIP 默认的 RFC2833 方式发送，适合大多数 SIP/PBX 场景。
  Future<bool> sendDtmf(int callId, String digit) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) {
      _addLog('⚠️ 当前没有可发送 DTMF 的已接通通话');
      return false;
    }
    if (digit.length != 1 || !'0123456789*#'.contains(digit)) {
      _addLog('⚠️ 无效 DTMF 按键: $digit');
      return false;
    }

    return using((Arena arena) {
      final digits = arena<pj_str_t>();
      _pjStr(digits.ref, digit.toNativeUtf8(allocator: arena));
      final status = _bindings.pjsua_call_dial_dtmf(callId, digits);
      if (status == 0) {
        _addLog('☎️ 已发送 DTMF: $digit, call=$callId');
        return true;
      } else {
        _addLog('❌ DTMF 发送失败: $digit, call=$callId, pj_status=$status');
        return false;
      }
    });
  }

  /// 盲转当前通话到指定号码或 SIP URI。
  ///
  /// 这里发送 SIP REFER。同步 status 只代表 REFER 请求是否成功发起。
  /// 产品层按“甩转”处理：REFER 发出后本机直接结束并移除原通话，
  /// 后续 NOTIFY 只进日志，不再影响本机通话列表。
  Future<bool> blindTransferCall(int callId, String destination) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) {
      _addLog('⚠️ 当前没有可转接的已接通通话');
      ToastUtil.showWarning('当前没有可转接的通话');
      return false;
    }
    if (_uiState.isInConference(callId)) {
      _addLog('⚠️ 会议成员暂不支持盲转，请先拆分三方通话');
      ToastUtil.showWarning('请先拆分三方通话，再执行转接');
      return false;
    }

    final targetUri = _transferTargetUri(call, destination);
    if (targetUri == null) {
      _addLog('⚠️ 盲转目标为空');
      ToastUtil.showWarning('请输入转接号码');
      return false;
    }

    final status = using((Arena arena) {
      final pjDest = arena<pj_str_t>();
      _pjStr(pjDest.ref, targetUri.toNativeUtf8(allocator: arena));
      return _bindings.pjsua_call_xfer(callId, pjDest, ffi.nullptr);
    });
    if (status == 0) {
      _addLog('➡️ 已发送盲转 REFER: call=$callId, target=$targetUri');
      _blindTransferAutoReleaseCallIds.add(callId);
      _blindTransferTargets[callId] = destination.trim();
      unawaited(
        Future<void>.delayed(const Duration(seconds: 30), () {
          _blindTransferAutoReleaseCallIds.remove(callId);
          _blindTransferTargets.remove(callId);
        }),
      );
      ToastUtil.showSuccess('已发送转接请求，正在结束本机通话');
      // 盲转在产品语义上是“把通话甩出去”。REFER 成功发出后，是否最终接通
      // 由对端/PBX 后续 NOTIFY 决定，本机不继续占着原通话；否则用户会看到
      // 已转出但本机仍在通话中。120ms 只留给 REFER 进入底层发送队列。
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 120), () async {
          if (!_uiState.calls.containsKey(callId)) return;
          await hangupCall(callId);
          if (!_uiState.calls.containsKey(callId)) return;
          _addLog('➡️ 盲转后本地移除通话: call=$callId');
          _removeCall(callId, hangupReason: 'blind transfer local release');
        }),
      );
      return true;
    } else {
      _addLog('❌ 盲转失败: call=$callId, target=$targetUri, pj_status=$status');
      ToastUtil.showError('转接请求发送失败');
      return false;
    }
  }

  String? _transferTargetUri(CallInfo call, String destination) {
    final target = destination.trim();
    if (target.isEmpty) return null;
    final hasScheme = RegExp(
      r'^[a-z][a-z0-9+.-]*:',
      caseSensitive: false,
    ).hasMatch(target);
    if (hasScheme) return target;
    if (target.contains('@')) return 'sip:$target';

    final accountId = call.accountId;
    final account = accountId == null ? null : _uiState.accounts[accountId];
    if (account == null) return 'sip:$target';
    return 'sip:$target@${account.host};transport=${account.transport.uriParam}';
  }

  /// 把一条已接通且处于 Hold 的通话，与当前活动通话合并为三方会议。
  ///
  /// PJSUA 的 conference bridge 是有方向的，所以除了两路通话分别连接声卡，
  /// 还必须建立 callA -> callB 和 callB -> callA，客户与经理才能互相听见。
  Future<void> mergeWithActiveCall(int callId) async {
    if (_uiState.hasConference) return;
    final activeId = _uiState.activeCallId;
    final active = activeId == null ? null : _uiState.calls[activeId];
    final target = _uiState.calls[callId];
    if (active == null ||
        target == null ||
        activeId == callId ||
        !active.isConnected ||
        !target.isConnected ||
        target.isRemoteOnHold) {
      _addLog('❌ 合并失败：需要一路当前通话和一路已接通的保持通话');
      return;
    }

    final members = <int>{activeId!, callId};
    // 先标记为会议成员，确保目标通话恢复媒体时的回调不会被单路模式断开。
    _uiState = _uiState.copyWith(
      conferenceCallIds: members,
      isConferencePaused: false,
      conferenceInterruptionCallId: null,
      activeCallId: null,
    );

    if (target.isOnHold) {
      _markCallControlOperation(callId);
      final status = _bindings.pjsua_call_reinvite(callId, 1, ffi.nullptr);
      if (status != 0) {
        _uiState = _uiState.copyWith(
          conferenceCallIds: const {},
          isConferencePaused: false,
          conferenceInterruptionCallId: null,
          activeCallId: activeId,
        );
        _connectCallToSound(activeId);
        _addLog('❌ 三方合并失败：恢复 call=$callId 失败，pj_status=$status');
        return;
      }
      _putCall(target.copyWith(isOnHold: false));
    }

    _rebuildConferenceBridge('合并后立即重建');
    _scheduleConferenceBridgeRebuilds('合并后等待媒体协商');
    _syncSharedConferenceNoteAcross(members);
    _addLog('👥 三方通话已建立: calls=${members.toList()}');
  }

  /// 拆分三方通话，并保留 [keepCallId] 与本机继续通话；另一方自动 Hold。
  Future<void> splitConference(int keepCallId) async {
    if (_uiState.isConferencePaused) {
      _addLog('⚠️ 请先结束当前插入通话并恢复会议，再执行拆分');
      return;
    }
    final members = Set<int>.of(_uiState.conferenceCallIds);
    if (!members.contains(keepCallId)) return;

    _disconnectConferenceBridge(members);
    final calls = Map<int, CallInfo>.of(_uiState.calls);
    for (final callId in members) {
      final call = calls[callId];
      if (call == null) continue;
      if (callId == keepCallId) {
        if (call.isOnHold) {
          _markCallControlOperation(callId);
          final status = _bindings.pjsua_call_reinvite(callId, 1, ffi.nullptr);
          if (status != 0) {
            _addLog('❌ 恢复保留通话失败: call=$callId, pj_status=$status');
            continue;
          }
        }
        calls[callId] = call.copyWith(isOnHold: false);
      } else {
        _markCallControlOperation(callId);
        final status = _bindings.pjsua_call_set_hold(callId, ffi.nullptr);
        if (status != 0) {
          _addLog('❌ 拆分时保持失败: call=$callId, pj_status=$status');
        } else {
          calls[callId] = call.copyWith(isOnHold: true);
        }
      }
    }

    _uiState = _uiState.copyWith(
      calls: calls,
      conferenceCallIds: const {},
      isConferencePaused: false,
      conferenceInterruptionCallId: null,
      activeCallId: keepCallId,
    );
    _connectCallToSound(keepCallId);
    _addLog('👥 三方通话已拆分，继续通话: call=$keepCallId');
  }

  /// 恢复因接听其他来电而暂停的三方通话。
  ///
  /// 两个成员仍保存在 [PjsipUIState.conferenceCallIds] 中，因此这里只需分别
  /// 解除 Hold；媒体 ACTIVE 回调到达后会自动重建三方音频矩阵。
  Future<void> resumeConference() async {
    if (!_uiState.isConferencePaused || !_uiState.hasConference) return;
    final activeId = _uiState.activeCallId;
    if (activeId != null && !_uiState.conferenceCallIds.contains(activeId)) {
      _addLog('⚠️ 当前仍在处理其他通话，请结束后再恢复三方通话');
      return;
    }

    final calls = Map<int, CallInfo>.of(_uiState.calls);
    var allResumed = true;
    for (final callId in _uiState.conferenceCallIds) {
      final call = calls[callId];
      if (call == null || !call.isConnected) {
        allResumed = false;
        continue;
      }
      if (call.isOnHold) {
        _markCallControlOperation(callId);
        final status = _bindings.pjsua_call_reinvite(callId, 1, ffi.nullptr);
        if (status != 0) {
          allResumed = false;
          _addLog('❌ 恢复会议成员失败: call=$callId, pj_status=$status');
          continue;
        }
        calls[callId] = call.copyWith(isOnHold: false);
      }
    }

    if (!allResumed) {
      _uiState = _uiState.copyWith(calls: calls);
      _addLog('⚠️ 三方通话尚未完全恢复，可稍后手动重试');
      return;
    }

    _uiState = _uiState.copyWith(
      calls: calls,
      isConferencePaused: false,
      conferenceInterruptionCallId: null,
      activeCallId: null,
    );
    _rebuildConferenceBridge('恢复会议后立即重建');
    _scheduleConferenceBridgeRebuilds('恢复会议后等待媒体协商');
    _addLog('▶️ 三方通话已恢复');
  }

  Future<bool> _holdActiveCallExcept(int targetCallId) async {
    // 关闭该策略时，接听、外呼和恢复都不改变其他通话的 SIP 状态。
    // 后续媒体回调会把每路已接通通话分别接入本机声卡。
    if (!_uiState.autoHoldOtherCalls) return true;

    // 接听/恢复目标通话前的音频占用处理顺序：
    //
    // 1. 先检查是否有【正在进行的会议】。
    //    如果有，则保留会议成员关系，但断开会议音频桥，并自动 Hold 除目标
    //    以外的所有会议成员，把会议标记成“已暂停”。
    //
    // 2. 如果没有活动会议，或者会议本来就处于暂停状态，则继续检查当前是否
    //    还有一条普通活动通话。如果有，先自动 Hold 当前通话，再处理目标通话。
    //
    // 3. 本方法只负责自动 Hold，绝不自动 Unhold。任何通话挂断后，原通话或
    //    原会议都必须由用户手动点击“恢复”或“恢复三方通话”才能重新激活。
    if (_uiState.isConferenceActive) {
      final members = Set<int>.of(_uiState.conferenceCallIds);
      _disconnectConferenceBridge(members);
      final calls = Map<int, CallInfo>.of(_uiState.calls);
      for (final callId in members) {
        if (callId == targetCallId) continue;
        final call = calls[callId];
        if (call == null || !call.isConnected) continue;
        _markCallControlOperation(callId);
        final status = _bindings.pjsua_call_set_hold(callId, ffi.nullptr);
        if (status == 0) {
          calls[callId] = call.copyWith(isOnHold: true);
        } else {
          _addLog('❌ 暂停会议时自动保持失败: call=$callId, pj_status=$status');
        }
      }
      _uiState = _uiState.copyWith(
        calls: calls,
        isConferencePaused: true,
        conferenceInterruptionCallId: targetCallId,
        activeCallId: null,
      );
      _addLog('⏸ 三方通话已暂停，正在处理 call=$targetCallId');
    } else if (_uiState.isConferencePaused) {
      // 暂停会议期间如果又切换到另一通来电，让最新通话成为恢复触发点。
      _uiState = _uiState.copyWith(conferenceInterruptionCallId: targetCallId);
    }

    final activeId = _uiState.activeCallId;
    if (activeId == null || activeId == targetCallId) return true;
    final active = _uiState.calls[activeId];
    if (active == null || !active.isConnected || active.isOnHold) return true;

    _addLog('⏸ 接听/恢复新通话前自动保持 call=$activeId');
    _markCallControlOperation(activeId);
    final status = _bindings.pjsua_call_set_hold(activeId, ffi.nullptr);
    if (status != 0) {
      _addLog('❌ 自动保持失败: call=$activeId, pj_status=$status');
      return false;
    }
    _putCall(active.copyWith(isOnHold: true));
    return true;
  }

  void _putCall(CallInfo call, {bool makeActive = false}) {
    final previous = _uiState.calls[call.callId];
    final nextCall = _withHoldTimingMetrics(previous, call);
    final calls = Map<int, CallInfo>.of(_uiState.calls)
      ..[nextCall.callId] = nextCall;
    _uiState = _uiState.copyWith(
      calls: calls,
      activeCallId: makeActive ? nextCall.callId : _unset,
    );
    if (previous == null && nextCall.isIncoming) {
      debugPrint(
        '⏱ 来电首帧追踪 t=${DateTime.now().toIso8601String()} | '
        'call=${nextCall.callId} 已写入 PJSIP UI 状态，准备启动铃声',
      );
    }
    _syncCallProgressSounds();
  }

  /// 在唯一的通话写入口统计 Hold 次数和累计时长。
  ///
  /// 本地按钮、自动保持、远端保持最终都会更新 `isOnHold/isRemoteOnHold`，
  /// 因此这里做前后状态差分，比在每个操作函数里分别计时更稳。
  CallInfo _withHoldTimingMetrics(CallInfo? previous, CallInfo next) {
    if (previous == null) return next;

    final wasHeld = previous.isOnHold || previous.isRemoteOnHold;
    final isHeld = next.isOnHold || next.isRemoteOnHold;
    final now = DateTime.now();

    if (!wasHeld && isHeld) {
      return next.copyWith(
        holdStartedAt: next.holdStartedAt ?? now,
        holdCount: next.holdCount + 1,
      );
    }

    if (wasHeld && !isHeld) {
      final holdStartedAt = previous.holdStartedAt;
      final elapsed = holdStartedAt == null
          ? Duration.zero
          : _positiveDuration(now.difference(holdStartedAt));
      return next.copyWith(
        holdStartedAt: null,
        totalHoldDuration: next.totalHoldDuration + elapsed,
      );
    }

    if (wasHeld && isHeld && next.holdStartedAt == null) {
      return next.copyWith(holdStartedAt: previous.holdStartedAt ?? now);
    }

    return next;
  }

  /// 查询通话在 PJSUA conference bridge 中的槽位。
  int? _getConferenceSlot(int callId) {
    return using((Arena arena) {
      final info = arena<pjsua_call_info>();
      if (_bindings.pjsua_call_get_info(callId, info) != 0) return null;
      final slot = info.ref.conf_slot;
      return slot < 0 ? null : slot;
    });
  }

  /// 参照 MicroSIP 的挂断顺序，先断开该路通话与本地声卡的双向连接，
  /// 再由调用方发送一次挂断请求。不改动会议成员之间的媒体连接。
  void _disconnectCallFromSoundBeforeHangup(int callId) {
    final slot = _getConferenceSlot(callId);
    if (slot == null) return;
    _bindings.pjsua_conf_disconnect(slot, 0);
    _bindings.pjsua_conf_disconnect(0, slot);
    _mediaConnectedCalls.remove(callId);
    _addLog('🎧 挂断前已断开本地音频桥: call=$callId, slot=$slot');
  }

  void _connectCallToSound(int callId) {
    // 恢复通话、拆分会议等路径也可能重新连接声卡；这里统一保证从 no-sound
    // 状态切回用户当前预选的输入/输出设备。
    if (!_ensureSoundDeviceOpen('连接通话声卡')) return;
    final slot = _getConferenceSlot(callId);
    if (slot == null) return;
    if (!_shouldUseLocalAudioForCall(callId)) {
      _bindings.pjsua_conf_disconnect(slot, 0);
      _bindings.pjsua_conf_disconnect(0, slot);
      _mediaConnectedCalls.remove(callId);
      return;
    }
    if (_shouldRouteCallToLocalSpeaker(callId)) {
      _bindings.pjsua_conf_connect(slot, 0);
    }
    if (!_uiState.isMicrophoneMuted) {
      _bindings.pjsua_conf_connect(0, slot);
    }
    _mediaConnectedCalls.add(callId);
    _applyAudioVolumeState();
  }

  /// 更新“切换通话时自动保持”策略并保存到本地。
  void setAutoHoldOtherCalls(bool enabled) {
    if (_uiState.autoHoldOtherCalls == enabled) return;
    _uiState = _uiState.copyWith(autoHoldOtherCalls: enabled);
    _applyAudioMuteState();
    _addLog(enabled ? '📞 已开启切换通话时自动保持' : '📞 已关闭自动保持，允许多路通话同时使用本机音频');
    unawaited(_persistAudioPreferences());
  }

  /// 重建三方音频矩阵：本机与每一路双向连接，两路远端之间也双向连接。
  ///
  /// 会议反复拆分/合并会触发多次 hold/unhold re-INVITE，PJSIP 的 conf_slot
  /// 也可能在媒体重新 ACTIVE 后变化。这里每次重建都先按“当前成员当前 slot”
  /// 清理旧连接，再重新建立矩阵，避免残留连接或旧回调把本机声卡路径断掉。
  void _rebuildConferenceBridge([String reason = '']) {
    final slots = <int, int>{};
    for (final callId in _uiState.conferenceCallIds) {
      final call = _uiState.calls[callId];
      if (call == null ||
          !call.isConnected ||
          call.isOnHold ||
          call.isRemoteOnHold) {
        continue;
      }
      final slot = _getConferenceSlot(callId);
      if (slot != null) slots[callId] = slot;
    }
    if (slots.length < 2) {
      if (reason.isNotEmpty) {
        _addLog('👥 会议桥暂未重建: $reason, 可用媒体=${slots.length}');
      }
      return;
    }

    _disconnectConferenceBridge(Set<int>.of(slots.keys));

    for (final entry in slots.entries) {
      final callId = entry.key;
      final slot = entry.value;
      if (!_uiState.isMicrophoneMuted) {
        _bindings.pjsua_conf_connect(0, slot); // 本机麦克风 -> 远端
      }
      if (_shouldRouteCallToLocalSpeaker(callId)) {
        _bindings.pjsua_conf_connect(slot, 0); // 远端 -> 本机扬声器
      }
    }
    final values = slots.values.toList();
    for (var i = 0; i < values.length; i++) {
      for (var j = i + 1; j < values.length; j++) {
        _bindings.pjsua_conf_connect(values[i], values[j]);
        _bindings.pjsua_conf_connect(values[j], values[i]);
      }
    }
    _mediaConnectedCalls.addAll(slots.keys);
    _applyAudioVolumeState();
    if (reason.isNotEmpty) {
      _addLog(
        '👥 会议桥已重建: $reason, '
        '${slots.entries.map((entry) => 'call=${entry.key}/slot=${entry.value}').join(', ')}',
      );
    }
  }

  void _scheduleConferenceBridgeRebuilds(String reason) {
    if (!_uiState.isConferenceActive) return;
    // 合并/恢复会议后，远端 SDP、ICE selected pair 和 PJSUA conf_slot 可能不是
    // 同一帧里全部稳定。快速拆分再合并时尤其明显：只重建一次会议桥会偶发单向音频。
    // 分几个短延迟重复按“当前 slot”重建，成本低，但能覆盖媒体回调乱序。
    for (final delay in const [
      Duration(milliseconds: 150),
      Duration(milliseconds: 500),
      Duration(milliseconds: 1200),
      Duration(milliseconds: 2500),
    ]) {
      Future<void>.delayed(delay, () {
        if (_isDisposed ||
            !_uiState.isInitialized ||
            !_uiState.isConferenceActive) {
          return;
        }
        _rebuildConferenceBridge('$reason +${delay.inMilliseconds}ms');
      });
    }
  }

  /// 拆除会议中的所有声卡和成员间连接，防止拆分后残留串音。
  void _disconnectConferenceBridge(Set<int> callIds) {
    final slots = callIds.map(_getConferenceSlot).whereType<int>().toList();
    for (final slot in slots) {
      _bindings.pjsua_conf_disconnect(0, slot);
      _bindings.pjsua_conf_disconnect(slot, 0);
    }
    for (var i = 0; i < slots.length; i++) {
      for (var j = i + 1; j < slots.length; j++) {
        _bindings.pjsua_conf_disconnect(slots[i], slots[j]);
        _bindings.pjsua_conf_disconnect(slots[j], slots[i]);
      }
    }
  }

  void _removeCall(int callId, {int? sipStatusCode, String? hangupReason}) {
    _delayedHangupTimers.remove(callId)?.cancel();
    _hangupCleanupTimers.remove(callId)?.cancel();
    _backgroundHoldScheduledCallIds.remove(callId);
    _lastCallControlOperationAt.remove(callId);
    _hangupRequestedCallIds.remove(callId);
    final endedCall = _uiState.calls[callId];
    if (endedCall != null) {
      final wasEndedLocally = _locallyEndedCallIds.contains(endedCall.callId);
      _notifyUnansweredCallEnded(
        endedCall,
        wasEndedLocally: wasEndedLocally,
        sipStatusCode: sipStatusCode,
        hangupReason: hangupReason,
      );
      _notifyConnectedCallEnded(
        endedCall,
        wasEndedLocally: wasEndedLocally,
        hangupReason: hangupReason,
      );
      _archiveEndedCall(
        endedCall,
        sipStatusCode: sipStatusCode,
        hangupReason: hangupReason,
      );
      _playCallEndedSound(endedCall, hangupReason: hangupReason);
    }
    final calls = Map<int, CallInfo>.of(_uiState.calls)..remove(callId);
    _mediaConnectedCalls.remove(callId);
    final remoteMutedCallIds = Set<int>.of(_uiState.remoteMutedCallIds)
      ..remove(callId);
    final wasConferencePaused = _uiState.isConferencePaused;
    final wasConferenceMember = _uiState.conferenceCallIds.contains(callId);
    final wasConferenceInterruption =
        wasConferencePaused && _uiState.conferenceInterruptionCallId == callId;
    final conferenceCallIds = Set<int>.of(_uiState.conferenceCallIds)
      ..remove(callId);
    final keepConference = conferenceCallIds.length >= 2;
    // 正常会议中任意一方挂断后，剩余一路自动回到普通活动通话。若会议正
    // 暂停且中断通话仍在进行，则保留当前中断通话，剩余会议成员继续 Hold。
    final remainingConferenceCallId = conferenceCallIds.length == 1
        ? conferenceCallIds.first
        : null;
    final currentActiveId = _uiState.activeCallId == callId
        ? null
        : _uiState.activeCallId;
    final activeCallId =
        remainingConferenceCallId != null &&
            !wasConferencePaused &&
            currentActiveId == null
        ? remainingConferenceCallId
        : currentActiveId;
    _uiState = _uiState.copyWith(
      calls: calls,
      remoteMutedCallIds: remoteMutedCallIds,
      conferenceCallIds: keepConference ? conferenceCallIds : const {},
      isConferencePaused: keepConference && wasConferencePaused,
      conferenceInterruptionCallId: keepConference
          ? _uiState.conferenceInterruptionCallId
          : null,
      activeCallId: activeCallId,
    );
    if (remainingConferenceCallId != null && !wasConferencePaused) {
      _connectCallToSound(remainingConferenceCallId);
      _addLog('👥 一名会议成员已离开，继续单路通话: call=$remainingConferenceCallId');
    } else if (wasConferenceMember && !keepConference) {
      _addLog('👥 一名会议成员已离开，原三方通话已结束');
    }
    if (wasConferenceInterruption && keepConference) {
      _addLog('⏸ 插入通话已结束，三方会议保持暂停，请手动恢复');
    }
    // 注意：这里故意不恢复任何被 Hold 的通话或暂停会议。挂断后用户可能
    // 需要处理记录、选择其他会话或暂时保持静音，恢复动作必须由用户发起。
    if (!calls.values.any((call) => call.isConnected)) {
      _stopCallTimer();
    }
    if (calls.isEmpty) {
      // 最后一通结束后延迟释放真实声卡；账号仍可保持注册在线，耳机插拔监控
      // 也继续运行。延迟释放能避免挂断音/连续来电时反复开关系统声卡。
      _scheduleSoundDeviceReleaseIfIdle('最后一通结束');
      _stopAudioLevelTimerIfIdle();
    }
    _syncCallProgressSounds();
    _hangupSoundPlayedCallIds.remove(callId);
    _knownIncomingCallIds.remove(callId);
    _outboundRingingAtByCallId.remove(callId);
    _callSnapshots.clear(callId);
  }

  CallReleasedInfo _releasedCallInfo(int callId, CallInfo? call) {
    final snapshot = _callSnapshots.getLast(callId);
    final snapshotReason = snapshot == null
        ? null
        : _customerEndReasonForSnapshot(snapshot, call);
    if (snapshotReason != null) {
      // 已接通通话结束时，如果快照还是外呼 INVITE 的 401/407，它只是
      // Digest 鉴权流程的一环，不代表这通电话最终因为认证失败断开。
      if (call?.connectedAt != null &&
          snapshot!.isInviteAuthenticationChallenge) {
        _addLog(
          '📌 忽略通话建立前鉴权快照: call=$callId, '
          'raw=${snapshot.diagnosticReason ?? 'empty'}',
        );
      } else {
        _addLog(
          '📌 使用通话结束快照: call=$callId, '
          'status=${snapshot!.statusCode}, reason=$snapshotReason, '
          'raw=${snapshot.diagnosticReason ?? 'empty'}',
        );
        debugPrint(
          '📌 [call snapshot hit] call=$callId, final=true, '
          'status=${snapshot.statusCode}, text=${snapshot.statusText}, '
          'method=${snapshot.method}, role=${snapshot.role}, '
          'state=${snapshot.transactionState}, event=${snapshot.eventType}, '
          'updatedAt=${snapshot.updatedAt.toIso8601String()}',
        );
        return CallReleasedInfo(
          reason: snapshotReason,
          sipStatusCode: snapshot.statusCode > 0 ? snapshot.statusCode : null,
          fromTransactionSnapshot: true,
        );
      }
    }
    final diagnosticReason = snapshot?.diagnosticReason;
    if (diagnosticReason != null) {
      _addLog(
        snapshot!.isInviteAuthenticationChallenge && call?.connectedAt != null
            ? '📌 通话结束快照已忽略，使用已接通兜底原因: call=$callId'
            : '📌 通话结束快照只有临时状态: call=$callId, raw=$diagnosticReason',
      );
      debugPrint(
        '📌 [call snapshot provisional] call=$callId, '
        'status=${snapshot.statusCode}, text=${snapshot.statusText}, '
        'method=${snapshot.method}, role=${snapshot.role}, '
        'state=${snapshot.transactionState}, event=${snapshot.eventType}, '
        'updatedAt=${snapshot.updatedAt.toIso8601String()}',
      );
    } else {
      debugPrint(
        '📌 [call snapshot miss] call=$callId, '
        'bridge=${_callSnapshots.isAvailable ? 'available' : 'unavailable'}, '
        'callKnown=${call != null}',
      );
    }

    if (call == null) {
      return const CallReleasedInfo(reason: '通话已结束，未返回最终原因');
    }
    if (call.connectedAt != null) {
      if (_locallyEndedCallIds.contains(call.callId)) {
        return const CallReleasedInfo(reason: '本机挂断');
      }
      return const CallReleasedInfo(reason: '对方或网络侧结束');
    }
    if (_locallyEndedCallIds.contains(call.callId)) {
      return const CallReleasedInfo(reason: '本机取消呼叫');
    }
    return const CallReleasedInfo(reason: '未接通通话已结束，未返回最终原因');
  }

  void _notifyConnectedCallEnded(
    CallInfo call, {
    required bool wasEndedLocally,
    String? hangupReason,
  }) {
    if (call.connectedAt == null) return;

    final phoneNumber = _extractPhoneNumber(call.remoteUri);
    final reason = hangupReason?.trim();
    final reasonLabel = reason == null || reason.isEmpty ? '未返回原因' : reason;
    _addLog(
      'ℹ️ 已接通通话结束: call=${call.callId}, '
      'number=${phoneNumber.isEmpty ? call.remoteUri : phoneNumber}, '
      'localEnded=$wasEndedLocally, reason=$reasonLabel',
    );

    // 本机主动挂断已经由按钮反馈和挂断提示音表达；这里只提示非本机结束。
    if (wasEndedLocally) return;

    final targetLabel = phoneNumber.isEmpty ? '' : '：$phoneNumber';
    ToastUtil.showInfo('通话$targetLabel 已结束');
  }

  void _notifyUnansweredCallEnded(
    CallInfo call, {
    required bool wasEndedLocally,
    int? sipStatusCode,
    String? hangupReason,
  }) {
    if (call.connectedAt != null) return;

    final phoneNumber = _extractPhoneNumber(call.remoteUri);
    final directionLabel = call.direction == PjsipCallDirection.inbound
        ? '来电'
        : '呼出';
    final statusLabel = _formatUnansweredCallEndStatus(
      call,
      sipStatusCode: sipStatusCode,
    );
    _addLog(
      'ℹ️ 未接通通话已结束: call=${call.callId}, '
      'direction=$directionLabel, number=${phoneNumber.isEmpty ? call.remoteUri : phoneNumber}, '
      'localEnded=$wasEndedLocally, sip=${sipStatusCode ?? 'unknown'}, '
      'reason=${hangupReason?.trim().isEmpty == false ? hangupReason!.trim() : 'unknown'}',
    );

    // 本机主动取消外呼或拒接来电时，按钮本身已经给了明确反馈，不再弹 Toast。
    if (wasEndedLocally) return;

    final targetLabel = phoneNumber.isEmpty ? '' : '：$phoneNumber';
    ToastUtil.showWarning('$directionLabel$targetLabel 未接通，$statusLabel');
  }

  String _formatUnansweredCallEndStatus(CallInfo call, {int? sipStatusCode}) {
    return _formatSipCallEndReason(
      sipStatusCode ?? 0,
      direction: call.direction,
      wasConnected: false,
      reachedRinging: _wasOutboundRinging(call),
    );
  }

  String? _customerEndReasonForSnapshot(
    CallSipTransactionSnapshot snapshot,
    CallInfo? call,
  ) {
    if (!snapshot.hasFinalStatus) return null;

    return _formatSipCallEndReason(
      snapshot.statusCode,
      direction: call?.direction,
      wasConnected: call?.connectedAt != null,
      reachedRinging: _wasOutboundRinging(call),
      includeSipCode: true,
    );
  }

  bool _wasOutboundRinging(CallInfo? call) {
    return call?.direction == PjsipCallDirection.outbound &&
        (call?.ringingAt != null ||
            _outboundRingingAtByCallId.containsKey(call?.callId) ||
            call?.state == pjsip_inv_state.PJSIP_INV_STATE_EARLY.value);
  }

  void _archiveEndedCall(
    CallInfo call, {
    int? sipStatusCode,
    String? hangupReason,
  }) {
    final wasEndedLocally = _locallyEndedCallIds.remove(call.callId);
    final endedAt = DateTime.now();
    final direction = call.direction == PjsipCallDirection.inbound
        ? CallHistoryDirection.inbound
        : CallHistoryDirection.outbound;
    final status = _resolveCallHistoryStatus(
      call,
      wasEndedLocally: wasEndedLocally,
      sipStatusCode: sipStatusCode,
    );
    final account = call.accountId == null
        ? null
        : _uiState.accounts[call.accountId];
    final phoneNumber = _extractPhoneNumber(call.remoteUri);
    final contact = _findContactForPhoneNumber(phoneNumber);
    final personalNote = _callNotes.remove(call.callId)?.trim();
    final sharedNote = _sharedConferenceNotes.remove(call.callId)?.trim();
    final transferTarget = _blindTransferTargets.remove(call.callId)?.trim();
    final ringingAt =
        call.ringingAt ??
        (call.direction == PjsipCallDirection.outbound
            ? _outboundRingingAtByCallId[call.callId]
            : null);
    if (call.direction == PjsipCallDirection.outbound) {
      final timeToRinging = ringingAt?.difference(call.startedAt);
      _addLog(
        timeToRinging == null
            ? '📈 外呼归档未拿到响铃时间: call=${call.callId}'
            : '📈 外呼响铃统计归档: call=${call.callId}, '
                  '拨号到响铃=${timeToRinging.inMilliseconds}ms',
      );
    }
    final note = _composeCallHistoryNote(
      personalNote: personalNote,
      sharedNote: sharedNote,
      transferTarget: transferTarget,
    );

    unawaited(
      _callHistoryDatabase
          .recordCall(
            callId: call.callId,
            direction: direction,
            status: status,
            remoteUri: call.remoteUri,
            phoneNumber: phoneNumber,
            startedAt: call.startedAt,
            ringingAt: ringingAt,
            answeredAt: call.connectedAt,
            mediaConnectedAt: call.mediaConnectedAt,
            endedAt: endedAt,
            displayName: contact?.name,
            contactId: contact?.id,
            accountId: call.accountId,
            accountLabel: account?.lineLabel,
            holdCount: call.holdCount,
            holdDuration: call.effectiveHoldDuration(endedAt),
            sipStatusCode: sipStatusCode,
            hangupReason: hangupReason?.trim().isEmpty == true
                ? null
                : hangupReason == 'blind transfer local release'
                ? '盲转'
                : hangupReason,
            note: note,
          )
          .catchError((Object error, StackTrace stackTrace) {
            _addLog('⚠️ 通话记录保存失败: $error');
          }),
    );
  }

  String? _composeCallHistoryNote({
    String? personalNote,
    String? sharedNote,
    String? transferTarget,
  }) {
    final personal = personalNote?.trim();
    final shared = sharedNote?.trim();
    final transfer = transferTarget?.trim();
    final sections = <String>[];
    if (transfer != null && transfer.isNotEmpty) {
      sections.add('盲转至：$transfer');
    }
    final hasPersonal = personal != null && personal.isNotEmpty;
    final hasShared = shared != null && shared.isNotEmpty;
    if (hasShared) {
      sections.add('会议备注：$shared');
    }
    if (hasPersonal && personal != shared) {
      sections.add(hasShared ? '客户备注：$personal' : personal);
    }
    if (sections.isEmpty) return null;
    return sections.join('\n\n');
  }

  CallHistoryStatus _resolveCallHistoryStatus(
    CallInfo call, {
    required bool wasEndedLocally,
    int? sipStatusCode,
  }) {
    if (call.connectedAt != null) return CallHistoryStatus.completed;
    if (call.direction == PjsipCallDirection.inbound) {
      return wasEndedLocally
          ? CallHistoryStatus.rejected
          : CallHistoryStatus.missed;
    }
    if (wasEndedLocally) return CallHistoryStatus.canceled;
    if (sipStatusCode != null && sipStatusCode >= 400) {
      return CallHistoryStatus.failed;
    }
    return CallHistoryStatus.failed;
  }

  String _extractPhoneNumber(String remoteUri) {
    final sipMatch = RegExp(
      r'sip:([^@;>]+)',
      caseSensitive: false,
    ).firstMatch(remoteUri);
    final raw = sipMatch?.group(1) ?? remoteUri;
    return raw.replaceAll(RegExp(r'[^0-9+*#]'), '');
  }

  CallInfo? _findOngoingCallForDialNumber(String number) {
    final targetNumber = _normalizePhoneNumber(_extractPhoneNumber(number));
    if (targetNumber.isEmpty) return null;

    for (final call in _uiState.calls.values) {
      if (call.state == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED.value) {
        continue;
      }
      final callNumber = _normalizePhoneNumber(
        _extractPhoneNumber(call.remoteUri),
      );
      if (callNumber == targetNumber) return call;
    }
    return null;
  }

  ContactEntry? _findContactForPhoneNumber(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    if (normalized.isEmpty) return null;
    for (final contact in _contacts) {
      if (contact.phoneEntries.any(
        (phone) => _normalizePhoneNumber(phone.number) == normalized,
      )) {
        return contact;
      }
    }
    return null;
  }

  String _normalizePhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9+*#]'), '');
  }
}
