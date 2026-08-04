part of '../pjsip_service.dart';

/// PJSIP 引擎、传输、编解码器和账号注册相关操作。
extension PjsipEngineOperations on PjsipService {
  Future<void> init() async {
    if (_uiState.isInitialized) return;
    final status = _bindings.pjsua_create();
    if (status != 0) {
      _addLog('❌ 创建失败: $status');
      return;
    }

    using((Arena arena) {
      final uaCfg = arena<pjsua_config>();
      final logCfg = arena<pjsua_logging_config>();
      final mediaCfg = arena<pjsua_media_config>();
      _bindings.pjsua_config_default(uaCfg);
      _bindings.pjsua_logging_config_default(logCfg);
      _bindings.pjsua_media_config_default(mediaCfg);

      // 当前三端都只启用 PCMU/PCMA（8 kHz、单声道）。如果继续使用 PJSIP
      // 默认的 16 kHz 会议桥，就需要在声卡、会议桥和 G.711 之间持续重采样；
      // Windows 蓝牙免提设备切到 HFP 后尤其容易出现 playdbuf/capdbuf
      // Underflow。这里统一与 MicroSIP 的 G.711 配置保持一致，减少重采样和
      // 软件回声消除负担。以后启用 Opus/G.722 时，需要同步按最高启用
      // 编解码器的采样率计算 clock_rate，不能继续固定为 8 kHz。
      mediaCfg.ref.clock_rate = 8000;
      mediaCfg.ref.channel_count = 1;
      mediaCfg.ref.ec_tail_len = 20;

      uaCfg.ref.cb.on_reg_state = _regStateCallable.nativeFunction;
      uaCfg.ref.cb.on_incoming_call = _incomingCallCallable.nativeFunction;
      uaCfg.ref.cb.on_call_state = _callStateCallable.nativeFunction;
      // 不再把 on_call_tsx_state 直接挂到 Dart。
      //
      // PJSIP 传入的 pjsip_transaction / pjsip_event 指针生命周期很短，
      // NativeCallable.listener 会把回调异步投递到 Dart 主线程；等 Dart
      // 读取时指针可能已经失效，macOS crash report 已确认这里有
      // EXC_BAD_ACCESS 风险。这里改为让 dylib wrapper 在 PJSIP 同步回调内
      // 复制普通字段，Dart 只读取安全快照。
      _callSnapshots.applyCallbacks(uaCfg);
      uaCfg.ref.cb.on_call_media_state = _callMediaStateCallable.nativeFunction;
      uaCfg.ref.cb.on_call_media_event = _callMediaEventCallable.nativeFunction;
      uaCfg.ref.cb.on_call_sdp_created = _callSdpCreatedCallable.nativeFunction;
      uaCfg.ref.cb.on_call_transfer_status =
          _callTransferStatusCallable.nativeFunction;
      uaCfg.ref.cb.on_ip_change_progress =
          _ipChangeProgressCallable.nativeFunction;

      // 当前动态库的 PJSUA_MAX_CALLS 为 4；显式启用四路并发通话。
      uaCfg.ref.max_calls = 4;

      // --- 关键修复：启用 SIP Session Timer (RFC 4028) ---
      //
      // 现象：呼出通话被对方挂断时，本端收不到任何回调、UI 一直停在“通话中”。
      //
      // 根因（由日志确认）：呼出 dialog 的 remoteContact 是
      //   <sip:139.59.100.15:5060;transport=TCP>
      // 即信令实际走了 TCP（带 SDP 的 INVITE 超过 UDP MTU 触发 PJSIP 自动切换）。
      // 这条 TCP 连接是本端经 NAT 主动建立的短连接，通话结束时往往已失效，
      // Asterisk 发回的 BYE 无法穿透 NAT 送达本端 → 永远等不到 DISCONNECTED。
      // 而来电走 UDP (remoteContact 无 transport=TCP)，BYE 能正常到达，所以正常。
      //
      // Session Timer 的作用：通话期间由本端【主动】周期性发 re-INVITE/UPDATE
      // 刷新会话。一旦刷新得不到响应（对端已挂断或传输已断），本端会在会话到期后
      // 【自行拆除通话】并触发 DISCONNECTED，不再依赖那条可能已失效的入站链路。
      //
      // 先关闭 Session Timer，避免部分 PBX 的 200 OK 未完整满足 RFC 4028 时，
      // PJSIP 以 421 "Failed processing session timer response" 主动挂断。
      uaCfg.ref.use_timerAsInt =
          pjsua_sip_timer_use.PJSUA_SIP_TIMER_INACTIVE.value;

      // PJSIP 原生日志写到文件最可靠。log callback 传入的是短生命周期字符
      // 指针，而 NativeCallable.listener 会异步投递到 Dart，直接读取容易出现
      // 空白/乱码。SIP 抓包时优先查看这个文件。
      try {
        Directory(_nativeLogDirectoryPath).createSync(recursive: true);
        File(_nativeLogFilePath).writeAsStringSync('');
      } catch (_) {}
      // 编译期 `PJ_LOG_MAX_LEVEL=6` 只代表动态库允许最高输出到 6 级；
      // 日常开发默认用 4 级（info），能看到关键 SIP/注册/媒体状态，又不会被
      // trace 级 mutex/ioqueue 日志刷屏。排查 DTLS-SRTP/ICE 细节时再临时调到 6。
      const runtimePjsipLogLevel = 4;
      logCfg.ref.msg_logging = 1;
      logCfg.ref.level = runtimePjsipLogLevel;
      logCfg.ref.console_level = runtimePjsipLogLevel;
      _pjStr(
        logCfg.ref.log_filename,
        _nativeLogFilePath.toNativeUtf8(allocator: arena),
      );
      logCfg.ref.log_file_flags = 0;
      logCfg.ref.cb = ffi.nullptr;

      // 与 MicroSIP 当前测试配置对齐：不使用 Google STUN，避免把与 Asterisk
      // 信令出口不一致的公网地址写进媒体 SDP。
      uaCfg.ref.stun_srv_cnt = 0;
      // 全局 STUN 不主动尝试 IPv6 fallback。IPv6 是否参与每条线路的 SIP/媒体
      // 候选由账号级开关控制；默认减少 ICE/SDP 体积，避免 UDP INVITE 过大。
      uaCfg.ref.stun_try_ipv6 = 0;
      // X-nat 是 PJSIP 的非标准 NAT 诊断字段，关闭后 SDP 更接近 MicroSIP。
      uaCfg.ref.nat_type_in_sdp = 0;

      final initStatus = _bindings.pjsua_init(uaCfg, logCfg, mediaCfg);
      if (initStatus != 0) {
        _addLog('❌ pjsua_init 失败: pj_status=$initStatus');
        return;
      }
      _addLog(
        '🎚️ 媒体配置: bridge=8000Hz, channel=1, '
        'frame=${mediaCfg.ref.audio_frame_ptime}ms, ecTail=20ms, '
        'recordLatency=${mediaCfg.ref.snd_rec_latency}ms, '
        'playLatency=${mediaCfg.ref.snd_play_latency}ms',
      );
      _addLog(
        '🧾 PJSIP 原生日志文件: $_nativeLogFilePath '
        '(level=$runtimePjsipLogLevel)',
      );

      final transportCfg = arena<pjsua_transport_config>();
      _bindings.pjsua_transport_config_default(transportCfg);

      // 关键改动：将端口设置为 0，让系统自动分配空闲端口。
      transportCfg.ref.port = 0;
      // transportCfg.ref.port = 5060; //端口竞争，只能有一个Voip监听

      final pTransportId = arena<ffi.Int>();
      final transportStatus = _bindings.pjsua_transport_create(
        pjsip_transport_type_e.PJSIP_TRANSPORT_UDP,
        transportCfg,
        pTransportId,
      );
      if (transportStatus != 0) {
        _addLog('❌ 创建 UDP transport 失败: pj_status=$transportStatus');
        return;
      }
      _sipTransportIds[SipTransport.udp] = pTransportId.value;
      _addLog('UDP transport 创建成功: id=${pTransportId.value}, localPort=系统分配');

      // PJSIP 可能因为带 SDP 的 INVITE 超过 UDP 阈值而自动选择 TCP。
      // REGISTER 较小所以仅有 UDP 时仍能成功，但外呼会在真正发送前报
      // PJSIP_ETPNOTSUITABLE/PJSIP_EUNSUPTRANSPORT。
      final tcpTransportCfg = arena<pjsua_transport_config>();
      _bindings.pjsua_transport_config_default(tcpTransportCfg);
      tcpTransportCfg.ref.port = 0;
      final pTcpTransportId = arena<ffi.Int>();
      final tcpTransportStatus = _bindings.pjsua_transport_create(
        pjsip_transport_type_e.PJSIP_TRANSPORT_TCP,
        tcpTransportCfg,
        pTcpTransportId,
      );
      if (tcpTransportStatus != 0) {
        _addLog('❌ 创建 TCP transport 失败: pj_status=$tcpTransportStatus');
        return;
      }
      _sipTransportIds[SipTransport.tcp] = pTcpTransportId.value;
      _addLog(
        'TCP transport 创建成功: id=${pTcpTransportId.value}, localPort=系统分配',
      );

      final startStatus = _bindings.pjsua_start();
      if (startStatus != 0) {
        _addLog('❌ pjsua_start 失败: pj_status=$startStatus');
        return;
      }
      _uiState = _uiState.copyWith(isInitialized: true);
      _addLog('✅ PJSIP 引擎启动成功');

      // 精简 codec，缩小 INVITE 的 SDP，避免超过 UDP MTU 后自动切换到 TCP。
      _configureCodecs();
    });

    if (_uiState.isInitialized) {
      // 启动时要允许自动策略跑一遍：如果用户已经戴着耳机，UI 和“下一通
      // 要使用的设备”应立即选中耳机。但空闲阶段仍由 _releaseSoundDeviceIfIdle()
      // 释放 PJSIP 声卡，避免注册在线就压低系统其他声音。
      await _refreshAudioDevices(
        reason: '启动初始化',
        logResult: true,
        allowAutomaticSwitch: true,
      );
      _applyAudioVolumeState();
      _releaseSoundDeviceIfIdle('启动后空闲');
      _startAudioDeviceMonitoring();
      _scheduleDialpadKeySoundWarmup();
    }
  }

