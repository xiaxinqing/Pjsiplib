import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veserve_vphone/src/ui/home/calls/stage/in_call_dtmf_popover.dart';

void main() {
  testWidgets('独立 DTMF 浮层通过回调发送按键并关闭', (tester) async {
    final controller = OverlayPortalController();
    final anchorLink = LayerLink();
    final tapRegionGroupId = Object();
    String? pressedDigit;
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: OverlayPortal(
                controller: controller,
                overlayChildBuilder: (context) => InCallDtmfPopover(
                  anchorLink: anchorLink,
                  tapRegionGroupId: tapRegionGroupId,
                  title: 'DTMF keypad',
                  closeTooltip: 'Close keypad',
                  previewText: 'Waiting for input',
                  previewActive: false,
                  statusText: null,
                  statusFailed: false,
                  onDismiss: () {
                    dismissed = true;
                    controller.hide();
                  },
                  onDigitPressed: (digit) => pressedDigit = digit,
                ),
                child: TapRegion(
                  groupId: tapRegionGroupId,
                  child: CompositedTransformTarget(
                    link: anchorLink,
                    child: FilledButton(
                      onPressed: controller.show,
                      child: const Text('Open keypad'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open keypad'));
    await tester.pump();
    expect(find.text('DTMF keypad'), findsOneWidget);

    await tester.tap(find.text('5'));
    expect(pressedDigit, '5');

    await tester.tap(find.byTooltip('Close keypad'));
    await tester.pump();
    expect(dismissed, isTrue);
    expect(find.text('DTMF keypad'), findsNothing);
  });
}
