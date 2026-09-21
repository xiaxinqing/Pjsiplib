import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/native_bridge/audio_device_change_controller.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

void main() {
  group('macOS 普通音频模式的系统端点映射', () {
    const microphone = PjsipAudioDevice(
      id: 0,
      name: 'MacBook Pro麦克风',
      driver: 'core audio',
      inputCount: 1,
      outputCount: 0,
      defaultSampleRate: 48000,
    );
    const speaker = PjsipAudioDevice(
      id: 1,
      name: 'MacBook Pro扬声器',
      driver: 'core audio',
      inputCount: 0,
      outputCount: 2,
      defaultSampleRate: 48000,
    );
    const virtual = PjsipAudioDevice(
      id: 3,
      name: 'BlackHole 2ch',
      driver: 'core audio',
      inputCount: 2,
      outputCount: 2,
      defaultSampleRate: 48000,
    );
    const devices = [virtual, speaker, microphone];

    test('系统扬声器和麦克风分别映射，不误选双向虚拟声卡', () {
      expect(
        PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
          devices: devices,
          systemDeviceName: microphone.name,
          capture: true,
        ),
        0,
      );
      expect(
        PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
          devices: devices,
          systemDeviceName: speaker.name,
          capture: false,
        ),
        1,
      );
    });

    test('允许系统明确选中的虚拟声卡', () {
      expect(
        PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
          devices: devices,
          systemDeviceName: virtual.name,
          capture: false,
        ),
        3,
      );
    });

    test('端点缺失、方向错误或重名时不回退到其他声卡', () {
      for (final name in [null, '', '已拔出的耳机', microphone.name]) {
        expect(
          PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
            devices: devices,
            systemDeviceName: name,
            capture: false,
          ),
          isNull,
        );
      }
      expect(
        PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
          devices: [speaker, speaker],
          systemDeviceName: speaker.name,
          capture: false,
        ),
        isNull,
      );
    });

    test('设备重新枚举后使用新索引', () {
      const movedSpeaker = PjsipAudioDevice(
        id: 7,
        name: 'MacBook Pro扬声器',
        driver: 'core audio',
        inputCount: 0,
        outputCount: 2,
        defaultSampleRate: 48000,
      );
      expect(
        PjsipAudioDevicePolicy.resolveSystemEndpointDeviceId(
          devices: [virtual, microphone, movedSpeaker],
          systemDeviceName: speaker.name,
          capture: false,
        ),
        7,
      );
    });
  });

  test('系统音频路由解析输入和输出端点', () {
    final route = SystemAudioRoute.fromMap({
      'input': {'id': 'input-1', 'name': 'MacBook Pro麦克风'},
      'output': {'id': 'output-1', 'name': 'MacBook Pro扬声器'},
    });

    expect(route?.input?.name, 'MacBook Pro麦克风');
    expect(route?.output?.name, 'MacBook Pro扬声器');
    expect(route?.signature, 'input-1|output-1');
  });

  test('系统暂时没有端点时仍保留空路由状态', () {
    final route = SystemAudioRoute.fromMap(const <String, Object?>{});

    expect(route, isNotNull);
    expect(route?.input, isNull);
    expect(route?.output, isNull);
    expect(route?.signature, '|');
  });

  test('跟随系统模式不会根据具体设备特征改选端点', () {
    const defaultInput = PjsipAudioDevice(
      id: -1,
      name: '跟随系统输入',
      driver: 'default',
      inputCount: 1,
      outputCount: 0,
      defaultSampleRate: 0,
    );
    const defaultOutput = PjsipAudioDevice(
      id: -2,
      name: '跟随系统输出',
      driver: 'default',
      inputCount: 0,
      outputCount: 1,
      defaultSampleRate: 0,
    );
    const display = PjsipAudioDevice(
      id: 3,
      name: 'DELL U2414H',
      driver: 'core audio',
      inputCount: 2,
      outputCount: 2,
      defaultSampleRate: 48000,
    );

    final choice = PjsipAudioDevicePolicy.choose(
      captureDevices: const [defaultInput, display],
      playbackDevices: const [defaultOutput, display],
      currentCaptureId: 3,
      currentPlaybackId: 3,
      mode: PjsipAudioDeviceMode.automatic,
      preferredCaptureSignature: null,
      preferredPlaybackSignature: null,
      hasAnyCall: true,
      allowInCallAutomaticSwitch: true,
    );

    expect(choice.captureDeviceId, -1);
    expect(choice.playbackDeviceId, -2);
    expect(choice.shouldSwitch, isTrue);
  });
}
