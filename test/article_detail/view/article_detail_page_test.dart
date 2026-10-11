import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 좋아요·싫어요·댓글·글 삭제만 흉내 내는 저장소. 호출을 기록하고 가짜 댓글 목록을 고친다.
/// `*Failure` 가 있으면 그 요청이 그 실패를 던진다(저장소 계약: 실패는 ApiFailure 뿐).
class _FakeNurbanRepository implements NurbanRepository {
  _FakeNurbanRepository({
    this.comments = const [],
    this.articleDeleteFailure,
    this.likeCreateFailure,
    this.commentCreateFailure,
  });

  List<NurbanComment> comments;
  final calls = <String>[];
  final ApiFailure? articleDeleteFailure;
  final ApiFailure? likeCreateFailure;
  final ApiFailure? commentCreateFailure;

  @override
  Future<int> nurbanLikeCreate({required int articleId}) async {
    calls.add('likeCreate');
    final failure = likeCreateFailure;
    if (failure != null) throw failure;
    return 36;
  }

  @override
  Future<int> nurbanLikeDelete({required int articleId}) async {
    calls.add('likeDelete');
    return 34;
  }

  @override
  Future<int> nurbanDislikeCreate({required int articleId}) async {
    calls.add('dislikeCreate');
    return 4;
  }

  @override
  Future<int> nurbanDislikeDelete({required int articleId}) async {
    calls.add('dislikeDelete');
    return 2;
  }

  @override
  Future<void> nurbanCommentCreate({required int articleId, required String content}) async {
    calls.add('commentCreate:$content');
    final failure = commentCreateFailure;
    if (failure != null) throw failure;
    comments = [...comments, _comment(99, content: content, userId: 7)];
  }

  @override
  Future<void> nurbanCommentDelete({required int commentId, required int articleId}) async {
    calls.add('commentDelete:$commentId');
    comments = comments.where((c) => c.id != commentId).toList();
  }

