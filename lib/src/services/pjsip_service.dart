import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/pjsip_bindings.g.dart';

class PjsipLog {
  final String message;
  final DateTime time;

  PjsipLog(this.message) : time = DateTime.now();
}

class CallInfo {
  final int callId;
  final int state; // pjsip_inv_state
  final String remoteUri;

  /// 通话接通 (进入 CONFIRMED) 的时间戳，用于计时。未接通时为 null。
  final DateTime? connectedAt;

  CallInfo({
    required this.callId,
    required this.state,
    required this.remoteUri,
    this.connectedAt,
  });

  bool get isIncoming =>
      state == pjsip_inv_state.PJSIP_INV_STATE_INCOMING.value;

  /// 通话是否已真正接通 (媒体已建立)。
  bool get isConnected =>
      state == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.value;

  /// 已接通时长。未接通返回 Duration.zero。
  Duration get duration => connectedAt == null
      ? Duration.zero
      : DateTime.now().difference(connectedAt!);

  /// 计时文案，形如 "01:23" 或 "1:02:03"。
  String get durationLabel {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  /// 根据 pjsip_inv_state 给出可显示的通话状态文案。
  String get statusLabel {
    switch (state) {
      case 1: // CALLING
        return '📲 正在呼叫…';
      case 2: // INCOMING
        return '🔔 收到来电';
      case 3: // EARLY
        return '📳 对方振铃中…';
      case 4: // CONNECTING
        return '🔗 接通中…';
      case 5: // CONFIRMED
        return '📞 通话中';
      case 6: // DISCONNECTED
        return '🔚 通话已结束';
      default:
        return '通话状态: $state';
    }
  }
}

class PjsipUIState {
  final List<PjsipLog> logs;
  final CallInfo? currentCall;
  final bool isInitialized;
  final int accId;
  final String host;

  PjsipUIState({
    required this.logs,
    this.currentCall,
    this.isInitialized = false,
    this.accId = -1,
    this.host = '',
  });

  PjsipUIState copyWith({
    List<PjsipLog>? logs,
    CallInfo? currentCall,
    bool? isInitialized,
    int? accId,
    String? host,
    bool clearCall = false,
  }) {
    return PjsipUIState(
      logs: logs ?? this.logs,
      currentCall: clearCall ? null : (currentCall ?? this.currentCall),
      isInitialized: isInitialized ?? this.isInitialized,
      accId: accId ?? this.accId,
      host: host ?? this.host,
    );
  }
}

class PjsipService extends Notifier<PjsipUIState> {
  late PjsipBindings _bindings;
  final Set<int> _mediaConnectedCalls = <int>{};

  // 通话计时器：接通后每秒触发一次 state 刷新，让 UI 上的时长走动。
  // duration 本身由 CallInfo.connectedAt 实时算出，timer 只负责触发重建。
  Timer? _callTimer;

