import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/call_recording_storage.dart';

void main() {
  test('录音文件名包含日期时间、方向、本端和对端号码', () {
    final outbound = CallRecordingStorage.buildFileStem(
      sessionKey: '1787205309623284-0',
      startedAt: DateTime(2026, 8, 20, 13, 56, 12, 231),
      directionCode: 'OUT',
      localNumber: '6529',
      remoteNumber: '6545',
    );
    final inbound = CallRecordingStorage.buildFileStem(
      sessionKey: '1787205309623285-3',
      startedAt: DateTime(2026, 8, 20, 14, 2, 3, 7),
      directionCode: 'IN',
      localNumber: '6529',
      remoteNumber: 'sip:10086@example.com',
    );

    expect(outbound, '20260820-135612-231_OUT_6529_TO_6545_C0');
    expect(inbound, '20260820-140203-007_IN_sip_10086_example_com_TO_6529_C3');
    expect(outbound, isNot(contains(RegExp(r'[<>:"/\\|?*]'))));
  });
}
