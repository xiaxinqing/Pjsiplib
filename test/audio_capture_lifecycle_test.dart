import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/generated/pjsip_bindings.g.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

void main() {
  CallInfo call({
    int id = 1,
    required pjsip_inv_state state,
    pjsua_call_media_status? media,
    bool held = false,
  }) => CallInfo(
    callId: id,
    state: state.value,
    remoteUri: 'sip:test@example.invalid',
    mediaStatus: media?.value,
    isOnHold: held,
  );

  bool needsCapture(List<CallInfo> calls, {bool recording = false}) =>
      PjsipAudioDevicePolicy.requiresCapture(
        calls: calls,
        microphoneRecording: recording,
      );

  test('空闲按键、来电响铃和本地回铃不打开麦克风', () {
    expect(needsCapture([]), isFalse);
    for (final state in [
      pjsip_inv_state.PJSIP_INV_STATE_INCOMING,
      pjsip_inv_state.PJSIP_INV_STATE_CALLING,
      pjsip_inv_state.PJSIP_INV_STATE_EARLY,
    ]) {
      expect(needsCapture([call(state: state)]), isFalse);
    }
  });

  test('早期媒体、接通及保持期间保留双向音频', () {
    expect(
      needsCapture([
        call(
          state: pjsip_inv_state.PJSIP_INV_STATE_EARLY,
          media: pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE,
        ),
      ]),
      isTrue,
    );
    for (final held in [false, true]) {
      expect(
        needsCapture([
          call(state: pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED, held: held),
        ]),
        isTrue,
      );
    }
  });

  test('通话中等待音不降级；最后一路结束后释放输入', () {
    final active = call(state: pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED);
    final waiting = call(
      id: 2,
      state: pjsip_inv_state.PJSIP_INV_STATE_INCOMING,
    );
    expect(needsCapture([active, waiting]), isTrue);
    expect(needsCapture([waiting]), isFalse);
    expect(needsCapture([]), isFalse);
    expect(
      needsCapture([
        active.copyWith(
          state: pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED.value,
          mediaStatus: pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE.value,
        ),
      ]),
      isFalse,
    );
  });

  test('麦克风测试只在录音阶段需要输入，回放只需要输出', () {
    expect(needsCapture([], recording: true), isTrue);
    expect(needsCapture([], recording: false), isFalse);
    expect(
      needsCapture([
        call(state: pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED),
      ], recording: false),
      isTrue,
    );
  });
}
