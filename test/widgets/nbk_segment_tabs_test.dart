import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_segment_tabs.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: NbkTheme.light, home: Scaffold(body: child));

void main() {
  group('NbkSegmentTabs', () {
    testWidgets('탭을 누르면 그 인덱스로 onChanged 가 불린다', (tester) async {
      int? changed;
      await tester.pumpWidget(_wrap(NbkSegmentTabs(
        labels: const ['주식', '코인'],
        index: 0,
        onChanged: (i) => changed = i,
      )));

      await tester.tap(find.text('코인'));
      expect(changed, 1);
    });

    testWidgets('활성 탭은 text1 굵게, 비활성은 text3 이다', (tester) async {
      await tester.pumpWidget(_wrap(NbkSegmentTabs(
        labels: const ['주식', '코인'],
        index: 0,
        onChanged: (_) {},
      )));

      final active = tester.widget<Text>(find.text('주식'));
      final inactive = tester.widget<Text>(find.text('코인'));
      expect(active.style?.color, NbkColors.text1);
      expect(active.style?.fontWeight, FontWeight.w700);
      expect(inactive.style?.color, NbkColors.text3);
    });

    testWidgets('활성 탭에만 꿀색 언더라인이 있다', (tester) async {
      await tester.pumpWidget(_wrap(NbkSegmentTabs(
        labels: const ['주식', '코인'],
        index: 0,
        onChanged: (_) {},
      )));

      Color underlineOf(String label) {
        final container = tester.widget<Container>(find.ancestor(
          of: find.text(label),
          matching: find.byType(Container),
        ).first);
        final border = (container.decoration as BoxDecoration).border as Border;
        return border.bottom.color;
      }

      expect(underlineOf('주식'), NbkColors.honey);
      expect(underlineOf('코인'), Colors.transparent);
    });

    testWidgets('카운트가 있으면 라벨 뒤에 붙는다', (tester) async {
      await tester.pumpWidget(_wrap(NbkSegmentTabs(
        labels: const ['내 글', '내 댓글'],
        counts: const [12, 48],
        index: 1,
        onChanged: (_) {},
      )));

      expect(find.text('내 글 12'), findsOneWidget);
      expect(find.text('내 댓글 48'), findsOneWidget);
    });
  });
}
