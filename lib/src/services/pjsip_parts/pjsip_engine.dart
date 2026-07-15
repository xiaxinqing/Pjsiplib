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

      uaCfg.ref.cb.on_reg_state = _regStateCallable.nativeFunction;
      uaCfg.ref.cb.on_incoming_call = _incomingCallCallable.nativeFunction;
      uaCfg.ref.cb.on_call_state = _callStateCallable.nativeFunction;
      uaCfg.ref.cb.on_call_media_state = _callMediaStateCallable.nativeFunction;
      uaCfg.ref.cb.on_call_sdp_created = _callSdpCreatedCallable.nativeFunction;
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
      // REQUIRED：强制双方都协商 timer，确保刷新机制一定生效。
      uaCfg.ref.use_timerAsInt =
          pjsua_sip_timer_use.PJSUA_SIP_TIMER_REQUIRED.value;
      // 会话过期时间（秒）。到期前会自动刷新；若刷新失败，最迟约 90s 内拆除通话。
      // 90 是 RFC 4028 允许的最小值，取较小值可让“对端消失”尽快被发现。
      uaCfg.ref.timer_setting.sess_expires = 90;
      uaCfg.ref.timer_setting.min_se = 90;

      // 原生日志直接输出到运行终端。FFI listener 回调是异步的，而日志字符
      // 指针只在原生回调期间有效，因此控制台日志也是最可靠的 SIP 抓取方式。
      logCfg.ref.msg_logging = 1;
      logCfg.ref.level = 6;
      logCfg.ref.console_level = 6;
      logCfg.ref.cb = _logCallable.nativeFunction;

      // --- 关键改进：添加 STUN 服务器解决 NAT 问题 ---
      ///STUN 的作用和影响：
      // 1.
      // 做什么：它让位于局域网内的 App 能够获知自己的公网出口 IP 和端口。
      // 2.
      // 为什么重要：SIP 协议默认会在报文中包含本地 IP。如果报文里写的是内网 IP（如 192.168.x.x），公网服务器的回包就无法送达你的 Mac。STUN 解决了这个问题，把报文里的地址改成了真实的公网地址。
      // 3.
      // 影响：
      // ◦
      // 优点：大幅提高外网通话的成功率，解决“有去无回”或者“单向语音”的问题。
      // ◦
      // 缺点：初始化时会多一次 DNS 解析和网络请求（约几十毫秒），但在现代网络下几乎无感。
      uaCfg.ref.stun_srv_cnt = 1;
      _pjStr(
        uaCfg.ref.stun_srv[0],
        'stun.l.google.com:19302'.toNativeUtf8(allocator: arena),
      );

      final initStatus = _bindings.pjsua_init(uaCfg, logCfg, mediaCfg);
      if (initStatus != 0) {
        _addLog('❌ pjsua_init 失败: pj_status=$initStatus');
        return;
      }

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
      await refreshAudioDevices();
      _startAudioDeviceMonitoring();
      _startAudioLevelTimer();
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
    required String username,
    required String password,
    required String host,
    SipTransport transport = SipTransport.udp,
    bool registrationEnabled = true,
    bool fromRestore = false,
  }) async {
    if (!_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，暂不发起 SIP 注册');
      ToastUtil.showWarning('当前网络不可用，暂不发起注册');
      return;
    }
    final normalizedUsername = username.trim();
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
      _configureAccountMediaSecurity(accCfg, transport);
      _pjStr(
        accCfg.ref.id,
        'sip:$normalizedUsername@$normalizedHost'.toNativeUtf8(
          allocator: arena,
        ),
      );
      _pjStr(
        accCfg.ref.reg_uri,
        'sip:$normalizedHost;transport=${transport.uriParam}'.toNativeUtf8(
          allocator: arena,
        ),
      );

      // 开启地址重写，对 NAT 更有好
      accCfg.ref.allow_contact_rewrite = 1;

      accCfg.ref.cred_count = 1;
      final cred = accCfg.ref.cred_info[0];
      _pjStr(cred.realm, '*'.toNativeUtf8(allocator: arena));
      _pjStr(cred.scheme, 'digest'.toNativeUtf8(allocator: arena));
      _pjStr(cred.username, normalizedUsername.toNativeUtf8(allocator: arena));
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
        username: normalizedUsername,
        password: password,
        host: normalizedHost,
        transport: transport,
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
      if (transport == SipTransport.tls) {
        _addLog('🔐 TLS 线路已启用 DTLS-SRTP 媒体加密');
      }
      if (!fromRestore) {
        unawaited(_persistSeatEnvironment());
      }
    });
  }

  void _configureAccountMediaSecurity(
    ffi.Pointer<pjsua_acc_config> accCfg,
    SipTransport transport,
  ) {
    if (transport != SipTransport.tls) {
      accCfg.ref.use_srtpAsInt = pjmedia_srtp_use.PJMEDIA_SRTP_DISABLED.value;
      return;
    }

    // TLS 只加密 SIP 信令。Asterisk `media_encryption=dtls` 还要求媒体使用
    // DTLS-SRTP，否则服务端会因 SDP 媒体协商失败而拒绝音频流。
    accCfg.ref.use_srtpAsInt = pjmedia_srtp_use.PJMEDIA_SRTP_MANDATORY.value;
    // 1 = SRTP 需要安全信令即可（TLS 满足）；2 会要求 SIPS 端到端信令。
    accCfg.ref.srtp_secure_signaling = 1;
    // Asterisk `media_encryption=dtls` 要求 SDP 里出现 fingerprint/setup。
    // 这里使用 DTLS-only，避免底层在 DTLS 不可用时退回 SDES 并发出 a=crypto。
    accCfg.ref.srtp_opt.keying_count = 1;
    accCfg.ref.srtp_opt.keying[0] =
        pjmedia_srtp_keying_method.PJMEDIA_SRTP_KEYING_DTLS_SRTP.value;
    // 当前 Asterisk endpoint 配置为 `use_avpf=no`，MicroSIP 也按传统
    // SRTP profile 工作。因此这里保持 SAVP，不启用 AVPF/RTCP mux。
    accCfg.ref.rtcp_fb_cfg.dont_use_avpf = 1;
    accCfg.ref.enable_rtcp_mux = 0;
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
        '❌ ${enabled ? '重新注册' : '暂停注册'}线路失败: ${account.lineLabel}, pj_status=$status',
      );
      ToastUtil.showError(enabled ? '重新注册失败' : '暂停线路失败');
      return;
    }
    if (!enabled) {
      _clearDefaultAccountIfUnavailable(accId);
    }
    _addLog('${enabled ? '🌐 重新注册线路' : '⏸ 暂停线路注册'}: ${account.lineLabel}');
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
    );
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
