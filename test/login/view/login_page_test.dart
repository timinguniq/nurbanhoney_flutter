import 'dart:async';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 토큰 저장이 실패하는 저장소
class _ThrowingStorage extends PreferenceStorage {
  const _ThrowingStorage({required super.plugin});

  @override
  Future<void> setToken(String value) => throw Exception('disk full');
}

/// 토큰은 저장되지만 userId 저장이 실패하는 저장소
class _UserIdThrowingStorage extends PreferenceStorage {
  const _UserIdThrowingStorage({required super.plugin});

  @override
  Future<void> setUserId(int value) => throw Exception('disk full');
}

/// 홈 위에 로그인 화면을 push 한 상태로 시작한다. 서버 로그인은 [serverLogin] 으로 흉내 낸다.
/// [storage] 로 저장소 준비를 늦추거나(Completer) 실패하는 저장소를 끼울 수 있다.
Widget _app({
  required Future<String?> Function() kakaoKey,
  Future<String?> Function()? googleKey,
  Future<LoginType> Function(String type, String key)? serverLogin,
  List<(String, String)>? serverCalls,
  Future<PreferenceStorage> Function()? storage,
}) {
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) => storage != null
            ? storage()
            : SharedPreferences.getInstance().then((p) => PreferenceStorage(plugin: p)),
      ),
      getLoginProvider.overrideWith((ref, records) {
        serverCalls?.add((records.$1, records.$2));
        return serverLogin!(records.$1, records.$2);
      }),
      getTermsProvider.overrideWith((ref) async => '약관 본문'),
      getPrivacyProvider.overrideWith((ref) async => '개인정보 본문'),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LoginPage(
                  kakaoKey: kakaoKey,
                  googleKey: googleKey ?? () async => null,
                ),
              ),
            ),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(NbkToast.hide);

  group('LoginPage', () {
    testWidgets('카카오 키를 받으면 서버 로그인 뒤 토큰·userId 를 저장하고 인증 상태를 바꾸고 닫힌다', (tester) async {
      final serverCalls = <(String, String)>[];
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: 'server-token', userId: '42'),
        serverCalls: serverCalls,
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      // 실제 앱에서는 AppView 가 인증 상태를 계속 watch 한다. autoDispose 라 테스트에서도 구독을 잡아 둔다.
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester);
      await tester.pumpAndSettle();

      expect(serverCalls, [('kakao', 'kakao-access')]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), 'server-token');
      expect(prefs.getInt('__pref_user_id__'), 42);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.authenticated);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('SDK 가 키를 주지 않으면(취소) 서버를 부르지 않고 실패 카드를 보여준다', (tester) async {
      final serverCalls = <(String, String)>[];
      await tester.pumpWidget(_app(
        kakaoKey: () async => '',
        serverLogin: (_, __) async => (token: 'x', userId: '1'),
        serverCalls: serverCalls,
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester);

      expect(serverCalls, isEmpty);
      expect(find.text(Strings.loginFailedTitle(Strings.providerKakao)), findsOneWidget);
      expect(find.text(Strings.loginFailedKakaoReason), findsOneWidget);
      expect(find.text(Strings.loginRetryWith(Strings.providerKakao)), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('서버가 토큰은 주지만 userId 가 숫자가 아니면 서버 실패로 처리한다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: 'server-token', userId: 'null'),
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.loginFailedServerReason), findsOneWidget);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), isNull);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('서버가 빈 토큰을 주면 서버 실패로 처리하고 저장하지 않는다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: '', userId: '42'),
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.loginFailedServerReason), findsOneWidget);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), isNull);
    });

    testWidgets('서버 로그인이 실패하면 서버 원인으로 실패 카드를 보여주고 인증 상태는 그대로다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => throw Exception('status code of 500'),
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.loginFailedServerReason), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('서버 실패 뒤 같은 키로 다시 시도하면 서버를 다시 부르고 성공하면 닫힌다', (tester) async {
      var attempts = 0;
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'same-key',
        serverLogin: (_, __) async {
          attempts++;
          if (attempts == 1) throw Exception('status code of 500');
          return (token: 'server-token', userId: '42');
        },
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);
      expect(find.text(Strings.loginRetryWith(Strings.providerKakao)), findsOneWidget);

      await tester.tap(find.text(Strings.loginRetryWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.authenticated);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('저장소가 늦게 준비돼도 토큰을 저장한 뒤에 인증 상태를 바꾸고 닫힌다', (tester) async {
      final storageReady = Completer<PreferenceStorage>();
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: 'server-token', userId: '42'),
        storage: () => storageReady.future,
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      expect(find.byType(LoginPage), findsOneWidget);

      storageReady.complete(PreferenceStorage(plugin: await SharedPreferences.getInstance()));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), 'server-token');
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.authenticated);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('토큰 저장에 실패하면 인증하지 않고 실패 카드로 돌아간다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: 'server-token', userId: '42'),
        storage: () async => _ThrowingStorage(plugin: await SharedPreferences.getInstance()),
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.loginFailedStorageReason), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('userId 저장에 실패하면 저장된 토큰을 되돌리고 실패 카드로 돌아간다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) async => (token: 'server-token', userId: '42'),
        storage: () async => _UserIdThrowingStorage(plugin: await SharedPreferences.getInstance()),
      ));
      await _open(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(LoginPage)));
      final auth = container.listen(authenticationServiceProvider, (_, __) {});
      addTearDown(auth.close);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.loginFailedStorageReason), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('__pref_auth_token__'), '__empty__');
      expect(container.read(authenticationServiceProvider), AuthenticationStatus.unauthenticated);
    });

    testWidgets('서버 실패 뒤 재시도의 응답을 기다리는 동안에는 이전 실패를 다시 처리하지 않는다', (tester) async {
      var attempts = 0;
      final second = Completer<LoginType>();
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'same-key',
        serverLogin: (_, __) {
          attempts++;
          if (attempts == 1) throw Exception('status code of 500');
          return second.future;
        },
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);
      expect(find.text(Strings.loginRetryWith(Strings.providerKakao)), findsOneWidget);

      await tester.tap(find.text(Strings.loginRetryWith(Strings.providerKakao)));
      await _pumpFrames(tester, 6);

      // 재시도 응답 대기 중: 이전 오류로 돌아가지 않고 스피너가 유지된다.
      expect(attempts, 2);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LoginFailureCard), findsNothing);

      second.complete((token: 'server-token', userId: '42'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('서버 응답을 기다리는 동안 스피너를 보여주고 X 는 눌리지 않는다', (tester) async {
      final completer = Completer<LoginType>();
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) => completer.future,
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      await _pumpFrames(tester);
      expect(find.byType(LoginPage), findsOneWidget);

      completer.complete((token: 't', userId: '1'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('서버 응답을 기다리는 동안에는 약관 링크가 눌리지 않는다', (tester) async {
      final completer = Completer<LoginType>();
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) => completer.future,
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester);
      // 스피너가 돌고 있어 pumpAndSettle 은 끝나지 않는다. 다이얼로그 애니메이션만큼만 돌린다.
      await tester.tap(find.text(Strings.terms));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('약관 본문'), findsNothing);

      completer.complete((token: 't', userId: '1'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('다이얼로그가 떠 있는 채로 성공 응답이 와도 로그인 화면까지 닫힌다', (tester) async {
      final completer = Completer<LoginType>();
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'kakao-access',
        serverLogin: (_, __) => completer.future,
      ));
      await _open(tester);
      final pageContext = tester.element(find.byType(LoginPage));

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await _pumpFrames(tester);
      // 응답을 기다리는 사이 로그인 화면 위에 다이얼로그가 떠 있는 상황
      showDialog<void>(
        context: pageContext,
        builder: (_) => const AlertDialog(title: Text('열린 다이얼로그')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('열린 다이얼로그'), findsOneWidget);

      completer.complete((token: 't', userId: '1'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('열린 다이얼로그'), findsNothing);
      expect(find.text('열기'), findsOneWidget);
    });

    testWidgets('Google 키를 받으면 google 타입으로 서버 로그인하고 닫힌다', (tester) async {
      final serverCalls = <(String, String)>[];
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'unused',
        googleKey: () async => 'google-id-token',
        serverLogin: (_, __) async => (token: 'server-token', userId: '42'),
        serverCalls: serverCalls,
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerGoogle)));
      await _pumpFrames(tester);
      await tester.pumpAndSettle();

      expect(serverCalls, [('google', 'google-id-token')]);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('Google 로그인을 취소하면(키 null) Google 원인으로 실패 카드를 보여준다', (tester) async {
      final serverCalls = <(String, String)>[];
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'unused',
        googleKey: () async => null,
        serverLogin: (_, __) async => (token: 'x', userId: '1'),
        serverCalls: serverCalls,
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerGoogle)));
      await _pumpFrames(tester);

      expect(serverCalls, isEmpty);
      expect(find.text(Strings.loginFailedTitle(Strings.providerGoogle)), findsOneWidget);
      expect(find.text(Strings.loginFailedGoogleReason), findsOneWidget);
      expect(find.text(Strings.loginRetryWith(Strings.providerGoogle)), findsOneWidget);
    });

    testWidgets('네이버를 누르면 준비 중 토스트만 띄운다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'x',
        serverLogin: (_, __) async => (token: 'x', userId: '1'),
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.loginWith(Strings.providerNaver)));
      await _pumpFrames(tester);

      expect(find.text(Strings.toastNaverNotReady), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('이용약관을 누르면 약관 다이얼로그가 열린다', (tester) async {
      await tester.pumpWidget(_app(
        kakaoKey: () async => 'x',
        serverLogin: (_, __) async => (token: 'x', userId: '1'),
      ));
      await _open(tester);

      await tester.tap(find.text(Strings.terms));
      await tester.pumpAndSettle();

      expect(find.text('약관 본문'), findsOneWidget);
    });
  });
}
