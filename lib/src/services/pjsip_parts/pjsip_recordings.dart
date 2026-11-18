part of '../pjsip_service.dart';

/// 历史录音播放操作的结果，供界面区分播放成功、主动停止和失败原因。
enum CallRecordingPlaybackResult {
  /// 已创建本地播放器，并把文件音频连接到本机扬声器。
  started,

  /// 用户再次点击正在播放的录音，或等待文件期间播放请求被取消。
  stopped,

  /// 当前有已接通的通话，暂不允许播放历史录音。
  activeCall,

  /// PJSIP 未初始化，或无法打开本机声卡。
  engineUnavailable,

  /// 数据库记录还在，但对应的本地文件已不存在。
  fileMissing,

  /// 录音正被其他操作占用，或创建、连接播放器失败。
  failed,
}

/// 一份正在写入的本地录音所持有的资源与音频连接状态。
///
/// 一份会话对应一个原生 recorder、一个 WAV 文件和一条数据库录音记录。
/// 普通通话通常只有一个参与者；会议时多个 callId 共用这份会话，
/// 各路远端声音与本机麦克风在 PJSIP conference bridge 中混合后写入同一文件。
/// 这里的“参与者”指 SIP 通话线路，本机麦克风作为独立音源另行连接。
class _CallRecordingSession {
  _CallRecordingSession({
    required this.databaseId,
    required this.sessionKey,
    required this.anchorCallId,
    required this.recorderId,
    required this.recorderPort,
    required this.preparedFile,
    required this.startedAt,
  });

  /// 数据库中这份录音的主键，用于更新状态、关联通话历史。
  final int databaseId;

  /// 录音会话的键；单路录音提升为会议录音后仍沿用原来的键。
  final String sessionKey;

  /// 最初创建这份录音的通话 ID，主要用于诊断日志。
  /// 会议中该通话可以先挂断，因此它不代表当前唯一或仍然存活的参与者。
  final int anchorCallId;

  /// PJSIP 录音器 ID，传给 pjsua_recorder_destroy 释放原生资源。
  /// 它与下面的音频桥端口号属于不同编号体系，不能混用。
  final int recorderId;

  /// 录音器在音频桥中的接收端口；所有待录音音源都连接到这个端口。
  final int recorderPort;

  /// 临时 .partial.wav 和最终 .wav 的文件对象及数据库相对路径。
  final PreparedCallRecordingFile preparedFile;

  /// 本次录音启动流程的开始时间，用于记录起止时间和计算持续时间。
  final DateTime startedAt;

  /// callId -> 该次通话的会话键。保留它可关联参与者加入、离开和历史记录。
  final Map<int, String> participantSessionKeys = <int, String>{};

  /// callId -> 已成功接入录音器的远端媒体端口。
  /// 与每次计算出的目标端口比较，可断开旧连接并避免重复连接。
  final Map<int, int> connectedCallSlots = <int, int>{};

  /// 是否曾提升为会议录音，用于查找可供新成员复用的录音会话。
  bool isConference = false;

  /// 本机声卡输入端口 0 是否已连接到录音器，避免重复接入麦克风。
  bool microphoneConnected = false;
}

/// PjsipService 持有的录音运行时状态；这些原生句柄只在当前进程内有效。
///
/// sessions 管理“文件级”会话，sessionKeyByCallId 管理“通话级”索引，
/// 所以多个会议成员可以指向同一个文件，而不是每人重复创建录音器。
class _PjsipRecordingRuntime {
  /// 录音会话键 -> 正在写入的会话。
  final Map<String, _CallRecordingSession> sessions = {};

  /// 通话 ID -> 所属录音会话键。
  final Map<int, String> sessionKeyByCallId = {};

  /// 正在异步准备录音的通话，防止状态和媒体回调同时创建重复录音器。
  final Set<int> startingCallIds = {};

  /// 服务关闭/销毁期间阻止新的录音启动；不等同于用户的录音开关。
  bool stoppingAll = false;

  /// 历史录音播放器的原生 ID，与录音器 ID 分开管理。
  int? playerId;

  /// 历史录音播放器在音频桥中的输出端口。
  int? playerPort;

  /// 当前播放的数据库录音 ID，用于界面高亮及再次点击停止。
  int? playingRecordingId;

  /// 按数据库中的录音时长结束播放的定时器。
  Timer? playbackTimer;

  /// 播放请求版本号；异步文件查询返回后，用它识别已被停止或替换的旧请求。
  int playbackRequest = 0;
}

