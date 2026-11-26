import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/windows_lan_connectivity.dart';
import 'package:win32/win32.dart' show COMException;

const _offline = [ConnectivityResult.none];
const _lan = [ConnectivityResult.other];

class _WindowsPlatform extends ConnectivityPlatform {
  final events = StreamController<List<ConnectivityResult>>.broadcast(
    sync: true,
  );
  var current = _offline;
  Object? checkError;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    final error = checkError;
    if (error != null) throw error;
    return current;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}

void main() {
  late _WindowsPlatform platform;

  setUp(() => platform = _WindowsPlatform());
  tearDown(() => platform.events.close());

  test('Windows 初查无公网时使用局域网；已识别的网络保留原类型', () async {
    var lanUp = true;
    var probes = 0;
    final diagnostics = <String>[];
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      onDiagnostic: diagnostics.add,
      hasLanConnection: () async {
        probes++;
        return lanUp;
      },
    );
    expect(await connectivity.checkConnectivity(source: '启动初查'), _lan);
    lanUp = false;
    expect(await connectivity.checkConnectivity(), _offline);

    platform.current = [ConnectivityResult.wifi, ConnectivityResult.vpn];
    expect(await connectivity.checkConnectivity(), platform.current);
    expect(probes, 2);
    expect(diagnostics, [
      'Windows 启动初查，插件原始类型=[none]，局域网补查=已连接，判定=可用[other]',
      'Windows 主动查询，插件原始类型=[none]，局域网补查=未连接，判定=离线[none]',
      'Windows 主动查询，插件原始类型=[wifi,vpn]，局域网补查=未执行，判定=可用[wifi,vpn]',
    ]);
  });

  test('诊断保留原始查询与补查的失败阶段和 HRESULT，不记录异常中的客户信息', () async {
    final diagnostics = <String>[];
    final denied = COMException(-2147024891, message: 'customer-sensitive');
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      hasLanConnection: () async => throw denied,
      onDiagnostic: diagnostics.add,
    );
    await expectLater(connectivity.checkConnectivity(), throwsA(same(denied)));
    platform.checkError = StateError('customer-sensitive');
    await expectLater(connectivity.checkConnectivity(), throwsStateError);
    expect(diagnostics, [
      'Windows 主动查询，插件原始类型=[none]，局域网补查=失败，HRESULT=0x80070005，沿用已有网络状态',
      'Windows 主动查询，插件原始类型=读取失败，局域网补查=未执行，错误类型=StateError，沿用已有网络状态',
    ]);
  });

  test('Windows 原始监听异常写入诊断并保留原错误', () async {
    final diagnostics = <String>[];
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      onDiagnostic: diagnostics.add,
      hasLanConnection: () async => fail('监听异常时不应开始内网补查'),
    );
    final error = PlatformException(code: '-2147024891', message: 'sensitive');
    final result = expectLater(
      connectivity.onConnectivityChanged.first,
      throwsA(same(error)),
    );
    platform.events.addError(error);
    await result;
    expect(diagnostics, [
      'Windows 系统网络变化，插件原始监听异常，局域网补查=未执行，HRESULT=0x80070005，沿用已有网络状态',
    ]);
  });

  test('局域网拔插时 Windows 连续上报 none 仍重新检查网卡', () async {
    var lanUp = true;
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      hasLanConnection: () async => lanUp,
    );
    final results = <List<ConnectivityResult>>[];
    final subscription = connectivity.onConnectivityChanged.listen(results.add);
    addTearDown(subscription.cancel);

    for (final connected in [true, false, true]) {
      lanUp = connected;
      platform.events.add(_offline);
      await Future<void>.delayed(Duration.zero);
    }
    expect(results, [_lan, _offline, _lan]);
  });

  test('较慢的局域网检查不能覆盖较新的在线事件', () async {
    final previousProbe = Completer<bool>();
    final diagnostics = <String>[];
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      hasLanConnection: () => previousProbe.future,
      onDiagnostic: diagnostics.add,
    );
    final results = <List<ConnectivityResult>>[];
    final subscription = connectivity.onConnectivityChanged.listen(results.add);
    addTearDown(subscription.cancel);

    platform.events.add(_offline);
    await Future<void>.delayed(Duration.zero);
    const ethernet = [ConnectivityResult.ethernet];
    platform.events.add(ethernet);
    await Future<void>.delayed(Duration.zero);
    expect(results, [ethernet]);

    previousProbe.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(results, [ethernet]);
    expect(diagnostics, [
      'Windows 系统网络变化，插件原始类型=[ethernet]，局域网补查=未执行，判定=可用[ethernet]',
    ]);
  });

  test('初查和前台检查与网卡通知交错时使用最新网络状态', () async {
    var pendingLan = Completer<bool>();
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      hasLanConnection: () => pendingLan.future,
    );
    final events = <List<ConnectivityResult>>[];
    final subscription = connectivity.onConnectivityChanged.listen(events.add);
    addTearDown(subscription.cancel);

    final startup = connectivity.checkConnectivity();
    await Future<void>.delayed(Duration.zero);
    const wifi = [ConnectivityResult.wifi];
    platform.events.add(wifi);
    await Future<void>.delayed(Duration.zero);
    expect(events, [wifi]);
    pendingLan.complete(false);
    expect(await startup, wifi);

    pendingLan = Completer<bool>();
    platform.events.add(_offline);
    await Future<void>.delayed(Duration.zero);
    const ethernet = [ConnectivityResult.ethernet];
    platform.current = ethernet;
    expect(await connectivity.checkConnectivity(), ethernet);
    pendingLan.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(events, [wifi, ethernet]);
  });

  test('取消订阅后旧的局域网查询不能通知新的订阅', () async {
    final firstProbe = Completer<bool>();
    var probes = 0;
    final connectivity = WindowsLanConnectivity(
      platform: platform,
      hasLanConnection: () =>
          ++probes == 1 ? firstProbe.future : Future.value(true),
    );
    final events = connectivity.onConnectivityChanged;
    final previous = <List<ConnectivityResult>>[];
    final firstSubscription = events.listen(previous.add);
    platform.events.add(_offline);
    await Future<void>.delayed(Duration.zero);
    await firstSubscription.cancel();

    final current = <List<ConnectivityResult>>[];
    final nextSubscription = events.listen(current.add);
    addTearDown(nextSubscription.cancel);
    platform.events.add(_offline);
    await Future<void>.delayed(Duration.zero);
    firstProbe.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(previous, isEmpty);
    expect(current, [_lan]);
  });
}
