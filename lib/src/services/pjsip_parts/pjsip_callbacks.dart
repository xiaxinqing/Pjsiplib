part of '../pjsip_service.dart';

/// PJSIP 原生回调适配层：负责把原生事件复制为安全的 Dart 状态。
extension _PjsipNativeCallbacks on PjsipService {
  // ⚠️ 关于“工作线程日志”的重要说明：
  //
  // 本 service 的回调全部用 NativeCallable.listener（异步）。PJSIP 工作线程调用
  // 回调时，只是往 Dart isolate 的消息队列投递一个事件后立即返回；回调闭包
  // 的代码会稍后在 Dart isolate 中执行，所以必须先复制原生数据再更新状态。
  //
  // 控制台诊断使用三个阶段：T1 原生日志、T2 Dart 收到事件、T3 更新业务状态。
  // _trace 不进入 UI 日志列表，避免 microtask 改变诊断时序。
  Future<void> _trace(String stage, String msg) async {
    debugPrint('🧵 [$stage] t=${DateTime.now().toIso8601String()} | $msg');
  }

  String _pjString(pj_str_t value) {
    if (value.ptr == ffi.nullptr || value.slen <= 0) return '';
    return value.ptr.cast<Utf8>().toDartString(length: value.slen);
  }

  String _sdpAttrLine(ffi.Pointer<pjmedia_sdp_attr> attr) {
    if (attr == ffi.nullptr) return '';
    final name = _pjString(attr.ref.name);
    final value = _pjString(attr.ref.value);
    return value.isEmpty ? 'a=$name' : 'a=$name:$value';
  }

  String _sdpConnLine(ffi.Pointer<pjmedia_sdp_conn> conn) {
    if (conn == ffi.nullptr) return '';
    return 'c=${_pjString(conn.ref.net_type)} '
        '${_pjString(conn.ref.addr_type)} '
        '${_pjString(conn.ref.addr)}';
  }

  String _sdpSummary(ffi.Pointer<pjmedia_sdp_session> sdp) {
    if (sdp == ffi.nullptr) return '<null>';
    final lines = <String>[];
    final session = sdp.ref;
    final sessionConn = _sdpConnLine(session.conn);
    if (sessionConn.isNotEmpty) lines.add(sessionConn);
    final sessionAttrCount = math.min(session.attr_count, 68);
    for (var i = 0; i < sessionAttrCount; i++) {
      final line = _sdpAttrLine(session.attr[i]);
      if (line.isNotEmpty) lines.add(line);
    }

    final mediaCount = math.min(session.media_count, 16);
    for (var mediaIndex = 0; mediaIndex < mediaCount; mediaIndex++) {
      final mediaPtr = session.media[mediaIndex];
      if (mediaPtr == ffi.nullptr) continue;
      final media = mediaPtr.ref;
      final mediaType = _pjString(media.desc.media);
      if (mediaType != 'audio') continue;

      final mediaConn = _sdpConnLine(media.conn);
      if (mediaConn.isNotEmpty) lines.add(mediaConn);
      final formats = <String>[];
      final fmtCount = math.min(media.desc.fmt_count, 32);
      for (var i = 0; i < fmtCount; i++) {
        final fmt = _pjString(media.desc.fmt[i]);
        if (fmt.isNotEmpty) formats.add(fmt);
      }
      lines.add(
        'm=$mediaType ${media.desc.port} '
        '${_pjString(media.desc.transport)} ${formats.join(' ')}',
      );

      final attrCount = math.min(media.attr_count, 68);
      for (var i = 0; i < attrCount; i++) {
        final line = _sdpAttrLine(media.attr[i]);
        if (line.isNotEmpty) lines.add(line);
      }
    }
    return lines.isEmpty ? '<empty>' : lines.join('\n');
  }

  void _logCallMediaDump(int callId, String reason) {
    if (!_uiState.isInitialized) return;
    using((Arena arena) {
      final buffer = arena<ffi.Char>(16000);
      final indent = ''.toNativeUtf8(allocator: arena).cast<ffi.Char>();
      final status = _bindings.pjsua_call_dump(
        callId,
        1,
        buffer,
        16000,
        indent,
      );
      if (status != 0) {
        _addLog('📊 媒体诊断获取失败: call=$callId, reason=$reason, pj_status=$status');
        return;
      }
      final dump = buffer.cast<Utf8>().toDartString();
      _addLog('📊 媒体诊断: call=$callId, reason=$reason\n$dump');
    });
  }