/// 本地通话录音、会议录音、录音回放和文件管理。
///
/// 本文件是 PjsipService 的 part，通过扩展复用服务的 PJSIP 绑定、通话状态、
/// 数据库和声卡管理。Dart 负责创建资源和安排连接，音频帧的混合与 WAV 写入
/// 由原生 PJSIP/PJMEDIA 完成；这里没有逐帧读取麦克风再手工拼接文件。
///
/// 核心音频路径（箭头表示单向的 pjsua_conf_connect(source, sink)）：
/// ```text
/// 本机麦克风 -> 声卡端口 0 -----------+
///                                  +-> recorderPort -> 本地 .partial.wav
/// 远端 RTP -> 接收/解码 -> call slot -+
/// ```
/// 端口 0 作为音源时提供本机采集音频，作为接收端时用于本机播放。
/// 通话自身的发送路径是 0 -> call slot，与 0 -> recorderPort 分别连接，
/// 因此录自己的声音不需要等待网络发送成功，也不需要远端把声音传回来。
/// 多个音源送入同一个 recorderPort 后，由音频桥混音；这里没有左右声道分轨。
///
/// 弱网边界：普通丢包不会直接切断本地麦克风录音，但远端录音只能包含接收、
/// 解码及丢包补偿后可用的声音，无法恢复网络中已经丢失的原始语音。
/// 本实现还要求通话媒体为 ACTIVE，并遵守保持、会议暂停和麦克风静音状态。
/// 媒体失效或通话结束后，不保证继续录本机声音；它不是独立常开的麦克风录音。
///
/// 阅读顺序：_ensureCallRecordingStarted 创建录音资源，
/// _syncRecordingSessionRoutes 决定录入哪些音源，
/// _finishRecordingSession 关闭文件并保存最终元数据。
extension PjsipRecordingOperations on PjsipService {
  /// 将通话开始时间与可复用的原生 callId 组合，区分不同时刻的两次通话。
  String _callRecordingSessionKey(CallInfo call) {
    return '${call.startedAt.toUtc().microsecondsSinceEpoch}-${call.callId}';
  }

  /// 修改并持久化本地录音开关。
  ///
  /// 开启时尝试给当前已接通、未保持的通话补建录音；之后的新通话由状态回调启动。
  /// 关闭时立即收尾所有现有录音。开启之前的音频没有缓存，不能追溯补录。
  void setLocalCallRecordingEnabled(bool enabled) {
    if (_uiState.localCallRecordingEnabled == enabled) return;
    _uiState = _uiState.copyWith(localCallRecordingEnabled: enabled);
    unawaited(_persistAudioPreferences());
    if (enabled) {
      _addLog('⏺ 已开启本地通话录音');
      for (final call in _uiState.calls.values) {
        if (call.isConnected && !call.isOnHold && !call.isRemoteOnHold) {
          unawaited(_ensureCallRecordingStarted(call.callId));
        }
      }
      return;
    }

    _addLog('⏹ 已关闭本地通话录音');
    _stopAllCallRecordings(CallRecordingStatus.completed);
  }

