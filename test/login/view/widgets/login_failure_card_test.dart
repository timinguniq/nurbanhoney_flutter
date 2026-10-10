import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/login/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';

void main() {
  group('LoginFailureCard', () {
    testWidgets('제목·원인을 보여주고 dangerTint 배경에 dangerLine 테두리, 아이콘은 20 이다', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: const Scaffold(
          body: LoginFailureCard(title: '카카오 로그인에 실패했어요', reason: '다시 시도해 주세요.'),
        ),
      ));

      expect(find.text('카카오 로그인에 실패했어요'), findsOneWidget);
      expect(find.text('다시 시도해 주세요.'), findsOneWidget);

      final decoration = tester
          .widget<Container>(find.descendant(
            of: find.byType(LoginFailureCard),
            matching: find.byType(Container),
          ))
          .decoration! as BoxDecoration;
      expect(decoration.color, NbkColors.dangerTint);
      // 테두리 색은 design/login-error.png 에서 잰 값으로 고정한다(토큰 값이 바뀌면 디자인과 어긋난다).
      expect(decoration.border, Border.all(color: const Color(0xFFF5C6C2)));
      expect(decoration.borderRadius, BorderRadius.circular(NbkRadius.card));

      // 아이콘 20, 아이콘과 글 사이 10 (design/login-error.png)
      final icon = find.byIcon(Icons.error_outline);
      expect(tester.getSize(icon), const Size(20, 20));
      expect(tester.widget<Icon>(icon).color, NbkColors.danger);
      expect(tester.getRect(find.text('카카오 로그인에 실패했어요')).left - tester.getRect(icon).right, 10);
    });

    testWidgets('원인이 길면 줄을 바꿔 카드 안에 머문다(넘침 없음)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: LoginFailureCard(title: '실패', reason: '아주 ' * 40),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(LoginFailureCard));
      final reason = tester.getRect(find.text('아주 ' * 40));
      expect(reason.right, lessThanOrEqualTo(card.right));
      expect(reason.bottom, lessThanOrEqualTo(card.bottom));
    });
  });
}
