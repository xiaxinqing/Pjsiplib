part of '../pjsip_service.dart';

/// PJSIP 音频设备错误处理。
///
/// 这层只做三件事：调用底层声卡切换、把 pj_status 翻译成 UI 文案、控制 Toast
/// 不要刷屏。页面不用关心 native 错误码，也不会把音频异常逻辑散落到各个 widget。
extension PjsipAudioIssueOperations on PjsipService {
  static const int _pjmediaAudioInvalidDevice = 420004;
  static const int _pjmediaAudioNoDevice = 420005;
  static const int _pjmediaAudioNoDefaultDevice = 420006;
  static const int _pjmediaAudioNotReady = 420007;
  static const Duration _audioIssueToastInterval = Duration(seconds: 6);

  /// 打开或切换 PJSIP 声卡。
  ///
  /// MicroSIP 在声卡打开失败时会尝试 speaker-only；这里保留同样的低风险兜底：
  /// 如果麦克风不可用但扬声器可用，至少让用户能听到对方，同时 UI 会明确提示
  /// “仅扬声器模式”。如果兜底也失败，就记录异常并提示用户检查设备。
  _SoundDeviceApplyResult _setSoundDevicesWithIssueHandling({
    required int captureId,
    required int playbackId,
    required String action,
  }) {
    final status = _bindings.pjsua_set_snd_dev(captureId, playbackId);
    if (status == 0) {
      _audioDeviceSpeakerOnlyFallbackActive = false;
      _clearAudioDeviceIssue();
      return const _SoundDeviceApplyResult.success();
    }

    final fallbackStatus = using((arena) {
      final params = arena<pjsua_snd_dev_param>();
      _bindings.pjsua_snd_dev_param_default(params);
      params.ref.capture_dev = captureId;
      params.ref.playback_dev = playbackId;
      params.ref.mode |= pjsua_snd_dev_mode.PJSUA_SND_DEV_SPEAKER_ONLY.value;
      return _bindings.pjsua_set_snd_dev2(params);
    });
    if (fallbackStatus == 0) {
      _recordSpeakerOnlyFallback(
        status: status,
        action: action,
        captureId: captureId,
        playbackId: playbackId,
      );
      return _SoundDeviceApplyResult.speakerOnly(status);
    }

    _recordAudioDeviceIssue(
      status: status,
      action: action,
      captureId: captureId,
      playbackId: playbackId,
    );
    return _SoundDeviceApplyResult.failure(status);
  }

  /// 记录声卡打开失败，并把它同步给 UI。
  void _recordAudioDeviceIssue({
    required int status,
    required String action,
    required int captureId,
    required int playbackId,
  }) {
    final message = _audioDeviceIssueMessage(status, action: action);
    _audioDeviceSpeakerOnlyFallbackActive = false;
    _uiState = _uiState.copyWith(
      audioDeviceStatus: message,
      audioDeviceIssueMessage: message,
      audioDeviceIssueStatus: status,
    );
    _addLog(
      '❌ $action失败: capture=$captureId, playback=$playbackId, pj_status=$status, message=$message',
    );
    _showAudioDeviceIssueToast(message);
  }

  /// 记录“无麦克风但扬声器可用”的降级状态。
  void _recordSpeakerOnlyFallback({
    required int status,
    required String action,
    required int captureId,
    required int playbackId,
  }) {
    const message = '麦克风不可用，已切到仅扬声器模式';
    _audioDeviceSpeakerOnlyFallbackActive = true;
    _uiState = _uiState.copyWith(
      audioDeviceStatus: message,
      audioDeviceIssueMessage: '$message，请检查输入设备',
      audioDeviceIssueStatus: status,
    );
    _addLog(
      '⚠️ $action使用仅扬声器模式: capture=$captureId, playback=$playbackId, original_status=$status',
    );
    _showAudioDeviceIssueToast('$message，请检查麦克风');
  }

  /// 清理已恢复的音频异常。只在 PJSIP 成功打开真实声卡后调用。
  void _clearAudioDeviceIssue() {
    if (_uiState.audioDeviceIssueStatus ==
        _audioIssueMicrophonePermissionDenied) {
      return;
    }
    if (!_uiState.hasAudioDeviceIssue &&
        _uiState.audioDeviceIssueStatus == null) {
      return;
    }
    _uiState = _uiState.copyWith(
      audioDeviceIssueMessage: null,
      audioDeviceIssueStatus: null,
    );
    _audioDeviceSpeakerOnlyFallbackActive = false;
    _lastAudioDeviceIssueToastAt = null;
  }

  /// PJSIP 声卡成功不代表 macOS 隐私权限恢复，所以权限类异常需要保留。
  String? get _audioDeviceIssueMessageAfterSuccessfulDeviceApply =>
      _uiState.audioDeviceIssueStatus == _audioIssueMicrophonePermissionDenied
      ? _uiState.audioDeviceIssueMessage
      : null;

  /// PJSIP 声卡成功不代表 macOS 隐私权限恢复，所以权限类异常需要保留。
  int? get _audioDeviceIssueStatusAfterSuccessfulDeviceApply =>
      _uiState.audioDeviceIssueStatus == _audioIssueMicrophonePermissionDenied
      ? _uiState.audioDeviceIssueStatus
      : null;

  /// 把 PJSIP 音频错误码翻译成适合用户看到的文案。
  String _audioDeviceIssueMessage(int status, {required String action}) {
    return switch (status) {
      _pjmediaAudioInvalidDevice => '$action失败：当前音频设备已失效，请刷新或重新选择设备',
      _pjmediaAudioNoDevice => '$action失败：没有检测到可用麦克风或扬声器',
      _pjmediaAudioNoDefaultDevice => '$action失败：系统默认麦克风或扬声器不可用',
      _pjmediaAudioNotReady => '$action失败：音频设备暂未就绪，请稍后重试',
      _ => '$action失败：音频设备不可用，错误码 $status',
    };
  }

  /// Toast 做节流，避免设备轮询或多路通话同时触发时连续弹出。
  void _showAudioDeviceIssueToast(String message) {
    final now = DateTime.now();
    final last = _lastAudioDeviceIssueToastAt;
    if (last != null && now.difference(last) < _audioIssueToastInterval) {
      return;
    }
    _lastAudioDeviceIssueToastAt = now;
    ToastUtil.showWarning(message);
  }
}

/// PJSIP 声卡应用结果。把“成功但降级”和“彻底失败”区分开，UI 才能保留提示。
class _SoundDeviceApplyResult {
  final bool success;
  final bool speakerOnlyFallback;
  final int status;

  const _SoundDeviceApplyResult._({
    required this.success,
    required this.speakerOnlyFallback,
    required this.status,
  });

  const _SoundDeviceApplyResult.success()
    : this._(success: true, speakerOnlyFallback: false, status: 0);

  const _SoundDeviceApplyResult.speakerOnly(int status)
    : this._(success: true, speakerOnlyFallback: true, status: status);

  const _SoundDeviceApplyResult.failure(int status)
    : this._(success: false, speakerOnlyFallback: false, status: status);
}