  // 精简音频 codec 列表：只保留 PCMU / PCMA (G.711 μ/A-law)，禁用其余全部。
  //
  // 目的：PJSIP 2.17 默认注册一长串 codec (opus / G722 / G729 / speex / iLBC /
  // GSM / AMR ...)，每个都会在 INVITE 的 SDP 里生成 rtpmap/fmtp 行。opus 的 fmtp
  // 尤其长，整体 SDP 很容易超过 PJSIP 的 UDP 阈值 (PJSIP_UDP_SIZE_THRESHOLD,
  // 默认 1300 字节)，一旦超过 PJSIP 会自动把 INVITE 改走 TCP。而经 NAT 的 TCP
  // 短连接在通话结束时往往已失效，导致对端的 BYE 无法送回、本端通话挂死。
  //
  // 只保留 G.711 (Asterisk 通吃、无专利、SDP 最小) 后，SDP 明显变短，INVITE 可
  // 回落到 UDP，remoteContact 不再带 transport=TCP，BYE 也就能正常到达。
  // 这与 Session Timer 是互补的两道保险：这里从源头避免走 TCP，Session Timer
  // 兜底处理任何仍然丢失 BYE 的情况。
  void _configureCodecs() {
    using((Arena arena) {
      // pjsua_enum_codecs 的 count 是 in/out 参数：传入数组容量，返回实际数量。
      const maxCodecs = 64;
      final codecs = arena<pjsua_codec_info>(maxCodecs);
      final count = arena<ffi.UnsignedInt>();
      count.value = maxCodecs;

      if (_bindings.pjsua_enum_codecs(codecs, count) != 0) {
        _addLog('⚠️ 枚举 codec 失败，保持默认 codec 配置');
        return;
      }

      final kept = <String>[];
      final disabled = <String>[];
      for (var i = 0; i < count.value; i++) {
        final info = codecs[i];
        final id = _pjString(info.codec_id); // 形如 "PCMU/8000/1"
        // 按前缀匹配，覆盖不同采样率/声道数的变体。
        final keep = id.startsWith('PCMU/') || id.startsWith('PCMA/');
        final pri = arena<pj_str_t>();
        _pjStr(pri.ref, id.toNativeUtf8(allocator: arena));
        // 优先级 0 = 禁用；非 0 = 启用 (数值越大优先级越高)。
        _bindings.pjsua_codec_set_priority(pri, keep ? 128 : 0);
        (keep ? kept : disabled).add(id);
      }
      _addLog('🎚️ codec 精简完成: 保留=$kept, 禁用${disabled.length}项');
    });
  }

