import 'dart:async';

import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/home/view/widgets/board_tab_view.dart';
import 'package:nurbanhoney/home/view/widgets/losscut_fab.dart';
import 'package:nurbanhoney/home/view/widgets/post_list_item.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class _FakeNurbanRepository implements NurbanRepository {
  _FakeNurbanRepository({this.createFailure});

  /// 있으면 좋아요 생성이 이 실패를 던진다
  final ApiFailure? createFailure;
  final likes = <(int, bool)>[];

  @override
  Future<int> nurbanLikeCreate({required int articleId}) async {
    likes.add((articleId, true));
    final failure = createFailure;
    if (failure != null) throw failure;
    return 35;
  }

  @override
  Future<int> nurbanLikeDelete({required int articleId}) async {
    likes.add((articleId, false));
    return 33;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BoardAllType _post(int id, {Reaction myReaction = Reaction.none, int likeCount = 34}) => (
      id: id,
      board: 2,
      thumbnail: null,
      title: '글 $id',
      lossCut: id * 1000,
      content: '본문 $id',
      commentCount: id,
      likeCount: likeCount,
      createdAt: '2026-10-10T10:00:00.000Z',
      userId: 1,
      nickname: '작성자 $id',
      badge: null,
      insignia: '[]',
      myReaction: myReaction,
    );

Widget _app({
  required DataFetchStatus fetchState,
  List<BoardAllType> items = const [],
  bool hasNextPage = false,
  List<int>? refreshes,
  List<int>? loadMores,
  NurbanRepository? repository,
  Future<void> Function()? onRefresh,
}) {
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      getRankTabProvider.overrideWith((ref, arg) async => []),
      if (repository != null) nurbanRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: BoardTabView(
        board: 2,
        fetchState: fetchState,
        items: items,
        hasNextPage: hasNextPage,
        onRefresh: onRefresh ?? () async => refreshes?.add(1),
        onLoadMore: () => loadMores?.add(1),
      ),
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 3]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(NbkToast.hide);

  group('BoardTabView', () {
    testWidgets('첫 로딩이면 스켈레톤을 보여주고 FAB 는 없다', (tester) async {
      await tester.pumpWidget(_app(fetchState: DataFetching()));
      await _pumpFrames(tester);

      expect(find.byType(PostItemSkeleton), findsNWidgets(2));
      expect(find.byType(LossCutFab), findsNothing);
    });

    testWidgets('목록이 비면 빈 상태와 첫 글 쓰기 CTA 를 보여주고 FAB 는 없다', (tester) async {
      await tester.pumpWidget(_app(fetchState: DataFetchSuccess()));
      await _pumpFrames(tester);

      expect(find.text(Strings.homeEmptyTitle(Strings.boardCoin)), findsOneWidget);
      expect(find.text(Strings.firstPostCta), findsOneWidget);
      expect(find.byType(LossCutFab), findsNothing);
    });

    testWidgets('네트워크 오류면 오프라인 배너와 오류 상태를 보여주고 다시 시도는 새로 받는다', (tester) async {
      final refreshes = <int>[];
      await tester.pumpWidget(_app(
        fetchState: DataFetchError(const ApiOffline()),
        refreshes: refreshes,
      ));
      await _pumpFrames(tester);

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byType(LossCutFab), findsNothing);
      await tester.tap(find.text(Strings.retry));
      expect(refreshes, [1]);
    });

    testWidgets('네트워크 오류가 아니면 오프라인 배너는 없다', (tester) async {
      await tester.pumpWidget(_app(
        fetchState: DataFetchError(const ApiHttpFailure(status: 500)),
      ));
      await _pumpFrames(tester);

      expect(find.byType(OfflineBanner), findsNothing);
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('글이 있으면 아이템과 FAB 를 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1), _post(2)],
      ));
      await _pumpFrames(tester);

      expect(find.text('글 1'), findsOneWidget);
      expect(find.text('글 2'), findsOneWidget);
      expect(find.text('-2,000원'), findsOneWidget);
      expect(find.byType(LossCutFab), findsOneWidget);
    });

    testWidgets('서버가 좋아요를 거절하면 오류 토스트를 띄우고 상태·수를 유지하며 다시 누를 수 있다', (tester) async {
      SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
      final repository = _FakeNurbanRepository(createFailure: const ApiServerFailure('already_liked'));
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1)],
        repository: repository,
      ));
      await _pumpFrames(tester);

      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);

      expect(find.text(Strings.toastLikeFailed), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isFalse);

      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);
      expect(repository.likes, [(1, true), (1, true)]);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('목록에서 좋아요를 누른 뒤 새로고침하면 서버 값(원래 값과 같아도)으로 돌아간다', (tester) async {
      SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1)],
        repository: repository,
      ));
      await _pumpFrames(tester);

      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);
      expect(find.text('35'), findsOneWidget);
      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isTrue);

      // 당겨서 새로고침: 서버 목록은 그대로(null/34)지만 로컬 덮어쓰기는 비워진다.
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(find.text('34'), findsOneWidget);
      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isFalse);
    });

    testWidgets('새로고침이 진행되는 동안 누른 좋아요는 새로고침이 끝나도 남는다', (tester) async {
      SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
      final repository = _FakeNurbanRepository();
      final refreshing = Completer<void>();
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1)],
        repository: repository,
        onRefresh: () => refreshing.future,
      ));
      await _pumpFrames(tester);

      // 새로고침 시작(응답은 아직) → 그 사이 좋아요 성공 → 새로고침 완료
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);
      expect(find.text('35'), findsOneWidget);

      refreshing.complete();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(find.text('35'), findsOneWidget);
      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isTrue);
    });

    testWidgets('새로고침 중(DataRefetching)에는 끝까지 스크롤해도 더 받지 않는다', (tester) async {
      final loadMores = <int>[];
      await tester.pumpWidget(_app(
        fetchState: DataRefetching(),
        items: [for (var i = 1; i <= 10; i++) _post(i)],
        hasNextPage: true,
        loadMores: loadMores,
      ));
      await _pumpFrames(tester);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
      await _pumpFrames(tester);

      expect(find.byType(LoadMoreTrigger), findsNothing);
      expect(loadMores, isEmpty);
    });

    testWidgets('목록에서 누른 좋아요는 더 받기(목록 확장) 뒤에도 유지된다', (tester) async {
      SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1)],
        repository: repository,
      ));
      await _pumpFrames(tester);
      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);

      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1), _post(2)],
        repository: repository,
      ));
      await _pumpFrames(tester);

      expect(find.text('35'), findsOneWidget);
      expect(find.text('글 2'), findsOneWidget);
    });

    testWidgets('새로고침한 목록에서 같은 글의 좋아요가 바뀌면 화면에 반영된다', (tester) async {
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1, myReaction: Reaction.like, likeCount: 34)],
      ));
      await _pumpFrames(tester);
      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isTrue);

      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1, myReaction: Reaction.none, likeCount: 33)],
      ));
      await _pumpFrames(tester);

      expect(tester.widget<ReactionButton>(find.byType(ReactionButton)).selected, isFalse);
      expect(find.text('33'), findsOneWidget);
    });

    testWidgets('다음 페이지가 있으면 끝까지 스크롤할 때 onLoadMore 를 부른다', (tester) async {
      final loadMores = <int>[];
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [for (var i = 1; i <= 10; i++) _post(i)],
        hasNextPage: true,
        loadMores: loadMores,
      ));
      await _pumpFrames(tester);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
      await _pumpFrames(tester);

      expect(loadMores, isNotEmpty);
    });

    testWidgets('비로그인 상태에서 좋아요를 누르면 로그인 안내 토스트를 띄우고 카운트는 그대로다', (tester) async {
      await tester.pumpWidget(_app(fetchState: DataFetchSuccess(), items: [_post(1)]));
      await _pumpFrames(tester);

      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);

      expect(find.text(Strings.toastLoginRequired), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('로그인 상태에서 좋아요를 누르면 저장소를 부르고 돌려받은 수로 바꾼다', (tester) async {
      SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        fetchState: DataFetchSuccess(),
        items: [_post(1)],
        repository: repository,
      ));
      await _pumpFrames(tester);

      await tester.tap(find.byType(ReactionButton));
      await _pumpFrames(tester);

      expect(repository.likes, [(1, true)]);
      expect(find.text('35'), findsOneWidget);
      expect(find.byType(PostListItem), findsOneWidget);
    });
  });
}
