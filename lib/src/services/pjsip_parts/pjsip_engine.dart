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
  }) async {
    if (!_uiState.isNetworkAvailable) {
      _addLog('❌ 当前网络不可用，暂不发起 SIP 注册');
      return;
    }
    if (!_uiState.isInitialized) await init();
    using((Arena arena) {
      final accCfg = arena<pjsua_acc_config>();
      _bindings.pjsua_acc_config_default(accCfg);
      _pjStr(
        accCfg.ref.id,
        'sip:$username@$host'.toNativeUtf8(allocator: arena),
      );
      _pjStr(accCfg.ref.reg_uri, 'sip:$host'.toNativeUtf8(allocator: arena));

      // 开启地址重写，对 NAT 更有好
      accCfg.ref.allow_contact_rewrite = 1;

      accCfg.ref.cred_count = 1;
      final cred = accCfg.ref.cred_info[0];
      _pjStr(cred.realm, '*'.toNativeUtf8(allocator: arena));
      _pjStr(cred.scheme, 'digest'.toNativeUtf8(allocator: arena));
      _pjStr(cred.username, username.toNativeUtf8(allocator: arena));
      cred.data_type = 0;
      _pjStr(cred.data, password.toNativeUtf8(allocator: arena));
      final pAccId = arena<ffi.Int>();
      final isDefault = _uiState.defaultAccountId == null ? 1 : 0;
      final status = _bindings.pjsua_acc_add(accCfg, isDefault, pAccId);
      if (status != 0) {
        _addLog('❌ 添加 SIP 账号失败: pj_status=$status');
        return;
      }
      final account = SipAccountInfo(
        accId: pAccId.value,
        username: username,
        host: host,
      );
      final accounts = Map<int, SipAccountInfo>.of(_uiState.accounts)
        ..[account.accId] = account;
      final defaultAccountId = _uiState.defaultAccountId ?? account.accId;
      final defaultAccount = accounts[defaultAccountId] ?? account;
      _uiState = _uiState.copyWith(
        accounts: accounts,
        defaultAccountId: defaultAccountId,
        accId: defaultAccount.accId,
        host: defaultAccount.host,
      );
      _addLog('🚀 注册请求已发送: ${account.lineLabel}');
    });
  }

  void setDefaultAccount(int accId) {
    final account = _uiState.accounts[accId];
    if (account == null) return;
    final status = _bindings.pjsua_acc_set_default(accId);
    if (status != 0) {
      _addLog('❌ 设置默认外呼线路失败: acc=$accId, pj_status=$status');
      return;
    }
    _uiState = _uiState.copyWith(
      defaultAccountId: accId,
      accId: account.accId,
      host: account.host,
    );
    _addLog('✅ 默认外呼线路已切换: ${account.lineLabel}');
  }
}
