import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 将桌面系统的音频设备变化通知桥接到 Dart。
///
/// macOS 和 Windows 只在 PJSIP 服务运行期间注册系统监听。原生回调不会直接
/// 操作 PJSIP，只负责通知 Dart；后续防抖、设备刷新和自动切换仍由现有逻辑处理。
class AudioDeviceChangeController {
  static const _channel = MethodChannel('voip_desk/audio_device_changes');

  VoidCallback? _onDevicesChanged;
  bool _monitoring = false;

  bool get isSupported => Platform.isMacOS || Platform.isWindows;

  /// 启动原生监听，并返回当前平台是否成功启用监听。
  ///
  /// 不支持的平台返回 false，由调用方自动回退到轮询。
  /// Linux 暂不支持
  Future<bool> startMonitoring(VoidCallback onDevicesChanged) async {
    if (!isSupported) return false;

    _onDevicesChanged = onDevicesChanged;
    _channel.setMethodCallHandler(_handleNativeMethod);
    if (_monitoring) return true;

    try {
      _monitoring =
          await _channel.invokeMethod<bool>('startMonitoring') ?? false;
      return _monitoring;
    } on MissingPluginException {
      _monitoring = false;
      return false;
    } on PlatformException catch (error) {
      debugPrint(
        'Start native audio-device monitoring failed: ${error.message}',
      );
      _monitoring = false;
      return false;
    }
  }

  /// 停止原生监听。该方法支持重复调用。
  Future<void> stopMonitoring() async {
    _onDevicesChanged = null;
    if (!isSupported) return;

    try {
      if (_monitoring) {
        await _channel.invokeMethod<void>('stopMonitoring');
      }
    } on MissingPluginException {
      // 测试环境或旧版 Runner 可能还没有注册原生桥接。
    } on PlatformException catch (error) {
      debugPrint(
        'Stop native audio-device monitoring failed: ${error.message}',
      );
    } finally {
      _monitoring = false;
      _channel.setMethodCallHandler(null);
    }
  }

  Future<void> _handleNativeMethod(MethodCall call) async {
    if (call.method != 'audioDevicesChanged') return;
    _onDevicesChanged?.call();
  }
}
