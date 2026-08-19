part of '../pjsip_service.dart';

enum CallRecordingPlaybackResult {
  started,
  stopped,
  activeCall,
  engineUnavailable,
  fileMissing,
  failed,
}

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

  final int databaseId;
  final String sessionKey;
  final int anchorCallId;
  final int recorderId;
  final int recorderPort;
  final PreparedCallRecordingFile preparedFile;
  final DateTime startedAt;
  final Map<int, String> participantSessionKeys = <int, String>{};
  final Map<int, int> connectedCallSlots = <int, int>{};
  bool isConference = false;
  bool microphoneConnected = false;
}

class _PjsipRecordingRuntime {
  final Map<String, _CallRecordingSession> sessions = {};
  final Map<int, String> sessionKeyByCallId = {};
  final Set<int> startingCallIds = {};
  bool stoppingAll = false;
  int? playerId;
  int? playerPort;
  int? playingRecordingId;
  Timer? playbackTimer;
}

extension PjsipRecordingOperations on PjsipService {
  String _callRecordingSessionKey(CallInfo call) {
    return '${call.startedAt.toUtc().microsecondsSinceEpoch}-${call.callId}';
  }

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

  Future<void> _ensureCallRecordingStarted(int callId) async {
    if (_recording.stoppingAll ||
        !_uiState.localCallRecordingEnabled ||
        !_uiState.isInitialized ||
        _recording.sessionKeyByCallId.containsKey(callId)) {
      _syncCallRecordingRoutesFor(callId);
      return;
    }
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
      prepared = await CallRecordingStorage.prepare(
        sessionKey: sessionKey,
        startedAt: DateTime.now(),
      );
      recordingStartedAt = DateTime.now();
      final databaseId = await _callHistoryDatabase.beginCallRecording(
        sessionKey: sessionKey,
        callId: callId,
        relativePath: prepared.temporaryRelativePath,
        startedAt: recordingStartedAt,
        participantSessionKey: participantSessionKey,
      );
      databaseRecordingId = databaseId;

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

      final recorder = using((Arena arena) {
        final filename = arena<pj_str_t>();
        final nativePath = prepared!.temporaryFile.path.toNativeUtf8(
          allocator: arena,
        );
        _pjStr(filename.ref, nativePath);
        final recorderId = arena<pjsua_recorder_id>();
        final status = _bindings.pjsua_recorder_create(
          filename,
          0,
          ffi.nullptr,
          -1,
          0,
          recorderId,
        );
        if (status != 0) return (status: status, id: -1, port: -1);
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
      _recording.startingCallIds.removeAll(startupCallIds);
    }
  }

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

  bool _syncCallRecordingRoutesFor(int callId) {
    final sessionKey = _recording.sessionKeyByCallId[callId];
    final session = sessionKey == null ? null : _recording.sessions[sessionKey];
    if (session == null) return false;
    return _syncRecordingSessionRoutes(session);
  }

  bool _syncRecordingSessionRoutes(_CallRecordingSession session) {
    if (!_uiState.isInitialized) return false;
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

    for (final entry in session.connectedCallSlots.entries.toList()) {
      if (desiredSlots[entry.key] == entry.value) continue;
      _bindings.pjsua_conf_disconnect(entry.value, session.recorderPort);
      session.connectedCallSlots.remove(entry.key);
    }
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

    final shouldConnectMicrophone = desiredSlots.keys.any((callId) {
      final audioAvailable = _uiState.isInConference(callId)
          ? !_uiState.isConferencePaused
          : _shouldUseLocalAudioForCall(callId);
      return audioAvailable && _shouldRouteMicrophoneToCall(callId);
    });
    if (shouldConnectMicrophone && !session.microphoneConnected) {
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
    return session.connectedCallSlots.isNotEmpty;
  }

  void _syncAllCallRecordingRoutes() {
    for (final session in _recording.sessions.values.toList(growable: false)) {
      _syncRecordingSessionRoutes(session);
    }
  }

  _CallRecordingSession? _recordingSessionForConferenceMember(int callId) {
    if (!_uiState.isInConference(callId)) return null;
    for (final memberId in _uiState.conferenceCallIds) {
      final key = _recording.sessionKeyByCallId[memberId];
      final session = key == null ? null : _recording.sessions[key];
      if (session?.isConference == true) return session;
    }
    return null;
  }

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

  void _finishRecordingSession(
    String sessionKey, {
    CallRecordingStatus status = CallRecordingStatus.completed,
    String? failureReason,
  }) {
    final session = _recording.sessions.remove(sessionKey);
    if (session == null) return;
    if (_uiState.isInitialized) {
      for (final slot in session.connectedCallSlots.values) {
        _bindings.pjsua_conf_disconnect(slot, session.recorderPort);
      }
      if (session.microphoneConnected) {
        _bindings.pjsua_conf_disconnect(0, session.recorderPort);
      }
      _bindings.pjsua_recorder_destroy(session.recorderId);
    }
    for (final callId in session.participantSessionKeys.keys) {
      if (_recording.sessionKeyByCallId[callId] == sessionKey) {
        _recording.sessionKeyByCallId.remove(callId);
        _setCallRecordingUi(callId, false);
      }
    }

    var finalStatus = status;
    var reason = failureReason;
    var relativePath = session.preparedFile.temporaryRelativePath;
    var fileSize = 0;
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

  void _stopAllCallRecordings(CallRecordingStatus status) {
    for (final key in _recording.sessions.keys.toList(growable: false)) {
      _finishRecordingSession(key, status: status);
    }
  }

  void _setCallRecordingUi(int callId, bool recording) {
    final ids = Set<int>.of(_uiState.recordingCallIds);
    final changed = recording ? ids.add(callId) : ids.remove(callId);
    if (changed) _uiState = _uiState.copyWith(recordingCallIds: ids);
  }

  Future<void> _recoverUnfinishedCallRecordings() async {
    try {
      final rows = await _callHistoryDatabase.listUnfinishedRecordings();
      for (final row in rows) {
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

  Future<CallRecordingPlaybackResult> toggleCallRecordingPlayback(
    CallRecording recording,
  ) async {
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
    final file = await CallRecordingStorage.resolve(recording.relativePath);
    if (!await file.exists()) return CallRecordingPlaybackResult.fileMissing;
    if (!_ensureSoundDeviceOpen('播放本地通话录音')) {
      return CallRecordingPlaybackResult.engineUnavailable;
    }
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
    final duration = Duration(
      milliseconds: recording.durationMs.clamp(500, 1 << 31).toInt(),
    );
    _recording.playbackTimer = Timer(duration, _stopCallRecordingPlayback);
    return CallRecordingPlaybackResult.started;
  }

  void stopCallRecordingPlayback() => _stopCallRecordingPlayback();

  void _stopCallRecordingPlayback({bool updateUi = true}) {
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

  Future<String?> exportCallRecording(
    CallRecording recording, {
    required String suggestedName,
  }) {
    return CallRecordingStorage.export(
      recording.relativePath,
      suggestedName: suggestedName,
    );
  }

  Future<bool> revealCallRecording(CallRecording recording) async {
    try {
      await CallRecordingStorage.reveal(recording.relativePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteCallRecording(CallRecording recording) async {
    if (_recording.playingRecordingId == recording.id) {
      _stopCallRecordingPlayback();
    }
    await CallRecordingStorage.delete(recording.relativePath);
    await _callHistoryDatabase.deleteRecording(recording.id);
  }

  Future<void> deleteCallRecordingsForHistory(int historyEntryId) async {
    final orphanedRecordings = await _callHistoryDatabase
        .unlinkRecordingsFromHistory(historyEntryId);
    for (final recording in orphanedRecordings) {
      await deleteCallRecording(recording);
    }
  }

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