  @override
  Future<void> nurbanArticleDelete({required int articleId, required String uuid}) async {
    calls.add('articleDelete:$uuid');
    final failure = articleDeleteFailure;
    if (failure != null) throw failure;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NurbanArticle _article({
  int userId = 1,
  String? thumbnail,
  Reaction myReaction = Reaction.none,
  int likes = 35,
  int dislikes = 3,
}) =>
    (
      id: 10,
      uuid: 'uuid-10',
      thumbnail: thumbnail,
      title: '삼전 물타기 실패했습니다',
      lossCut: 1250000,
      content: '7만전자에서 물 타고 6만전자에서 또 탔는데',
      count: 123,
      commentCount: 2,
      likeCount: likes,
      dislikeCount: dislikes,
      updatedAt: '2026-10-10T14:30:00',
      userId: userId,
      badge: null,
      nickname: '삼전홀더',
      insignia: '[]',
      myReaction: myReaction,
    );

NurbanComment _comment(int id, {String content = '', int userId = 2}) => (
      id: id,
      content: content.isEmpty ? '위로 $id' : content,
      userId: userId,
      badge: null,
      nickname: '존버실패',
      insignia: '[]',
    );

Widget _app({
  NurbanArticle? article,
  Object? articleError,
  required _FakeNurbanRepository repository,
  List<bool?>? popped,
}) {
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      getNurbanArticleProvider.overrideWith((ref, id) async {
        if (articleError != null) throw articleError;
        return article!;
      }),
      getNurbanCommentsProvider.overrideWith((ref, id) async => repository.comments),
      nurbanRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                ArticleDetailPage.route(board: 1, articleId: 10),
              );
              popped?.add(result);
            },
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

/// 상세 화면을 열고 route 전환 애니메이션과 Provider 로딩이 끝날 때까지 돌린다.
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('열기'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  await _pumpFrames(tester);
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      '__pref_auth_token__': 'token-1',
      '__pref_user_id__': 7,
    });
    // AdMob 은 자체 코덱의 플랫폼 채널을 쓰므로 '성공(null)' 봉투([0, 0])만 그대로 돌려준다(광고는 로드되지 않는다).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'plugins.flutter.io/google_mobile_ads',
      (_) async => ByteData.sublistView(Uint8List.fromList([0, 0])),
    );
  });
  tearDown(NbkToast.hide);

  group('ArticleDetailPage', () {
    testWidgets('제목·작성자·손실액·본문·반응·댓글을 보여주고 남의 글이면 더보기가 없다', (tester) async {
      final repository = _FakeNurbanRepository(comments: [_comment(1), _comment(2)]);
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      expect(find.text('삼전 물타기 실패했습니다'), findsOneWidget);
      expect(find.text('삼전홀더'), findsOneWidget);
      expect(find.text('2026.10.10 14:30 · ${Strings.views('123')}'), findsOneWidget);
      expect(find.text('-1,250,000원'), findsOneWidget);
      expect(find.text(Strings.boardStock), findsOneWidget);
      expect(find.text('${Strings.like} 35'), findsOneWidget);
      expect(find.text('${Strings.dislike} 3'), findsOneWidget);
      expect(find.text('위로 1'), findsOneWidget);
      expect(find.text('위로 2'), findsOneWidget);
      expect(find.text('${Strings.commentsHeader} 2'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsNothing);
      expect(find.text(Strings.myPost), findsNothing);
      expect(find.byType(NbkThumbnail), findsNothing);
    });

    testWidgets('내 글이면 내 글 필과 더보기를 보여주고 확인 시트를 거쳐 삭제한 뒤 true 로 닫힌다', (tester) async {
      final repository = _FakeNurbanRepository();
      final popped = <bool?>[];
      await tester.pumpWidget(_app(article: _article(userId: 7), repository: repository, popped: popped));
      await _open(tester);

      expect(find.text(Strings.myPost), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text(Strings.deleteArticleTitle), findsOneWidget);

      await tester.tap(find.text(Strings.delete));
      await tester.pumpAndSettle();

      expect(repository.calls, ['articleDelete:uuid-10']);
      expect(popped, [true]);
      expect(find.text(Strings.toastArticleDeleted), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('글 삭제에 실패하면 오류 토스트를 띄우고 화면은 그대로다', (tester) async {
      final repository = _FakeNurbanRepository(articleDeleteFailure: const ApiServerFailure('not_owner'));
      final popped = <bool?>[];
      await tester.pumpWidget(_app(article: _article(userId: 7), repository: repository, popped: popped));
      await _open(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.delete));
      await _pumpFrames(tester, 6);

      expect(repository.calls, ['articleDelete:uuid-10']);
      expect(popped, isEmpty);
      expect(find.byType(ArticleDetailPage), findsOneWidget);
      expect(find.text(Strings.toastArticleDeleteFailed), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('없는 글(404)이면 토스트를 띄우고 false 로 바로 닫힌다', (tester) async {
      final popped = <bool?>[];
      await tester.pumpWidget(_app(
        articleError: const ApiHttpFailure(status: 404),
        repository: _FakeNurbanRepository(),
        popped: popped,
      ));
      await _open(tester);
      await tester.pumpAndSettle();

      expect(find.byType(ArticleDetailPage), findsNothing);
      expect(find.text(Strings.toastArticleNotFound), findsOneWidget);
      expect(popped, [false]);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('그 밖의 오류면 앱바는 유지하고 오류 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        articleError: const ApiOffline(),
        repository: _FakeNurbanRepository(),
      ));
      await _open(tester);

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text(Strings.boardStock), findsOneWidget);
    });

    testWidgets('좋아요를 누르면 저장소를 부르고 돌려받은 수로 바꾸며, 싫어요 상태였다면 싫어요 수가 하나 준다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        article: _article(myReaction: Reaction.dislike, likes: 35, dislikes: 3),
        repository: repository,
      ));
      await _open(tester);

      await tester.tap(find.text('${Strings.like} 35'));
      await _pumpFrames(tester);

      expect(repository.calls, ['likeCreate']);
      expect(find.text('${Strings.like} 36'), findsOneWidget);
      expect(find.text('${Strings.dislike} 2'), findsOneWidget);
    });

    testWidgets('싫어요를 누르면 싫어요를 만들고, 좋아요 상태였다면 좋아요 수가 하나 준다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        article: _article(myReaction: Reaction.like, likes: 35, dislikes: 3),
        repository: repository,
      ));
      await _open(tester);

      await tester.tap(find.text('${Strings.dislike} 3'));
      await _pumpFrames(tester);

      expect(repository.calls, ['dislikeCreate']);
      expect(find.text('${Strings.dislike} 4'), findsOneWidget);
      expect(find.text('${Strings.like} 34'), findsOneWidget);
      expect(
        tester.widget<ReactionButton>(find.byWidgetPredicate((w) => w is ReactionButton && w.kind == ReactionKind.dislike)).selected,
        isTrue,
      );
    });

    testWidgets('이미 싫어요한 글의 싫어요를 다시 누르면 취소한다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        article: _article(myReaction: Reaction.dislike, likes: 35, dislikes: 3),
        repository: repository,
      ));
      await _open(tester);

      await tester.tap(find.text('${Strings.dislike} 3'));
      await _pumpFrames(tester);

      expect(repository.calls, ['dislikeDelete']);
      expect(find.text('${Strings.dislike} 2'), findsOneWidget);
      expect(find.text('${Strings.like} 35'), findsOneWidget);
    });

    testWidgets('이미 좋아요한 글의 좋아요를 다시 누르면 취소한다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        article: _article(myReaction: Reaction.like),
        repository: repository,
      ));
      await _open(tester);

      await tester.tap(find.text('${Strings.like} 35'));
      await _pumpFrames(tester);

      expect(repository.calls, ['likeDelete']);
      expect(find.text('${Strings.like} 34'), findsOneWidget);
    });

    testWidgets('서버가 반응을 거절하면 반응 실패 토스트를 띄우고 상태를 유지하며 다시 누를 수 있다', (tester) async {
      final repository = _FakeNurbanRepository(likeCreateFailure: const ApiServerFailure('already_reacted'));
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.tap(find.text('${Strings.like} 35'));
      await _pumpFrames(tester);
      expect(find.text(Strings.toastReactionFailed), findsOneWidget);
      expect(find.text('${Strings.like} 35'), findsOneWidget);

      await tester.tap(find.text('${Strings.like} 35'));
      await _pumpFrames(tester);
      expect(repository.calls, ['likeCreate', 'likeCreate']);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('반응 요청이 네트워크 오류로 실패하면 네트워크 안내 토스트를 띄우고 수는 그대로다', (tester) async {
      final repository = _FakeNurbanRepository(likeCreateFailure: const ApiTimeout());
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.tap(find.text('${Strings.like} 35'));
      await _pumpFrames(tester);

      expect(find.text(Strings.toastNetworkError), findsOneWidget);
      expect(find.text('${Strings.like} 35'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('글을 로그인 상태로 받아 내 반응이 있으면 그 버튼이 선택돼 보인다', (tester) async {
      await tester.pumpWidget(_app(article: _article(myReaction: Reaction.like), repository: _FakeNurbanRepository()));
      await _open(tester);

      final like = tester.widget<ReactionButton>(find.widgetWithText(ReactionButton, '${Strings.like} 35'));
      final dislike = tester.widget<ReactionButton>(find.widgetWithText(ReactionButton, '${Strings.dislike} 3'));
      expect(like.selected, isTrue);
      expect(dislike.selected, isFalse);
    });

    testWidgets('비로그인 상태에서 반응을 누르면 로그인 안내 토스트만 띄운다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.tap(find.text('${Strings.dislike} 3'));
      await _pumpFrames(tester);

      expect(repository.calls, isEmpty);
      expect(find.text(Strings.toastLoginRequired), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('키보드가 올라오면 댓글 입력 바가 키보드 위로 올라간다', (tester) async {
      await tester.pumpWidget(_app(article: _article(), repository: _FakeNurbanRepository()));
      await _open(tester);
      final before = tester.getRect(find.byType(TextField)).bottom;

      tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await _pumpFrames(tester);

      final field = tester.getRect(find.byType(TextField));
      final screen = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(field.bottom, lessThanOrEqualTo(screen - 300));
      expect(field.bottom, lessThan(before));
      expect(find.text(Strings.register), findsOneWidget);
    });

    testWidgets('댓글이 없으면 말풍선 빈 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(article: _article(), repository: _FakeNurbanRepository()));
      await _open(tester);

      expect(find.text(Strings.emptyCommentsTitle), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('댓글을 입력해 등록하면 저장소를 부르고 입력을 비우고 목록을 다시 받는다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.enterText(find.byType(TextField), '같이 울어요');
      await tester.pump();
      expect(find.text('6/60'), findsOneWidget);

      await tester.tap(find.text(Strings.register));
      await _pumpFrames(tester, 6);

      expect(repository.calls, ['commentCreate:같이 울어요']);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
      expect(find.text('같이 울어요'), findsOneWidget);
    });

    testWidgets('댓글 카운터는 이모지도 글자 하나로 센다', (tester) async {
      await tester.pumpWidget(_app(article: _article(), repository: _FakeNurbanRepository()));
      await _open(tester);

      await tester.enterText(find.byType(TextField), '😀');
      await tester.pump();
      expect(find.text('1/60'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '👨‍👩‍👧‍👦');
      await tester.pump();
      expect(find.text('1/60'), findsOneWidget);
    });

    testWidgets('댓글 등록이 네트워크 오류로 실패하면 오류 토스트를 띄우고 입력을 유지한다', (tester) async {
      final repository = _FakeNurbanRepository(commentCreateFailure: const ApiOffline());
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.enterText(find.byType(TextField), '같이 울어요');
      await tester.tap(find.text(Strings.register));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastCommentCreateFailed), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '같이 울어요');
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('서버가 댓글 등록을 거절하면(error) 성공으로 처리하지 않고 오류 토스트를 띄운다', (tester) async {
      final repository = _FakeNurbanRepository(commentCreateFailure: const ApiServerFailure('too_long'));
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.enterText(find.byType(TextField), '같이 울어요');
      await tester.tap(find.text(Strings.register));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastCommentCreateFailed), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '같이 울어요');
      expect(repository.comments, isEmpty);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('빈 댓글을 등록하면 안내 토스트만 띄운다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.tap(find.text(Strings.register));
      await _pumpFrames(tester);

      expect(repository.calls, isEmpty);
      expect(find.text(Strings.toastCommentEmpty), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('비로그인 상태에서 댓글을 등록하면 로그인 화면으로 보낸다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      await tester.enterText(find.byType(TextField), '안녕');
      await tester.tap(find.text(Strings.register));
      await tester.pumpAndSettle();

      expect(repository.calls, isEmpty);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('내 댓글의 휴지통은 확인 시트를 거쳐 삭제하고 목록을 다시 받는다', (tester) async {
      final repository = _FakeNurbanRepository(comments: [_comment(1, userId: 7), _comment(2)]);
      await tester.pumpWidget(_app(article: _article(), repository: repository));
      await _open(tester);

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.delete));
      await _pumpFrames(tester, 6);

      expect(repository.calls, ['commentDelete:1']);
      expect(find.text('위로 1'), findsNothing);
      expect(find.text('위로 2'), findsOneWidget);
      expect(find.text(Strings.toastCommentDeleted), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