  /// 确保指定通话已有可用的录音会话；重复调用时同步路由而不重复创建。
  ///
  /// 通话 CONFIRMED 和媒体 ACTIVE 回调均会尝试调用本方法，因为两者到达顺序
  /// 不固定。只有通话与媒体均满足条件时才真正开始；会议成员优先复用已有会话。
  /// 启动顺序：检查条件 -> 准备文件 -> 建数据库记录 -> 创建 recorder -> 接音源。
  Future<void> _ensureCallRecordingStarted(int callId) async {
    if (_recording.stoppingAll ||
        !_uiState.localCallRecordingEnabled ||
        !_uiState.isInitialized ||
        _recording.sessionKeyByCallId.containsKey(callId)) {
      _syncCallRecordingRoutesFor(callId);
      return;
    }
    // 文件准备和数据库操作会 await。会议中必须把所有成员一起标记为“启动中”，
    // 否则另一个成员的回调可能在等待期间创建第二份会议录音。
    final startupCallIds = _uiState.isInConference(callId)
        ? Set<int>.of(_uiState.conferenceCallIds)
        : <int>{callId};
    if (startupCallIds.any(_recording.startingCallIds.contains)) return;
    _recording.startingCallIds.addAll(startupCallIds);

    int? databaseRecordingId;
    DateTime? recordingStartedAt;
    PreparedCallRecordingFile? prepared;
    try {
      final initialCall = _uiState.calls[callId];
      if (!_canRecordCall(initialCall)) return;
      final participantSessionKey = _callRecordingSessionKey(initialCall!);
      // 加入已有会议时只建立参与者关联，再把该成员的媒体端口接入同一个文件。
      final conferenceSession = _recordingSessionForConferenceMember(callId);
      if (conferenceSession != null) {
        await _attachCallToRecordingSession(
          conferenceSession,
          initialCall,
          joinedAt: DateTime.now(),
        );
        _syncRecordingSessionRoutes(conferenceSession);
        return;
      }

      final sessionKey = participantSessionKey;
      final startedAt = DateTime.now();
      // 存储层负责应用支持目录、年月子目录和安全文件名；真正的 WAV 由原生层创建。
      // 写入期间使用 .partial.wav，结束并关闭录音器后才改成最终的 .wav。
      prepared = await CallRecordingStorage.prepare(
        sessionKey: sessionKey,
        startedAt: startedAt,
        directionCode: initialCall.direction == PjsipCallDirection.inbound
            ? 'IN'
            : 'OUT',
        localNumber: initialCall.accountId == null
            ? ''
            : _uiState.accounts[initialCall.accountId]?.username ?? '',
        remoteNumber: _extractPhoneNumber(initialCall.remoteUri),
      );
      recordingStartedAt = startedAt;
      // 先记录“录音中”和临时路径。即使之后进程意外退出，下次启动仍可找到文件。
      final databaseId = await _callHistoryDatabase.beginCallRecording(
        sessionKey: sessionKey,
        callId: callId,
        relativePath: prepared.temporaryRelativePath,
        startedAt: recordingStartedAt,
        participantSessionKey: participantSessionKey,
      );
      databaseRecordingId = databaseId;

      // await 期间用户可能已经挂断、保持或关闭录音，因此创建原生资源前再检查一次。
      if (!_canRecordCall(_uiState.calls[callId])) {
        await _callHistoryDatabase.finalizeCallRecording(
          id: databaseId,
          status: CallRecordingStatus.interrupted,
          endedAt: DateTime.now(),
          duration: Duration.zero,
          fileSizeBytes: 0,
          failureReason: 'call media no longer active before recorder creation',
        );
        return;
      }

      // Arena 管理本次 FFI 调用的临时字符串和输出参数；原生 recorder 在调用后
      // 继续存活，必须在录音结束时通过 pjsua_recorder_destroy 单独释放。
      final recorder = using((Arena arena) {
        final filename = arena<pj_str_t>();
        final nativePath = prepared!.temporaryFile.path.toNativeUtf8(
          allocator: arena,
        );
        _pjStr(filename.ref, nativePath);
        final recorderId = arena<pjsua_recorder_id>();
        // 参数依次为：文件路径、编码类型 0、无编码附加参数、max_size=-1、
        // options=0、输出录音器 ID。这里 max_size 使用 PJSIP 接受的占位值，
        // 原生实现并不提供按这个参数自动切割文件的功能。
        // .wav 后缀选择 WAV 写入器；默认选项使用 PCM，采样率等由媒体桥配置决定。
        // 创建只把录音器注册进音频桥，尚未指定要录麦克风还是哪一路通话。
        final status = _bindings.pjsua_recorder_create(
          filename,
          0,
          ffi.nullptr,
          -1,
          0,
          recorderId,
        );
        if (status != 0) return (status: status, id: -1, port: -1);
        // 连接音源必须使用音频桥端口号，而不是 recorderId。
        final port = _bindings.pjsua_recorder_get_conf_port(recorderId.value);
        if (port < 0) {
          _bindings.pjsua_recorder_destroy(recorderId.value);
          return (status: -1, id: -1, port: -1);
        }
        return (status: 0, id: recorderId.value, port: port);
      });
      if (recorder.status != 0) {
        await _callHistoryDatabase.finalizeCallRecording(
          id: databaseId,
          status: CallRecordingStatus.failed,
          endedAt: DateTime.now(),
          duration: Duration.zero,
          fileSizeBytes: 0,
          failureReason: 'pjsua_recorder_create=${recorder.status}',
        );
        _addLog('❌ 创建通话录音器失败: call=$callId, status=${recorder.status}');
        return;
      }

      // 保存原生资源与文件信息，并建立 callId 到会话的索引，供后续回调复用。
      final session = _CallRecordingSession(
        databaseId: databaseId,
        sessionKey: sessionKey,
        anchorCallId: callId,
        recorderId: recorder.id,
        recorderPort: recorder.port,
        preparedFile: prepared,
        startedAt: recordingStartedAt,
      );
      session.participantSessionKeys[callId] = participantSessionKey;
      _recording.sessions[sessionKey] = session;
      _recording.sessionKeyByCallId[callId] = sessionKey;
      if (_uiState.isInConference(callId)) {
        session.isConference = true;
        await _callHistoryDatabase.promoteCallRecordingToConference(databaseId);
        final joinedAt = DateTime.now();
        for (final memberId in _uiState.conferenceCallIds) {
          if (memberId == callId) continue;
          final member = _uiState.calls[memberId];
          if (member != null) {
            await _attachCallToRecordingSession(
              session,
              member,
              joinedAt: joinedAt,
            );
          }
        }
      }
      // 至少要有一条远端媒体端口连接成功才算启动成功。
      // 这个结果不代表麦克风也一定接入成功；本机音源连接失败会单独记录警告。
      final routeReady = _syncCallRecordingRoutesFor(callId);
      if (!routeReady) {
        _finishRecordingSession(
          sessionKey,
          status: CallRecordingStatus.failed,
          failureReason: 'unable to connect remote call audio',
        );
        return;
      }
      _setCallRecordingUi(callId, true);
      _addLog('⏺ 本地通话录音已开始: call=$callId, file=${prepared.finalRelativePath}');
    } catch (error) {
      _addLog('❌ 启动本地通话录音失败: call=$callId, error=$error');
      final databaseId = databaseRecordingId;
      if (databaseId != null) {
        unawaited(
          _callHistoryDatabase.finalizeCallRecording(
            id: databaseId,
            status: CallRecordingStatus.failed,
            endedAt: DateTime.now(),
            duration: Duration.zero,
            fileSizeBytes: 0,
            failureReason: '$error',
          ),
        );
      }
    } finally {
      // 成功、失败或提前返回都要解除启动标记，允许后续回调重新尝试。
      _recording.startingCallIds.removeAll(startupCallIds);
    }
  }

