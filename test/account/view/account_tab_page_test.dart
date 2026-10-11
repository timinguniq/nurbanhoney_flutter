import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/account/account.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 처음 상태를 정해 두는 인증 서비스. `set` 은 그대로라 테스트 중에 상태를 바꿀 수 있다.
class _FakeAuthentication extends AuthenticationService {
  _FakeAuthentication(this.initial);

  final AuthenticationStatus initial;

  @override
  AuthenticationStatus build() => initial;
}

/// 댓글 삭제만 흉내 내는 저장소. 호출 기록을 남기고 [onDelete] 로 가짜 목록을 고친다.
class _FakeNurbanRepository implements NurbanRepository {
  _FakeNurbanRepository({this.result = 'nurbancomment_deleted', this.onDelete});

  final String result;
  final void Function(int commentId)? onDelete;
  final deleted = <(int, int)>[];

  @override
  Future<String> nurbanCommentDelete({
    required String token,
    required int commentId,
    required int articleId,
  }) async {
    deleted.add((commentId, articleId));
    onDelete?.call(commentId);
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProfileType _profile({int articles = 2, int comments = 1, String? description = '장기투자자였는데 어쩌다 단타를 치고 있습니다'}) => (
      id: 7,
      loginType: 'kakao',
      badge: '',
      nickname: '제희',
      description: description,
      point: 1240,
      insigniaShow: '[]',
      insigniaOwn: '[]',
      myArticleCount: articles,
      myCommentCount: comments,
      createdAt: null,
    );

ProfileArticleType _article(int id, {int? lossCut}) => (
      id: id,
      board: id.isEven ? 2 : 1,
      thumbnail: '',
      title: '글 $id',
      count: id * 3,
      commentCount: id,
      createdAt: '2026-10-10T10:00:00.000Z',
      lossCut: lossCut,
    );

ProfileCommentType _comment(int id) => (
      id: id,
      board: 1,
      title: '원문 $id',
      content: '댓글 $id',
      createdAt: '2026-10-10T10:00:00.000Z',
      articleId: 100 + id,
    );

Widget _app({
  required AuthenticationStatus auth,
  ProfileType? profile,
  Object? profileError,
  List<ProfileArticleType> articles = const [],
  List<ProfileCommentType> comments = const [],
  List<int>? articleOffsets,
  List<int>? profileCalls,
  NurbanRepository? nurbanRepository,
}) {
  return ProviderScope(
    overrides: [
      authenticationServiceProvider.overrideWith(() => _FakeAuthentication(auth)),
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      getProfileProvider.overrideWith((ref) async {
        profileCalls?.add(profileCalls.length + 1);
        if (profileError != null) throw profileError;
        return profile!;
      }),
      getProfileArticleProvider.overrideWith((ref, page) async {
        articleOffsets?.add(page.offset);
        return articles.skip(page.offset).take(page.limit).toList();
      }),
      getProfileCommentProvider.overrideWith(
        (ref, page) async => comments.skip(page.offset).take(page.limit).toList(),
      ),
      appVersionProvider.overrideWith((ref) async => '1.1.0'),
      if (nurbanRepository != null)
        nurbanRepositoryProvider.overrideWithValue(nurbanRepository),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: const AccountTabPage(),
    ),
  );
}

/// Future Provider 들이 끝나고 화면이 그려질 때까지 몇 프레임 돌린다(스켈레톤 애니메이션 때문에 pumpAndSettle 은 안 쓴다).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
  });

  tearDown(NbkToast.hide);

  group('AccountTabPage', () {
    testWidgets('비로그인이면 로그인 안내 카드와 앱 정보를 보여주고 설정 아이콘은 없다', (tester) async {
      await tester.pumpWidget(_app(auth: AuthenticationStatus.unauthenticated));
      await _pumpFrames(tester);

      expect(find.text(Strings.accountLoggedOutTitle), findsOneWidget);
      expect(find.text(Strings.loginCta), findsOneWidget);
      expect(find.text(Strings.terms), findsOneWidget);
      expect(find.text('1.1.0'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      expect(find.byType(AccountProfileView), findsNothing);
    });

    testWidgets('로그인 상태면 프로필·활동 요약·내 글 목록을 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        articles: [_article(1), _article(2)],
      ));
      await _pumpFrames(tester);

      expect(find.text('제희'), findsOneWidget);
      expect(find.text('1,240'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.text('글 1'), findsOneWidget);
      expect(find.text('글 2'), findsOneWidget);
      expect(find.text('2026.10.10  ${Strings.views('6')}'), findsOneWidget);
      expect(find.text(Strings.accountLoggedOutTitle), findsNothing);
    });

    testWidgets('소개가 없으면(null) 소개 안내 문구를 보여준다', (tester) async {
      await tester.pumpWidget(_app(auth: AuthenticationStatus.authenticated, profile: _profile(description: null)));
      await _pumpFrames(tester);

      expect(find.text(Strings.descriptionPlaceholder), findsOneWidget);
      expect(find.text('null'), findsNothing);
    });

    testWidgets('내 글에 손실액이 있으면 손실액 캡션을 보여주고, 없으면 날짜·조회만 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        // 서버 원문 형식(숫자 문자열·'1,200,000원' 등)은 저장소가 정수로 읽는다(profile_repository_test).
        articles: [_article(1, lossCut: 430000), _article(2), _article(3, lossCut: 1200000)],
      ));
      await _pumpFrames(tester);

      expect(find.text('-430,000원'), findsOneWidget);
      expect(find.text('-1,200,000원'), findsOneWidget);
      expect(find.byType(LossAmount), findsNWidgets(2));
      expect(find.text(' · '), findsNWidgets(2));
      expect(find.text('2026.10.10  ${Strings.views('6')}'), findsOneWidget);
    });

    testWidgets('포인트 옆 도움말을 누르면 적립·사용 규칙 안내 시트를 보여준다', (tester) async {
      await tester.pumpWidget(_app(auth: AuthenticationStatus.authenticated, profile: _profile()));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(Strings.pointsRuleTitle), findsOneWidget);
      expect(find.text(Strings.pointsRule), findsOneWidget);
    });

    testWidgets('로그아웃으로 인증 상태가 바뀌면 프로필 대신 비로그인 카드로 바뀐다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        articles: [_article(1)],
      ));
      await _pumpFrames(tester);
      expect(find.text('제희'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AccountTabPage)),
      );
      container
          .read(authenticationServiceProvider.notifier)
          .set(AuthenticationStatus.unauthenticated);
      await _pumpFrames(tester);

      expect(find.text('제희'), findsNothing);
      expect(find.text(Strings.accountLoggedOutTitle), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    });

    testWidgets('내 댓글 탭을 누르면 댓글 목록을 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        articles: [_article(1)],
        comments: [_comment(1)],
      ));
      await _pumpFrames(tester);

      await tester.tap(find.textContaining(Strings.myComments, findRichText: true));
      await _pumpFrames(tester);

      expect(find.text('댓글 1'), findsOneWidget);
      expect(find.text('원문 1'), findsOneWidget);
      expect(find.text('글 1'), findsNothing);
    });

    testWidgets('프로필을 불러오지 못하면 오류 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profileError: Exception('connection error'),
      ));
      await _pumpFrames(tester);

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text(Strings.retry), findsOneWidget);
      expect(find.text('제희'), findsNothing);
    });

    testWidgets('내 글이 없으면 빈 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(articles: 0),
      ));
      await _pumpFrames(tester);

      expect(find.text(Strings.emptyMyArticlesTitle), findsOneWidget);
    });

    testWidgets('댓글 휴지통은 확인 시트를 거쳐 삭제하고 목록을 새로 받는다', (tester) async {
      final comments = [_comment(1), _comment(2)];
      final repository = _FakeNurbanRepository(
        onDelete: (id) => comments.removeWhere((c) => c.id == id),
      );
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(comments: 2),
        comments: comments,
        nurbanRepository: repository,
      ));
      await _pumpFrames(tester);
      await tester.tap(find.textContaining(Strings.myComments, findRichText: true));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text(Strings.deleteCommentTitle), findsOneWidget);
      expect(repository.deleted, isEmpty);

      await tester.tap(find.text(Strings.delete));
      await _pumpFrames(tester, 6);

      expect(repository.deleted, [(1, 101)]);
      expect(find.text('댓글 1'), findsNothing);
      expect(find.text('댓글 2'), findsOneWidget);
      expect(find.text(Strings.toastCommentDeleted), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('확인 시트에서 취소하면 삭제하지 않는다', (tester) async {
      final repository = _FakeNurbanRepository();
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        comments: [_comment(1)],
        nurbanRepository: repository,
      ));
      await _pumpFrames(tester);
      await tester.tap(find.textContaining(Strings.myComments, findRichText: true));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.cancel));
      await _pumpFrames(tester);

      expect(repository.deleted, isEmpty);
      expect(find.text('댓글 1'), findsOneWidget);
    });

    testWidgets('삭제에 실패하면 오류 토스트를 보여주고 목록은 그대로다', (tester) async {
      final repository = _FakeNurbanRepository(result: 'error');
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(),
        comments: [_comment(1)],
        nurbanRepository: repository,
      ));
      await _pumpFrames(tester);
      await tester.tap(find.textContaining(Strings.myComments, findRichText: true));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.delete));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastCommentDeleteFailed), findsOneWidget);
      expect(find.text('댓글 1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('내용이 짧아도(빈 목록) 당겨서 새로고침하면 프로필과 목록을 다시 받는다', (tester) async {
      final profileCalls = <int>[];
      final offsets = <int>[];
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(articles: 0),
        profileCalls: profileCalls,
        articleOffsets: offsets,
      ));
      await _pumpFrames(tester);
      expect(find.text(Strings.emptyMyArticlesTitle), findsOneWidget);
      expect(profileCalls, hasLength(1));
      expect(offsets, [0]);

      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(profileCalls, hasLength(2));
      expect(offsets, [0, 0]);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('한 페이지가 꽉 차면 끝까지 스크롤할 때 다음 offset 을 받는다', (tester) async {
      final offsets = <int>[];
      await tester.pumpWidget(_app(
        auth: AuthenticationStatus.authenticated,
        profile: _profile(articles: 25),
        articles: [for (var i = 1; i <= 25; i++) _article(i)],
        articleOffsets: offsets,
      ));
      await _pumpFrames(tester);
      expect(offsets.first, 0);

      for (var i = 0; i < 4; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
        await _pumpFrames(tester);
      }

      expect(find.text('글 25'), findsOneWidget);
      expect(offsets.toSet(), {0, 10, 20});
    });
  });
}