  // 保持对 Callable 的引用，防止被 GC 回收
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)
  >
  _logCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _regStateCallable;
  late ffi.NativeCallable<
    ffi.Void Function(ffi.Int, ffi.Int, ffi.Pointer<pjsip_rx_data>)
  >
  _incomingCallCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int, ffi.Pointer<pjsip_event>)>
  _callStateCallable;
  late ffi.NativeCallable<ffi.Void Function(ffi.Int)> _callMediaStateCallable;

  @override
  PjsipUIState build() {
    final dylib = ffi.DynamicLibrary.open('libpjsip.dylib');
    _bindings = PjsipBindings(dylib);
    _setupCallables();
    // Notifier 不会自动调用 dispose()，必须显式注册清理，否则 NativeCallable
    // 永远不会 close()，pjsua 也不会销毁。
    ref.onDispose(_cleanup);
    return PjsipUIState(logs: []);
  }

  void _addLog(String msg) {
    debugPrint('🔔 printLog: ID $msg');
    scheduleMicrotask(() {
      state = state.copyWith(logs: [...state.logs, PjsipLog(msg)]);
    });
  }

  // 每秒重建一次 state，驱动 UI 上的通话时长刷新。connectedAt 不变，因此
  // 只是触发 Riverpod 通知；durationLabel 会算出最新的秒数。
  void _startCallTimer() {
    if (_callTimer != null) return; // 已在计时，避免重复启动
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final call = state.currentCall;
      if (call == null || !call.isConnected) {
        _stopCallTimer();
        return;
      }
      // 用同一份 CallInfo 触发一次通知即可，duration 是实时计算的。
      state = state.copyWith(currentCall: call);
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  // ⚠️ 关于“工作线程日志”的重要说明：
  //
  // 本 service 的回调全部用 NativeCallable.listener（异步）。PJSIP 工作线程调用
  // 回调时，只是往 Dart isolate 的消息队列投递一个事件后【立即返回】，回调闭包
  // 的每一行代码都在 isolate 上【延迟执行】，因此无法“在工作线程里”用 Dart 打日志。
  //
  // 真正的工作线程实时输出是 PJSIP 的 native 日志（console_level=6，同步打印
  // SIP 报文到控制台）。要判断“回调被吞 vs 处理错了”，请对照下面三类时间点：
  //   [T1 native]   —— 工作线程：PJSIP 打印的 SIP 报文 (收到 BYE / 200 OK 等)
  //   [T2 enqueue]  —— isolate：回调闭包入口，说明事件已投递到 Dart 侧
  //   [T3 handle]   —— isolate microtask：真正处理状态的地方
  //
  // 若看到 T1 有 BYE 但没有 T2 → 回调确实被吞（NativeCallable 层面）。
  // 若 T2 有、T3 逻辑没按预期走 → 是 Dart 处理逻辑的问题。
  //
  // _trace 用 debugPrint 同步输出到控制台（不进 microtask、不进 UI 日志列表），
  // 保证时序尽可能贴近事件真实发生的顺序，避免被 scheduleMicrotask 打乱。
  void _trace(String stage, String msg) {
    debugPrint(
      '🧵 [$stage] t=${DateTime.now().toIso8601String()} | $msg',
    );
  }

  String _pjString(pj_str_t value) {
    if (value.ptr == ffi.nullptr || value.slen <= 0) return '';
    return value.ptr.cast<Utf8>().toDartString(length: value.slen);
  }

  String _callSnapshot(pjsua_call_info info) {
    return 'call=${info.id}, state=${info.state.value}(${_pjString(info.state_text)}), '
        'lastSip=${info.last_status.value}(${_pjString(info.last_status_text)}), '
        'media=${info.media_status.value}, active=${_bindings.pjsua_call_is_active(info.id)}, '
        'remote=${_pjString(info.remote_info)}, '
        'localContact=${_pjString(info.local_contact)}, '
        'remoteContact=${_pjString(info.remote_contact)}, '
        'callId=${_pjString(info.call_id)}';
  }

  void _setupCallables() {
    _logCallable = ffi.NativeCallable.listener((
      int level,
      ffi.Pointer<ffi.Char> data,
      int len,
    ) {
      if (!state.isInitialized) return;
      if (data != ffi.nullptr) {
        final msg = data.cast<Utf8>().toDartString(length: len);
        // [T1 native] PJSIP 报文/日志。虽然 listener 是异步的，但这条能反映
        // 工作线程侧发生了什么。收到 BYE 时额外高亮，便于对照后续 T2/T3。
        if (msg.contains('BYE')) {
          _trace('T1 native', '⬅️ 检测到 BYE 报文: ${msg.trim()}');
        }
        _addLog('[PJSIP Native] $msg'.trim());
      }
    });

    _regStateCallable = ffi.NativeCallable.listener((int accId) {
      if (!state.isInitialized) return;
      // [T2 enqueue] on_reg_state 闭包入口
      _trace('T2 enqueue', 'on_reg_state: acc=$accId');
      using((Arena arena) {
        final info = arena<pjsua_acc_info>();
        if (_bindings.pjsua_acc_get_info(accId, info) == 0) {
          final statusText = info.ref.status_text.ptr.cast<Utf8>().toDartString(
            length: info.ref.status_text.slen,
          );
          _addLog('🔔 账号状态更新: ID $accId, 状态: ${info.ref.status} ($statusText)');
        }
      });
    });

    _incomingCallCallable = ffi.NativeCallable.listener((
      int accId,
      int callId,
      ffi.Pointer<pjsip_rx_data> rdata,
    ) {
      if (!state.isInitialized) return;
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
            _trace('T3 handle', 'on_incoming_call: 设置 currentCall=$callId');
            state = state.copyWith(
              currentCall: CallInfo(
                callId: callId,
                state: callState,
                remoteUri: remoteUri,
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
      if (!state.isInitialized) return;
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
              '${gotInfo ? ', state=${info.ref.stateAsInt}' : ' (call 已被 PJSIP 释放)'}',
        );

        if (!gotInfo) {
          // 查不到 info == call 已被释放。远端 BYE / 本地挂断后的 DISCONNECTED
          // 都会走到这里。当作“通话已结束”处理。
          scheduleMicrotask(() {
            // [T3 handle] 走“已释放 → 判定 DISCONNECTED”分支
            _trace('T3 handle', 'on_call_state: call=$callId 走“已释放”清理分支');
            _addLog('📞 通话已结束: call=$callId (info 已释放，判定为 DISCONNECTED)');
            // 旧通话的延迟回调不能误清刚建立的新通话。
            if (state.currentCall?.callId == callId) {
              state = state.copyWith(clearCall: true);
            }
            _mediaConnectedCalls.remove(callId);
            _stopCallTimer();
          });
          return;
        }

        // 不保留任何指向 Arena 的 enum/struct 包装，异步闭包只使用纯 Dart 值。
        final remoteUri = _pjString(info.ref.remote_info);
        final callState = info.ref.stateAsInt;
        final snapshot = _callSnapshot(info.ref);

        scheduleMicrotask(() {
          // [T3 handle] get_info 成功分支
          _trace('T3 handle', 'on_call_state: call=$callId, state=$callState');
          _addLog('📞 通话状态回调: $snapshot');
          if (callState == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED.value) {
            // 少数情况下 isolate 抢在 PJSIP 释放 call 之前执行，get_info 成功
            // 且状态就是 DISCONNECTED。与上面的失败分支做同样的清理。
            _addLog('通话已挂断: $callId');
            if (state.currentCall?.callId == callId) {
              state = state.copyWith(clearCall: true);
            }
            _mediaConnectedCalls.remove(callId);
            _stopCallTimer();
          } else {
            _addLog('通话状态变更: $callId -> $callState');
            final isConfirmed =
                callState == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.value;
            // 进入 CONFIRMED 时记录接通时刻并启动计时。若已在通话中，保留原
            // connectedAt，避免中途的状态刷新把计时清零。
            final prev = state.currentCall;
            final connectedAt = isConfirmed
                ? (prev?.callId == callId ? prev?.connectedAt : null) ??
                      DateTime.now()
                : null;
            if (isConfirmed) {
              _startCallTimer();
            }
            state = state.copyWith(
              currentCall: CallInfo(
                callId: callId,
                state: callState,
                remoteUri: remoteUri,
                connectedAt: connectedAt,
              ),
            );
          }
        });
      });
    });

    _callMediaStateCallable = ffi.NativeCallable.listener((int callId) {
      if (!state.isInitialized) return;
      // [T2 enqueue] on_call_media_state 闭包入口
      _trace('T2 enqueue', 'on_call_media_state: call=$callId');
      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        final gotInfo = _bindings.pjsua_call_get_info(callId, info) == 0;
        _trace(
          'T2 enqueue',
          'on_call_media_state: call=$callId, get_info成功=$gotInfo'
              '${gotInfo ? ', media=${info.ref.media_statusAsInt}, slot=${info.ref.conf_slot}' : ''}',
        );
        if (!gotInfo) return;

        final mediaStatus = info.ref.media_status;
        final confSlot = info.ref.conf_slot;
        const invalidId = -1; // PJSUA_INVALID_ID

        if (mediaStatus == pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE &&
            confSlot != invalidId) {
          // 媒体激活：把通话音频桥接到默认声卡 (Slot 0)。
          // 每次协商完成 (接通/hold 恢复/换编码) 都会触发本回调，且 conf_slot
          // 可能变化，因此每次都重连。pjsua_conf_connect 幂等，重复调用安全。
          _bindings.pjsua_conf_connect(confSlot, 0);
          _bindings.pjsua_conf_connect(0, confSlot);
          if (_mediaConnectedCalls.add(callId)) {
            _addLog('🎙️ 媒体通道已建立并连接到声卡 (slot=$confSlot)');
          }
        } else {
          // 非激活 (远端/本地 hold、inactive、error)：断开桥接，避免向
          // 无效 slot 连接或残留旧的音频通路。
          if (_mediaConnectedCalls.remove(callId) && confSlot != invalidId) {
            _bindings.pjsua_conf_disconnect(confSlot, 0);
            _bindings.pjsua_conf_disconnect(0, confSlot);
          }
          _addLog('🎙️ 媒体状态=${mediaStatus.value}，音频桥接已断开');
        }
      });
    });
  }

  Future<void> init() async {
    if (state.isInitialized) return;
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
      state = state.copyWith(isInitialized: true);
      _addLog('✅ PJSIP 引擎启动成功');

      // 精简 codec，缩小 INVITE 的 SDP，避免超过 UDP MTU 后自动切换到 TCP。
      _configureCodecs();
    });
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
    if (!state.isInitialized) await init();
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
      final status = _bindings.pjsua_acc_add(accCfg, 1, pAccId);
      if (status != 0) {
        _addLog('❌ 添加 SIP 账号失败: pj_status=$status');
        return;
      }
      state = state.copyWith(accId: pAccId.value, host: host);
      _addLog('🚀 注册请求已发送');
    });
  }

  Future<void> makeCall(String number) async {
    if (state.accId == -1) {
      _addLog('❌ 请先注册账号');
      return;
    }
    using((Arena arena) {
      // 注册及可正常工作的来电均使用 UDP。显式指定 UDP 可避免外呼因
      // 自动切换到 TCP 后，PBX 无法沿同一 dialog 路由远端 BYE。
      final targetUri = 'sip:$number@${state.host};transport=udp';
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
      _pjStr(pjUri.ref, dstUri);
      _addLog('➡️ 发起 INVITE: $targetUri, acc=${state.accId}');
      final status = _bindings.pjsua_call_make_call(
        state.accId,
        pjUri,
        callSetting,
        ffi.nullptr,
        ffi.nullptr,
        pCallId,
      );
      if (status == 0) {
        final callId = pCallId.value;
        state = state.copyWith(
          currentCall: CallInfo(
            callId: callId,
            state: pjsip_inv_state.PJSIP_INV_STATE_CALLING.value,
            remoteUri: targetUri,
          ),
        );
        _addLog('拨打请求已接受: number=$number, call=$callId');
      } else {
        _addLog('❌ 拨打失败: number=$number, pj_status=$status');
      }
    });
  }

  Future<void> answerCall() async {
    final call = state.currentCall;
    if (call == null) return;
    final status = _bindings.pjsua_call_answer(
      call.callId,
      200,
      ffi.nullptr,
      ffi.nullptr,
    );
    if (status == 0) {
      _addLog('✅ 已接听电话');
    } else {
      _addLog('❌ 接听失败: $status');
    }
  }

  Future<void> hangupCall() async {
    final call = state.currentCall;
    if (call == null) return;
    // 延迟到达的 DISCONNECTED microtask 可能尚未清除 currentCall，此时
    // callId 可能已失效。对死 id 调 hangup 无害但没意义，直接清理本地状态。
    if (_bindings.pjsua_call_is_active(call.callId) == 0) {
      _addLog('通话已不活跃，清理本地状态: call=${call.callId}');
      if (state.currentCall?.callId == call.callId) {
        state = state.copyWith(clearCall: true);
      }
      _mediaConnectedCalls.remove(call.callId);
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

  void _pjStr(pj_str_t target, ffi.Pointer<Utf8> source) {
    target.ptr = source.cast<ffi.Char>();
    // pj_str_t.slen 需要 UTF-8 字节长度。Utf8Pointer.length 返回 strlen
    // (字节数)，而 toDartString().length 返回的是 UTF-16 码元数，遇到非
    // ASCII 字符会算错并导致字段截断/损坏。
    target.slen = source.length;
  }

  void stop() {
    if (!state.isInitialized) return;
    _stopCallTimer();
    _bindings.pjsua_destroy();
    _mediaConnectedCalls.clear();
    state = state.copyWith(isInitialized: false, clearCall: true);
    _addLog('⏹ 引擎已关闭');
  }

  void _cleanup() {
    _stopCallTimer();
    if (state.isInitialized) {
      _bindings.pjsua_destroy();
      _mediaConnectedCalls.clear();
    }
    _logCallable.close();
    _regStateCallable.close();
    _incomingCallCallable.close();
    _callStateCallable.close();
    _callMediaStateCallable.close();
  }
}

final pjsipServiceProvider = NotifierProvider<PjsipService, PjsipUIState>(
  PjsipService.new,
);
