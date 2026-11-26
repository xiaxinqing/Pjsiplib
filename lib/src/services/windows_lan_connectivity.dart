import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:stream_transform/stream_transform.dart';
import 'package:win32/win32.dart' show COMException;

import 'windows_lan_probe.dart';

/// SIP can use a local network even when Windows reports no Internet access.
class WindowsLanConnectivity implements Connectivity {
  WindowsLanConnectivity({
    ConnectivityPlatform? platform,
    this.hasLanConnection = hasWindowsLanConnection,
    this.onDiagnostic,
  }) : _platform = platform ?? ConnectivityPlatform.instance;

  final ConnectivityPlatform _platform;
  final Future<bool> Function() hasLanConnection;
  final void Function(String)? onDiagnostic;
  int _revision = 0;
  late Future<List<ConnectivityResult>> _latestResult;

  // Startup/resume queries can overlap network events. Give both callers the
  // newest result if a slower LAN query completes after the connection changed.
  Future<List<ConnectivityResult>> _track(
    String source, {
    List<ConnectivityResult>? eventTypes,
  }) {
    final revision = ++_revision;
    return _latestResult = _evaluate(source, eventTypes, revision);
  }

  Future<List<ConnectivityResult>> _evaluate(
    String source,
    List<ConnectivityResult>? eventTypes,
    int revision,
  ) async {
    List<ConnectivityResult>? raw;
    late List<ConnectivityResult> result;
    var lan = '未执行';
    try {
      raw = eventTypes ?? await _platform.checkConnectivity();
      result = raw;
      if (!raw.any((type) => type != ConnectivityResult.none)) {
        final connected = await hasLanConnection();
        lan = connected ? '已连接' : '未连接';
        result = connected
            ? const [ConnectivityResult.other]
            : const [ConnectivityResult.none];
      }
    } catch (error) {
      if (revision == _revision) {
        onDiagnostic?.call(
          'Windows $source，插件原始类型=${raw == null ? '读取失败' : _typesLabel(raw)}，'
          '局域网补查=${raw == null ? '未执行' : '失败'}，${_errorLabel(error)}，沿用已有网络状态',
        );
      }
      rethrow;
    }

    if (revision != _revision) return _latestResult;
    final available = result.any((type) => type != ConnectivityResult.none);
    onDiagnostic?.call(
      'Windows $source，插件原始类型=${_typesLabel(raw)}，局域网补查=$lan，'
      '判定=${available ? '可用' : '离线'}${_typesLabel(result)}',
    );
    return result;
  }

  static String _typesLabel(List<ConnectivityResult> types) =>
      '[${types.map((type) => type.name).join(',')}]';

  static String _errorLabel(Object error) {
    final hr = switch (error) {
      COMException() => error.hr,
      PlatformException() => int.tryParse(error.code),
      _ => null,
    };
    return hr == null
        ? '错误类型=${error.runtimeType}'
        : 'HRESULT=0x${hr.toUnsigned(32).toRadixString(16).padLeft(8, '0')}';
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity({
    String source = '主动查询',
  }) => _track(source);

  // One LAN cable can produce 'none' on both unplug and reconnect. Listen
  // before Connectivity's distinct() so both Windows notifications get checked.
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _platform
      .onConnectivityChanged
      .handleError((Object error, StackTrace stack) {
        onDiagnostic?.call(
          'Windows 系统网络变化，插件原始监听异常，局域网补查=未执行，${_errorLabel(error)}，沿用已有网络状态',
        );
        Error.throwWithStackTrace(error, stack);
      })
      .switchMap(
        (types) => Stream.fromFuture(_track('系统网络变化', eventTypes: types)),
      );
}
