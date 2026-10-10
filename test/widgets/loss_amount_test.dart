import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/loss_amount.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: NbkTheme.light, home: Scaffold(body: child));

void main() {
  group('LossAmount', () {
    testWidgets('마이너스·콤마·원 형식으로 손실 색을 써서 보여준다', (tester) async {
      await tester.pumpWidget(_wrap(const LossAmount(amount: 1250000)));

      final text = tester.widget<Text>(find.text('-1,250,000원'));
      expect(text.style?.color, NbkColors.loss);
      expect(text.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('compact 면 만원 단위로 줄인다', (tester) async {
      await tester.pumpWidget(
        _wrap(const LossAmount(amount: 12480000, compact: true)),
      );
      expect(find.text('-1,248만원'), findsOneWidget);
    });

    testWidgets('크기에 따라 글자 크기가 달라진다', (tester) async {
      await tester.pumpWidget(_wrap(const Column(children: [
        LossAmount(amount: 1, size: LossAmountSize.detail),
        LossAmount(amount: 2, size: LossAmountSize.caption),
      ])));

      final detail = tester.widget<Text>(find.text('-1원'));
      final caption = tester.widget<Text>(find.text('-2원'));
      expect(detail.style?.fontSize, NbkTypography.lossDetail.fontSize);
      expect(caption.style?.fontSize, NbkTypography.lossCaption.fontSize);
    });
  });
}