  String _mediaEventName(int type) {
    return switch (type) {
      0 => 'NONE',
      1212370246 => 'FMT_CHANGED',
      1111905362 => 'RX_RTCP_FB',
      1381123393 => 'AUD_DEV_ERROR',
      1381123414 => 'VID_DEV_ERROR',
      1381123412 => 'MEDIA_TP_ERR',
      538985027 => 'CALLBACK',
      _ => 'UNKNOWN($type)',
    };
  }

  void _addNativeLog(int level, String msg) {
    final normalized = msg.trimRight();
    if (normalized.trim().isEmpty) return;

    // SIP/SDP 报文可能很长。分段写入可以避免终端或 UI 单条日志过长时
    // 看起来像“后半段丢失”，排查 TLS/SRTP 协商时尤其重要。
    const chunkSize = 1600;
    final total = (normalized.length / chunkSize).ceil();
    for (var i = 0; i < normalized.length; i += chunkSize) {
      final end = math.min(i + chunkSize, normalized.length);
      final chunk = normalized.substring(i, end);
      final part = total > 1 ? ' ${i ~/ chunkSize + 1}/$total' : '';
      _addLog('[PJSIP Native L$level$part] $chunk');
    }
  }

  String _callSnapshot(pjsua_call_info info) {
    return 'call=${info.id}, _uiState =${info.state.value}(${_pjString(info.state_text)}), '
        'lastSip=${info.last_status.value}(${_pjString(info.last_status_text)}), '
        'media=${info.media_status.value}, active=${_bindings.pjsua_call_is_active(info.id)}, '
        'remote=${_pjString(info.remote_info)}, '
        'localContact=${_pjString(info.local_contact)}, '
        'remoteContact=${_pjString(info.remote_contact)}, '
        'callId=${_pjString(info.call_id)}';
  }

  /// 根据 PJSUA 媒体状态更新 Hold 标记。
  ///
  /// NONE/ERROR 常出现在媒体协商或网络异常的过渡阶段，不能据此判断已经
  /// Unhold；REMOTE_HOLD 也不能否定本地已经发出的 Hold 请求。
  ({bool local, bool remote}) _resolveHoldFlags(
    int mediaStatus,
    CallInfo? current,
  ) {
    final previousLocal = current?.isOnHold ?? false;
    final previousRemote = current?.isRemoteOnHold ?? false;

    return switch (mediaStatus) {
      1 => (local: false, remote: false), // ACTIVE
      2 => (local: true, remote: false), // LOCAL_HOLD
      3 => (local: previousLocal, remote: true), // REMOTE_HOLD
      _ => (local: previousLocal, remote: previousRemote), // NONE/ERROR
    };
  }

