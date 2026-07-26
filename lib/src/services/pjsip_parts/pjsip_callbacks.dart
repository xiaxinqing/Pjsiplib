part of '../pjsip_service.dart';

/// PJSIP 原生回调适配层：负责把原生事件复制为安全的 Dart 状态。
extension _PjsipNativeCallbacks on PjsipService {
  // ⚠️ 关于“工作线程日志”的重要说明：
  //
  // 本 service 的回调全部用 NativeCallable.listener（异步）。PJSIP 工作线程调用
  // 回调时，只是往 Dart isolate 的消息队列投递一个事件后立即返回；回调闭包
  // 的代码会稍后在 Dart isolate 中执行，所以必须先复制原生数据再更新状态。
  //
  // _printLog 不进入 UI 日志列表，避免 microtask 改变诊断时序。
  Future<void> _printLog(String stage, String msg) async {
    debugPrint('🧵 [$stage] t=${DateTime.now().toIso8601String()} | $msg');
  }

  /// 把 PJSIP 的 `pj_str_t` 安全转换成 Dart 字符串。
  ///
  /// `pj_str_t` 不是以 `\0` 结尾的 C 字符串，必须按 `slen` 指定长度读取；
  /// 否则轻则读到脏字符，重则越界。
  String _pjString(pj_str_t value) {
    if (value.ptr == ffi.nullptr || value.slen <= 0) return '';
    return value.ptr.cast<Utf8>().toDartString(length: value.slen);
  }

  /// 格式化单条 SDP attribute，输出类似 `a=rtpmap:0 PCMU/8000`。
  ///
  /// 这里主要服务于日志诊断，不参与真实媒体协商。
  String _sdpAttrLine(ffi.Pointer<pjmedia_sdp_attr> attr) {
    if (attr == ffi.nullptr) return '';
    final name = _pjString(attr.ref.name);
    final value = _pjString(attr.ref.value);
    return value.isEmpty ? 'a=$name' : 'a=$name:$value';
  }

  /// 格式化 SDP connection 行，输出类似 `c=IN IP4 1.2.3.4`。
  String _sdpConnLine(ffi.Pointer<pjmedia_sdp_conn> conn) {
    if (conn == ffi.nullptr) return '';
    return 'c=${_pjString(conn.ref.net_type)} '
        '${_pjString(conn.ref.addr_type)} '
        '${_pjString(conn.ref.addr)}';
  }

  /// 生成便于人读的 SDP 摘要。
  ///
  /// PJSIP 的完整 SDP 结构层级较深；排查 ICE/STUN、DTLS-SRTP、codec 时，
  /// 只需要会话级属性和 audio media 段即可。这里还限制了最大行数，避免
  /// 异常 SDP 导致 UI 日志爆量。
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

  /// 调用 PJSIP 的 `pjsua_call_dump()` 输出媒体诊断。
  ///
  /// 常用于媒体 ACTIVE 后或传输错误时确认 SRTP、ICE selected pair、收发包
  /// 数量和丢包情况。它只读当前 call 的诊断信息，不改变通话状态。
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

