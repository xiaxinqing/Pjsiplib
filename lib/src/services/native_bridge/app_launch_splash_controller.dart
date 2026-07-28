import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Coordinates the native launch placeholder with Flutter's first rendered
/// frame. macOS shows a lightweight native logo view before Flutter is ready;
/// other desktop platforms can safely ignore this channel.
class AppLaunchSplashController {
  AppLaunchSplashController._();

  static const MethodChannel _channel = MethodChannel(
    'voip_desk/launch_splash',
  );
  static Timer? _fallbackTimer;
  static bool _hideRequested = false;

  /// Hides the native launch placeholder after Flutter has produced its first
  /// frame, avoiding a fixed startup delay.
  ///
  /// A short fallback protects desktop startup from getting permanently stuck
  /// behind the native placeholder if the post-frame callback or method channel
  /// is delayed by an early plugin/native initialization edge case.
  static void hideAfterFirstFrame() {
    _fallbackTimer?.cancel();
    _hideRequested = false;
    _fallbackTimer = Timer(const Duration(seconds: 4), () {
      unawaited(_hide(reason: 'fallback-timeout'));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_hide(reason: 'first-frame'));
    });
  }

  static Future<void> _hide({required String reason}) async {
    if (_hideRequested) return;
    _hideRequested = true;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;

    try {
      debugPrint('Launch splash hide requested: $reason');
      await _channel.invokeMethod<void>('hide', {'reason': reason});
    } on MissingPluginException {
      // Platforms without a native launch placeholder do not need to respond.
    } on PlatformException catch (error) {
      // Startup polish should never block the app from opening.
      debugPrint('Launch splash hide failed: ${error.message}');
    }
  }
}
