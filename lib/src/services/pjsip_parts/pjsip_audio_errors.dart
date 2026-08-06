part of '../pjsip_service.dart';

const int _audioIssueNoConcreteCaptureDevice = -900002;
const int _audioIssueNoConcretePlaybackDevice = -900003;
const int _audioIssueNoConcreteInputOutputDevice = -900004;

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
  static const Duration _soundDeviceOpenFailureCooldown = Duration(seconds: 8);

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
      _clearSoundDeviceOpenFailure();
      _clearAudioDeviceIssueAfterSuccessfulDeviceApply();
      return const _SoundDeviceApplyResult.success();
    }

    // 只对 PJSIP 明确归类的音频设备错误尝试 speaker-only。CoreAudio 这类未知
    // native 错误可能已经在底层阻塞重试过，再立即 fallback 会把一次失败放大成
    // 两轮长阻塞，所以直接记录异常并进入短暂熔断。
    if (!_shouldTrySpeakerOnlyFallback(status)) {
      _recordAudioDeviceIssue(
        status: status,
        action: action,
        captureId: captureId,
        playbackId: playbackId,
      );
      return _SoundDeviceApplyResult.failure(status);
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
      _clearSoundDeviceOpenFailure();
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
    _recordSoundDeviceOpenFailure(
      captureId: captureId,
      playbackId: playbackId,
      status: status,
    );
    final message = _audioDeviceIssueMessage(status, action: action);
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
    _lastAudioDeviceIssueToastAt = null;
  }

  bool _isAudioDeviceAvailabilityIssue(int? status) =>
      status == _audioIssueNoConcreteCaptureDevice ||
      status == _audioIssueNoConcretePlaybackDevice ||
      status == _audioIssueNoConcreteInputOutputDevice;

  /// 成功应用 PJSIP 声卡后，只清理由本次打开失败产生的运行时异常。
  ///
  /// “无真实设备”必须等设备枚举确认恢复，“麦克风权限”必须等系统权限检查确认
  /// 恢复。仅凭 `pjsua_set_snd_dev` 返回成功就清除，会让来电响铃期间短暂显示
  /// 音频正常，接通后又重新显示异常。
  void _clearAudioDeviceIssueAfterSuccessfulDeviceApply() {
    if (_shouldPreserveAudioDeviceIssueAfterSuccessfulDeviceApply) {
      return;
    }
    _clearAudioDeviceIssue();
  }

  bool get _shouldPreserveAudioDeviceIssueAfterSuccessfulDeviceApply =>
      _uiState.audioDeviceIssueStatus ==
          _audioIssueMicrophonePermissionDenied ||
      _isAudioDeviceAvailabilityIssue(_uiState.audioDeviceIssueStatus);

  /// 根据设备枚举结果同步“没有真实输入/输出设备”的提示。
  ///
  /// `系统默认麦克风/扬声器` 是我们为了跟随系统设置手动补进 UI 的选项，不代表
  /// 机器上真的存在可打开的声卡。Mac mini 这类无内置输入/输出的设备上，需要把
  /// “无设备”和“无麦克风权限”分开提示，避免用户误以为只要授权就能恢复。
  void _syncAudioDeviceAvailabilityIssue(
    _AudioDeviceSnapshot snapshot, {
    required String reason,
  }) {
    final hasConcreteCapture = snapshot.captureDevices.any(
      (device) => !device.isSystemDefault,
    );
    final hasConcretePlayback = snapshot.playbackDevices.any(
      (device) => !device.isSystemDefault,
    );
    final (status, message) = switch ((
      hasConcreteCapture,
      hasConcretePlayback,
    )) {
      (false, false) => (
        _audioIssueNoConcreteInputOutputDevice,
        '没有检测到可用麦克风或扬声器，请连接耳机或音频设备',
      ),
      (false, true) => (
        _audioIssueNoConcreteCaptureDevice,
        '没有检测到可用麦克风，请连接耳机或输入设备',
      ),
      (true, false) => (
        _audioIssueNoConcretePlaybackDevice,
        '没有检测到可用扬声器，请连接耳机或输出设备',
      ),
      (true, true) => (null, null),
    };

    if (message == null) {
      if (_isAudioDeviceAvailabilityIssue(_uiState.audioDeviceIssueStatus)) {
        _clearAudioDeviceIssue();
        _addLog('✅ 音频设备已恢复: $reason');
      }
      return;
    }

    if (_uiState.audioDeviceIssueStatus == status &&
        _uiState.audioDeviceIssueMessage == message) {
      return;
    }
    _uiState = _uiState.copyWith(
      audioDeviceStatus: message,
      audioDeviceIssueMessage: message,
      audioDeviceIssueStatus: status,
    );
    _addLog('⚠️ $message ($reason)');
  }

  /// PJSIP 声卡成功不代表权限或真实设备已经恢复，所以权威检测类异常需要保留。
  String? get _audioDeviceIssueMessageAfterSuccessfulDeviceApply =>
      _shouldPreserveAudioDeviceIssueAfterSuccessfulDeviceApply
      ? _uiState.audioDeviceIssueMessage
      : null;

  /// PJSIP 声卡成功不代表权限或真实设备已经恢复，所以权威检测类异常需要保留。
  int? get _audioDeviceIssueStatusAfterSuccessfulDeviceApply =>
      _shouldPreserveAudioDeviceIssueAfterSuccessfulDeviceApply
      ? _uiState.audioDeviceIssueStatus
      : null;

  /// 把 PJSIP 音频错误码翻译成适合用户看到的文案。
  String _audioDeviceIssueMessage(int status, {required String action}) {
    final recoveryHint = '请重新插拔音频设备，必要时重启应用或电脑';
    return switch (status) {
      _pjmediaAudioInvalidDevice => '$action失败：当前音频设备已失效，请刷新或重新选择设备',
      _pjmediaAudioNoDevice => '$action失败：没有检测到可用麦克风或扬声器',
      _pjmediaAudioNoDefaultDevice => '$action失败：系统默认麦克风或扬声器不可用',
      _pjmediaAudioNotReady => '$action失败：音频设备暂未就绪，请稍后重试',
      _ => '$action失败：音频设备不可用，错误码 $status。$recoveryHint',
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

  /// 判断当前失败是否还在熔断窗口内。
  ///
  /// 只拦截同一组输入/输出设备，避免“系统默认失败后插上耳机”仍被挡住。设备变化、
  /// 手动修复、真实打开成功都会清理这组状态。
  bool _isSoundDeviceOpenCoolingDown(int captureId, int playbackId) {
    final until = _audio.failedSoundDeviceUntil;
    if (until == null || DateTime.now().isAfter(until)) {
      _clearSoundDeviceOpenFailure();
      return false;
    }
    return _audio.failedSoundDeviceCaptureId == captureId &&
        _audio.failedSoundDevicePlaybackId == playbackId;
  }

  /// 记录一次声卡打开失败，后续自动触发路径会在冷却期内直接短路。
  void _recordSoundDeviceOpenFailure({
    required int captureId,
    required int playbackId,
    required int status,
  }) {
    _audio.failedSoundDeviceCaptureId = captureId;
    _audio.failedSoundDevicePlaybackId = playbackId;
    _audio.failedSoundDeviceStatus = status;
    _audio.failedSoundDeviceUntil = DateTime.now().add(
      _soundDeviceOpenFailureCooldown,
    );
    _audio.lastSoundDeviceCooldownLogAt = null;
  }

  /// 清理声卡打开失败熔断状态。
  void _clearSoundDeviceOpenFailure() {
    _audio.failedSoundDeviceCaptureId = null;
    _audio.failedSoundDevicePlaybackId = null;
    _audio.failedSoundDeviceStatus = null;
    _audio.failedSoundDeviceUntil = null;
    _audio.lastSoundDeviceCooldownLogAt = null;
  }

  /// 熔断期间只偶尔打日志，避免铃声/回铃音连续触发时刷屏。
  void _addSoundDeviceCooldownLogIfNeeded({
    required String action,
    required int captureId,
    required int playbackId,
    required String reason,
  }) {
    final status = _audio.failedSoundDeviceStatus;
    final message = status == null
        ? '$action暂缓：音频设备刚失败，稍后自动重试'
        : _audioDeviceIssueMessage(status, action: action);
    _uiState = _uiState.copyWith(
      audioDeviceStatus: message,
      audioDeviceIssueMessage: message,
      audioDeviceIssueStatus: status,
    );
    _showAudioDeviceIssueToast(message);

    final now = DateTime.now();
    final last = _audio.lastSoundDeviceCooldownLogAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }
    _audio.lastSoundDeviceCooldownLogAt = now;
    _addLog(
      '⏸️ $action已短路: capture=$captureId, playback=$playbackId, '
      'status=${status ?? 'unknown'}, reason=$reason',
    );
  }

  /// 是否值得尝试 PJSIP speaker-only 兜底。
  ///
  /// speaker-only 能救“麦克风不可用但扬声器可用”的场景；但对 CoreAudio 原生层
  /// 未知错误，fallback 常常只是第二次长阻塞，所以这里只接受 PJSIP 明确音频码。
  bool _shouldTrySpeakerOnlyFallback(int status) {
    return status == _pjmediaAudioInvalidDevice ||
        status == _pjmediaAudioNoDevice ||
        status == _pjmediaAudioNoDefaultDevice ||
        status == _pjmediaAudioNotReady;
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
