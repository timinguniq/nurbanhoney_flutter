import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/skeleton.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: NbkTheme.light, home: Scaffold(body: child));

void main() {
  group('스켈레톤', () {
    testWidgets('320dp 폭에서도 넘치지 않는다', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(const Shimmer(
        child: Column(
          children: [
            PostItemSkeleton(),
            RankRowSkeleton(),
            PodiumSkeleton(),
            Align(alignment: Alignment.centerLeft, child: Top3CardSkeleton()),
          ],
        ),
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(RankRowSkeleton), findsOneWidget);
    });

    testWidgets('Shimmer 는 애니메이션이 돌아도 자식을 그대로 보여준다', (tester) async {
      await tester.pumpWidget(_wrap(const Shimmer(child: SkeletonBox(width: 80))));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SkeletonBox), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
