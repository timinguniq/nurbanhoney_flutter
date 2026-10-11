import 'dart:async';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/account/account.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney/myaccount_setting/myaccount_setting.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class _FakeAuthentication extends AuthenticationService {
  _FakeAuthentication(this.initial);

  final AuthenticationStatus initial;

  @override
  AuthenticationStatus build() => initial;
}

/// 탈퇴만 흉내 내는 프로필 저장소
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.failure, this.gate});

  /// 있으면 탈퇴 요청이 이 실패를 던진다
  final ApiFailure? failure;

  /// 있으면 탈퇴 응답을 이 Completer 가 끝날 때까지 미룬다
  final Completer<void>? gate;
  final withdrawals = <int>[];

  @override
  Future<void> myaccountWithdrawal({required int userId}) async {
    withdrawals.add(userId);
    await gate?.future;
    final failure = this.failure;
    if (failure != null) throw failure;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 탈퇴 뒤 홈으로 갈 때 홈 목록이 서버를 부르지 않게 빈 목록을 주는 저장소
class _FakeNurbanRepository implements NurbanRepository {
  @override
  Future<List<BoardAllType>> getNurbanAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async =>
      [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 토큰 삭제를 [gate] 가 끝날 때까지 미루는 저장소(로그아웃 진행 중 상태를 보기 위해)
class _SlowLogoutStorage extends PreferenceStorage {
  _SlowLogoutStorage({required super.plugin, required this.gate});

  final Completer<void> gate;

  @override
  Future<void> setEmptyToken() async {
    await gate.future;
    await super.setEmptyToken();
  }
}

ProfileType _profile({String loginType = 'kakao', String? createdAt}) => (
      id: 7,
      loginType: loginType,
      badge: '',
      nickname: '제희',
      description: '',
      point: 1240,
      insigniaShow: '[]',
      insigniaOwn: '[]',
      myArticleCount: 12,
      myCommentCount: 48,
      createdAt: createdAt,
    );

Widget _app({
  ProfileType? profile,
  Object? profileError,
  _FakeProfileRepository? repository,
  Future<PreferenceStorage> Function()? storage,
}) {
  return ProviderScope(
    overrides: [
      authenticationServiceProvider.overrideWith(() => _FakeAuthentication(AuthenticationStatus.authenticated)),
      preferenceStorageProvider.overrideWith(
        (ref) => storage != null
            ? storage()
            : SharedPreferences.getInstance().then((p) => PreferenceStorage(plugin: p)),
      ),
      getProfileProvider.overrideWith((ref) async {
        if (profileError != null) throw profileError;
        return profile ?? _profile();
      }),
      profileRepositoryProvider.overrideWithValue(repository ?? _FakeProfileRepository()),
      nurbanRepositoryProvider.overrideWithValue(_FakeNurbanRepository()),
      getRankTabProvider.overrideWith((ref, arg) async => []),
      appVersionProvider.overrideWith((ref) async => '1.1.0'),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MyaccountSettingPage.route()),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

/// 설정 화면을 열고 route 전환 애니메이션과 Provider 로딩이 끝날 때까지 돌린다.
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
  setUp(() => SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1', '__pref_user_id__': 7}));
  tearDown(NbkToast.hide);

  group('MyaccountSettingPage', () {
    testWidgets('카카오 계정이면 카카오 행, 프로필 수정, 앱 정보, 탈퇴하기를 보여준다', (tester) async {
      await tester.pumpWidget(_app());
      await _open(tester);

      expect(find.text(Strings.kakaoAccount), findsOneWidget);
      expect(find.text('제희'), findsOneWidget);
      expect(find.text(Strings.logout), findsOneWidget);
      expect(find.text(Strings.profileEdit), findsOneWidget);
      expect(find.text(Strings.terms), findsOneWidget);
      expect(find.text('1.1.0'), findsOneWidget);
      expect(find.text(Strings.withdraw), findsOneWidget);
      expect(find.text('kakao'), findsNothing);
    });

    testWidgets('프로필에 createdAt 이 있으면 닉네임 옆에 가입일을 보여준다', (tester) async {
      await tester.pumpWidget(_app(profile: _profile(createdAt: '2024-03-12T09:00:00.000Z')));
      await _open(tester);

      expect(find.text(Strings.joinedCaption('제희', '2024.03.12')), findsOneWidget);
      expect(find.text('제희'), findsNothing);
    });

    testWidgets('createdAt 을 날짜로 읽을 수 없으면 닉네임만 보여준다', (tester) async {
      await tester.pumpWidget(_app(profile: _profile(createdAt: 'n/a')));
      await _open(tester);

      expect(find.text('제희'), findsOneWidget);
    });

    testWidgets('구글 계정이면 Google 계정 행을 보여준다', (tester) async {
      await tester.pumpWidget(_app(profile: _profile(loginType: 'google')));
      await _open(tester);

      expect(find.text(Strings.googleAccount), findsOneWidget);
      expect(find.text(Strings.kakaoAccount), findsNothing);
    });

    testWidgets('로그아웃하면 토큰을 지우고 인증 상태를 바꾸고 토스트 뒤 직전 화면으로 돌아간다', (tester) async {
      await tester.pumpWidget(_app());
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(MyaccountSettingPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.logout));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), '__empty__');
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      expect(find.byType(MyaccountSettingPage), findsNothing);
      expect(find.text('열기'), findsOneWidget);
      expect(find.text(Strings.toastLoggedOut), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('로그아웃이 진행되는 동안 본문은 눌리지 않고, 끝나면 설정 화면이 닫힌다', (tester) async {
      final gate = Completer<void>();
      await tester.pumpWidget(_app(
        storage: () async => _SlowLogoutStorage(plugin: await SharedPreferences.getInstance(), gate: gate),
      ));
      await _open(tester);

      final container = ProviderScope.containerOf(tester.element(find.byType(MyaccountSettingPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.logout));
      await _pumpFrames(tester);

      // 진행 중: 프로필 수정 행을 눌러도 아무 화면도 열리지 않고, 토큰이 지워지기 전엔 인증 상태도 그대로다.
      await tester.tap(find.text(Strings.profileEdit), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(MyaccountSettingPage), findsOneWidget);
      expect(find.byType(MyaccountEditPage), findsNothing);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.authenticated);

      // 그 사이 다른 route(다이얼로그)가 위에 떠도 완료되면 설정 화면까지 닫힌다.
      final pageContext = tester.element(find.byType(MyaccountSettingPage));
      showDialog<void>(
        context: pageContext,
        builder: (_) => const AlertDialog(title: Text('열린 다이얼로그')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('열린 다이얼로그'), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      expect(find.text('열린 다이얼로그'), findsNothing);
      expect(find.byType(MyaccountSettingPage), findsNothing);
      expect(find.text('열기'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('탈퇴는 체크박스를 켠 뒤에만 진행되고, 성공하면 홈으로 돌아간다', (tester) async {
      final repository = _FakeProfileRepository();
      await tester.pumpWidget(_app(repository: repository));
      await _open(tester);

      await tester.tap(find.text(Strings.withdraw));
      await tester.pumpAndSettle();
      expect(find.text(Strings.withdrawConfirmTitle), findsOneWidget);
      expect(find.text(Strings.withdrawConfirmMessage('12', '48', '1,240')), findsOneWidget);
      expect(tester.widget<NbkButton>(find.widgetWithText(NbkButton, Strings.withdrawAction)).onPressed, isNull);

      await tester.tap(find.text(Strings.withdrawCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.withdrawAction));
      // 홈으로 가는 route 전환까지 돌린다.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await _pumpFrames(tester);

      expect(repository.withdrawals, [7]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), '__empty__');
      expect(find.byType(MyaccountSettingPage), findsNothing);
      expect(find.byType(HomePageRefactor), findsOneWidget);
      expect(find.text(Strings.toastWithdrawn), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('탈퇴 응답을 기다리는 동안 뒤로 가기는 막히고, 강제로 나가도 성공하면 토큰·인증 상태를 정리한다', (tester) async {
      final gate = Completer<void>();
      final repository = _FakeProfileRepository(gate: gate);
      await tester.pumpWidget(_app(repository: repository));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(MyaccountSettingPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.withdraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.withdrawCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.withdrawAction));
      await _pumpFrames(tester);
      expect(repository.withdrawals, [7]);

      // 뒤로 가기(maybePop)는 요청 중 막힌다.
      final pageContext = tester.element(find.byType(MyaccountSettingPage));
      await Navigator.of(pageContext).maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(MyaccountSettingPage), findsOneWidget);

      // 강제로 화면이 사라진 뒤 성공 응답이 와도 세션은 정리된다.
      Navigator.of(pageContext).pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyaccountSettingPage), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), '__empty__');
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
    });

    testWidgets('탈퇴에 실패하면 토스트를 띄우고 화면·토큰은 그대로다', (tester) async {
      await tester.pumpWidget(_app(repository: _FakeProfileRepository(failure: const ApiServerFailure('not_owner'))));
      await _open(tester);

      await tester.tap(find.text(Strings.withdraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.withdrawCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.withdrawAction));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastWithdrawFailed), findsOneWidget);
      expect(find.byType(MyaccountSettingPage), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), 'token-1');
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('프로필을 받지 못하면 오류 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(profileError: const ApiOffline()));
      await _open(tester);

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });
}
