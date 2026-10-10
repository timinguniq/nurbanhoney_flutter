import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/article_create/view/widgets/loss_amount_field.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

void main() {
  group('LossAmountField', () {
    testWidgets('입력하면 콤마가 붙어 보이고 onChanged 에는 숫자만 전달되며 한글 금액이 보조 표기된다', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final received = <String>[];
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: Scaffold(
          body: LossAmountField(controller: controller, onChanged: received.add),
        ),
      ));

      await tester.enterText(find.byType(TextField), '1250000');
      await tester.pump();

      expect(controller.text, '1,250,000');
      expect(received.last, '1250000');
      expect(find.text('백이십오만 원'), findsOneWidget);
    });

    testWidgets('비어 있으면 안내 문구를 보여주고 onChanged 에 빈 문자열을 전달한다', (tester) async {
      final controller = TextEditingController(text: '1,000');
      addTearDown(controller.dispose);
      final received = <String>[];
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: Scaffold(
          body: LossAmountField(controller: controller, onChanged: received.add),
        ),
      ));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(received.last, '');
      expect(find.text(Strings.lossHelper), findsOneWidget);
    });
  });
}