  Future<void> register({
    String lineName = '',
    required String username,
    String authUsername = '',
    String sipDisplayName = '',
    String outboundProxy = '',
    required String password,
    required String host,
    SipTransport transport = SipTransport.udp,
    MediaSecurityConfig? mediaSecurity,
    IceConfig? iceConfig,
    TurnConfig turnConfig = const TurnConfig(),
    bool ipv6Enabled = false,
    bool registrationEnabled = true,
    bool fromRestore = false,
  }) async {
    if (!_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，暂不发起 SIP 注册');
      ToastUtil.showWarning('当前网络不可用，暂不发起注册');
      return;
    }
    final normalizedLineName = lineName.trim();
    final normalizedUsername = username.trim();
    final normalizedAuthUsername = authUsername.trim();
    final normalizedSipDisplayName = sipDisplayName.trim();
    final normalizedOutboundProxy = outboundProxy.trim();
    final effectiveAuthUsername = normalizedAuthUsername.isEmpty
        ? normalizedUsername
        : normalizedAuthUsername;
    final normalizedHost = _normalizeSipHost(host, transport);
    final normalizedHostKey = _sipHostIdentityKey(normalizedHost);
    if (fromRestore) {
      _removeRestoringPlaceholder(
        username: normalizedUsername,
        hostKey: normalizedHostKey,
        transport: transport,
      );
    }
    final duplicate = _uiState.accounts.values.any(
      (account) =>
          account.username == normalizedUsername &&
          _sipHostIdentityKey(account.host) == normalizedHostKey,
    );
    if (duplicate) {
      final account = _uiState.accounts.values.firstWhere(
        (account) =>
            account.username == normalizedUsername &&
            _sipHostIdentityKey(account.host) == normalizedHostKey,
      );
      if (account.transport != transport) {
        _addLog(
          '⚠️ 线路已存在，不能直接切换传输协议: ${account.lineLabel} '
          '${account.transport.label} -> ${transport.label}',
        );
        ToastUtil.showWarning('线路已存在，如需切换协议请先删除后重新添加');
        return;
      }
      if (account.isRegistered) {
        _addLog('⚠️ 线路已在线，跳过重复添加: ${account.lineLabel}');
        ToastUtil.showWarning('线路已在线');
        return;
      }
      _addLog('🌐 线路已存在但未在线，重新发起注册: ${account.lineLabel}');
      if (registrationEnabled) {
        setAccountRegistration(account.accId, true);
      }
      return;
    }
    if (!_uiState.isInitialized) await init();
    if (!_uiState.isInitialized) return;
    final effectiveMediaSecurity =
        mediaSecurity ?? _defaultMediaSecurityForTransport(transport);
    final requestedIceConfig = iceConfig ?? const IceConfig();
    final effectiveIceConfig =
        turnConfig.isUsable && !requestedIceConfig.enabled
        ? requestedIceConfig.copyWith(enabled: true)
        : requestedIceConfig;
    _logUdpIceRiskIfNeeded(transport, effectiveIceConfig);
    final transportId = _ensureSipTransport(transport);
    if (transportId == null) {
      ToastUtil.showError('${transport.label} 传输初始化失败');
      return;
    }
    using((Arena arena) {
      final accCfg = arena<pjsua_acc_config>();
      _bindings.pjsua_acc_config_default(accCfg);
      accCfg.ref.transport_id = transportId;
      accCfg.ref.register_on_acc_add = registrationEnabled ? 1 : 0;
      // MicroSIP 默认账号 keep-alive 是 15 秒，用于维持 SIP/NAT 信令通道。
      accCfg.ref.ka_interval = 15;
      _configureAccountIpv6(accCfg, ipv6Enabled);
      _configureStunServersIfNeeded(effectiveIceConfig, arena);
      _configureAccountStun(accCfg, effectiveIceConfig);
      _configureAccountIce(accCfg, effectiveIceConfig, turnConfig, arena);
      _configureAccountMediaSecurity(accCfg, effectiveMediaSecurity, transport);
      _configureAccountOutboundProxy(
        accCfg,
        normalizedOutboundProxy,
        transport,
        arena,
      );
      if (effectiveMediaSecurity.usesSrtp) {
        _addLog(
          '🔐 SRTP 配置已写入: mode=${effectiveMediaSecurity.mode.label}, '
          'use_srtp=${accCfg.ref.use_srtpAsInt}, '
          'secure_signaling=${accCfg.ref.srtp_secure_signaling}, '
          'keying_count=${accCfg.ref.srtp_opt.keying_count}',
        );
      }
      _pjStr(
        accCfg.ref.id,
        _accountSipIdentity(
          username: normalizedUsername,
          host: normalizedHost,
          sipDisplayName: normalizedSipDisplayName,
        ).toNativeUtf8(allocator: arena),
      );
      _pjStr(
        accCfg.ref.reg_uri,
        'sip:$normalizedHost;transport=${transport.uriParam}'.toNativeUtf8(
          allocator: arena,
        ),
      );

      // 与 MicroSIP 对齐：Via/Contact/SDP 都允许按服务器看到的公网地址重写。
      accCfg.ref.allow_via_rewrite = 1;
      accCfg.ref.allow_contact_rewrite = 2;

      accCfg.ref.allow_sdp_nat_rewrite = 1;
      accCfg.ref.contact_rewrite_method =
          pjsua_contact_rewrite_method.PJSUA_CONTACT_REWRITE_UNREGISTER.value |
          pjsua_contact_rewrite_method
              .PJSUA_CONTACT_REWRITE_ALWAYS_UPDATE
              .value;
      accCfg.ref.cred_count = 1;
      final cred = accCfg.ref.cred_info[0];
      _pjStr(cred.realm, '*'.toNativeUtf8(allocator: arena));
      _pjStr(cred.scheme, 'digest'.toNativeUtf8(allocator: arena));
      // 认证用户名只参与 SIP Digest 鉴权；为空时沿用线路账号。
      // SIP URI/From/Contact 仍使用线路账号，避免服务器侧分机身份被改乱。
      _pjStr(
        cred.username,
        effectiveAuthUsername.toNativeUtf8(allocator: arena),
      );
      cred.data_type = 0;
      _pjStr(cred.data, password.toNativeUtf8(allocator: arena));
      final pAccId = arena<ffi.Int>();
      final isDefault = _uiState.accounts.isEmpty && registrationEnabled
          ? 1
          : 0;
      final status = _bindings.pjsua_acc_add(accCfg, isDefault, pAccId);
      if (status != 0) {
        _addLog('❌ 添加 SIP 账号失败: pj_status=$status');
        ToastUtil.showError('添加线路失败');
        return;
      }
      final account = SipAccountInfo(
        accId: pAccId.value,
        lineName: normalizedLineName,
        username: normalizedUsername,
        authUsername: normalizedAuthUsername,
        sipDisplayName: normalizedSipDisplayName,
        outboundProxy: normalizedOutboundProxy,
        password: password,
        host: normalizedHost,
        transport: transport,
        mediaSecurity: effectiveMediaSecurity,
        iceConfig: effectiveIceConfig,
        turnConfig: turnConfig,
        ipv6Enabled: ipv6Enabled,
        registrationStatus: registrationEnabled ? null : 0,
        registrationStatusText: registrationEnabled ? '注册中' : '已暂停',
        registrationExpires: registrationEnabled ? null : 0,
        registrationEnabled: registrationEnabled,
        registrationActionInProgress: registrationEnabled,
      );
      final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
        ..[account.accId] = account;
      final defaultAccountId = _uiState.bestOutgoingAccount?.accId;
      final defaultAccount = defaultAccountId == null
          ? null
          : accounts[defaultAccountId];
      _uiState = _uiState.copyWith(
        accounts: accounts,
        defaultAccountId: defaultAccountId,
        accId: defaultAccount?.accId ?? -1,
        host: defaultAccount?.host ?? '',
      );
      _addLog(
        registrationEnabled
            ? '🚀 注册请求已发送: ${account.lineLabel} (${transport.label})'
            : '⏸ 已恢复暂停线路: ${account.lineLabel} (${transport.label})',
      );
      if (effectiveMediaSecurity.usesSrtp) {
        _addLog('🔐 媒体加密: ${effectiveMediaSecurity.mode.label}');
      }
      final stunServers = _stunServersForConfig(effectiveIceConfig);
      if (stunServers.isNotEmpty) {
        _addLog('🌐 STUN 服务器: ${stunServers.join(', ')}');
      }
      if (normalizedOutboundProxy.isNotEmpty) {
        _addLog(
          '🧭 SIP 出站代理: ${_normalizeOutboundProxyUri(normalizedOutboundProxy, transport)}',
        );
      }
      if (effectiveIceConfig.enabled) {
        final turn = turnConfig.isUsable
            ? '，TURN=${turnConfig.transport.label}:${turnConfig.server.trim()}'
            : '';
        _addLog('🧊 ICE 已启用$turn');
      }
      if (!fromRestore) {
        unawaited(_persistSeatEnvironment());
      }
    });
  }