  CallMediaSecurity? _readCallMediaSecurity(
    int callId,
    pjsua_call_info info,
    Arena arena, {
    bool logFailure = false,
  }) {
    final mediaCount = math.min(info.media_cnt, 16);
    for (var mediaIndex = 0; mediaIndex < mediaCount; mediaIndex++) {
      final media = info.media[mediaIndex];
      if (media.typeAsInt != pjmedia_type.PJMEDIA_TYPE_AUDIO.value) continue;
      final transportInfo = arena<pjmedia_transport_info>();
      final status = _bindings.pjsua_call_get_med_transport_info(
        callId,
        media.index,
        transportInfo,
      );
      if (status != 0) {
        if (logFailure) {
          _addLog(
            '🔐 媒体安全信息获取失败: call=$callId, media=${media.index}, pj_status=$status',
          );
        }
        return null;
      }

      var hasSrtp = false;
      final stack = <String>[];
      final count = math.min(transportInfo.ref.specific_info_cnt, 4);
      for (var index = 0; index < count; index++) {
        final type = transportInfo.ref.spc_info[index].typeAsInt;
        final label = _mediaTransportTypeLabel(type);
        if (label.isNotEmpty) stack.add(label);
        if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_SRTP.value) {
          hasSrtp = true;
        }
      }
      return CallMediaSecurity(
        hasSrtpTransport: hasSrtp,
        transportStack: stack,
      );
    }
    return null;
  }

  String _mediaTransportTypeLabel(int type) {
    if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_UDP.value) {
      return 'UDP';
    }
    if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_ICE.value) {
      return 'ICE';
    }
    if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_SRTP.value) {
      return 'SRTP';
    }
    if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_LOOP.value) {
      return 'LOOP';
    }
    if (type == pjmedia_transport_type.PJMEDIA_TRANSPORT_TYPE_USER.value) {
      return 'USER';
    }
    return 'UNKNOWN($type)';
  }

  /// 把 `pjmedia_event_type` 的整数值转换成便于阅读的名称。
  ///
  /// 生成绑定里有 enum，但日志里直接打印业务名称更快定位问题；未知值保留
  /// 原始数字，方便和 PJSIP 源码或原生日志对照。
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

  /// 提取一次 call info 快照，集中打印通话状态、SIP 状态和 Contact。
  ///
  /// 这个函数只在同步读取 `pjsua_call_info` 后立即调用；返回值是纯 Dart
  /// 字符串，可以安全带入后面的 microtask。
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

  /// 创建并保存所有注册给 PJSIP 的 Native 回调。
  ///
  /// 这些 `NativeCallable.listener` 必须在 `pjsua_init()` 前创建，并在 service
  /// dispose 时关闭。listener 是异步回调：PJSIP 工作线程只负责投递事件，
  /// Dart 闭包稍后才执行，所以每个回调都要特别注意“原生指针生命周期”。
  void _setupCallables() {
    // 本地 SDP 创建回调。
    //
    // 触发时机：
    // - PJSIP 为 INVITE/200 OK/re-INVITE 等生成本地 SDP 时触发。
    //
    // 用途：
    // - 打印本地 audio SDP，确认 codec、ICE candidate、DTLS fingerprint/setup。
    // - 如果启用了 DTLS-SRTP 但 SDP 缺少 fingerprint/setup，直接提示编译配置。
    //
    // 注意：
    // - `sdp/remSdp/pool` 都是原生结构，只能在当前闭包内同步读取。
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

    // 媒体事件回调。
    //
    // 触发时机：
    // - 媒体传输层、RTCP feedback、音视频设备等出现事件时触发。
    //
    // 用途：
    // - 普通事件记一行日志。
    // - `MEDIA_TP_ERR` 代表 RTP/RTCP/ICE/DTLS 传输错误，额外 dump call 诊断。
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

    // 盲转/咨询转状态回调。
    //
    // pjsua_call_xfer() 只代表 REFER 已发出；是否真正转接成功，需要等待
    // PBX/对端通过 NOTIFY 汇报。这里使用 NativeCallable.listener，回调会异步
    // 投递到 Dart，所以 st_text/p_cont 这类原生指针不能在闭包里解引用。
    _callTransferStatusCallable = ffi.NativeCallable.listener((
      int callId,
      int statusCode,
      ffi.Pointer<pj_str_t> statusTextPointer,
      int isFinal,
      ffi.Pointer<ffi.Int> continueReportingPointer,
    ) {
      if (!_uiState.isInitialized) return;
      final finalStatus = isFinal != 0;
      final autoRelease = _blindTransferAutoReleaseCallIds.contains(callId);
      final hasLocalCall = _uiState.calls.containsKey(callId);
      _addLog(
        '➡️ 转接状态: call=$callId, status=$statusCode, final=$finalStatus, '
        'autoRelease=$autoRelease, hasLocalCall=$hasLocalCall',
      );
      if (!finalStatus) return;

      if (autoRelease || !hasLocalCall) {
        _addLog('➡️ 甩转本机已收尾，忽略最终转接状态: call=$callId, status=$statusCode');
        return;
      }

      if (statusCode >= 200 && statusCode < 300) {
        ToastUtil.showSuccess('转接已完成');
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 120), () async {
            if (!_uiState.calls.containsKey(callId)) return;
            await hangupCall(callId);
          }),
        );
        return;
      }

      ToastUtil.showError('转接失败：$statusCode');
    });

    // 账号注册状态回调。
    //
    // 触发时机：
    // - REGISTER/UNREGISTER 收到响应，或账号注册状态发生变化。
    //
    // 用途：
    // - 更新账号 SIP 状态码、expires、暂停/注册中的 UI 状态。
    // - 注册成功后选择/提升默认外呼线路。
    // - 注册失败时清理不可用默认线路并弹出提示。
    //
    // 注意：
    // - `pjsua_acc_info` 属于 Arena；只把 status/expires/text 复制成 Dart 值。
    _regStateCallable = ffi.NativeCallable.listener((int accId) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_reg_state 闭包入口
      _printLog('T2 enqueue', 'on_reg_state: acc=$accId');
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
              ToastUtil.showSuccess('${account.displayName}线路已暂停');
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

    // 来电回调。
    //
    // 触发时机：
    // - PJSIP 收到新的 INVITE。
    //
    // 用途：
    // - 读取来电号码和所属账号，把 call 放进 UI 状态。
    //
    // 注意：
    // - `rdata` 是原始 SIP 收包数据，本实现暂不读取。
    // - call info 仍需同步复制，真正更新 UI 放到 microtask 的 T3 阶段。
    _incomingCallCallable = ffi.NativeCallable.listener((
      int accId,
      int callId,
      ffi.Pointer<pjsip_rx_data> rdata,
    ) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_incoming_call 闭包入口
      _printLog('T2 enqueue', 'on_incoming_call: call=$callId, acc=$accId');
      _addLog('📞 收到来电！ID: $callId, 来自账号: $accId');

      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        if (_bindings.pjsua_call_get_info(callId, info) == 0) {
          final remoteUri = info.ref.remote_info.ptr.cast<Utf8>().toDartString(
            length: info.ref.remote_info.slen,
          );
          // pjsua_call_info 属于 Arena；进入 microtask 前必须复制为 Dart 值。
          final callState = info.ref.stateAsInt;
          final mediaStatus = info.ref.media_statusAsInt;
          scheduleMicrotask(() {
            // [T3 handle] 真正更新状态
            _printLog('T3 handle', 'on_incoming_call: 添加 call=$callId');
            _putCall(
              CallInfo(
                callId: callId,
                state: callState,
                remoteUri: remoteUri,
                accountId: accId,
                direction: PjsipCallDirection.inbound,
                startedAt: DateTime.now(),
                mediaStatus: mediaStatus,
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
    //
    // 通话状态回调负责：
    // - CALLING/CONNECTING/CONFIRMED/DISCONNECTED 等 SIP dialog 状态同步到 UI。
    // - CONFIRMED 时记录接通时间并启动计时。
    // - DISCONNECTED 或 info 已释放时统一清理 call。
    _callStateCallable = ffi.NativeCallable.listener((
      int callId,
      ffi.Pointer<pjsip_event> e,
    ) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_call_state 闭包入口。
      // 如果对方挂断时你在控制台看到了 [T1 native] BYE，但这里【没有】T2，
      // 说明是 NativeCallable 层把回调吞了；若 T2 出现了，问题就在下面的处理。
      _printLog('T2 enqueue', 'on_call_state: call=$callId');

      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        final gotInfo = _bindings.pjsua_call_get_info(callId, info) == 0;
        // 关键诊断：get_info 是否成功。DISCONNECTED 后 call 被释放会返回非 0。
        _printLog(
          'T2 enqueue',
          'on_call_state: call=$callId, get_info成功=$gotInfo'
              '${gotInfo ? ', _uiState =${info.ref.stateAsInt}' : ' (call 已被 PJSIP 释放)'}',
        );

        if (!gotInfo) {
          // 查不到 info == call 已被释放。远端 BYE / 本地挂断后的 DISCONNECTED
          // 都会走到这里。当作“通话已结束”处理。
          scheduleMicrotask(() {
            // [T3 handle] 走“已释放 → 判定 DISCONNECTED”分支
            _printLog('T3 handle', 'on_call_state: call=$callId 走“已释放”清理分支');
            if (_locallyReleasedCallIds.remove(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('⏹ 本地已收尾，忽略已释放状态回调: call=$callId');
              return;
            }
            if (_blindTransferAutoReleaseCallIds.contains(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('➡️ 盲转本机已移除，忽略已释放状态回调: call=$callId');
              return;
            }
            _addLog(
              '📞 通话已结束: call=$callId\n'
              '原因: info 已释放，判定为 DISCONNECTED\n'
              '触发方判断: 请查看 PJSIP 原生日志中的 BYE/CANCEL/408/487\n'
              'PJSIP 原生日志: $_nativeLogFilePath',
            );
            _logEarlyOutboundDisconnectWithoutAutoRecovery(
              _uiState.calls[callId],
              sipStatusCode: 0,
              sipStatusText: 'info released',
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
        final mediaSecurity = _readCallMediaSecurity(callId, info.ref, arena);

        scheduleMicrotask(() {
          // [T3 handle] get_info 成功分支
          _printLog(
            'T3 handle',
            'on_call_state: call=$callId, state=$callState',
          );
          _addLog('📞 通话状态回调: $snapshot');
          if (callState == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED.value) {
            // 少数情况下 isolate 抢在 PJSIP 释放 call 之前执行，get_info 成功
            // 且状态就是 DISCONNECTED。与上面的失败分支做同样的清理。
            if (_locallyReleasedCallIds.remove(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('⏹ 本地已收尾，忽略断开状态回调: call=$callId');
              return;
            }
            if (_blindTransferAutoReleaseCallIds.contains(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('➡️ 盲转本机已移除，忽略断开状态回调: call=$callId');
              return;
            }
            _addLog(
              '📞 通话已挂断: call=$callId\n'
              'lastSip=$lastStatus${lastStatusText.isEmpty ? '' : ' ($lastStatusText)'}\n'
              '触发方判断: 请查看 PJSIP 原生日志中的 BYE/CANCEL/408/487\n'
              'PJSIP 原生日志: $_nativeLogFilePath',
            );
            _logEarlyOutboundDisconnectWithoutAutoRecovery(
              _uiState.calls[callId],
              sipStatusCode: lastStatus,
              sipStatusText: lastStatusText,
            );
            _removeCall(
              callId,
              sipStatusCode: lastStatus,
              hangupReason: lastStatusText,
            );
          } else {
            if (_blindTransferAutoReleaseCallIds.contains(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('➡️ 盲转本机已移除，忽略后续通话状态: call=$callId, state=$callState');
              return;
            }
            if (_locallyReleasedCallIds.contains(callId) &&
                !_uiState.calls.containsKey(callId)) {
              _addLog('⏹ 本地已收尾，忽略后续通话状态: call=$callId, state=$callState');
              return;
            }
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
                direction: prev?.direction ?? PjsipCallDirection.outbound,
                startedAt: prev?.startedAt,
                connectedAt: connectedAt,
                isOnHold: holdFlags.local,
                isRemoteOnHold: holdFlags.remote,
                mediaStatus: mediaStatus,
                mediaSecurity: mediaSecurity ?? prev?.mediaSecurity,
              ),
            );
            if (isConfirmed) {
              _scheduleBackgroundConfirmedHoldIfNeeded(callId);
            }
          }
        });
      });
    });

    // 通话媒体状态回调。
    //
    // 触发时机：
    // - SDP 协商完成、媒体 ACTIVE、hold/unhold、媒体错误等。
    //
    // 用途：
    // - 更新本地/远端 hold 标记。
    // - 媒体 ACTIVE 后才打开声卡并连接 PJSIP conference bridge。
    // - 会议通话时重建三方桥；非当前活动通话保持声卡断开。
    //
    // 注意：
    // - 这里是“真正接声卡”的入口。注册在线、空闲设备检测都不应提前打开声卡，
    //   否则 macOS 会压低系统其他声音。
    _callMediaStateCallable = ffi.NativeCallable.listener((int callId) {
      if (!_uiState.isInitialized) return;
      // [T2 enqueue] on_call_media_state 闭包入口
      _printLog('T2 enqueue', 'on_call_media_state: call=$callId');
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

        _printLog(
          'T2 enqueue',
          'on_call_media_state: call=$callId, get_info成功=$gotInfo'
              '${gotInfo ? ', media=$mediaStatusName(${info.ref.media_statusAsInt}), slot=${info.ref.conf_slot}' : ''}',
        );
        if (!gotInfo) return;

        final mediaStatusInt = info.ref.media_statusAsInt;
        final confSlot = info.ref.conf_slot;
        final mediaSecurity = _readCallMediaSecurity(
          callId,
          info.ref,
          arena,
          logFailure:
              mediaStatusInt !=
              pjsua_call_media_status.PJSUA_CALL_MEDIA_NONE.value,
        );
        const invalidId = -1; // PJSUA_INVALID_ID

        scheduleMicrotask(() {
          // [T3 handle] 更新 hold 状态
          final current = _uiState.calls[callId];
          if (current == null) {
            _printLog(
              'T3 handle',
              'on_call_media_state: call=$callId 不在列表中，跳过',
            );
            return;
          }

          final holdFlags = _resolveHoldFlags(mediaStatusInt, current);

          // 本地 Hold/Unhold 在按钮操作处已经记录“请求”日志；这里只记录
          // 无法从本地操作预知的远端 Hold 状态变化。
          if (holdFlags.remote && !current.isRemoteOnHold) {
            _addLog('⏸️ 对方已暂停通话: call=$callId');
            _printLog('T3 handle', 'on_call_media_state: 检测到远程 HOLD');
          } else if (!holdFlags.remote && current.isRemoteOnHold) {
            _addLog('▶️ 对方已恢复通话: call=$callId');
            _printLog('T3 handle', 'on_call_media_state: 检测到远程 UNHOLD');
          }

          _putCall(
            current.copyWith(
              isOnHold: holdFlags.local,
              isRemoteOnHold: holdFlags.remote,
              mediaStatus: mediaStatusInt,
              mediaSecurity: mediaSecurity ?? current.mediaSecurity,
            ),
          );
          if (mediaStatusInt ==
              pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value) {
            _scheduleBackgroundConfirmedHoldIfNeeded(callId);
          }
        });

        if (mediaStatusInt ==
                pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value &&
            confSlot != invalidId) {
          // 空闲阶段只预选设备，不打开声卡；媒体真正 ACTIVE 时才按需打开，
          // 然后再连接 conference bridge，避免注册在线期间影响系统外放音量。
          if (!_ensureSoundDeviceOpen('通话媒体已激活')) return;
          // 会议成员不受“只能有一个 activeCallId”的限制。会议桥会把本机声卡、
          // 客户和经理三方互相连接；后续任意一路媒体重新协商完成时都会重建桥。
          if (_uiState.isConferenceActive &&
              _uiState.conferenceCallIds.contains(callId)) {
            _mediaConnectedCalls.add(callId);
            _rebuildConferenceBridge('会议成员媒体 ACTIVE');
            _applyAudioVolumeState();
            _scheduleConferenceBridgeRebuilds('会议成员媒体 ACTIVE 后补偿');
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
          if (_shouldRouteCallToLocalSpeaker(callId)) {
            _bindings.pjsua_conf_connect(confSlot, 0);
          }
          if (!_uiState.isMicrophoneMuted) {
            _bindings.pjsua_conf_connect(0, confSlot);
          }
          _applyAudioVolumeState();
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

    // IP 变化处理进度回调。
    //
    // 触发时机：
    // - 网络切换、IP 变化、PJSIP 尝试重注册/更新 Contact 等过程中。
    //
    // 注意：
    // - `info` 指针只在原生回调期间有效；listener 异步投递后不再安全。
    // - 当前只传递 op/status 两个按值参数给网络处理逻辑。
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

  /// 判断注册失败是否更像网络问题，而不是账号密码或服务器拒绝。
  ///
  /// 408/503/5xx 通常意味着超时、服务不可用或网关错误；401/403 这类鉴权
  /// 失败不应把整体网络状态标记为 failed。
  bool _isNetworkRegistrationFailure(int sipStatus) {
    return sipStatus == 408 || sipStatus == 503 || sipStatus >= 500;
  }
}
