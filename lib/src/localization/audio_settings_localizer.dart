import '../../l10n/app_localizations.dart';
import '../../utils/toast_util.dart';

/// 音频设置与运行时提示的统一文案转换入口。
///
/// PJSIP 服务继续用中文记录诊断状态和日志；界面根据稳定错误码在显示时本地化，
/// 避免切换语言后残留服务启动时写入的旧语言文案。
abstract final class AudioSettingsLocalizer {
  static const int microphonePermissionDenied = -900001;
  static const int noConcreteCaptureDevice = -900002;
  static const int noConcretePlaybackDevice = -900003;
  static const int noConcreteInputOutputDevice = -900004;
  static const int invalidDevice = 420004;
  static const int noDevice = 420005;
  static const int noDefaultDevice = 420006;
  static const int notReady = 420007;

  static AppLocalizations? get current {
    final context = ToastUtil.navigatorKey.currentContext;
    return context == null ? null : AppLocalizations.of(context);
  }

  static String deviceIssue(
    AppLocalizations l10n,
    int? status, {
    String? diagnosticMessage,
  }) {
    if (_isSpeakerOnlyMessage(diagnosticMessage)) {
      return l10n.audioIssueSpeakerOnly;
    }
    return switch (status) {
      microphonePermissionDenied => l10n.audioIssueMicrophonePermission,
      noConcreteCaptureDevice => l10n.audioIssueNoMicrophone,
      noConcretePlaybackDevice => l10n.audioIssueNoSpeaker,
      noConcreteInputOutputDevice => l10n.audioIssueNoInputOutput,
      invalidDevice => l10n.audioIssueInvalidDevice,
      noDevice => l10n.audioIssueNoDevice,
      noDefaultDevice => l10n.audioIssueNoDefaultDevice,
      notReady => l10n.audioIssueNotReady,
      final int code => l10n.audioIssueUnavailable(code),
      null =>
        diagnosticMessage?.trim().isNotEmpty == true
            ? diagnosticMessage!.trim()
            : l10n.audioUsingSelectedDevicesStatus,
    };
  }

  static String runtimeDeviceIssue(int status, {String? diagnosticMessage}) {
    final l10n = current;
    if (l10n == null) {
      return diagnosticMessage?.trim().isNotEmpty == true
          ? diagnosticMessage!.trim()
          : '音频设备暂不可用（错误码 $status），请重新连接设备后重试';
    }
    return deviceIssue(l10n, status, diagnosticMessage: diagnosticMessage);
  }

  static String runtimeSpeakerOnly() =>
      current?.audioIssueSpeakerOnly ?? '麦克风暂不可用，当前仅使用扬声器，请检查输入设备';

  static String runtimePermissionAvailable() =>
      current?.audioPermissionAvailableToast ?? '麦克风权限已开启';

  static String runtimePermissionRequired() =>
      current?.audioPermissionRequiredToast ?? '请在系统设置中允许 VPhone 使用麦克风';

  static String runtimePermissionPending() =>
      current?.audioPermissionPendingToast ?? '开始通话时，系统将请求麦克风权限';

  static String runtimePermissionSystemManaged() =>
      current?.audioPermissionSystemManagedToast ?? '麦克风权限由当前操作系统统一管理';

  static String runtimePermissionUnknown() =>
      current?.audioPermissionUnknownToast ?? '暂时无法确认麦克风权限状态';

  static bool _isSpeakerOnlyMessage(String? message) {
    final normalized = message?.toLowerCase() ?? '';
    return normalized.contains('仅扬声器') ||
        normalized.contains('speaker-only') ||
        normalized.contains('speaker only');
  }
}
