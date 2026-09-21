import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/generated/pjsip_bindings.g.dart';

// 显式运行：VPHONE_RUN_NATIVE_AUDIO_TESTS=1 flutter test
//   --no-pub test/native_audio_startup_test.dart
// 验证真实 PJSIP 的声卡生命周期，不注册账号、不打开麦克风或播放声音。
void main() {
  test(
    '原生启动保留默认编号但声卡未打开；no-sound 阻止提示音连接隐式打开设备',
    () {
      final dylib = ffi.DynamicLibrary.open(
        '${Directory.current.path}/macos/Frameworks/libpjsip.dylib',
      );
      dylib.lookupFunction<ffi.Void Function(ffi.Int), void Function(int)>(
        'pj_log_set_level',
      )(0);
      final bindings = PjsipBindings(dylib);
      expect(bindings.pjsua_create(), 0);
      try {
        using((arena) {
          final ua = arena<pjsua_config>();
          final logging = arena<pjsua_logging_config>();
          final media = arena<pjsua_media_config>();
          bindings.pjsua_config_default(ua);
          bindings.pjsua_logging_config_default(logging);
          bindings.pjsua_media_config_default(media);
          ua.ref.max_calls = 4;
          logging.ref.level = 0;
          logging.ref.console_level = 0;
          logging.ref.msg_logging = 0;
          media.ref.clock_rate = 8000;
          media.ref.channel_count = 1;
          media.ref.ec_tail_len = 20;
          media.ref.ec_options = 64;
          expect(bindings.pjsua_init(ua, logging, media), 0);
          expect(bindings.pjsua_start(), 0);

          final capture = arena<ffi.Int>();
          final playback = arena<ffi.Int>();
          expect(bindings.pjsua_get_snd_dev(capture, playback), 0);
          // 这正是不能通过“编号不等于 NO_DEV”判定已打开声卡的原生状态。
          expect(capture.value, -1);
          expect(playback.value, -2);
          expect(bindings.pjsua_snd_is_active(), 0);

          bindings.pjsua_set_no_snd_dev();
          final filename = arena<pj_str_t>();
          final bytes = '${Directory.current.path}/assets/audio/ringtone.wav'
              .toNativeUtf8(allocator: arena);
          filename.ref.ptr = bytes.cast<ffi.Char>();
          filename.ref.slen = bytes.length;
          final player = arena<pjsua_player_id>();
          expect(bindings.pjsua_player_create(filename, 0, player), 0);
          try {
            final slot = bindings.pjsua_player_get_conf_port(player.value);
            expect(slot, greaterThanOrEqualTo(0));
            expect(bindings.pjsua_conf_connect(slot, 0), 0);
            expect(bindings.pjsua_snd_is_active(), 0);
            expect(bindings.pjsua_get_snd_dev(capture, playback), 0);
            expect(capture.value, pjsua_snd_dev_id.PJSUA_SND_NO_DEV.value);
            expect(playback.value, pjsua_snd_dev_id.PJSUA_SND_NO_DEV.value);
          } finally {
            bindings.pjsua_player_destroy(player.value);
          }
        });
      } finally {
        bindings.pjsua_destroy();
      }
    },
    skip:
        !Platform.isMacOS ||
        Platform.environment['VPHONE_RUN_NATIVE_AUDIO_TESTS'] != '1',
  );
}
