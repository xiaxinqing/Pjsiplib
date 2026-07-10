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

  CallInfo({
    required this.callId,
    required this.state,
    required this.remoteUri,
  });
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
    return PjsipUIState(logs: []);
  }

  void _addLog(String msg) {
    debugPrint('🔔 printLog: ID $msg');
    scheduleMicrotask(() {
      state = state.copyWith(logs: [...state.logs, PjsipLog(msg)]);
    });
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
        _addLog('[PJSIP Native] $msg'.trim());
      }
    });

    _regStateCallable = ffi.NativeCallable.listener((int accId) {
      if (!state.isInitialized) return;
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
      _addLog('📞 收到来电！ID: $callId, 来自账号: $accId');

      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        if (_bindings.pjsua_call_get_info(callId, info) == 0) {
          final remoteUri = info.ref.remote_info.ptr.cast<Utf8>().toDartString(
            length: info.ref.remote_info.slen,
          );
          scheduleMicrotask(() {
            state = state.copyWith(
              currentCall: CallInfo(
                callId: callId,
                state: info.ref.state.value,
                remoteUri: remoteUri,
              ),
            );
          });
        }
      });
    });

    _callStateCallable = ffi.NativeCallable.listener((
      int callId,
      ffi.Pointer<pjsip_event> e,
    ) {
      if (!state.isInitialized) return;
      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        if (_bindings.pjsua_call_get_info(callId, info) == 0) {
          final remoteUri = info.ref.remote_info.ptr.cast<Utf8>().toDartString(
            length: info.ref.remote_info.slen,
          );
          final callState = info.ref.state;

          scheduleMicrotask(() {
            if (callState == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED) {
              _addLog('通话已挂断: $callId');
              state = state.copyWith(clearCall: true);
            } else {
              _addLog('通话状态变更: $callId -> ${callState.value}');
              state = state.copyWith(
                currentCall: CallInfo(
                  callId: callId,
                  state: callState.value,
                  remoteUri: remoteUri,
                ),
              );
            }
          });
        }
      });
    });

    _callMediaStateCallable = ffi.NativeCallable.listener((int callId) {
      if (!state.isInitialized) return;
      using((Arena arena) {
        final info = arena<pjsua_call_info>();
        if (_bindings.pjsua_call_get_info(callId, info) == 0) {
          if (info.ref.media_status ==
                  pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE ||
              info.ref.media_status ==
                  pjsua_call_media_status.PJSUA_CALL_MEDIA_REMOTE_HOLD) {
            // 连接通话媒体到声卡 (Slot 0 是默认声卡)
            _bindings.pjsua_conf_connect(info.ref.conf_slot, 0);
            _bindings.pjsua_conf_connect(0, info.ref.conf_slot);
            _addLog('🎙️ 媒体通道已建立并连接到声卡');
          }
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

      logCfg.ref.cb = _logCallable.nativeFunction;
      logCfg.ref.level = 4;
      logCfg.ref.console_level = 0;

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
      _pjStr(uaCfg.ref.stun_srv[0], 'stun.l.google.com:19302'.toNativeUtf8(allocator: arena));

      if (_bindings.pjsua_init(uaCfg, logCfg, mediaCfg) != 0) return;

      final transportCfg = arena<pjsua_transport_config>();
      _bindings.pjsua_transport_config_default(transportCfg);
      
      // 关键改动：将端口设置为 0，让系统自动分配空闲端口。
      transportCfg.ref.port = 0;
      // transportCfg.ref.port = 5060; //端口竞争，只能有一个Voip监听

      final pTransportId = arena<ffi.Int>();
      _bindings.pjsua_transport_create(
        pjsip_transport_type_e.PJSIP_TRANSPORT_UDP,
        transportCfg,
        pTransportId,
      );

      if (_bindings.pjsua_start() != 0) return;
      state = state.copyWith(isInitialized: true);
      _addLog('✅ PJSIP 引擎启动成功');
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
      _bindings.pjsua_acc_add(accCfg, 1, pAccId);
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
      final dstUri = 'sip:$number@${state.host}'.toNativeUtf8(allocator: arena);
      final pjUri = arena<pj_str_t>();
      _pjStr(pjUri.ref, dstUri);
      final status = _bindings.pjsua_call_make_call(
        state.accId,
        pjUri,
        ffi.nullptr,
        ffi.nullptr,
        ffi.nullptr,
        ffi.nullptr,
      );
      if (status == 0) {
        _addLog('拨打中: $number');
      } else {
        _addLog('❌ 拨打失败: $status');
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
    _bindings.pjsua_call_hangup(call.callId, 0, ffi.nullptr, ffi.nullptr);
    _addLog('⏹ 正在挂断...');
  }

  void _pjStr(pj_str_t target, ffi.Pointer<Utf8> source) {
    target.ptr = source.cast<ffi.Char>();
    target.slen = source.toDartString().length;
  }

  void stop() {
    if (!state.isInitialized) return;
    _bindings.pjsua_destroy();
    state = state.copyWith(isInitialized: false, clearCall: true);
    _addLog('⏹ 引擎已关闭');
  }

  void dispose() {
    stop();
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