  /// 创建录音器的前提：开关开启、引擎可用、通话已接通、双方未保持、
  /// 媒体 ACTIVE 且能找到媒体端口。这里只检查状态，不要求已收到远端语音包。
  bool _canRecordCall(CallInfo? call) {
    return !_recording.stoppingAll &&
        _uiState.localCallRecordingEnabled &&
        _uiState.isInitialized &&
        call != null &&
        call.isConnected &&
        !call.isOnHold &&
        !call.isRemoteOnHold &&
        call.mediaStatus ==
            pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value &&
        _getConferenceSlot(call.callId) != null;
  }

  /// 由通话 ID 找到录音会话，并更新整份会话的音源；会议中会同步所有成员。
  /// 返回值表示至少有一路远端媒体端口已连接，不表示文件一定已有有效语音。
  bool _syncCallRecordingRoutesFor(int callId) {
    final sessionKey = _recording.sessionKeyByCallId[callId];
    final session = sessionKey == null ? null : _recording.sessions[sessionKey];
    if (session == null) return false;
    return _syncRecordingSessionRoutes(session);
  }

  /// 根据当前通话、媒体和静音状态，维护“音源 -> 录音器”的单向连接。
  ///
  /// 先计算应录入的远端端口，移除过期连接并补齐新连接，最后独立处理本机麦克风。
  /// 通话媒体回调、静音切换和会议变化会触发同步，因此它不是只在启动时执行一次。
  /// 暂时失去音源时只拆连接，保留 recorder 和会话；恢复后可继续写同一个文件。
  /// 这不承诺中断期间有可用音频，也没有在 Dart 中补录或拼接丢失的内容。
  bool _syncRecordingSessionRoutes(_CallRecordingSession session) {
    if (!_uiState.isInitialized) return false;
    // 1. 计算当前应录入的远端线路。这里检查媒体状态，不检查网络在线标志或收包数，
    // 因此单纯 RTP 丢包且媒体仍为 ACTIVE 时，不会仅因没有收到包就拆掉录音路由。
    final desiredSlots = <int, int>{};
    for (final callId in session.participantSessionKeys.keys) {
      final call = _uiState.calls[callId];
      final active =
          call != null &&
          call.isConnected &&
          !call.isOnHold &&
          !call.isRemoteOnHold &&
          call.mediaStatus ==
              pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value;
      final slot = active ? _getConferenceSlot(callId) : null;
      if (slot != null) desiredSlots[callId] = slot;
    }

    // 2. 清理已挂断、保持、媒体失效或端口改变后的旧路由。
    // 遍历副本，因为循环中会删除 connectedCallSlots 的条目。
    for (final entry in session.connectedCallSlots.entries.toList()) {
      if (desiredSlots[entry.key] == entry.value) continue;
      _bindings.pjsua_conf_disconnect(entry.value, session.recorderPort);
      session.connectedCallSlots.remove(entry.key);
    }
    // 3. 将远端接收/解码后的音频送到录音器。这里不经过本机扬声器回采，
    // 也不依据扬声器静音决定是否录对方；会议时多路远端端口指向同一录音器。
    for (final entry in desiredSlots.entries) {
      if (session.connectedCallSlots[entry.key] == entry.value) continue;
      final status = _bindings.pjsua_conf_connect(
        entry.value,
        session.recorderPort,
      );
      if (status != 0) {
        _addLog('❌ 连接远端录音音源失败: call=${entry.key}, status=$status');
        continue;
      }
      session.connectedCallSlots[entry.key] = entry.value;
    }

    // 4. 本机麦克风只接一次。至少有一位有效成员允许本机音频且未静音时才接入：
    // - 会议：会议未暂停；普通通话：遵守活动通话/自动保持策略。
    // - _shouldRouteMicrophoneToCall 同时检查全局及该线路的麦克风静音。
    // desiredSlots 为空时 any 返回 false，媒体全部失效也会断开麦克风录音。
    final shouldConnectMicrophone = desiredSlots.keys.any((callId) {
      final audioAvailable = _uiState.isInConference(callId)
          ? !_uiState.isConferencePaused
          : _shouldUseLocalAudioForCall(callId);
      return audioAvailable && _shouldRouteMicrophoneToCall(callId);
    });
    if (shouldConnectMicrophone && !session.microphoneConnected) {
      // 关键：直接把本机采集音频送到本地录音器，与发往网络的连接分别建立。
      final status = _bindings.pjsua_conf_connect(0, session.recorderPort);
      if (status == 0) {
        session.microphoneConnected = true;
      } else {
        _addLog(
          '⚠️ 连接本机录音音源失败: recording=${session.databaseId}, status=$status',
        );
      }
    } else if (!shouldConnectMicrophone && session.microphoneConnected) {
      _bindings.pjsua_conf_disconnect(0, session.recorderPort);
      session.microphoneConnected = false;
    }
    // 连接成功仅说明桥路由可用，不代表对方正在说话或网络已经收到有效音频包。
    return session.connectedCallSlots.isNotEmpty;
  }

