part of '../pjsip_service.dart';

/// 音频设备枚举、切换、静音和电平监测。
extension PjsipAudioDeviceOperations on PjsipService {
  Future<void> refreshAudioDevices() async {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ 请先初始化 PJSIP，再刷新音频设备');
      return;
    }

    using((Arena arena) {
      const maxDevices = 64;
      final devices = arena<pjmedia_aud_dev_info>(maxDevices);
      final count = arena<ffi.UnsignedInt>();
      count.value = maxDevices;

      final status = _bindings.pjsua_enum_aud_devs(devices, count);
      if (status != 0) {
        _addLog('❌ 枚举音频设备失败: pj_status=$status');
        return;
      }

      final captureDevices = <PjsipAudioDevice>[
        const PjsipAudioDevice(
          id: -1,
          name: '系统默认麦克风',
          driver: 'default',
          inputCount: 1,
          outputCount: 0,
          defaultSampleRate: 0,
        ),
      ];
      final playbackDevices = <PjsipAudioDevice>[
        const PjsipAudioDevice(
          id: -2,
          name: '系统默认扬声器',
          driver: 'default',
          inputCount: 0,
          outputCount: 1,
          defaultSampleRate: 0,
        ),
      ];

      for (var i = 0; i < count.value; i++) {
        final info = devices[i];
        final device = PjsipAudioDevice(
          id: info.id,
          name: _nativeCharArrayToString(info.name, 64),
          driver: _nativeCharArrayToString(info.driver, 32),
          inputCount: info.input_count,
          outputCount: info.output_count,
          defaultSampleRate: info.default_samples_per_sec,
        );
        if (device.canCapture) captureDevices.add(device);
        if (device.canPlayback) playbackDevices.add(device);
      }

      final current = _currentSoundDeviceIds(arena);
      _uiState = _uiState.copyWith(
        captureDevices: captureDevices,
        playbackDevices: playbackDevices,
        selectedCaptureDeviceId: current.captureId,
        selectedPlaybackDeviceId: current.playbackId,
      );
      _addLog(
        '🎧 音频设备已刷新: 麦克风=${captureDevices.length}, 扬声器=${playbackDevices.length}',
      );
    });
  }

  Future<void> setAudioDevices({int? captureDeviceId, int? playbackDeviceId}) {
    if (!_uiState.isInitialized) {
      _addLog('⚠️ PJSIP 尚未初始化，无法切换音频设备');
      return Future.value();
    }

    return Future<void>(() {
      using((Arena arena) {
        final current = _currentSoundDeviceIds(arena);
        final captureId =
            captureDeviceId ??
            _uiState.selectedCaptureDeviceId ??
            current.captureId ??
            pjsua_snd_dev_id.PJSUA_SND_DEFAULT_CAPTURE_DEV.value;
        final playbackId =
            playbackDeviceId ??
            _uiState.selectedPlaybackDeviceId ??
            current.playbackId ??
            pjsua_snd_dev_id.PJSUA_SND_DEFAULT_PLAYBACK_DEV.value;

        final status = _bindings.pjsua_set_snd_dev(captureId, playbackId);
        if (status != 0) {
          _addLog(
            '❌ 切换音频设备失败: capture=$captureId, playback=$playbackId, pj_status=$status',
          );
          return;
        }

        _uiState = _uiState.copyWith(
          selectedCaptureDeviceId: captureId,
          selectedPlaybackDeviceId: playbackId,
        );
        _applyAudioMuteState();
        _addLog('✅ 音频设备已切换: capture=$captureId, playback=$playbackId');
      });
    });
  }

  void setMicrophoneMuted(bool muted) {
    if (_uiState.isMicrophoneMuted == muted) return;
    _uiState = _uiState.copyWith(isMicrophoneMuted: muted);
    _applyAudioMuteState();
    _addLog(muted ? '🔇 麦克风已静音' : '🎙️ 麦克风已恢复');
  }

  void setSpeakerMuted(bool muted) {
    if (_uiState.isSpeakerMuted == muted) return;
    _uiState = _uiState.copyWith(isSpeakerMuted: muted);
    _applyAudioMuteState();
    _addLog(muted ? '🔈 扬声器已静音' : '🔊 扬声器已恢复');
  }

  ({int? captureId, int? playbackId}) _currentSoundDeviceIds(Arena arena) {
    final capture = arena<ffi.Int>();
    final playback = arena<ffi.Int>();
    final status = _bindings.pjsua_get_snd_dev(capture, playback);
    if (status != 0) return (captureId: null, playbackId: null);
    return (captureId: capture.value, playbackId: playback.value);
  }

  String _nativeCharArrayToString(ffi.Array<ffi.Char> chars, int maxLength) {
    final bytes = <int>[];
    for (var i = 0; i < maxLength; i++) {
      final value = chars[i];
      if (value == 0) break;
      bytes.add(value & 0xff);
    }
    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  void _applyAudioMuteState() {
    for (final entry in _uiState.calls.entries) {
      final callId = entry.key;
      final call = entry.value;
      if (!call.isConnected || call.isOnHold || call.isRemoteOnHold) continue;
      final slot = _getConferenceSlot(callId);
      if (slot == null) continue;

      _bindings.pjsua_conf_disconnect(0, slot);
      _bindings.pjsua_conf_disconnect(slot, 0);

      final shouldUseLocalAudio =
          (_uiState.isConferenceActive &&
              _uiState.conferenceCallIds.contains(callId)) ||
          _uiState.activeCallId == callId;
      if (!shouldUseLocalAudio) continue;

      if (!_uiState.isMicrophoneMuted) {
        _bindings.pjsua_conf_connect(0, slot);
      }
      if (!_uiState.isSpeakerMuted) {
        _bindings.pjsua_conf_connect(slot, 0);
      }
    }
  }

  void _startAudioLevelTimer() {
    if (_audioLevelTimer != null) return;
    _audioLevelTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_uiState.isInitialized) return;
      final hasConnectedCall = _uiState.calls.values.any(
        (call) => call.isConnected,
      );
      if (!hasConnectedCall) {
        if (_uiState.microphoneLevel != 0 || _uiState.speakerLevel != 0) {
          _uiState = _uiState.copyWith(microphoneLevel: 0, speakerLevel: 0);
        }
        return;
      }

      using((Arena arena) {
        final tx = arena<ffi.UnsignedInt>();
        final rx = arena<ffi.UnsignedInt>();
        final status = _bindings.pjsua_conf_get_signal_level(0, tx, rx);
        if (status != 0) return;
        _uiState = _uiState.copyWith(
          microphoneLevel: _uiState.isMicrophoneMuted ? 0 : tx.value,
          speakerLevel: _uiState.isSpeakerMuted ? 0 : rx.value,
        );
      });
    });
  }

  void _stopAudioLevelTimer() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = null;
  }
}
