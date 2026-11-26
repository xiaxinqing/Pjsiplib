import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

class _DiagnosticsService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('断网后立即导出的文本包含当前状态和 SIP 注册被阻止的原因', () async {
    final directory = await Directory.systemTemp.createTemp('vphone_network_');
    addTearDown(() => directory.delete(recursive: true));
    final output = File.fromUri(directory.uri.resolve('diagnostics.txt'));
    final nativeLog = File.fromUri(directory.uri.resolve('native.log'));
    await nativeLog.writeAsString('test native log');
    const channel = MethodChannel('plugins.flutter.io/file_selector');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getSavePath');
      return output.path;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    PackageInfo.setMockInitialValues(
      appName: 'VPhone',
      packageName: 'vphone.test',
      version: '1',
      buildNumber: '1',
      buildSignature: '',
    );

    final container = ProviderContainer(
      overrides: [pjsipServiceProvider.overrideWith(_DiagnosticsService.new)],
    );
    addTearDown(container.dispose);
    final service = container.read(pjsipServiceProvider.notifier);
    service.handleNetworkChanged(isAvailable: false);
    await service.register(
      username: 'test-line',
      password: 'private-test-password',
      host: 'example.invalid',
    );

    // 让导出器读取临时原生日志，不访问测试机器上的用户日志。
    final fileZone = Zone.current;
    final exported = await IOOverrides.runZoned(
      service.exportDiagnosticLogs,
      createFile: (path) => path.endsWith('vphone_native.log')
          ? nativeLog
          : fileZone.run(() => File(path)),
    );
    expect(exported, output.path);
    final report = await output.readAsString();
    expect(report, contains('网络: 不可用'));
    expect(report, contains('网络恢复状态: offline'));
    expect(report, contains('最近一次网络判断: 尚未取得检测结果'));
    final events = report.split('===== 应用事件日志').last.split('===== PJSIP').first;
    expect(events, matches(RegExp(r'\[网络诊断\].*新增线路.*离线.*PJSIP')));
    expect(report, isNot(contains('private-test-password')));
    expect(report, contains('test native log'));
  });
}