  /// 对全部录音会话应用最新音频状态，例如全局静音或会议结构改变之后。
  void _syncAllCallRecordingRoutes() {
    for (final session in _recording.sessions.values.toList(growable: false)) {
      _syncRecordingSessionRoutes(session);
    }
  }

  /// 查找该通话所在会议中已经存在的会议录音，避免每位成员各录一份相同混音。
  _CallRecordingSession? _recordingSessionForConferenceMember(int callId) {
    if (!_uiState.isInConference(callId)) return null;
    for (final memberId in _uiState.conferenceCallIds) {
      final key = _recording.sessionKeyByCallId[memberId];
      final session = key == null ? null : _recording.sessions[key];
      if (session?.isConference == true) return session;
    }
    return null;
  }

  /// 将通话关联到已有录音，保存加入时间并更新界面。
  ///
  /// 这里只登记参与者，不直接接音频；调用方随后同步路由，按媒体状态决定是否接入。
  /// 使用通话会话键判断重复加入，可区分原生 callId 被后续通话复用的情况。
  Future<void> _attachCallToRecordingSession(
    _CallRecordingSession session,
    CallInfo call, {
    required DateTime joinedAt,
  }) async {
    final participantSessionKey = _callRecordingSessionKey(call);
    if (session.participantSessionKeys[call.callId] == participantSessionKey) {
      return;
    }
    session.participantSessionKeys[call.callId] = participantSessionKey;
    _recording.sessionKeyByCallId[call.callId] = session.sessionKey;
    _setCallRecordingUi(call.callId, true);
    await _callHistoryDatabase.addCallRecordingParticipant(
      recordingId: session.databaseId,
      callSessionKey: participantSessionKey,
      callId: call.callId,
      joinedAt: joinedAt,
    );
  }

  /// 把原来的单路录音原地提升为会议录音。原 WAV 和录音器均不重建，
  /// 因而 A+B 合并 C 之前的音频会自然保留在同一个文件开头。
  ///
  /// 优先沿用 preferredAnchorCallId 的录音；没有时选择成员已有的另一份录音。
  /// 合并后所有成员关联到主录音，并把其他独立录音正常收尾。
  /// 这里不会把多个旧 WAV 拼接到一起：其他成员的会前片段仍保存在各自旧文件中。
  Future<void> _promoteCallRecordingsToConference(
    Set<int> members, {
    required int preferredAnchorCallId,
  }) async {
    if (!_uiState.localCallRecordingEnabled || members.length < 2) return;
    if (!_recording.sessionKeyByCallId.containsKey(preferredAnchorCallId)) {
      await _ensureCallRecordingStarted(preferredAnchorCallId);
    }
    var primaryKey = _recording.sessionKeyByCallId[preferredAnchorCallId];
    primaryKey ??= members
        .map((id) => _recording.sessionKeyByCallId[id])
        .whereType<String>()
        .firstOrNull;
    final primary = primaryKey == null ? null : _recording.sessions[primaryKey];
    if (primary == null) return;

    primary.isConference = true;
    await _callHistoryDatabase.promoteCallRecordingToConference(
      primary.databaseId,
    );
    final secondaryKeys = <String>{};
    final joinedAt = DateTime.now();
    for (final callId in members) {
      final oldKey = _recording.sessionKeyByCallId[callId];
      if (oldKey != null && oldKey != primary.sessionKey) {
        secondaryKeys.add(oldKey);
      }
      final call = _uiState.calls[callId];
      if (call != null) {
        await _attachCallToRecordingSession(primary, call, joinedAt: joinedAt);
      }
    }
    _syncRecordingSessionRoutes(primary);
    // 两路都曾独立录音时，主通话文件继续成为会议录音；另一段作为“会前片段”
    // 正常收尾，不覆盖也不丢弃。
    for (final key in secondaryKeys) {
      _finishRecordingSession(key);
    }
    _addLog(
      '⏺ 单路录音已提升为会议录音: recording=${primary.databaseId}, '
      'calls=${members.toList()}',
    );
  }

  /// 通话结束时撤掉该成员的录音连接，并记录其离开时间。
  ///
  /// 最后一位成员离开才关闭整个录音；会议中一人挂断时，其余成员可继续写原文件。
  /// 因此不能在任意一个成员挂断时直接销毁共享的 recorder。
  void _detachCallFromRecording(int callId) {
    final sessionKey = _recording.sessionKeyByCallId.remove(callId);
    final session = sessionKey == null ? null : _recording.sessions[sessionKey];
    if (session == null) return;
    final participantSessionKey = session.participantSessionKeys.remove(callId);
    final slot = session.connectedCallSlots.remove(callId);
    if (_uiState.isInitialized && slot != null) {
      _bindings.pjsua_conf_disconnect(slot, session.recorderPort);
    }
    _setCallRecordingUi(callId, false);
    if (participantSessionKey != null) {
      unawaited(
        _callHistoryDatabase.leaveCallRecordingParticipant(
          recordingId: session.databaseId,
          callSessionKey: participantSessionKey,
          leftAt: DateTime.now(),
        ),
      );
    }
    if (session.participantSessionKeys.isEmpty) {
      _finishRecordingSession(session.sessionKey);
    } else {
      _syncRecordingSessionRoutes(session);
    }
  }

