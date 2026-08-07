import '../../l10n/app_localizations.dart';
import '../services/pjsip_service.dart';

/// Centralizes semantic labels for calls that are still active.
///
/// The service model deliberately keeps PJSIP state values language-neutral.
/// Screens can choose different layouts while sharing the same status meaning.
abstract final class ActiveCallLocalizer {
  static String status(AppLocalizations l10n, CallInfo call) {
    if (call.isOnHold) return l10n.activeCallStatusLocalHold;
    if (call.isRemoteOnHold) return l10n.activeCallStatusRemoteHold;

    return switch (call.state) {
      1 => l10n.activeCallStatusCalling,
      2 => l10n.activeCallStatusIncoming,
      3 =>
        call.direction == PjsipCallDirection.inbound
            ? l10n.activeCallStatusWaitingAnswer
            : l10n.activeCallStatusRemoteRinging,
      4 => l10n.activeCallStatusConnecting,
      5 => l10n.activeCallStatusInCall,
      6 => l10n.activeCallStatusEnded,
      _ => l10n.activeCallStatusUnknown(call.state),
    };
  }

  static String mediaStatus(AppLocalizations l10n, CallInfo call) {
    return switch (call.mediaStatus) {
      1 => l10n.activeCallMediaConnected,
      2 => l10n.activeCallMediaLocalHold,
      3 => l10n.activeCallMediaRemoteHold,
      4 => l10n.activeCallMediaError,
      0 =>
        call.isConnected
            ? l10n.activeCallMediaNotReady
            : l10n.activeCallMediaPending,
      null =>
        call.isConnected
            ? l10n.activeCallMediaUnconfirmed
            : l10n.activeCallMediaPending,
      final status => l10n.activeCallMediaUnknown(status),
    };
  }

  /// Converts negotiated call security into user-facing language.
  ///
  /// Technical protocol names stay in diagnostics and tooltips. The primary UI
  /// communicates the outcome without presenting a standard RTP call as an
  /// alarming error state.
  static String securityStatus(
    AppLocalizations l10n, {
    required bool signalingEncrypted,
    required bool? audioEncrypted,
    required bool encryptionConfigured,
  }) {
    if (audioEncrypted == true) {
      return signalingEncrypted
          ? l10n.activeCallEncryptedCall
          : l10n.activeCallEncryptedAudio;
    }
    if (audioEncrypted == false || !encryptionConfigured) {
      return l10n.activeCallStandardCall;
    }
    return l10n.activeCallVerifyingEncryption;
  }
}