  Future<void> updateAccount({
    required int accId,
    required String lineName,
    required String username,
    required String authUsername,
    required String sipDisplayName,
    required String outboundProxy,
    required String password,
    required String host,
    required SipTransport transport,
    required MediaSecurityConfig mediaSecurity,
    required IceConfig iceConfig,
    required TurnConfig turnConfig,
    required bool ipv6Enabled,
  }) async {
    final original = _uiState.accounts[accId];
    if (original == null || original.isRestoringPlaceholder) return;
    if (original.registrationActionInProgress) {
      _addLog('⚠️ 线路注册操作处理中，暂不能编辑: ${original.lineLabel}');
      ToastUtil.showWarning('线路操作处理中，请稍后');
      return;
    }
    final hasActiveCalls = _uiState.calls.values.any(
      (call) => call.accountId == accId,
    );
    if (hasActiveCalls) {
      _addLog('⚠️ 线路仍有通话，不能编辑: ${original.lineLabel}');
      ToastUtil.showWarning('线路仍有通话，不能编辑');
      return;
    }
    if (original.registrationEnabled && !_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，暂不能编辑在线线路: ${original.lineLabel}');
      ToastUtil.showWarning('当前网络不可用，暂不能编辑在线线路');
      return;
    }

    final normalizedLineName = lineName.trim();
    final normalizedUsername = username.trim();
    final normalizedAuthUsername = authUsername.trim();
    final normalizedSipDisplayName = sipDisplayName.trim();
    final normalizedOutboundProxy = outboundProxy.trim();
    final effectiveAuthUsername = normalizedAuthUsername.isEmpty
        ? normalizedUsername
        : normalizedAuthUsername;
    final normalizedHost = _normalizeSipHost(host, transport);
    final normalizedHostKey = _sipHostIdentityKey(normalizedHost);
    final duplicate = _uiState.accounts.values.any(
      (account) =>
          account.accId != accId &&
          account.username == normalizedUsername &&
          _sipHostIdentityKey(account.host) == normalizedHostKey,
    );
    if (duplicate) {
      _addLog('⚠️ 已存在相同账号和服务器的线路，不能保存编辑: $normalizedUsername@$normalizedHost');
      ToastUtil.showWarning('已存在相同账号和服务器的线路');
      return;
    }

    if (!_uiState.isInitialized) await init();
    if (!_uiState.isInitialized) return;
    final effectiveIceConfig = turnConfig.isUsable && !iceConfig.enabled
        ? iceConfig.copyWith(enabled: true)
        : iceConfig;
    _logUdpIceRiskIfNeeded(transport, effectiveIceConfig);
    final transportId = _ensureSipTransport(transport);
    if (transportId == null) {
      ToastUtil.showError('${transport.label} 传输初始化失败');
      return;
    }

    final modifyStatus = using<int>((Arena arena) {
      final accCfg = arena<pjsua_acc_config>();
      _bindings.pjsua_acc_config_default(accCfg);
      accCfg.ref.transport_id = transportId;
      accCfg.ref.register_on_acc_add = original.registrationEnabled ? 1 : 0;
      accCfg.ref.ka_interval = 15;
      _configureAccountIpv6(accCfg, ipv6Enabled);
      _configureStunServersIfNeeded(effectiveIceConfig, arena);
      _configureAccountStun(accCfg, effectiveIceConfig);
      _configureAccountIce(accCfg, effectiveIceConfig, turnConfig, arena);
      _configureAccountMediaSecurity(accCfg, mediaSecurity, transport);
      _configureAccountOutboundProxy(
        accCfg,
        normalizedOutboundProxy,
        transport,
        arena,
      );
      _pjStr(
        accCfg.ref.id,
        _accountSipIdentity(
          username: normalizedUsername,
          host: normalizedHost,
          sipDisplayName: normalizedSipDisplayName,
        ).toNativeUtf8(allocator: arena),
      );
      _pjStr(
        accCfg.ref.reg_uri,
        'sip:$normalizedHost;transport=${transport.uriParam}'.toNativeUtf8(
          allocator: arena,
        ),
      );
      accCfg.ref.allow_via_rewrite = 1;
      accCfg.ref.allow_contact_rewrite = 2;
      accCfg.ref.allow_sdp_nat_rewrite = 1;
      accCfg.ref.contact_rewrite_method =
          pjsua_contact_rewrite_method.PJSUA_CONTACT_REWRITE_UNREGISTER.value |
          pjsua_contact_rewrite_method
              .PJSUA_CONTACT_REWRITE_ALWAYS_UPDATE
              .value;
      accCfg.ref.cred_count = 1;
      final cred = accCfg.ref.cred_info[0];
      _pjStr(cred.realm, '*'.toNativeUtf8(allocator: arena));
      _pjStr(cred.scheme, 'digest'.toNativeUtf8(allocator: arena));
      // 认证用户名只参与 SIP Digest 鉴权；为空时沿用线路账号。
      // SIP URI/From/Contact 仍使用线路账号，避免服务器侧分机身份被改乱。
      _pjStr(
        cred.username,
        effectiveAuthUsername.toNativeUtf8(allocator: arena),
      );
      cred.data_type = 0;
      _pjStr(cred.data, password.toNativeUtf8(allocator: arena));
      final status = _bindings.pjsua_acc_modify(accId, accCfg);
      if (status != 0) return status;
      return _bindings.pjsua_acc_set_transport(accId, transportId);
    });
    if (modifyStatus != 0) {
      _addLog('❌ 编辑线路失败: ${original.lineLabel}, pj_status=$modifyStatus');
      ToastUtil.showError('编辑线路失败');
      return;
    }

    final shouldRegister = original.registrationEnabled;
    final updated = original.copyWith(
      lineName: normalizedLineName,
      username: normalizedUsername,
      authUsername: normalizedAuthUsername,
      sipDisplayName: normalizedSipDisplayName,
      outboundProxy: normalizedOutboundProxy,
      password: password,
      host: normalizedHost,
      transport: transport,
      mediaSecurity: mediaSecurity,
      iceConfig: effectiveIceConfig,
      turnConfig: turnConfig,
      ipv6Enabled: ipv6Enabled,
      registrationStatus: shouldRegister ? null : 0,
      registrationStatusText: shouldRegister ? '注册中' : '已暂停',
      registrationExpires: shouldRegister ? null : 0,
      registrationEnabled: shouldRegister,
      registrationActionInProgress: shouldRegister,
    );
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
      ..[accId] = updated;
    final defaultAccountId = _uiState.defaultAccountId;
    final defaultAccount = defaultAccountId == null
        ? null
        : accounts[defaultAccountId];
    _uiState = _uiState.copyWith(
      accounts: accounts,
      accId: defaultAccount?.accId ?? -1,
      host: defaultAccount?.host ?? '',
    );
    if (defaultAccountId == accId ||
        _preferredDefaultLineKey ==
            _lineKey(original.username, original.host)) {
      _preferredDefaultLineKey = _lineKey(updated.username, updated.host);
    }
    unawaited(_persistSeatEnvironment());

    if (shouldRegister) {
      final regStatus = _bindings.pjsua_acc_set_registration(accId, 1);
      if (regStatus != 0) {
        final failedAccounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
          ..[accId] = updated.copyWith(
            registrationStatus: 0,
            registrationStatusText: '注册失败',
            registrationExpires: 0,
            registrationActionInProgress: false,
          );
        _uiState = _uiState.copyWith(accounts: failedAccounts);
        unawaited(_persistSeatEnvironment());
        _addLog('❌ 编辑后重新注册失败: ${updated.lineLabel}, pj_status=$regStatus');
        ToastUtil.showError('编辑已保存，但重新注册失败');
        return;
      }
    }

    _addLog(
      shouldRegister
          ? '✏️ 线路已更新，正在重新注册: ${updated.lineLabel} (${transport.label})'
          : '✏️ 已保存暂停线路: ${updated.lineLabel} (${transport.label})',
    );
    ToastUtil.showSuccess(shouldRegister ? '线路已更新，正在重新注册' : '线路已保存');
  }

  MediaSecurityConfig _defaultMediaSecurityForTransport(
    SipTransport transport,
  ) {
    // 兼容旧逻辑：代码里没有显式传媒体加密配置时，TLS 线路仍默认走基础
    // DTLS-SRTP；弹窗会显式传入用户选择，所以用户选“不加密”不会被覆盖。
    return transport == SipTransport.tls
        ? const MediaSecurityConfig(mode: MediaEncryptionMode.dtlsSrtp)
        : const MediaSecurityConfig();
  }

  void _logUdpIceRiskIfNeeded(SipTransport transport, IceConfig iceConfig) {
    if (transport != SipTransport.udp || !iceConfig.enabled) return;
    _addLog(
      '⚠️ 当前线路使用 UDP + ICE：ICE 会增大 INVITE/SDP，部分网络丢弃 UDP 分片时，'
      '可能表现为外呼后服务端无日志。建议优先改用 TCP/TLS，或关闭 ICE。',
    );
  }

  void _configureStunServersIfNeeded(IceConfig iceConfig, Arena arena) {
    final stunServers = _stunServersForConfig(iceConfig);
    if (stunServers.isEmpty) return;

    // PJSUA 的 STUN server 是全局配置，不是单个账号字段；账号开启
    // STUN/ICE 前先把“用户填写 + 默认兜底”的列表更新到底层。
    _updateStunServers(stunServers, arena, reason: '账号 ICE/STUN 配置');
  }

  void _refreshStunServersForCurrentAccounts(String reason) {
    if (!_uiState.isInitialized || _uiState.accounts.isEmpty) return;
    final seen = <String>{};
    final stunServers = <String>[];
    for (final account in _uiState.accounts.values) {
      for (final server in _stunServersForConfig(account.iceConfig)) {
        if (seen.add(server.toLowerCase())) stunServers.add(server);
      }
    }
    if (stunServers.isEmpty) return;
    using((Arena arena) {
      _updateStunServers(stunServers, arena, reason: reason);
    });
  }

  void _updateStunServers(
    List<String> stunServers,
    Arena arena, {
    required String reason,
  }) {
    final stun = arena<pj_str_t>(stunServers.length);
    for (var i = 0; i < stunServers.length; i++) {
      _pjStr(stun[i], stunServers[i].toNativeUtf8(allocator: arena));
    }
    final status = _bindings.pjsua_update_stun_servers(
      stunServers.length,
      stun,
      0,
    );
    if (status != 0) {
      _addLog('⚠️ 更新 STUN 服务器失败: ${stunServers.join(', ')}, pj_status=$status');
    } else {
      _addLog('🌐 STUN 服务器已应用: ${stunServers.join(', ')} ($reason)');
    }
  }

  List<String> _stunServersForConfig(IceConfig iceConfig) {
    const defaultStunServers = <String>[
      'stun.l.google.com:19302',
      'stun.pjsip.org',
    ];
    // 用户填写的 STUN 放在最前面，后面两个默认服务器只做兜底。
    // 去重时忽略大小写，避免同一个地址被 PJSIP 重复解析。
    final userStunServers = iceConfig.stunServer
        .split(RegExp(r'[\s,;]+'))
        .map((server) => server.trim())
        .where((server) => server.isNotEmpty);
    final servers = <String>[...userStunServers, ...defaultStunServers];
    final seen = <String>{};
    return [
      for (final server in servers)
        if (server.isNotEmpty && seen.add(server.toLowerCase())) server,
    ];
  }

  void _configureAccountStun(
    ffi.Pointer<pjsua_acc_config> accCfg,
    IceConfig iceConfig,
  ) {
    if (_stunServersForConfig(iceConfig).isEmpty) {
      accCfg.ref.sip_stun_useAsInt =
          pjsua_stun_use.PJSUA_STUN_USE_DISABLED.value;
      accCfg.ref.media_stun_useAsInt =
          pjsua_stun_use.PJSUA_STUN_USE_DISABLED.value;
      return;
    }

    // STUN 用来发现公网映射地址，可以独立于 ICE 配置；ICE 开启时它会提供
    // server-reflexive candidate，ICE 关闭时仍可让账号按全局 STUN 设置做 NAT 处理。
    accCfg.ref.sip_stun_useAsInt = pjsua_stun_use.PJSUA_STUN_USE_DEFAULT.value;
    accCfg.ref.media_stun_useAsInt =
        pjsua_stun_use.PJSUA_STUN_RETRY_ON_FAILURE.value;
  }