  /// 用户拆分会议时先结束原会议录音，再为保留的通话尝试创建新录音。
  /// 使用集合去重，因为多个成员可能指向同一份共享录音。
  Future<void> _endConferenceRecordingForSplit(
    Set<int> members,
    int keepCallId,
  ) async {
    final keys = members
        .map((id) => _recording.sessionKeyByCallId[id])
        .whereType<String>()
        .toSet();
    for (final key in keys) {
      _finishRecordingSession(key);
    }
    await _ensureCallRecordingStarted(keepCallId);
  }

  /// 结束一份录音：撤掉音源 -> 销毁原生 recorder -> 文件改名 -> 更新数据库。
  ///
  /// 关闭录音开关、最后一个参与者挂断、拆分会议或服务退出等路径都会调用这里。
  /// status 表达调用方希望记录的结果；文件不存在或收尾失败时会改为 failed。
  /// 本方法同步关闭原生资源和处理文件，数据库更新则异步提交。
  void _finishRecordingSession(
    String sessionKey, {
    CallRecordingStatus status = CallRecordingStatus.completed,
    String? failureReason,
  }) {
    // 先从运行时移除，使重复到达的结束请求不会再次销毁同一个原生录音器。
    final session = _recording.sessions.remove(sessionKey);
    if (session == null) return;
    if (_uiState.isInitialized) {
      for (final slot in session.connectedCallSlots.values) {
        _bindings.pjsua_conf_disconnect(slot, session.recorderPort);
      }
      if (session.microphoneConnected) {
        _bindings.pjsua_conf_disconnect(0, session.recorderPort);
      }
      // destroy 不只是停止采集：原生 WAV 写入器会在关闭时完成缓冲写入和文件头更新。
      // 必须先完成这一步，再把临时文件作为最终录音交给历史列表或播放器使用。
      _bindings.pjsua_recorder_destroy(session.recorderId);
    }
    for (final callId in session.participantSessionKeys.keys) {
      // 合并会议时，成员可能已指向新的主会话；结束旧会话不能清掉新的关联和图标。
      if (_recording.sessionKeyByCallId[callId] == sessionKey) {
        _recording.sessionKeyByCallId.remove(callId);
        _setCallRecordingUi(callId, false);
      }
    }

    var finalStatus = status;
    var reason = failureReason;
    var relativePath = session.preparedFile.temporaryRelativePath;
    var fileSize = 0;
    // 文件收尾和数据库更新分开处理：先取得最终路径、实际大小，再持久化元数据。
    try {
      final temporary = session.preparedFile.temporaryFile;
      final destination = session.preparedFile.finalFile;
      if (temporary.existsSync()) {
        if (destination.existsSync()) destination.deleteSync();
        temporary.renameSync(destination.path);
      }
      if (destination.existsSync()) {
        relativePath = session.preparedFile.finalRelativePath;
        fileSize = destination.lengthSync();
      } else {
        finalStatus = CallRecordingStatus.failed;
        reason ??= 'recording file was not created';
      }
    } catch (error) {
      finalStatus = CallRecordingStatus.failed;
      reason = 'finalize file failed: $error';
    }
    // 这里保存的是起止时间之差，而非逐帧统计的有效语音长度。
    // 保持、媒体中断等情况下，不应把数据库 duration 理解为连续有声的时长。
    final endedAt = DateTime.now();
    unawaited(
      _callHistoryDatabase
          .finalizeCallRecording(
            id: session.databaseId,
            status: finalStatus,
            endedAt: endedAt,
            duration: endedAt.difference(session.startedAt),
            fileSizeBytes: fileSize,
            relativePath: relativePath,
            failureReason: reason,
          )
          .catchError((Object error, StackTrace stackTrace) {
            _addLog('⚠️ 保存通话录音元数据失败: $error');
          }),
    );
    _addLog(
      '⏹ 本地通话录音已结束: recording=${session.databaseId}, '
      'anchorCall=${session.anchorCallId}, size=$fileSize',
    );
  }

  /// 按指定状态结束全部录音；遍历键的副本，因为收尾会删除 sessions 中的条目。
  void _stopAllCallRecordings(CallRecordingStatus status) {
    for (final key in _recording.sessions.keys.toList(growable: false)) {
      _finishRecordingSession(key, status: status);
    }
  }

