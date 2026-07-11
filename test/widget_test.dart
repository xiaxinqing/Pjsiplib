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

  testWidgets('VoIP 主界面可以正常构建', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pjsipServiceProvider.overrideWith(FakePjsipService.new)],
        child: const MyApp(),
      ),
    );

    expect(find.text('VoIP 调试终端 (PJSIP)'), findsOneWidget);
    expect(find.text('初始化 PJSIP'), findsOneWidget);
    expect(find.text('运行日志'), findsOneWidget);
  });
}