  void _configureAccountIpv6(
    ffi.Pointer<pjsua_acc_config> accCfg,
    bool enabled,
  ) {
    // 账号级 IPv6 策略：这里只控制 PJSIP 是否在 SIP/媒体配置里使用 IPv6。
    // 它不是系统 IPv6 开关。默认关闭能减少 ICE/SDP candidate 数量，降低
    // UDP INVITE 过大、分片后被 PBX/网络链路丢弃的概率。
    final mode = enabled
        ? pjsua_ipv6_use.PJSUA_IPV6_ENABLED_PREFER_IPV4
        : pjsua_ipv6_use.PJSUA_IPV6_DISABLED;
    accCfg.ref.ipv6_sip_useAsInt = mode.value;
    accCfg.ref.ipv6_media_useAsInt = mode.value;
  }

  void _configureAccountIce(
    ffi.Pointer<pjsua_acc_config> accCfg,
    IceConfig iceConfig,
    TurnConfig turnConfig,
    Arena arena,
  ) {
    if (!iceConfig.enabled) return;

    // ICE 是媒体层 NAT 穿透配置，和 SIP 注册传输无关。仅在用户开启时按账号
    // 覆盖默认值，避免普通内网/PBX 场景下多生成公网候选地址。
    accCfg.ref.ice_cfg_useAsInt =
        pjsua_ice_config_use.PJSUA_ICE_CONFIG_USE_CUSTOM.value;
    accCfg.ref.ice_cfg.enable_ice = 1;

    if (!turnConfig.isUsable) return;
    accCfg.ref.turn_cfg_useAsInt =
        pjsua_turn_config_use.PJSUA_TURN_CONFIG_USE_CUSTOM.value;
    _configureTurnRelay(accCfg, turnConfig, arena);
  }

  void _configureTurnRelay(
    ffi.Pointer<pjsua_acc_config> accCfg,
    TurnConfig turnConfig,
    Arena arena,
  ) {
    final turn = accCfg.ref.turn_cfg;
    turn.enable_turn = 1;
    _pjStr(
      turn.turn_server,
      turnConfig.server.trim().toNativeUtf8(allocator: arena),
    );
    turn.turn_conn_typeAsInt = _pjTurnTransportType(turnConfig.transport).value;

    final hasCredential =
        turnConfig.username.trim().isNotEmpty || turnConfig.password.isNotEmpty;
    if (!hasCredential) return;

    // TURN 鉴权通常使用 long-term credential。realm 用 "*" 让 PJSIP 按服务器
    // 返回的 realm 完成认证，密码以明文方式交给底层库处理。
    final cred = turn.turn_auth_cred;
    cred.typeAsInt = pj_stun_auth_cred_type.PJ_STUN_AUTH_CRED_STATIC.value;
    final staticCred = cred.data.static_cred;
    _pjStr(staticCred.realm, '*'.toNativeUtf8(allocator: arena));
    _pjStr(
      staticCred.username,
      turnConfig.username.trim().toNativeUtf8(allocator: arena),
    );
    staticCred.data_typeAsInt = pj_stun_passwd_type.PJ_STUN_PASSWD_PLAIN.value;
    _pjStr(staticCred.data, turnConfig.password.toNativeUtf8(allocator: arena));
  }

  String _accountSipIdentity({
    required String username,
    required String host,
    required String sipDisplayName,
  }) {
    final uri = 'sip:$username@$host';
    final displayName = sipDisplayName.trim();
    if (displayName.isEmpty) return uri;

    // SIP display-name 可能进入 From 头，例如 "客服一线" <sip:1001@example.com>。
    // 本地线路名 lineName 不走这里，避免用户为了 UI 改名影响服务器侧身份。
    final escapedDisplayName = displayName
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
    return '"$escapedDisplayName" <$uri>';
  }

  void _configureAccountOutboundProxy(
    ffi.Pointer<pjsua_acc_config> accCfg,
    String outboundProxy,
    SipTransport transport,
    Arena arena,
  ) {
    final proxyUri = _normalizeOutboundProxyUri(outboundProxy, transport);
    if (proxyUri.isEmpty) return;

    // PJSIP 的 account proxy 是 Route 集合，REGISTER/INVITE 等请求都会先走它。
    // 这里仅使用第一个代理，避免普通账号弹窗变成复杂代理链配置。
    accCfg.ref.proxy_cnt = 1;
    _pjStr(accCfg.ref.proxy[0], proxyUri.toNativeUtf8(allocator: arena));
  }

  String _normalizeOutboundProxyUri(
    String outboundProxy,
    SipTransport transport,
  ) {
    final value = outboundProxy.trim();
    if (value.isEmpty) return '';
    if (value.startsWith(RegExp(r'sips?:', caseSensitive: false))) {
      return value;
    }
    final hasTransport = value.toLowerCase().contains(';transport=');
    final transportParam = hasTransport
        ? ''
        : ';transport=${transport.uriParam}';
    return 'sip:$value$transportParam';
  }

  void _configureAccountMediaSecurity(
    ffi.Pointer<pjsua_acc_config> accCfg,
    MediaSecurityConfig mediaSecurity,
    SipTransport transport,
  ) {
    final mode = mediaSecurity.mode;
    accCfg.ref.srtp_opt.crypto_count = 0;
    accCfg.ref.srtp_opt.keying_count = 0;
    if (mode == MediaEncryptionMode.none) {
      accCfg.ref.use_srtpAsInt = pjmedia_srtp_use.PJMEDIA_SRTP_DISABLED.value;
      return;
    }

    // SRTP 是媒体加密；DTLS/SDES 只是“SRTP 密钥怎么协商”的两种方式。
    // mandatory = 对端必须支持 SRTP；optional = 可加密也可回退，兼容性更好。

    accCfg.ref.use_srtpAsInt = mode.isOptional
        ? pjmedia_srtp_use.PJMEDIA_SRTP_OPTIONAL.value
        : pjmedia_srtp_use.PJMEDIA_SRTP_MANDATORY.value;

    // 1 表示 SRTP 需要安全信令承载。只有 TLS 信令能满足；UDP/TCP 下如果强制
    // 要求安全信令，PJSIP 会拒绝发起 SRTP，所以这里按传输协议自动放宽。
    accCfg.ref.srtp_secure_signaling = transport.isSecure ? 1 : 0;

    // accCfg.ref.enable_rtcp_mux=0;

    final keyingMethods = _srtpKeyingMethodsFor(mode);
    accCfg.ref.srtp_opt.keying_count = keyingMethods.length;
    for (var i = 0; i < keyingMethods.length; i++) {
      accCfg.ref.srtp_opt.keying[i] = keyingMethods[i].value;
    }
  }

  List<pjmedia_srtp_keying_method> _srtpKeyingMethodsFor(
    MediaEncryptionMode mode,
  ) {
    return switch (mode) {
      MediaEncryptionMode.none => const [],
      MediaEncryptionMode.dtlsSrtp => const [
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_DTLS_SRTP,
      ],
      MediaEncryptionMode.sdesSrtp => const [
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_SDES,
      ],
      MediaEncryptionMode.optionalDtlsFirst => const [
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_DTLS_SRTP,
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_SDES,
      ],
      MediaEncryptionMode.optionalSdesFirst => const [
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_SDES,
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_DTLS_SRTP,
      ],
    };
  }

  pj_turn_tp_type _pjTurnTransportType(TurnTransport transport) {
    return switch (transport) {
      TurnTransport.udp => pj_turn_tp_type.PJ_TURN_TP_UDP,
      TurnTransport.tcp => pj_turn_tp_type.PJ_TURN_TP_TCP,
      TurnTransport.tls => pj_turn_tp_type.PJ_TURN_TP_TLS,
    };
  }

