import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/services/pjsip_service.dart';

class _SeatService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(
    logs: [],
    isInitialized: true,
    accounts: {
      for (final id in [1, 2])
        id: SipAccountInfo(accId: id, username: 'test$id', host: 'localhost'),
    },
  );

  void clearEngineState() {
    state = state.copyWith(accounts: {}, isInitialized: false);
  }
}

void main() {
  testWidgets('线路等待保存时关闭引擎，仍保存触发写入时的账号及顺序', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [pjsipServiceProvider.overrideWith(_SeatService.new)],
    );
    addTearDown(container.dispose);
    final service =
        container.read(pjsipServiceProvider.notifier) as _SeatService;
    service.reorderAccounts([2, 1]);
    service.clearEngineState();
    await tester.pump(const Duration(milliseconds: 100));
    final raw = await const FlutterSecureStorage().read(
      key: 'veserve_seat_environment_v1',
    );
    final lines = jsonDecode(raw!)['lines'] as List;
    expect(lines.map((line) => line['username']), ['test2', 'test1']);
  });
}
