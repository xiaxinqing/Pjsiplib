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

  test('多线路状态可以记录默认外呼线路', () {
    final account6523 = SipAccountInfo(
      accId: 0,
      username: '6523',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
    );
    final account6529 = SipAccountInfo(
      accId: 1,
      username: '6529',
      host: '139.59.100.15',
      registrationStatus: 200,
      registrationStatusText: 'OK',
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {0: account6523, 1: account6529},
      defaultAccountId: 1,
      accId: 1,
      host: account6529.host,
    );

    expect(state.accounts.length, 2);
    expect(state.defaultAccount?.username, '6529');
    expect(state.hasRegisteredAccount, isTrue);
  });

  test('通话可以关联到具体线路', () {
    final account = SipAccountInfo(
      accId: 7,
      username: '售后',
      host: 'pbx.example.com',
    );
    final call = CallInfo(
      callId: 3,
      state: 2,
      remoteUri: 'sip:10086@pbx.example.com',
      accountId: 7,
    );
    final state = PjsipUIState(
      logs: [],
      accounts: {7: account},
      calls: {3: call},
    );

    expect(state.accountForCall(call)?.username, '售后');
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
