import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/view/widgets/widgets.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

import '../../config/src/secret.dart';

/// 소셜 SDK 에서 받은 키(카카오 액세스 토큰·Google ID 토큰). 비어 있거나 null 이면 취소·실패.
typedef SocialKeyProvider = Future<String?> Function();

/// 로그인(풀스크린 모달). 소셜 SDK 로 받은 키를 [getLoginProvider] 에 넘겨 서버 토큰을 받고,
/// 성공하면 토큰·userId 를 저장하고 인증 상태를 바꾼 뒤 직전 화면으로 돌아간다.
/// [kakaoKey]·[googleKey] 는 테스트에서 SDK 대신 끼워 넣기 위한 것이다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    this.kakaoKey = kakaoAccessToken,
    this.googleKey = googleIdToken,
    super.key,
  });

  final SocialKeyProvider kakaoKey;
  final SocialKeyProvider googleKey;

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginPage(),
    );
  }

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  LoginTypeStatus? _inProgress;
  LoginTypeStatus? _failed;
  String? _failureReason;

  /// 진행 중인 서버 로그인 구독. 결과를 한 번 처리하면 닫는다.
  ProviderSubscription<AsyncValue<({String token, int userId})>>? _serverLogin;

  @override
  void dispose() {
    _serverLogin?.close();
    super.dispose();
  }

  static String _typeName(LoginTypeStatus type) => switch (type) {
        LoginTypeStatus.naver => 'naver',
        LoginTypeStatus.google => 'google',
        LoginTypeStatus.kakao || LoginTypeStatus.init => 'kakao',
      };

  Future<void> _signIn(LoginTypeStatus type) async {
    if (type == LoginTypeStatus.naver) {
      NbkToast.info(Strings.toastNaverNotReady);
      return;
    }
    setState(() {
      _inProgress = type;
      _failed = null;
      _failureReason = null;
    });

    String? key;
    try {
      key = type == LoginTypeStatus.kakao ? await widget.kakaoKey() : await widget.googleKey();
    } catch (e) {
      log('$type sign-in error: $e');
      key = null;
    }
    if (!mounted) return;
    if (key == null || key.isEmpty) {
      _fail(
        type,
        type == LoginTypeStatus.kakao
            ? Strings.loginFailedKakaoReason
            : Strings.loginFailedGoogleReason,
      );
      return;
    }
    _requestServerLogin(type, key);
  }

  /// 서버 로그인([getLoginProvider])을 받아 결과를 한 번만 처리한다.
  /// 같은 키로 다시 시도하면 invalidate 로 오류 상태를 버리고 새로 받는다. 받는 동안(isLoading)은
  /// 이전 값·오류가 남아 있으므로 건너뛴다.
  void _requestServerLogin(LoginTypeStatus type, String key) {
    final provider = getLoginProvider((_typeName(type), key, null));
    _serverLogin?.close();
    ref.invalidate(provider);
    _serverLogin = ref.listenManual(
      provider,
      (_, next) {
        if (next.isLoading) return;
        _serverLogin?.close();
        _serverLogin = null;
        final login = next.valueOrNull;
        // 저장소가 빈 토큰·숫자가 아닌 userId 를 실패(ApiFailure)로 돌려주므로 값이 있으면 성공이다.
        if (login != null) {
          _succeed(type, login);
        } else {
          log('server login error: ${next.error}');
          _fail(type, Strings.loginFailedServerReason);
        }
      },
      fireImmediately: true,
    );
  }

  void _fail(LoginTypeStatus type, String reason) {
    setState(() {
      _inProgress = null;
      _failed = type;
      _failureReason = reason;
    });
  }

  /// 서버 토큰을 저장소에 쓴 뒤에만 인증 상태를 바꾸고 닫는다. 저장소가 아직 준비 전이면 기다리고,
  /// 저장에 실패하면 실패 카드로 돌아간다(저장 없이 인증 상태만 바꾸면 다음 실행에서 로그아웃된 채 시작한다).
  Future<void> _succeed(LoginTypeStatus type, ({String token, int userId}) login) async {
    try {
      final storage = await ref.read(preferenceStorageProvider.future);
      try {
        await storage.setToken(login.token);
        await storage.setUserId(login.userId);
      } catch (e) {
        // 토큰만 남으면 다음 실행에서 userId 없이 인증된 채 시작하므로 되돌린다.
        try {
          await storage.setEmptyToken();
        } catch (rollback) {
          log('login storage rollback error: $rollback');
        }
        rethrow;
      }
    } catch (e) {
      log('login storage error: $e');
      if (mounted) _fail(type, Strings.loginFailedStorageReason);
      return;
    }
    if (!mounted) return;
    ref.read(authenticationServiceProvider.notifier).set(AuthenticationStatus.authenticated);
    // 위에 다이얼로그가 떠 있으면 먼저 닫고, 로그인 화면 자체를 닫는다.
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    if (route == null) return;
    navigator.popUntil((r) => r == route);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // 성공 시 토큰을 바로 저장할 수 있게 저장소를 미리 받아 둔다.
    ref.watch(preferenceStorageProvider);

    return LoginView(
      inProgress: _inProgress,
      failed: _failed,
      failureReason: _failureReason,
      onClose: () => Navigator.of(context).maybePop(),
      onSignIn: _signIn,
      onTerms: _inProgress != null
          ? null
          : () => showPolicyDialog(context, title: Strings.terms, provider: getTermsProvider),
      onPrivacy: _inProgress != null
          ? null
          : () => showPolicyDialog(context, title: Strings.privacy, provider: getPrivacyProvider),
    );
  }
}

/// 카카오 로그인. 카카오톡이 설치돼 있으면 카카오톡으로, 아니면 카카오계정으로 로그인한다. 취소·실패면 빈 문자열.
Future<String?> kakaoAccessToken() async {
  if (await isKakaoTalkInstalled()) {
    try {
      final token = await UserApi.instance.loginWithKakaoTalk();
      return token.accessToken;
    } catch (error) {
      log('카카오톡으로 로그인 실패 $error');
      // 카카오톡 설치 후 권한 요청 화면에서 로그인을 취소한 경우는 의도적인 취소로 보고 카카오계정 로그인을 띄우지 않는다.
      if (error is PlatformException && error.code == 'CANCELED') return '';
    }
  }
  try {
    final token = await UserApi.instance.loginWithKakaoAccount();
    return token.accessToken;
  } catch (error) {
    log('카카오계정으로 로그인 실패 $error');
    return '';
  }
}

bool _googleInitialized = false;

/// Google 로그인. 기존처럼 가벼운 인증(attemptLightweightAuthentication)으로 계정을 받아 ID 토큰을 돌려준다.
/// 계정을 받지 못하면 null.
Future<String?> googleIdToken() async {
  final signIn = GoogleSignIn.instance;
  if (!_googleInitialized) {
    await signIn.initialize(serverClientId: webClientId);
    _googleInitialized = true;
  }
  final account = await signIn.attemptLightweightAuthentication();
  return account?.authentication.idToken;
}
