import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: NbkTheme.light, home: Scaffold(body: Center(child: child)));

void main() {
  group('NbkButton', () {
    testWidgets('누르면 onPressed 가 불린다', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(NbkButton(
        label: '완료',
        onPressed: () => pressed++,
      )));

      await tester.tap(find.text('완료'));
      expect(pressed, 1);
    });

    testWidgets('onPressed 가 null 이면 비활성이라 눌리지 않는다', (tester) async {
      await tester.pumpWidget(_wrap(const NbkButton(label: '완료', onPressed: null)));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('loading 이면 라벨 대신 스피너를 보여주고 눌리지 않는다', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(NbkButton(
        label: '카카오로 로그인',
        loading: true,
        onPressed: () => pressed++,
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('카카오로 로그인'), findsNothing);
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(pressed, 0);
    });

    testWidgets('크기에 따라 높이가 정해진다', (tester) async {
      await tester.pumpWidget(_wrap(const Column(children: [
        NbkButton(label: 'a', onPressed: null, size: NbkButtonSize.large),
        NbkButton(label: 'b', onPressed: null, size: NbkButtonSize.small),
      ])));

      expect(tester.getSize(find.widgetWithText(ElevatedButton, 'a')).height,
          NbkSize.buttonLg);
      expect(tester.getSize(find.widgetWithText(ElevatedButton, 'b')).height,
          NbkSize.pillButton);
    });
  });
}