  /// 维护界面中显示“正在录音”的通话集合，不承担实际音频连接操作。
  void _setCallRecordingUi(int callId, bool recording) {
    final ids = Set<int>.of(_uiState.recordingCallIds);
    final changed = recording ? ids.add(callId) : ids.remove(callId);
    if (changed) _uiState = _uiState.copyWith(recordingCallIds: ids);
  }

  /// 启动时恢复未正常结束的录音，再按存储设置清理过期通话历史和录音。
  Future<void> _prepareLocalStorage() async {
    // 先收好上次意外退出留下的录音，再清理过期内容，不挡住页面和电话启动。
    await _recoverUnfinishedCallRecordings();
    try {
      final storage = _storageManager;
      final settings = await storage.readSettings();
      final plan = await storage.findExpired(settings);
      final result = await storage.cleanExpired(
        plan,
        isPlaying: isRecordingPlaying,
      );
      if (!plan.isEmpty) {
        _addLog(
          '🧹 存储清理：通话记录 ${result.historyCount} 条，录音 ${result.recordingCount} 条，失败 ${result.failedCount} 条',
        );
      }
    } catch (error) {
      _addLog('⚠️ 存储清理未完成，下次启动再试: $error');
    }
  }

  /// 处理上次崩溃、强制退出等情况留下的“录音中”数据库记录。
  ///
  /// 存储层查找并重命名已有临时文件，根据文件大小估算时长；有文件则标为
  /// interrupted，没有则标为 failed。这只能保留已写入磁盘的数据，
  /// 不会恢复尚在原生缓冲区中的音频，也不在这里修复 WAV 文件头。
  Future<void> _recoverUnfinishedCallRecordings() async {
    try {
      final rows = await _callHistoryDatabase.listUnfinishedRecordings();
      for (final row in rows) {
        // 启动期间如果已经接到电话，别把这一轮刚开始的录音当成旧文件。
        if (_recording.sessions.values.any(
          (session) => session.databaseId == row.id,
        )) {
          continue;
        }
        final recovered = await CallRecordingStorage.recoverInterrupted(
          row.relativePath,
        );
        await _callHistoryDatabase.finalizeCallRecording(
          id: row.id,
          status: recovered == null
              ? CallRecordingStatus.failed
              : CallRecordingStatus.interrupted,
          endedAt: DateTime.now(),
          duration: recovered?.estimatedDuration ?? Duration.zero,
          fileSizeBytes: recovered?.fileSizeBytes ?? 0,
          relativePath: recovered?.relativePath,
          failureReason: recovered == null
              ? 'unfinished recording file was missing on startup'
              : 'application exited before recording was finalized',
        );
      }
      if (rows.isNotEmpty) {
        _addLog('🛠 已恢复 ${rows.length} 条未正常结束的本地录音');
      }
    } catch (error) {
      _addLog('⚠️ 恢复未完成录音失败: $error');
    }
  }

  /// 点击历史录音时开始播放；再次点击同一条则停止。
  ///
  /// 回放路径是 WAV -> PJSIP player -> 音频桥端口 0 -> 本机扬声器，
  /// 不经过网络。当前有已接通通话时拒绝开始回放，避免干扰通话音频。
  /// 这是读取已有文件的 player，与写入新文件的 recorder 属于不同资源。
  Future<CallRecordingPlaybackResult> toggleCallRecordingPlayback(
    CallRecording recording,
  ) async {
    final storage = _storageManager;
    // 与过期清理共享占用标记，避免开始播放时文件被清理；finally 中必须释放。
    if (!storage.busyRecordingIds.add(recording.id)) {
      return CallRecordingPlaybackResult.failed;
    }
    try {
      if (_recording.playingRecordingId == recording.id) {
        _stopCallRecordingPlayback();
        return CallRecordingPlaybackResult.stopped;
      }
      if (_uiState.calls.values.any((call) => call.isConnected)) {
        return CallRecordingPlaybackResult.activeCall;
      }
      if (!_uiState.isInitialized) {
        return CallRecordingPlaybackResult.engineUnavailable;
      }
      // 文件查询会 await，期间用户可能停止播放、切换录音，或刚好接通一通电话。
      // 因此记录请求版本，并在等待结束后重新检查版本和通话状态。
      final request = ++_recording.playbackRequest;
      final file = await CallRecordingStorage.resolve(recording.relativePath);
      final exists = await file.exists();
      // 查文件这段时间用户可能已经关窗，或点了另一条录音，别再悄悄开始播放。
      if (request != _recording.playbackRequest) {
        return CallRecordingPlaybackResult.stopped;
      }
      if (!exists) return CallRecordingPlaybackResult.fileMissing;
      if (_uiState.calls.values.any((call) => call.isConnected)) {
        return CallRecordingPlaybackResult.activeCall;
      }
      if (!_ensureSoundDeviceOpen('播放本地通话录音')) {
        return CallRecordingPlaybackResult.engineUnavailable;
      }
      // 替换旧播放器，暂不清空界面字段，成功创建后直接切换为新录音 ID。
      _stopCallRecordingPlayback(updateUi: false);

      final player = using((Arena arena) {
        final filename = arena<pj_str_t>();
        final nativePath = file.path.toNativeUtf8(allocator: arena);
        _pjStr(filename.ref, nativePath);
        final playerId = arena<pjsua_player_id>();
        // 使用循环播放器并按数据库时长主动销毁，规避部分平台在 EOF 后销毁触发断言。
        final status = _bindings.pjsua_player_create(filename, 0, playerId);
        if (status != 0) return (status: status, id: -1, port: -1);
        final port = _bindings.pjsua_player_get_conf_port(playerId.value);
        if (port < 0) {
          _bindings.pjsua_player_destroy(playerId.value);
          return (status: -1, id: -1, port: -1);
        }
        // player 作为音源、端口 0 作为播放接收端；与录音的 0 -> recorder 方向相反。
        final connectStatus = _bindings.pjsua_conf_connect(port, 0);
        if (connectStatus != 0) {
          _bindings.pjsua_player_destroy(playerId.value);
          return (status: connectStatus, id: -1, port: -1);
        }
        return (status: 0, id: playerId.value, port: port);
      });
      if (player.status != 0) {
        return CallRecordingPlaybackResult.failed;
      }
      _recording.playerId = player.id;
      _recording.playerPort = player.port;
      _recording.playingRecordingId = recording.id;
      _uiState = _uiState.copyWith(playingRecordingId: recording.id);
      // 当前使用循环播放器，因此必须安排主动停止。这里按数据库时长计时，
      // 最短 500ms；它不是通过原生 EOF 回调精确判断文件结尾。
      final duration = Duration(
        milliseconds: recording.durationMs.clamp(500, 1 << 31).toInt(),
      );
      _recording.playbackTimer = Timer(duration, _stopCallRecordingPlayback);
      return CallRecordingPlaybackResult.started;
    } finally {
      storage.busyRecordingIds.remove(recording.id);
    }
  }

