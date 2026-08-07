part of '../pjsip_service.dart';

const int _audioIssueMicrophonePermissionDenied = -900001;

const MethodChannel _macOsAudioPermissionChannel = MethodChannel(
  'voip_desk/audio_permission',
);

/// macOS 麦克风隐私权限同步。
///
/// PJSIP/CoreAudio 在权限被拒绝时仍可能枚举出“系统默认麦克风”，所以不能只靠
/// 设备列表判断输入是否真的可用。这里仅查询系统授权状态，并把拒绝/受限状态同步
/// 到统一的 `audioDeviceIssueMessage`，让主舞台、设置页和侧边栏复用同一套提示。
extension PjsipAudioPermissionOperations on PjsipService {
  /// 主动检查麦克风权限。
  ///
  /// 设置页会调用这个方法做诊断；通话打开声卡前也会调用一次做风险提示。
  /// 它只读取系统授权状态，不主动弹出权限申请框。
  Future<void> checkMicrophonePermission({
    String reason = '检查麦克风权限',
    bool showResult = false,
  }) async {
    final status = await _syncMicrophonePermissionIssue(reason: reason);
    if (!showResult) return;

    switch (status) {
      case PjsipMicrophonePermissionStatus.authorized:
        ToastUtil.showSuccess(
          AudioSettingsLocalizer.runtimePermissionAvailable(),
        );
      case PjsipMicrophonePermissionStatus.denied:
      case PjsipMicrophonePermissionStatus.restricted:
        ToastUtil.showWarning(
          AudioSettingsLocalizer.runtimePermissionRequired(),
        );
      case PjsipMicrophonePermissionStatus.notDetermined:
        ToastUtil.showInfo(AudioSettingsLocalizer.runtimePermissionPending());
      case null:
        if (!Platform.isMacOS) {
          ToastUtil.showInfo(
            AudioSettingsLocalizer.runtimePermissionSystemManaged(),
          );
        }
      case PjsipMicrophonePermissionStatus.unsupported:
        ToastUtil.showInfo(
          AudioSettingsLocalizer.runtimePermissionSystemManaged(),
        );
      case PjsipMicrophonePermissionStatus.unknown:
        ToastUtil.showWarning(
          AudioSettingsLocalizer.runtimePermissionUnknown(),
        );
    }
  }

  /// 处理权限状态行点击。
  ///
  /// macOS 只允许 App 在 notDetermined 时弹系统授权框；如果用户已经拒绝，
  /// 后续只能引导到系统设置手动开启。
  Future<void> handleMicrophonePermissionAction() async {
    final status =
        await _syncMicrophonePermissionIssue(reason: '点击麦克风权限状态') ??
        _uiState.microphonePermissionStatus;

    switch (status) {
      case PjsipMicrophonePermissionStatus.authorized:
        ToastUtil.showSuccess(
          AudioSettingsLocalizer.runtimePermissionAvailable(),
        );
      case PjsipMicrophonePermissionStatus.notDetermined:
        final requestedStatus = await _requestMacOsMicrophoneAccess();
        final nextStatus = _applyMicrophonePermissionStatus(
          requestedStatus,
          reason: '系统麦克风授权',
        );
        if (nextStatus == PjsipMicrophonePermissionStatus.authorized) {
          ToastUtil.showSuccess(
            AudioSettingsLocalizer.runtimePermissionAvailable(),
          );
        }
      case PjsipMicrophonePermissionStatus.denied:
      case PjsipMicrophonePermissionStatus.restricted:
        await _openMacOsMicrophonePrivacySettings();
        ToastUtil.showInfo(AudioSettingsLocalizer.runtimePermissionRequired());
      case PjsipMicrophonePermissionStatus.unsupported:
        ToastUtil.showInfo(
          AudioSettingsLocalizer.runtimePermissionSystemManaged(),
        );
      case PjsipMicrophonePermissionStatus.unknown:
        ToastUtil.showWarning(
          AudioSettingsLocalizer.runtimePermissionUnknown(),
        );
    }
  }

