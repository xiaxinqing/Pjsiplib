import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pjsip_lib/main.dart';
import 'package:pjsip_lib/src/services/pjsip_service.dart';

class FakePjsipService extends PjsipService {
  @override
  PjsipUIState build() => PjsipUIState(logs: []);
}

void main() {
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
