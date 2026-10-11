import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/account/view/widgets/paged_sliver_list.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

const _pageSize = 3;

/// [pages] 를 그대로 보여주는 화면. 콜백 호출을 [loadMore]·[retried] 에 기록한다.
Widget _host(
  List<AsyncValue<List<int>>> pages, {
  List<int>? loadMore,
  List<int>? retried,
}) {
  return MaterialApp(
    theme: NbkTheme.light,
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          PagedSliverList<int>(
            pages: pages,
            pageSize: _pageSize,
            itemBuilder: (item) => SizedBox(height: 40, child: Text('항목 $item')),
            empty: const Text('비어 있음'),
            skeleton: const SkeletonBox(height: 40),
            onLoadMore: () => loadMore?.add(1),
            onRetry: (page) => retried?.add(page),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('PagedSliverList', () {
    testWidgets('첫 페이지가 로딩 중이면 스켈레톤만 보여준다', (tester) async {
      await tester.pumpWidget(_host([const AsyncLoading()]));
      await tester.pump();

      expect(find.byType(SkeletonBox), findsNWidgets(3));
      expect(find.textContaining('항목'), findsNothing);
    });

    testWidgets('첫 페이지가 실패하면 오류 상태를 보여주고 다시 시도는 0 페이지를 받는다', (tester) async {
      final retried = <int>[];
      await tester.pumpWidget(_host(
        [AsyncError(const ApiOffline(), StackTrace.empty)],
        retried: retried,
      ));
      await tester.pump();

      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text(Strings.retry));
      expect(retried, [0]);
    });

    testWidgets('첫 페이지가 비어 있으면 빈 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_host([const AsyncData([])]));
      await tester.pump();

      expect(find.text('비어 있음'), findsOneWidget);
    });

    testWidgets('여러 페이지의 항목을 offset 순서 그대로 위에서 아래로 보여준다', (tester) async {
      await tester.pumpWidget(
        _host([const AsyncData([1, 2, 3]), const AsyncData([4, 5])]),
      );
      await tester.pump();

      final tops = [for (var i = 1; i <= 5; i++) tester.getTopLeft(find.text('항목 $i')).dy];
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], greaterThan(tops[i - 1]), reason: '항목 ${i + 1} 은 항목 $i 아래에 있어야 한다');
      }
    });

    testWidgets('중간 페이지가 실패하면 그 앞 항목만 보여주고 실패한 페이지를 다시 시도한다', (tester) async {
      final retried = <int>[];
      await tester.pumpWidget(_host(
        [
          const AsyncData([1, 2, 3]),
          AsyncError(const ApiOffline(), StackTrace.empty),
          const AsyncData([7, 8]),
        ],
        retried: retried,
      ));
      await tester.pump();

      expect(find.text('항목 3'), findsOneWidget);
      expect(find.text('항목 7'), findsNothing);
      expect(find.byType(ErrorState), findsNothing);
      await tester.tap(find.text(Strings.retry));
      expect(retried, [1]);
    });

    testWidgets('중간 페이지가 로딩 중이면 그 앞 항목과 스켈레톤 한 행을 보여주고 더 받지 않는다', (tester) async {
      final loadMore = <int>[];
      await tester.pumpWidget(_host(
        [const AsyncData([1, 2, 3]), const AsyncLoading(), const AsyncData([7, 8, 9])],
        loadMore: loadMore,
      ));
      await tester.pump();

      expect(find.text('항목 3'), findsOneWidget);
      expect(find.text('항목 7'), findsNothing);
      expect(find.byType(SkeletonBox), findsOneWidget);
      expect(loadMore, isEmpty);
    });

    testWidgets('마지막 페이지가 꽉 차 있으면 끝이 보일 때 onLoadMore 를 한 번 부른다', (tester) async {
      final loadMore = <int>[];
      await tester.pumpWidget(_host([const AsyncData([1, 2, 3])], loadMore: loadMore));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoadMoreTrigger), findsOneWidget);
      expect(loadMore, [1]);
    });

    testWidgets('마지막 페이지가 덜 차 있으면 더 받지 않는다', (tester) async {
      final loadMore = <int>[];
      await tester.pumpWidget(
        _host([const AsyncData([1, 2, 3]), const AsyncData([4])], loadMore: loadMore),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('항목 4'), findsOneWidget);
      expect(find.byType(LoadMoreTrigger), findsNothing);
      expect(loadMore, isEmpty);
    });
  });
}