  void _setupCallables() {
    _logCallable = ffi.NativeCallable.listener((
      int level,
      ffi.Pointer<ffi.Char> data,
      int len,
    ) {
      if (!_uiState.isInitialized) return;
      if (data != ffi.nullptr) {
        final bytes = data.cast<ffi.Uint8>().asTypedList(len);
        final msg = utf8.decode(bytes, allowMalformed: true);
        // [T1 native] PJSIP 报文/日志。虽然 listener 是异步的，但这条能反映
        // 工作线程侧发生了什么。挂断相关 SIP 报文额外高亮，便于对照后续 T2/T3。
        final trimmed = msg.trim();
        final isIncoming = trimmed.contains('<--- Received');
        final isOutgoing = trimmed.contains('---> Transmitting');
        final direction = isIncoming
            ? '收到远端'
            : isOutgoing
            ? '本端发出'
            : 'PJSIP';
        if (msg.contains('BYE') ||
            msg.contains('CANCEL') ||
            msg.contains('SIP/2.0 487') ||
            msg.contains('SIP/2.0 408')) {
          _trace('T1 native', '$direction 挂断相关 SIP: $trimmed');
          _addLog('🧾 $direction 挂断相关 SIP\n$trimmed');
        }
        _addNativeLog(level, msg);
      }
    });

    _callSdpCreatedCallable = ffi.NativeCallable.listener((
      int callId,
      ffi.Pointer<pjmedia_sdp_session> sdp,
      ffi.Pointer<pj_pool_t> pool,
      ffi.Pointer<pjmedia_sdp_session> remSdp,
    ) {
      if (!_uiState.isInitialized) return;
      final summary = _sdpSummary(sdp);
      _addLog(
        '🧾 本地 SDP 已生成: call=$callId, remoteSdp=${remSdp != ffi.nullptr}\n'
        '$summary',
      );
      if (summary.contains('RTP/SAVP') &&
          !summary.contains('a=fingerprint') &&
          !summary.contains('a=setup')) {
        _addLog(
          '⚠️ 本地 SDP 未包含 DTLS-SRTP fingerprint/setup，'
          '请确认 libpjsip 已使用 PJMEDIA_SRTP_HAS_DTLS=1 重新编译',
        );
      }
      if (remSdp != ffi.nullptr) {
        _addLog('🧾 远端 SDP 摘要: call=$callId\n${_sdpSummary(remSdp)}');
      }
    });

    _callMediaEventCallable = ffi.NativeCallable.listener((
      int callId,
      int mediaIndex,
      ffi.Pointer<pjmedia_event> event,
    ) {
      if (!_uiState.isInitialized || event == ffi.nullptr) return;
      final type = event.ref.typeAsInt;
      final eventName = _mediaEventName(type);
      if (type == pjmedia_event_type.PJMEDIA_EVENT_MEDIA_TP_ERR.value) {
        final err = event.ref.data.med_tp_err;
        _addLog(
          '⚠️ 媒体传输错误: call=$callId, media=$mediaIndex, '
          'event=$eventName, mediaType=${err.typeAsInt}, '
          'isRtp=${err.is_rtp}, dir=${err.dirAsInt}, pj_status=${err.status}',
        );
        _logCallMediaDump(callId, 'media-transport-error');
        return;
      }
      _addLog('📡 媒体事件: call=$callId, media=$mediaIndex, event=$eventName');
    });

    _regStateCallable = ffi.NativeCallable.listener((int accId) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_reg_state 闭包入口
      _trace('T2 enqueue', 'on_reg_state: acc=$accId');
      using((Arena arena) {
        final info = arena<pjsua_acc_info>();
        if (_bindings.pjsua_acc_get_info(accId, info) == 0) {
          // pjsua_acc_info 属于 Arena，进入其他异步任务前只保留按值字段。
          final sipStatus = info.ref.statusAsInt;
          final expires = info.ref.expires;
          final statusText = info.ref.status_text.ptr.cast<Utf8>().toDartString(
            length: info.ref.status_text.slen,
          );
          if (sipStatus == 200) {
            _uiState = _uiState.copyWith(networkState: PjsipNetworkState.idle);
          } else if (_isNetworkRegistrationFailure(sipStatus) &&
              _uiState.isNetworkAvailable) {
            _uiState = _uiState.copyWith(
              networkState: PjsipNetworkState.failed,
            );
          }
          final account = _uiState.accounts[accId];
          final wasActionInProgress =
              account?.registrationActionInProgress ?? false;
          if (account != null) {
            final wasRegistered = account.isRegistered;
            final isPauseAck =
                wasActionInProgress &&
                !account.registrationEnabled &&
                sipStatus == 200;
            final isPaused =
                !account.registrationEnabled && (expires == 0 || isPauseAck);
            final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
              ..[accId] = account.copyWith(
                registrationStatus: isPaused ? 0 : sipStatus,
                registrationStatusText: isPaused ? '已暂停' : statusText,
                registrationExpires: isPaused ? 0 : expires,
                registrationActionInProgress: false,
              );
            _uiState = _uiState.copyWith(accounts: accounts);
            if (isPaused && wasActionInProgress) {
              ToastUtil.showSuccess('线路已暂停');
            } else if (sipStatus == 200 &&
                expires != 0 &&
                account.registrationEnabled &&
                (wasActionInProgress || !wasRegistered)) {
              ToastUtil.showSuccess('线路注册成功');
            } else if (sipStatus >= 300 &&
                account.registrationEnabled &&
                (wasActionInProgress || wasRegistered)) {
              ToastUtil.showError('线路注册失败：$statusText', longTime: true);
            } else if (sipStatus >= 300 &&
                !account.registrationEnabled &&
                wasActionInProgress) {
              ToastUtil.showError('暂停线路失败：$statusText', longTime: true);
            }
          }
          if (sipStatus == 200) {
            _applyPreferredDefaultAccount();
            _promoteDefaultAccountIfNeeded(accId);
          } else if (sipStatus >= 300) {
            _clearDefaultAccountIfUnavailable(accId);
          }
          unawaited(_persistSeatEnvironment());
          _addLog('🔔 账号状态更新: ID $accId, 状态: $sipStatus ($statusText)');
        }
      });
    });

