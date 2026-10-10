import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/reaction_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: NbkTheme.light, home: Scaffold(body: Center(child: child)));

void main() {
  group('ReactionButton', () {
    testWidgets('미선택 좋아요는 외곽선 아이콘과 text3 카운트다', (tester) async {
      await tester.pumpWidget(_wrap(ReactionButton.like(
        count: 34,
        selected: false,
        onTap: () {},
      )));

      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      expect(tester.widget<Text>(find.text('34')).style?.color, NbkColors.text3);
    });

    testWidgets('선택한 좋아요는 채운 꿀색 아이콘과 honeyDeep 카운트다', (tester) async {
      await tester.pumpWidget(_wrap(ReactionButton.like(
        count: 35,
        selected: true,
        onTap: () {},
      )));

      final icon = tester.widget<Icon>(find.byIcon(Icons.thumb_up));
      expect(icon.color, NbkColors.honey);
      expect(tester.widget<Text>(find.text('35')).style?.color, NbkColors.honeyDeep);
    });

    testWidgets('선택한 싫어요는 loss 색이다', (tester) async {
      await tester.pumpWidget(_wrap(ReactionButton.dislike(
        count: 4,
        selected: true,
        onTap: () {},
      )));

      expect(tester.widget<Icon>(find.byIcon(Icons.thumb_down)).color, NbkColors.loss);
      expect(tester.widget<Text>(find.text('4')).style?.color, NbkColors.loss);
    });

    testWidgets('필 형태는 라벨을 붙이고 누르면 onTap 이 불린다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(ReactionButton.like(
        count: 35,
        selected: false,
        pill: true,
        onTap: () => taps++,
      )));

      await tester.tap(find.text('좋아요 35'));
      expect(taps, 1);
    });

    testWidgets('카운트는 천 단위 콤마를 붙인다', (tester) async {
      await tester.pumpWidget(_wrap(ReactionButton.like(
        count: 1234,
        selected: false,
        onTap: () {},
      )));

      expect(find.text('1,234'), findsOneWidget);
    });
  });
}