  /// 查询指定数据库录音是否正在回放，也供存储清理逻辑跳过正在播放的文件。
  bool isRecordingPlaying(int id) => _uiState.playingRecordingId == id;

  /// 对外提供的停止回放入口，同时使尚未完成的异步播放请求失效。
  void stopCallRecordingPlayback() => _stopCallRecordingPlayback();

  /// 取消等待中的播放请求和计时器，断开并销毁播放器，再安排空闲声卡释放。
  /// updateUi=false 用于替换播放器时暂时保留界面状态。
  void _stopCallRecordingPlayback({bool updateUi = true}) {
    _recording.playbackRequest++;
    _recording.playbackTimer?.cancel();
    _recording.playbackTimer = null;
    final playerId = _recording.playerId;
    final playerPort = _recording.playerPort;
    _recording.playerId = null;
    _recording.playerPort = null;
    _recording.playingRecordingId = null;
    if (_uiState.isInitialized && playerId != null) {
      if (playerPort != null && playerPort >= 0) {
        _bindings.pjsua_conf_disconnect(playerPort, 0);
      }
      _bindings.pjsua_player_destroy(playerId);
    }
    if (updateUi && _uiState.playingRecordingId != null) {
      _uiState = _uiState.copyWith(playingRecordingId: null);
    }
    _scheduleSoundDeviceReleaseIfIdle('本地通话录音播放结束');
  }

  /// 由存储层选择保存位置并导出录音；取消或源文件不存在时返回空值。
  Future<String?> exportCallRecording(
    CallRecording recording, {
    required String suggestedName,
  }) {
    return CallRecordingStorage.export(
      recording.relativePath,
      suggestedName: suggestedName,
    );
  }

  /// 在系统文件管理器中定位录音；平台不支持或操作失败时返回 false。
  Future<bool> revealCallRecording(CallRecording recording) async {
    try {
      await CallRecordingStorage.reveal(recording.relativePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 删除一份录音前先停止其回放，再依次删除本地文件和数据库记录。
  Future<void> deleteCallRecording(CallRecording recording) async {
    if (_recording.playingRecordingId == recording.id) {
      _stopCallRecordingPlayback();
    }
    await CallRecordingStorage.delete(recording.relativePath);
    await _callHistoryDatabase.deleteRecording(recording.id);
  }

  /// 解除通话历史与录音的关联，只删除已不再被其他历史引用的录音。
  /// 会议录音可能关联多条通话历史，删除其中一条不能把共享文件一起删掉。
  Future<void> deleteCallRecordingsForHistory(int historyEntryId) async {
    final orphanedRecordings = await _callHistoryDatabase
        .unlinkRecordingsFromHistory(historyEntryId);
    for (final recording in orphanedRecordings) {
      await deleteCallRecording(recording);
    }
  }

  /// 批量删除已归档录音；跳过仍标记为 recording 的记录，避免删除正在写入的文件。
  Future<void> deleteAllArchivedCallRecordings() async {
    final recordings = await _callHistoryDatabase.listAllRecordings();
    for (final recording in recordings) {
      if (recording.status == CallRecordingStatus.recording.storageKey) {
        continue;
      }
      await deleteCallRecording(recording);
    }
  }
}