  String _normalizeSipHost(String host, SipTransport transport) {
    final strippedScheme = host.trim().replaceFirst(
      RegExp(r'^sips?:', caseSensitive: false),
      '',
    );
    if (strippedScheme.isEmpty) return strippedScheme;

    final paramIndex = strippedScheme.indexOf(';');
    final hostPart = paramIndex == -1
        ? strippedScheme
        : strippedScheme.substring(0, paramIndex);
    final params = paramIndex == -1 ? '' : strippedScheme.substring(paramIndex);
    if (_sipHostHasPort(hostPart)) return '$hostPart$params';

    // SIP URI 中 IPv6 地址需要加方括号。这里顺手规范化，避免补端口后 URI 非法。
    final normalizedHostPart = _looksLikeUnbracketedIpv6(hostPart)
        ? '[$hostPart]'
        : hostPart;
    return '$normalizedHostPart:${transport.defaultPort}$params';
  }

  bool _sipHostHasPort(String host) {
    if (host.startsWith('[')) {
      final closingBracket = host.indexOf(']');
      return closingBracket != -1 &&
          closingBracket + 1 < host.length &&
          host[closingBracket + 1] == ':';
    }
    return ':'.allMatches(host).length == 1;
  }

  bool _looksLikeUnbracketedIpv6(String host) {
    return ':'.allMatches(host).length > 1;
  }

  String _sipHostIdentityKey(String host) {
    final withoutParams = host.split(';').first;
    if (withoutParams.startsWith('[')) {
      final closingBracket = withoutParams.indexOf(']');
      if (closingBracket != -1) {
        return withoutParams.substring(1, closingBracket).toLowerCase();
      }
    }
    final parts = withoutParams.split(':');
    if (parts.length == 2) return parts.first.toLowerCase();
    return withoutParams.toLowerCase();
  }

