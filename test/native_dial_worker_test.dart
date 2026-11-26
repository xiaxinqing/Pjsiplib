import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/generated/pjsip_bindings.g.dart';
import 'package:veserve_vphone/src/services/native_bridge/pjsip_dial_worker.dart';

void main() {
  // Use the packaged library for the host platform. Both lines use loopback.
  final path = Platform.environment['VPHONE_TEST_DIAL_LIBRARY'];
  test('工作线程用所选线路发送 INVITE，关闭时送达已提交请求的结果', () async {
    final library = ffi.DynamicLibrary.open(path!);
    final sip = PjsipBindings(library);
    final peer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final from = Completer<String>();
    final sockets = <Socket>[];
    peer.listen((socket) {
      sockets.add(socket);
      socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('From:') && !from.isCompleted) {
              from.complete(line);
            }
          });
    });
    addTearDown(() async {
      for (final socket in sockets) {
        socket.destroy();
      }
      await peer.close();
    });
    expect(sip.pjsua_create(), 0);
    addTearDown(sip.pjsua_destroy);
    final selected = using((arena) {
      final ua = arena<pjsua_config>();
      final media = arena<pjsua_media_config>();
      final log = arena<pjsua_logging_config>();
      sip.pjsua_config_default(ua);
      sip.pjsua_media_config_default(media);
      sip.pjsua_logging_config_default(log);
      log.ref.console_level = 0;
      expect(sip.pjsua_init(ua, log, media), 0);
      final transport = arena<pjsua_transport_config>();
      sip.pjsua_transport_config_default(transport);
      final id = arena<ffi.Int>();
      expect(
        sip.pjsua_transport_create(
          pjsip_transport_type_e.PJSIP_TRANSPORT_TCP,
          transport,
          id,
        ),
        0,
      );
      expect(sip.pjsua_start(), 0);
      sip.pjsua_set_no_snd_dev();
      final defaultLine = arena<ffi.Int>();
      final selectedLine = arena<ffi.Int>();
      for (final (number, line) in [
        ('6523', defaultLine),
        ('6524', selectedLine),
      ]) {
        final cfg = arena<pjsua_acc_config>();
        sip.pjsua_acc_config_default(cfg);
        final uri = 'sip:$number@127.0.0.1'.toNativeUtf8(allocator: arena);
        cfg.ref.id.ptr = uri.cast();
        cfg.ref.id.slen = uri.length;
        expect(sip.pjsua_acc_add(cfg, number == '6523' ? 1 : 0, line), 0);
      }
      expect(selectedLine.value, isNot(defaultLine.value));
      return selectedLine.value;
    });
    final worker = PjsipDialWorker(library);
    addTearDown(worker.close);
    final uri = 'sip:1001@127.0.0.1:${peer.port};transport=tcp';
    final result = await worker.dial(selected, uri, tls: false);
    expect(result.status, 0);
    expect(result.callId, greaterThanOrEqualTo(0));
    expect(
      await from.future.timeout(const Duration(seconds: 5)),
      contains('sip:6524@'),
    );
    final failure = worker.dial(42, uri, tls: false);
    worker.close();
    final rejected = await failure.timeout(const Duration(seconds: 2));
    expect(rejected.status, isNot(0));
    expect(rejected.callId, -1);
  }, skip: path == null);
}
