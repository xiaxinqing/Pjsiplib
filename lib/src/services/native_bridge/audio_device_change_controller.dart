import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class SystemAudioEndpoint {
  const SystemAudioEndpoint({required this.id, required this.name});

  final String id;
  final String name;

  static SystemAudioEndpoint? fromMap(Object? value) {
    if (value is! Map) return null;
    final id = value['id']?.toString().trim() ?? '';
    final name = value['name']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty) return null;
    return SystemAudioEndpoint(id: id, name: name);
  }
}

@immutable
class SystemAudioRoute {
  const SystemAudioRoute({this.input, this.output});

  final SystemAudioEndpoint? input;
  final SystemAudioEndpoint? output;

  String get signature => '${input?.id ?? ''}|${output?.id ?? ''}';

  static SystemAudioRoute? fromMap(Object? value) {
    if (value is! Map) return null;
    return SystemAudioRoute(
      input: SystemAudioEndpoint.fromMap(value['input']),
      output: SystemAudioEndpoint.fromMap(value['output']),
    );
  }
}

/// 将桌面系统的音频设备变化通知桥接到 Dart。
///
/// 桌面平台只在 PJSIP 服务运行期间注册系统监听。原生回调不会直接
/// 操作 PJSIP，只负责通知 Dart；后续防抖、设备刷新和自动切换仍由现有逻辑处理。
class AudioDeviceChangeController {
  static const _channel = MethodChannel('voip_desk/audio_device_changes');

  VoidCallback? _onDevicesChanged;
  bool _monitoring = false;

  bool get isSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// 查询操作系统当前默认的输入和输出端点。
  ///
  /// 跟随系统模式下，PJSIP 使用默认设备 ID；设备的真实名称由系统 API 提供，
  /// 不再根据 PJSIP 枚举名称猜测。
  Future<SystemAudioRoute?> getCurrentAudioRoute() async {
    if (!isSupported) return null;
    try {
      final value = await _channel.invokeMethod<Object?>(
        'getCurrentAudioRoute',
      );
      return SystemAudioRoute.fromMap(value);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('Read system audio route failed: ${error.message}');
      return null;
    }
  }

  /// 启动原生监听，并返回当前平台是否成功启用监听。
  ///
  /// 不支持的平台返回 false，由调用方自动回退到轮询。
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
      // 即使首次 start 返回 false，后续路由查询也可能已经让原生服务恢复连接。
      // stopMonitoring 在各 Runner 中均可重复调用，因此这里始终通知原生释放监听。
      await _channel.invokeMethod<void>('stopMonitoring');
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
