import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/home/view/widgets/top3_section.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

RankType _rank(int id, {required int loss, required int likes}) => (
      id: id,
      totalLossCut: loss,
      totalLikeCount: likes,
      userId: id,
      badge: null,
      nickname: '사용자$id',
      insignia: '[]',
    );

Widget _app({List<RankType>? ranks, Object? error, List<int>? calls}) {
  return ProviderScope(
    overrides: [
      getRankTabProvider.overrideWith((ref, arg) async {
        calls?.add(arg.offset);
        if (error != null) throw error;
        return ranks ?? [];
      }),
    ],
    child: MaterialApp(
      theme: NbkTheme.light,
      home: const Scaffold(body: SingleChildScrollView(child: Top3Section())),
    ),
  );
}

void main() {
  group('Top3Section', () {
    testWidgets('응답 순서대로 1·2·3위 카드를 만들고 추천 수에는 totalLikeCount 를 쓴다', (tester) async {
      await tester.pumpWidget(_app(ranks: [
        _rank(7, loss: 12480000, likes: 128),
        _rank(8, loss: 8900000, likes: 51),
        _rank(9, loss: 1200000, likes: 3),
      ]));
      await tester.pump();

      expect(find.text(Strings.rankLabel(1)), findsOneWidget);
      expect(find.text(Strings.rankLabel(2)), findsOneWidget);
      expect(find.text(Strings.rankLabel(3)), findsOneWidget);
      expect(find.text(Strings.rankLabel(7)), findsNothing);
      expect(find.text('-12,480,000원'), findsOneWidget);
      expect(find.text(Strings.recommend('128')), findsOneWidget);
      expect(find.text(Strings.recommend('12,480,000')), findsNothing);
      expect(find.byType(Top3Card), findsNWidgets(3));
    });

    testWidgets('랭킹이 비면 점선 박스 안내를 보여준다', (tester) async {
      await tester.pumpWidget(_app(ranks: []));
      await tester.pump();

      expect(find.byType(DashedBox), findsOneWidget);
      expect(find.text(Strings.top3Empty), findsOneWidget);
      expect(find.byType(Top3Card), findsNothing);
    });

    testWidgets('받지 못하면 안내와 다시 시도를 보여주고, 누르면 다시 받는다', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(_app(error: const ApiOffline(), calls: calls));
      await tester.pump();

      expect(find.text(Strings.top3Error), findsOneWidget);
      await tester.tap(find.text(Strings.retry));
      await tester.pump();
      expect(calls, [0, 0]);
    });

    testWidgets('전체보기를 누르면 하단 탭을 랭킹으로 바꾼다', (tester) async {
      await tester.pumpWidget(_app(ranks: []));
      await tester.pump();

      await tester.tap(find.text(Strings.seeAll));
      final container = ProviderScope.containerOf(tester.element(find.byType(Top3Section)));
      expect(container.read(homeBottomNavigationProvider), HomeBottomStatus.rank);
    });
  });
}