  void _removeRestoringPlaceholder({
    required String username,
    required String hostKey,
    required SipTransport transport,
  }) {
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts);
    final placeholders = accounts.entries
        .where(
          (entry) =>
              entry.value.isRestoringPlaceholder &&
              entry.value.username == username &&
              _sipHostIdentityKey(entry.value.host) == hostKey &&
              entry.value.transport == transport,
        )
        .map((entry) => entry.key)
        .toList();
    if (placeholders.isEmpty) return;
    for (final accId in placeholders) {
      accounts.remove(accId);
    }
    final currentDefaultWasPlaceholder =
        _uiState.defaultAccountId != null &&
        placeholders.contains(_uiState.defaultAccountId);
    _uiState = _uiState.copyWith(
      accounts: accounts,
      defaultAccountId: currentDefaultWasPlaceholder
          ? null
          : _uiState.defaultAccountId,
      accId: currentDefaultWasPlaceholder ? -1 : _uiState.accId,
      host: currentDefaultWasPlaceholder ? '' : _uiState.host,
    );
  }

  int? _ensureSipTransport(SipTransport transport) {
    final existing = _sipTransportIds[transport];
    if (existing != null) return existing;

    final statusAndId = using<(int, int?)>((Arena arena) {
      final cfg = arena<pjsua_transport_config>();
      _bindings.pjsua_transport_config_default(cfg);
      cfg.ref.port = 0;
      if (transport == SipTransport.tls) {
        // 这里先启用 TLS 信令加密，证书校验后续再通过高级设置接入。
        // verify_server=0 可兼容自签名 PBX；它仍会加密，但不防中间人攻击。
        cfg.ref.tls_setting.verify_server = 0;
      }

      final pTransportId = arena<pjsua_transport_id>();
      final status = _bindings.pjsua_transport_create(
        _pjsipTransportType(transport),
        cfg,
        pTransportId,
      );
      return (status, status == 0 ? pTransportId.value : null);
    });

    final status = statusAndId.$1;
    final transportId = statusAndId.$2;
    if (status != 0 || transportId == null) {
      _addLog('❌ 创建 ${transport.label} transport 失败: pj_status=$status');
      return null;
    }
    _sipTransportIds[transport] = transportId;
    _addLog(
      '${transport.label} transport 创建成功: id=$transportId, localPort=系统分配',
    );
    return transportId;
  }

  pjsip_transport_type_e _pjsipTransportType(SipTransport transport) {
    return switch (transport) {
      SipTransport.udp => pjsip_transport_type_e.PJSIP_TRANSPORT_UDP,
      SipTransport.tcp => pjsip_transport_type_e.PJSIP_TRANSPORT_TCP,
      SipTransport.tls => pjsip_transport_type_e.PJSIP_TRANSPORT_TLS,
    };
  }

  void setDefaultAccount(int accId) {
    final account = _uiState.accounts[accId];
    if (account == null) return;
    if (!account.isRegistered) {
      _addLog('⚠️ 线路尚未注册成功，不能设为默认外呼: ${account.lineLabel}');
      ToastUtil.showWarning('线路尚未注册成功');
      return;
    }
    final status = _bindings.pjsua_acc_set_default(accId);
    if (status != 0) {
      _addLog('❌ 设置默认外呼线路失败: acc=$accId, pj_status=$status');
      ToastUtil.showError('默认外呼切换失败');
      return;
    }
    _uiState = _uiState.copyWith(
      defaultAccountId: accId,
      accId: account.accId,
      host: account.host,
    );
    _preferredDefaultLineKey = _lineKey(account.username, account.host);
    unawaited(_persistSeatEnvironment());
    _addLog('✅ 默认外呼线路已切换: ${account.lineLabel}');
    ToastUtil.showSuccess('默认外呼已切换');
  }

  void setAccountRegistration(int accId, bool enabled) {
    final account = _uiState.accounts[accId];
    if (account == null || !_uiState.isInitialized) return;
    if (account.registrationActionInProgress) {
      _addLog('⚠️ 线路注册操作处理中，请稍后再试: ${account.lineLabel}');
      ToastUtil.showWarning('线路操作处理中，请稍后');
      return;
    }
    if (enabled &&
        account.registrationEnabled &&
        account.registrationStatus == null) {
      _addLog('⚠️ 线路正在注册中，请等待结果: ${account.lineLabel}');
      ToastUtil.showWarning('线路正在注册中');
      return;
    }
    if (!enabled && !account.registrationEnabled) {
      _addLog('⚠️ 线路已暂停: ${account.lineLabel}');
      ToastUtil.showWarning('线路已暂停');
      return;
    }
    if (!enabled &&
        _uiState.calls.values.any((call) => call.accountId == accId)) {
      _addLog('⚠️ 线路仍有通话，不能暂停: ${account.lineLabel}');
      ToastUtil.showWarning('线路仍有通话，不能暂停');
      return;
    }
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
      ..[accId] = account.copyWith(
        registrationStatus: enabled ? null : 0,
        registrationStatusText: enabled ? '注册中' : '暂停中',
        registrationExpires: enabled ? null : 0,
        registrationEnabled: enabled,
        registrationActionInProgress: true,
      );
    _uiState = _uiState.copyWith(accounts: accounts);
    unawaited(_persistSeatEnvironment());

    final status = _bindings.pjsua_acc_set_registration(accId, enabled ? 1 : 0);
    if (status != 0) {
      final rollbackAccounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
        ..[accId] = account.copyWith(registrationActionInProgress: false);
      _uiState = _uiState.copyWith(accounts: rollbackAccounts);
      unawaited(_persistSeatEnvironment());
      _addLog(
        '❌ ${enabled ? '刷新注册' : '暂停注册'}线路失败: ${account.lineLabel}, pj_status=$status',
      );
      ToastUtil.showError(enabled ? '刷新失败' : '停止线路失败');
      return;
    }
    if (!enabled) {
      _clearDefaultAccountIfUnavailable(accId);
    }
    _addLog('${enabled ? '🌐 刷新线路注册' : '⏸ 暂停线路注册'}: ${account.lineLabel}');
  }

  void forceReconnectAccount(int accId) {
    final account = _uiState.accounts[accId];
    if (account == null || !_uiState.isInitialized) return;
    if (account.registrationActionInProgress) {
      _addLog('⚠️ 线路注册操作处理中，请稍后再试: ${account.lineLabel}');
      ToastUtil.showWarning('线路操作处理中，请稍后');
      return;
    }
    if (_uiState.calls.values.any((call) => call.accountId == accId)) {
      _addLog('⚠️ 线路仍有通话，不能重启线路: ${account.lineLabel}');
      ToastUtil.showWarning('线路仍有通话，不能重启');
      return;
    }
    if (!_uiState.isNetworkAvailable) {
      _addLog('⚠️ 当前网络不可用，暂不能重启线路: ${account.lineLabel}');
      ToastUtil.showWarning('当前网络不可用');
      return;
    }
    _hangupNativeCallsIfUiIdle('重启线路前');
    _refreshStunServersForCurrentAccounts('重启线路前');
    _startOutgoingMediaRecoveryCooldown('重启线路，等待 ICE/STUN 媒体传输重建');

    final shouldUnregister =
        account.registrationEnabled &&
        (account.isRegistered ||
            account.registrationStatus == null ||
            (account.registrationExpires ?? 0) > 0);
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
      ..[accId] = account.copyWith(
        registrationStatus: null,
        registrationStatusText: '网络恢复中',
        registrationExpires: null,
        registrationEnabled: true,
        registrationActionInProgress: true,
      );
    _uiState = _uiState.copyWith(accounts: accounts);
    unawaited(_persistSeatEnvironment());

    final networkRecoveryRequested = requestSipNetworkRecovery(
      reason: '重启线路 ${account.lineLabel}',
    );

    try {
      // pjsua_acc_refresh_transport() 只刷新账号持有的 transport/cache，
      // 不等价于 unregister/register；旧版本或某些平台可能没有效果，所以失败只记日志。
      final refreshStatus = _bindings.pjsua_acc_refresh_transport(accId);
      if (refreshStatus != 0) {
        _addLog(
          '⚠️ 刷新线路传输缓存失败: ${account.lineLabel}, pj_status=$refreshStatus',
        );
      }
    } catch (error) {
      _addLog('⚠️ 当前 PJSIP 不支持刷新线路传输缓存，将继续重连: $error');
    }

    var unregisterSent = false;
    final shouldUnregisterNow = shouldUnregister && !networkRecoveryRequested;
    if (shouldUnregisterNow) {
      // 没有触发 IP Change 时，重启线路就是先发注销 REGISTER，再延迟重新注册。
      // 如果正在做 IP Change，则等 transport/listener 稳定后在 _completeForceReconnectAccount()
      // 里再注销，避免注销请求发到正在重建的旧通道。
      final unregisterStatus = _bindings.pjsua_acc_set_registration(accId, 0);
      if (unregisterStatus == 0) {
        unregisterSent = true;
        _addLog('🔄 重启线路：已发送线路注销请求: ${account.lineLabel}');
      } else {
        _addLog(
          '⚠️ 重启线路：注销请求失败，将直接重新注册: ${account.lineLabel}, pj_status=$unregisterStatus',
        );
      }
    }

    unawaited(
      _completeForceReconnectAccount(
        accId,
        networkRecoveryRequested
            ? const Duration(milliseconds: 2500)
            : unregisterSent
            ? const Duration(milliseconds: 900)
            : const Duration(milliseconds: 2500),
        unregisterBeforeRegister: shouldUnregister && networkRecoveryRequested,
      ),
    );
    ToastUtil.showSuccess('已开始重启线路');
  }

  Future<void> _completeForceReconnectAccount(
    int accId,
    Duration delay, {
    required bool unregisterBeforeRegister,
  }) async {
    await Future<void>.delayed(delay);
    if (_isDisposed || !_uiState.isInitialized) return;
    final account = _uiState.accounts[accId];
    if (account == null) return;

    if (unregisterBeforeRegister) {
      // IP Change 完成后的二段式重连：先让服务器移除旧 Contact，再注册新 Contact。
      // 直接 register 容易留下旧 NAT 映射，表现为能接听但外呼/媒体短暂异常。
      final unregisterAccounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
        ..[accId] = account.copyWith(
          registrationStatus: null,
          registrationStatusText: '重连中',
          registrationExpires: null,
          registrationEnabled: true,
          registrationActionInProgress: true,
        );
      _uiState = _uiState.copyWith(accounts: unregisterAccounts);
      unawaited(_persistSeatEnvironment());

      final unregisterStatus = _bindings.pjsua_acc_set_registration(accId, 0);
      if (unregisterStatus == 0) {
        _addLog('🔄 重启线路：网络恢复后已发送线路注销请求: ${account.lineLabel}');
        await Future<void>.delayed(const Duration(milliseconds: 450));
      } else {
        _addLog(
          '⚠️ 重启线路：网络恢复后注销请求失败，将直接重新注册: ${account.lineLabel}, pj_status=$unregisterStatus',
        );
      }
      if (_isDisposed || !_uiState.isInitialized) return;
    }

    final latestAccount = _uiState.accounts[accId];
    if (latestAccount == null) return;
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
      ..[accId] = latestAccount.copyWith(
        registrationStatus: null,
        registrationStatusText: '注册中',
        registrationExpires: null,
        registrationEnabled: true,
        registrationActionInProgress: true,
      );
    _uiState = _uiState.copyWith(accounts: accounts);
    unawaited(_persistSeatEnvironment());

    final status = _bindings.pjsua_acc_set_registration(accId, 1);
    if (status != 0) {
      final rollbackAccount = _uiState.accounts[accId];
      if (rollbackAccount != null) {
        final rollbackAccounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
          ..[accId] = rollbackAccount.copyWith(
            registrationStatusText: '重连失败',
            registrationActionInProgress: false,
          );
        _uiState = _uiState.copyWith(accounts: rollbackAccounts);
        unawaited(_persistSeatEnvironment());
      }
      _addLog('❌ 重启线路失败: ${account.lineLabel}, pj_status=$status');
      ToastUtil.showError('重启线路失败');
      return;
    }

    _addLog('🌐 重启线路：已重新发送注册请求: ${account.lineLabel}');
  }

  void disconnectAllAccounts() {
    if (!_uiState.isInitialized || _uiState.accounts.isEmpty) return;
    if (_uiState.isPhoneServiceRestarting) {
      ToastUtil.showWarning('电话服务正在重启');
      return;
    }
    if (_uiState.calls.isNotEmpty) {
      _addLog('⚠️ 当前仍有通话，不能断开全部线路');
      ToastUtil.showWarning('请先结束当前通话，再断开全部线路');
      return;
    }

    final stopWatch = Stopwatch()..start();
    final accountsSnapshot = _uiState.accounts.values.toList();
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts);
    final pendingAccounts = <SipAccountInfo>[];
    var locallyPaused = 0;
    var alreadyDisconnected = 0;

    for (final account in accountsSnapshot) {
      if (account.registrationActionInProgress) {
        _addLog('⚠️ 跳过处理中线路: ${account.lineLabel}');
        continue;
      }
      if (!account.registrationEnabled && !account.isRegistered) {
        alreadyDisconnected++;
        continue;
      }

      // 已经失败/离线的账号没有必要再向 PJSIP 发 unregister。直接把 UI 和持久化
      // 状态标记为暂停即可；真正在线或注册中的账号才需要通知 PJSIP。
      final shouldUnregisterNative =
          account.isRegistered || account.registrationStatus == null;
      if (shouldUnregisterNative) {
        pendingAccounts.add(account);
      } else {
        locallyPaused++;
      }
      accounts[account.accId] = account.copyWith(
        registrationStatus: 0,
        registrationStatusText: shouldUnregisterNative ? '暂停中' : '已暂停',
        registrationExpires: 0,
        registrationEnabled: false,
        registrationActionInProgress: shouldUnregisterNative,
      );
    }

    if (pendingAccounts.isEmpty && locallyPaused == 0) {
      ToastUtil.showWarning(alreadyDisconnected > 0 ? '线路已断开' : '没有可断开的线路');
      return;
    }

    // “断开全部”只注销账号，不销毁 pjsua endpoint。pjsua_destroy() 在桌面端
    // 常会同步等待网络/transport 清理 1 秒左右，放在 UI isolate 会造成明显卡顿。
    _uiState = _uiState.copyWith(
      accounts: accounts,
      defaultAccountId: null,
      accId: -1,
      host: '',
    );
    unawaited(_persistSeatEnvironment());

    var sent = 0;
    var failed = 0;
    for (final account in pendingAccounts) {
      final status = _bindings.pjsua_acc_set_registration(account.accId, 0);
      if (status == 0) {
        sent++;
        _addLog('⏸ 暂停线路注册: ${account.lineLabel}');
        continue;
      }

      failed++;
      final rollbackAccounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
        ..[account.accId] = account.copyWith(
          registrationActionInProgress: false,
        );
      _uiState = _uiState.copyWith(accounts: rollbackAccounts);
      _addLog('❌ 断开线路失败: ${account.lineLabel}, pj_status=$status');
    }

    if (failed == 0) {
      ToastUtil.showSuccess(sent > 0 ? '已发送全部线路断开请求' : '已断开全部线路');
    } else {
      ToastUtil.showError('部分线路断开失败');
    }
    _addLog(
      '⏱ 断开全部线路请求耗时: ${stopWatch.elapsedMilliseconds}ms, '
      'sent=$sent, local=$locallyPaused, skipped=$alreadyDisconnected, failed=$failed',
    );
  }

  Future<void> restartPhoneService() async {
    if (_uiState.isPhoneServiceRestarting) {
      ToastUtil.showWarning('电话服务正在重启');
      return;
    }
    if (_uiState.calls.isNotEmpty) {
      _addLog('⚠️ 当前仍有通话，不能重启电话服务');
      ToastUtil.showWarning('请先结束当前通话，再重启电话服务');
      return;
    }
    if (_uiState.accounts.values.any(
      (account) => account.registrationActionInProgress,
    )) {
      _addLog('⚠️ 线路仍有注册操作处理中，不能重启电话服务');
      ToastUtil.showWarning('线路操作处理中，请稍后');
      return;
    }
    if (!_uiState.isNetworkAvailable) {
      _addLog('⚠️ 当前网络不可用，暂不能重启电话服务');
      ToastUtil.showWarning('当前网络不可用');
      return;
    }

    final stopWatch = Stopwatch()..start();
    _uiState = _uiState.copyWith(isPhoneServiceRestarting: true);
    _addLog('🔁 准备重启电话服务');

    try {
      // 先保存当前“真实线路配置”。后面临时把线路标成“重启中”、
      // stop() 又会清空账号列表，如果先改状态再持久化，就会把账号错误地存成临时状态。
      await _persistSeatEnvironmentNow();
      if (_isDisposed) return;

      final accountsSnapshot = _uiState.accounts.values
          .where((account) => !account.isRestoringPlaceholder)
          .toList();

      if (_uiState.isInitialized) {
        await _unregisterAccountsBeforeRestart(accountsSnapshot);
        if (_isDisposed) return;

        _addLog('⏳ 正在关闭 PJSIP 引擎，等待 transport/media 资源释放');
        stop(keepRestarting: true);

        // pjsua_destroy() 返回后，底层 transport/media 资源在桌面端仍可能有短暂释放窗口。
        // 给它一段安静时间，避免马上 init/register 时复用到半释放的网络或声卡状态。
        // 这里比普通强制重连更重：适合“休眠恢复后只能接不能打”等底层状态卡住的场景。
        await Future<void>.delayed(const Duration(seconds: 4));
        if (_isDisposed) return;
      }

      await init();
      if (_isDisposed) return;
      await _loadCachedAgent();
      if (_isDisposed) return;

      _uiState = _uiState.copyWith(isPhoneServiceRestarting: false);
      _addLog('✅ 电话服务重启完成: ${stopWatch.elapsedMilliseconds}ms');
      ToastUtil.showSuccess('电话服务已重启');
    } catch (error) {
      if (_isDisposed) return;
      _uiState = _uiState.copyWith(isPhoneServiceRestarting: false);
      _addLog('❌ 电话服务重启失败: $error');
      ToastUtil.showError('电话服务重启失败');
    }
  }

  Future<void> _unregisterAccountsBeforeRestart(
    List<SipAccountInfo> accountsSnapshot,
  ) async {
    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts);
    var sent = 0;
    var skipped = 0;
    var failed = 0;

    for (final account in accountsSnapshot) {
      if (_isDisposed || !_uiState.isInitialized) return;
      final shouldUnregister =
          account.registrationEnabled &&
          (account.isRegistered ||
              account.registrationStatus == null ||
              (account.registrationExpires ?? 0) > 0);
      if (!shouldUnregister) {
        skipped++;
        continue;
      }

      final latest = accounts[account.accId] ?? account;
      accounts[account.accId] = latest.copyWith(
        registrationStatus: null,
        registrationStatusText: '重启中',
        registrationExpires: null,
        registrationActionInProgress: true,
      );
      _uiState = _uiState.copyWith(
        accounts: Map<int, SipAccountInfo>.of(accounts),
      );

      final status = _bindings.pjsua_acc_set_registration(account.accId, 0);
      if (status == 0) {
        sent++;
        _addLog('🔄 重启电话服务：已发送线路注销请求: ${account.lineLabel}');
      } else {
        failed++;
        _addLog(
          '⚠️ 重启电话服务：注销请求失败，将继续重启: ${account.lineLabel}, pj_status=$status',
        );
      }

      // 多账号注销不要并发打给 PJSIP。逐个等一下，能降低 registrar/transport
      // 同时处理多条 REGISTER expires=0 时的偶发失败，也便于日志对应具体线路。
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    _addLog('⏱ 重启前注销完成: sent=$sent, skipped=$skipped, failed=$failed');
  }

  void removeAccount(int accId) {
    final account = _uiState.accounts[accId];
    if (account == null || !_uiState.isInitialized) return;
    final hasActiveCalls = _uiState.calls.values.any(
      (call) => call.accountId == accId,
    );
    if (hasActiveCalls) {
      _addLog('⚠️ 线路仍有通话，不能删除: ${account.lineLabel}');
      ToastUtil.showWarning('线路仍有通话，不能删除');
      return;
    }

    final status = using((Arena arena) {
      final param = arena<pjsua_acc_del_param>();
      _bindings.pjsua_acc_del_param_default(param);
      param.ref.force = 1;
      return _bindings.pjsua_acc_del2(accId, param);
    });
    if (status != 0) {
      _addLog('❌ 删除线路失败: ${account.lineLabel}, pj_status=$status（请先结束该线路通话）');
      ToastUtil.showError('删除线路失败');
      return;
    }

    final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
      ..remove(accId);
    final removedPreferredLine =
        _preferredDefaultLineKey == _lineKey(account.username, account.host);
    if (removedPreferredLine) {
      _preferredDefaultLineKey = null;
    }
    final nextDefaultId = _uiState.defaultAccountId == accId
        ? _firstRegisteredAccountId(accounts)
        : _uiState.defaultAccountId;
    final nextDefault = nextDefaultId == null ? null : accounts[nextDefaultId];
    if (nextDefaultId != null) {
      _bindings.pjsua_acc_set_default(nextDefaultId);
      if (removedPreferredLine && nextDefault != null) {
        _preferredDefaultLineKey = _lineKey(
          nextDefault.username,
          nextDefault.host,
        );
      }
    }
    _uiState = _uiState.copyWith(
      accounts: accounts,
      defaultAccountId: nextDefaultId,
      accId: nextDefault?.accId ?? -1,
      host: nextDefault?.host ?? '',
      seatEnvironmentState: accounts.isEmpty
          ? SeatEnvironmentState.ready
          : _uiState.seatEnvironmentState,
    );
    if (accounts.isEmpty) {
      _resetLineRecoveryStateWithoutAccounts(reason: '已删除最后一条线路');
    }
    unawaited(_persistSeatEnvironment());
    _addLog('🗑 已删除线路: ${account.lineLabel}');
    ToastUtil.showSuccess('线路已删除');
  }

  int? _firstRegisteredAccountId(Map<int, SipAccountInfo> accounts) {
    for (final account in accounts.values) {
      if (account.isRegistered) return account.accId;
    }
    return null;
  }

  void _promoteDefaultAccountIfNeeded(int accId) {
    final account = _uiState.accounts[accId];
    if (account == null || !account.isRegistered) return;
    final currentDefault = _uiState.defaultAccount;
    if (currentDefault?.isRegistered == true) return;
    final status = _bindings.pjsua_acc_set_default(accId);
    if (status != 0) {
      _addLog('❌ 自动切换默认外呼线路失败: ${account.lineLabel}, pj_status=$status');
      ToastUtil.showError('默认外呼自动切换失败');
      return;
    }
    _uiState = _uiState.copyWith(
      defaultAccountId: accId,
      accId: account.accId,
      host: account.host,
    );
    unawaited(_persistSeatEnvironment());
    _addLog('✅ 已自动选择可用外呼线路: ${account.lineLabel}');
  }

  void _clearDefaultAccountIfUnavailable(int accId) {
    if (_uiState.defaultAccountId != accId) return;
    final nextDefaultId = _firstRegisteredAccountId(_uiState.accounts);
    final nextDefault = nextDefaultId == null
        ? null
        : _uiState.accounts[nextDefaultId];
    if (nextDefaultId != null) {
      _bindings.pjsua_acc_set_default(nextDefaultId);
    }
    _uiState = _uiState.copyWith(
      defaultAccountId: nextDefaultId,
      accId: nextDefault?.accId ?? -1,
      host: nextDefault?.host ?? '',
    );
    unawaited(_persistSeatEnvironment());
  }
}