    _incomingCallCallable = ffi.NativeCallable.listener((
      int accId,
      int callId,
      ffi.Pointer<pjsip_rx_data> rdata,
    ) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_incoming_call 闭包入口
      _trace('T2 enqueue', 'on_incoming_call: call=$callId, acc=$accId');
      _addLog('📞 收到来电！ID: $callId, 来自账号: $accId');

      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        if (_bindings.pjsua_call_get_info(callId, info) == 0) {
          final remoteUri = info.ref.remote_info.ptr.cast<Utf8>().toDartString(
            length: info.ref.remote_info.slen,
          );
          // pjsua_call_info 属于 Arena；进入 microtask 前必须复制为 Dart 值。
          final callState = info.ref.stateAsInt;
          scheduleMicrotask(() {
            // [T3 handle] 真正更新状态
            _trace('T3 handle', 'on_incoming_call: 添加 call=$callId');
            _putCall(
              CallInfo(
                callId: callId,
                state: callState,
                remoteUri: remoteUri,
                accountId: accId,
              ),
            );
          });
        }
      });
    });

    // ⚠️ 关键点：这是 NativeCallable.listener（异步）。
    //
    // PJSIP 在它自己的工作线程上调用 on_call_state 时，native 侧会【立即返回】，
    // 不会等待下面这个 Dart 闭包执行完。整个闭包（包括开头的 pjsua_call_get_info）
    // 是稍后在 Dart isolate 的事件循环上才被执行的。
    //
    // 这对 DISCONNECTED 状态是致命的：PJSIP 在 on_call_state(DISCONNECTED) 返回后
    // 会【马上释放这个 call】。等本闭包真正跑起来时，call 往往已经被销毁，
    // pjsua_call_get_info(callId) 会返回非 0。
    //
    // 之前“对方主动挂断这边无任何提示”的根因就在这里：旧代码用
    // `if (get_info == 0) { ... }` 把全部逻辑（打日志 + 清理通话状态）都包住了，
    // 一旦 get_info 失败，整段被跳过，UI 永远停留在“通话中”。
    //
    // 修复：get_info 失败时，判定该 call 已被 PJSIP 释放（等价于 DISCONNECTED），
    // 照常清理状态。callId 是按值传入的 int，已被安全拷贝，可放心跨异步使用。
    _callStateCallable = ffi.NativeCallable.listener((
      int callId,
      ffi.Pointer<pjsip_event> e,
    ) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_call_state 闭包入口。
      // 如果对方挂断时你在控制台看到了 [T1 native] BYE，但这里【没有】T2，
      // 说明是 NativeCallable 层把回调吞了；若 T2 出现了，问题就在下面的处理。
      _trace('T2 enqueue', 'on_call_state: call=$callId');

      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        final gotInfo = _bindings.pjsua_call_get_info(callId, info) == 0;
        // 关键诊断：get_info 是否成功。DISCONNECTED 后 call 被释放会返回非 0。
        _trace(
          'T2 enqueue',
          'on_call_state: call=$callId, get_info成功=$gotInfo'
              '${gotInfo ? ', _uiState =${info.ref.stateAsInt}' : ' (call 已被 PJSIP 释放)'}',
        );

        if (!gotInfo) {
          // 查不到 info == call 已被释放。远端 BYE / 本地挂断后的 DISCONNECTED
          // 都会走到这里。当作“通话已结束”处理。
          scheduleMicrotask(() {
            // [T3 handle] 走“已释放 → 判定 DISCONNECTED”分支
            _trace('T3 handle', 'on_call_state: call=$callId 走“已释放”清理分支');
            _addLog(
              '📞 通话已结束: call=$callId\n'
              '原因: info 已释放，判定为 DISCONNECTED\n'
              '触发方判断: 请查看 PJSIP 原生日志中的 BYE/CANCEL/408/487\n'
              'PJSIP 原生日志: $_nativeLogFilePath',
            );
            _removeCall(callId);
          });
          return;
        }

        // 不保留任何指向 Arena 的 enum/struct 包装，异步闭包只使用纯 Dart 值。
        final remoteUri = _pjString(info.ref.remote_info);
        final callState = info.ref.stateAsInt;
        final mediaStatus = info.ref.media_statusAsInt;
        final lastStatus = info.ref.last_status.value;
        final lastStatusText = _pjString(info.ref.last_status_text);
        final snapshot = _callSnapshot(info.ref);

        scheduleMicrotask(() {
          // [T3 handle] get_info 成功分支
          _trace('T3 handle', 'on_call_state: call=$callId, state=$callState');
          _addLog('📞 通话状态回调: $snapshot');
          if (callState == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED.value) {
            // 少数情况下 isolate 抢在 PJSIP 释放 call 之前执行，get_info 成功
            // 且状态就是 DISCONNECTED。与上面的失败分支做同样的清理。
            _addLog(
              '📞 通话已挂断: call=$callId\n'
              'lastSip=$lastStatus${lastStatusText.isEmpty ? '' : ' ($lastStatusText)'}\n'
              '触发方判断: 请查看 PJSIP 原生日志中的 BYE/CANCEL/408/487\n'
              'PJSIP 原生日志: $_nativeLogFilePath',
            );
            _removeCall(callId);
          } else {
            _addLog('通话状态变更: $callId -> $callState');
            final isConfirmed =
                callState == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.value;
            // 进入 CONFIRMED 时记录接通时刻并启动计时。若已在通话中，保留原
            // connectedAt，避免中途的状态刷新把计时清零。
            final prev = _uiState.calls[callId];
            final holdFlags = _resolveHoldFlags(mediaStatus, prev);
            final connectedAt = isConfirmed
                ? prev?.connectedAt ?? DateTime.now()
                : null;
            if (isConfirmed) {
              _startCallTimer();
            }
            _putCall(
              CallInfo(
                callId: callId,
                state: callState,
                remoteUri: remoteUri,
                accountId: prev?.accountId,
                connectedAt: connectedAt,
                isOnHold: holdFlags.local,
                isRemoteOnHold: holdFlags.remote,
              ),
            );
          }
        });
      });
    });

    _callMediaStateCallable = ffi.NativeCallable.listener((int callId) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_call_media_state 闭包入口
      _trace('T2 enqueue', 'on_call_media_state: call=$callId');
      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        final gotInfo = _bindings.pjsua_call_get_info(callId, info) == 0;

        // 增强诊断：明确显示媒体状态名称
        String mediaStatusName = '';
        if (gotInfo) {
          final mediaStatus = info.ref.media_statusAsInt;
          mediaStatusName = switch (mediaStatus) {
            0 => 'NONE',
            1 => 'ACTIVE',
            2 => 'LOCAL_HOLD',
            3 => 'REMOTE_HOLD',
            4 => 'ERROR',
            _ => 'UNKNOWN($mediaStatus)',
          };
        }

        _trace(
          'T2 enqueue',
          'on_call_media_state: call=$callId, get_info成功=$gotInfo'
              '${gotInfo ? ', media=$mediaStatusName(${info.ref.media_statusAsInt}), slot=${info.ref.conf_slot}' : ''}',
        );
        if (!gotInfo) return;

        final mediaStatusInt = info.ref.media_statusAsInt;
        final confSlot = info.ref.conf_slot;
        const invalidId = -1; // PJSUA_INVALID_ID

        scheduleMicrotask(() {
          // [T3 handle] 更新 hold 状态
          final current = _uiState.calls[callId];
          if (current == null) {
            _trace('T3 handle', 'on_call_media_state: call=$callId 不在列表中，跳过');
            return;
          }

          final holdFlags = _resolveHoldFlags(mediaStatusInt, current);

          // 本地 Hold/Unhold 在按钮操作处已经记录“请求”日志；这里只记录
          // 无法从本地操作预知的远端 Hold 状态变化。
          if (holdFlags.remote && !current.isRemoteOnHold) {
            _addLog('⏸️ 对方已暂停通话: call=$callId');
            _trace('T3 handle', 'on_call_media_state: 检测到远程 HOLD');
          } else if (!holdFlags.remote && current.isRemoteOnHold) {
            _addLog('▶️ 对方已恢复通话: call=$callId');
            _trace('T3 handle', 'on_call_media_state: 检测到远程 UNHOLD');
          }

          _putCall(
            current.copyWith(
              isOnHold: holdFlags.local,
              isRemoteOnHold: holdFlags.remote,
            ),
          );
        });

        if (mediaStatusInt ==
                pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value &&
            confSlot != invalidId) {
          // 会议成员不受“只能有一个 activeCallId”的限制。会议桥会把本机声卡、
          // 客户和经理三方互相连接；后续任意一路媒体重新协商完成时都会重建桥。
          if (_uiState.isConferenceActive &&
              _uiState.conferenceCallIds.contains(callId)) {
            _mediaConnectedCalls.add(callId);
            _rebuildConferenceBridge();
            _addLog('👥 会议媒体已就绪: call=$callId, slot=$confSlot');
            return;
          }
          // 只有 activeCallId 对应的通话可以占用默认声卡。其他通话即使
          // 因协商时序短暂进入 ACTIVE，也不会和当前通话混音。
          if (_uiState.activeCallId != callId) {
            _bindings.pjsua_conf_disconnect(confSlot, 0);
            _bindings.pjsua_conf_disconnect(0, confSlot);
            _mediaConnectedCalls.remove(callId);
            _addLog('🎙️ call=$callId 非当前活动通话，保持声卡断开');
            return;
          }
          // 每次协商完成 (接通/hold 恢复/换编码) 都会触发本回调，且 conf_slot
          // 可能变化，因此每次都重连。pjsua_conf_connect 幂等，重复调用安全。
          if (!_uiState.isSpeakerMuted) {
            _bindings.pjsua_conf_connect(confSlot, 0);
          }
          if (!_uiState.isMicrophoneMuted) {
            _bindings.pjsua_conf_connect(0, confSlot);
          }
          if (_mediaConnectedCalls.add(callId)) {
            _addLog('🎙️ 媒体通道已建立并连接到声卡 (slot=$confSlot)');
          }
          Future<void>.delayed(const Duration(seconds: 2), () {
            _logCallMediaDump(callId, 'media-active+2s');
          });
        } else {
          // 非激活 (远端/本地 hold、inactive、error)：断开桥接，避免向
          // 无效 slot 连接或残留旧的音频通路。
          if (_mediaConnectedCalls.remove(callId) && confSlot != invalidId) {
            _bindings.pjsua_conf_disconnect(confSlot, 0);
            _bindings.pjsua_conf_disconnect(0, confSlot);
          }
          _addLog('🎙️ 媒体状态=$mediaStatusInt，音频桥接已断开');
        }
      });
    });

    // info 指针只在原生回调期间有效，而 NativeCallable.listener 会异步投递到
    // Dart isolate，所以这里刻意只使用按值复制的 op/status，不读取 info。
    _ipChangeProgressCallable = ffi.NativeCallable.listener((
      int op,
      int status,
      ffi.Pointer<pjsua_ip_change_op_info> info,
    ) {
      _handleIpChangeProgress(op, status);
    });
  }

  bool _isNetworkRegistrationFailure(int sipStatus) {
    return sipStatus == 408 || sipStatus == 503 || sipStatus >= 500;
  }
}
