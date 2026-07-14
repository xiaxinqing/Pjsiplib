import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pjsip_lib/main.dart';
import 'package:pjsip_lib/src/services/pjsip_service.dart';

class FakePjsipService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: []);
}

void main() {
  test('网络恢复状态可以独立记录', () {
    final offline = PjsipUIState(logs: []).copyWith(
      isNetworkAvailable: false,
      networkState: PjsipNetworkState.offline,
    );

    expect(offline.isNetworkAvailable, isFalse);
    expect(offline.networkState, PjsipNetworkState.offline);
  });

  test('会议暂停时保留原会议成员和中断通话', () {
    final state = PjsipUIState(
      logs: [],
      conferenceCallIds: const {1, 2},
      isConferencePaused: true,
      conferenceInterruptionCallId: 3,
      activeCallId: 3,
    );

    expect(state.hasConference, isTrue);
    expect(state.isConferenceActive, isFalse);
    expect(state.isInConference(1), isTrue);
    expect(state.conferenceInterruptionCallId, 3);
  });

  test('断开连接时账号状态应回到未登录', () {
    final disconnected = PjsipUIState(
      logs: [],
      isInitialized: true,
      accId: 0,
      host: '139.59.100.15',
    ).copyWith(isInitialized: false, accId: -1, host: '');

    expect(disconnected.isInitialized, isFalse);
    expect(disconnected.accId, -1);
    expect(disconnected.host, isEmpty);
  });

  testWidgets('VoIP 主界面可以正常构建', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pjsipServiceProvider.overrideWith(FakePjsipService.new)],
        child: const MyApp(),
      ),
    );

    expect(find.text('VoIP Desk'), findsOneWidget);
    expect(find.text('拨号'), findsWidgets);
    expect(find.text('设置'), findsOneWidget);
  });
}