  Future<PjsipMicrophonePermissionStatus?> _syncMicrophonePermissionIssue({
    required String reason,
  }) async {
    if (!Platform.isMacOS) {
      _uiState = _uiState.copyWith(
        microphonePermissionStatus: PjsipMicrophonePermissionStatus.unsupported,
      );
      return PjsipMicrophonePermissionStatus.unsupported;
    }

    final status = await _readMacOsMicrophoneAuthorizationStatus();
    if (status == null) return null;
    return _applyMicrophonePermissionStatus(status, reason: reason);
  }

  PjsipMicrophonePermissionStatus _applyMicrophonePermissionStatus(
    String? rawStatus, {
    required String reason,
  }) {
    final status = _parseMicrophonePermissionStatus(rawStatus);

    if (status == PjsipMicrophonePermissionStatus.denied ||
        status == PjsipMicrophonePermissionStatus.restricted) {
      const message = '麦克风权限未开启，请在系统设置中允许 VPhone 使用麦克风';
      if (_uiState.audioDeviceIssueStatus !=
              _audioIssueMicrophonePermissionDenied ||
          _uiState.audioDeviceIssueMessage != message ||
          _uiState.microphonePermissionStatus != status) {
        _uiState = _uiState.copyWith(
          audioDeviceStatus: message,
          audioDeviceIssueMessage: message,
          audioDeviceIssueStatus: _audioIssueMicrophonePermissionDenied,
          microphonePermissionStatus: status,
        );
        _addLog('⚠️ macOS 麦克风权限不可用: status=${status.name}, reason=$reason');
        _showAudioDeviceIssueToast(
          AudioSettingsLocalizer.runtimePermissionRequired(),
        );
      }
      return status;
    }

    if (_uiState.microphonePermissionStatus != status) {
      _uiState = _uiState.copyWith(microphonePermissionStatus: status);
    }
    if (_uiState.audioDeviceIssueStatus ==
        _audioIssueMicrophonePermissionDenied) {
      _uiState = _uiState.copyWith(
        audioDeviceIssueMessage: null,
        audioDeviceIssueStatus: null,
        microphonePermissionStatus: status,
      );
      _lastAudioDeviceIssueToastAt = null;
      _addLog('✅ macOS 麦克风权限已恢复: status=${status.name}, reason=$reason');
    }
    return status;
  }

  PjsipMicrophonePermissionStatus _parseMicrophonePermissionStatus(
    String? status,
  ) {
    return switch (status) {
      'authorized' => PjsipMicrophonePermissionStatus.authorized,
      'denied' => PjsipMicrophonePermissionStatus.denied,
      'restricted' => PjsipMicrophonePermissionStatus.restricted,
      'notDetermined' => PjsipMicrophonePermissionStatus.notDetermined,
      _ => PjsipMicrophonePermissionStatus.unknown,
    };
  }

  Future<String?> _readMacOsMicrophoneAuthorizationStatus() async {
    try {
      return await _macOsAudioPermissionChannel.invokeMethod<String>(
        'microphoneAuthorizationStatus',
      );
    } on PlatformException catch (error) {
      _addLog('⚠️ 读取 macOS 麦克风权限失败: ${error.code}');
      return null;
    } on MissingPluginException {
      // 非 macOS 或热重载后通道短暂不可用时，不影响 PJSIP 自身音频流程。
      return null;
    }
  }

  Future<String?> _requestMacOsMicrophoneAccess() async {
    if (!Platform.isMacOS) return null;
    try {
      return await _macOsAudioPermissionChannel.invokeMethod<String>(
        'requestMicrophoneAccess',
      );
    } on PlatformException catch (error) {
      _addLog('⚠️ 申请 macOS 麦克风权限失败: ${error.code}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> _openMacOsMicrophonePrivacySettings() async {
    if (!Platform.isMacOS) return;
    try {
      await _macOsAudioPermissionChannel.invokeMethod<void>(
        'openMicrophonePrivacySettings',
      );
    } on PlatformException catch (error) {
      _addLog('⚠️ 打开 macOS 麦克风设置失败: ${error.code}');
    } on MissingPluginException {
      // 非 macOS 或热重载后通道短暂不可用时忽略。
    }
  }
}
