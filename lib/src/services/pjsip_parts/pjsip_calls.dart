part of '../pjsip_service.dart';

/// 单路、多路及三方会议的通话控制与音频桥管理。
extension PjsipCallOperations on PjsipService {
  Future<void> makeCall(String number) async {
    return makeCallFromAccount(number, _uiState.defaultAccountId);
  }

  Future<void> makeCallFromAccount(String number, int? accountId) async {
    if (!_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，无法发起呼叫');
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
    // 发起新通话也遵循“单路激活”规则。
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
    if (!await _holdActiveCallExcept(callId)) return;
    final status = _bindings.pjsua_call_answer(
      callId,
      200,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _uiState = _uiState.copyWith(activeCallId: callId);
      _addLog('✅ 已接听电话: call=$callId');
    } else {
      _addLog('❌ 接听失败: $status');
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
      _addLog('🚫 已拒绝来电: call=$callId');
    } else {
      _addLog('❌ 拒绝来电失败: call=$callId, pj_status=$status');
    }
  }

  Future<void> hangupCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null) return;
    // 延迟到达的 DISCONNECTED microtask 可能尚未清除本地记录，此时
    // callId 可能已失效。对死 id 调 hangup 无害但没意义，直接清理本地状态。
    if (_bindings.pjsua_call_is_active(call.callId) == 0) {
      _addLog('通话已不活跃，清理本地状态: call=${call.callId}');
      _removeCall(callId);
      return;
    }
    _addLog('⏹ 请求挂断: call=${call.callId}');
    final status = _bindings.pjsua_call_hangup(
      call.callId,
      0,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _addLog('挂断 API 调用成功，等待 DISCONNECTED: call=${call.callId}');
    } else {
      _addLog('❌ 挂断失败: call=${call.callId}, pj_status=$status');
    }
  }

  Future<void> holdCall(int callId) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) return;
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
    _addLog('▶️ 请求恢复通话: call=${call.callId}');
    // pjsua_call_reinvite(callId, 1, ...) 发起 re-INVITE 恢复媒体 sendrecv
    final status = _bindings.pjsua_call_reinvite(call.callId, 1, ffi.nullptr);
    if (status != 0) {
      _addLog('❌ 恢复失败: call=${call.callId}, pj_status=$status');
    } else {
      _putCall(call.copyWith(isOnHold: false), makeActive: true);
    }
  }

  /// 通话中发送 DTMF 按键。
  ///
  /// DTMF 是用户在 IVR 菜单里按 1/2/3、输入分机号时用到的“电话按键音”。
  /// 这里使用 PJSIP 默认的 RFC2833 方式发送，适合大多数 SIP/PBX 场景。
  Future<void> sendDtmf(int callId, String digit) async {
    final call = _uiState.calls[callId];
    if (call == null || !call.isConnected) {
      _addLog('⚠️ 当前没有可发送 DTMF 的已接通通话');
      return;
    }
    if (digit.length != 1 || !'0123456789*#'.contains(digit)) {
      _addLog('⚠️ 无效 DTMF 按键: $digit');
      return;
    }

    using((Arena arena) {
      final digits = arena<pj_str_t>();
      _pjStr(digits.ref, digit.toNativeUtf8(allocator: arena));
      final status = _bindings.pjsua_call_dial_dtmf(callId, digits);
      if (status == 0) {
        _addLog('☎️ 已发送 DTMF: $digit, call=$callId');
      } else {
        _addLog('❌ DTMF 发送失败: $digit, call=$callId, pj_status=$status');
      }
    });
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

    _rebuildConferenceBridge();
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
          final status = _bindings.pjsua_call_reinvite(callId, 1, ffi.nullptr);
          if (status != 0) {
            _addLog('❌ 恢复保留通话失败: call=$callId, pj_status=$status');
            continue;
          }
        }
        calls[callId] = call.copyWith(isOnHold: false);
      } else {
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
    _rebuildConferenceBridge();
    _addLog('▶️ 三方通话已恢复');
  }

  Future<bool> _holdActiveCallExcept(int targetCallId) async {
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
    final status = _bindings.pjsua_call_set_hold(activeId, ffi.nullptr);
    if (status != 0) {
      _addLog('❌ 自动保持失败: call=$activeId, pj_status=$status');
      return false;
    }
    _putCall(active.copyWith(isOnHold: true));
    return true;
  }

  void _putCall(CallInfo call, {bool makeActive = false}) {
    final calls = Map<int, CallInfo>.of(_uiState.calls)..[call.callId] = call;
    _uiState = _uiState.copyWith(
      calls: calls,
      activeCallId: makeActive ? call.callId : _unset,
    );
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

  void _connectCallToSound(int callId) {
    final slot = _getConferenceSlot(callId);
    if (slot == null) return;
    if (!_uiState.isSpeakerMuted) {
      _bindings.pjsua_conf_connect(slot, 0);
    }
    if (!_uiState.isMicrophoneMuted) {
      _bindings.pjsua_conf_connect(0, slot);
    }
    _mediaConnectedCalls.add(callId);
  }

  /// 重建三方音频矩阵：本机与每一路双向连接，两路远端之间也双向连接。
  void _rebuildConferenceBridge() {
    final slots = <int, int>{};
    for (final callId in _uiState.conferenceCallIds) {
      final slot = _getConferenceSlot(callId);
      if (slot != null) slots[callId] = slot;
    }
    for (final slot in slots.values) {
      if (!_uiState.isMicrophoneMuted) {
        _bindings.pjsua_conf_connect(0, slot); // 本机麦克风 -> 远端
      }
      if (!_uiState.isSpeakerMuted) {
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

  void _removeCall(int callId) {
    final calls = Map<int, CallInfo>.of(_uiState.calls)..remove(callId);
    _mediaConnectedCalls.remove(callId);
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
  }
}
