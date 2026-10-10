import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';

Widget _view({
  LoginTypeStatus? inProgress,
  LoginTypeStatus? failed,
  String? failureReason,
  ValueChanged<LoginTypeStatus>? onSignIn,
  VoidCallback? onClose,
  VoidCallback? onTerms,
  VoidCallback? onPrivacy,
}) {
  return MaterialApp(
    theme: NbkTheme.light,
    home: LoginView(
      inProgress: inProgress,
      failed: failed,
      failureReason: failureReason,
      onClose: onClose ?? () {},
      onSignIn: onSignIn ?? (_) {},
      onTerms: onTerms ?? () {},
      onPrivacy: onPrivacy ?? () {},
    ),
  );
}

void main() {
  group('LoginView', () {
    testWidgets('기본 상태: 제목·설명·버튼 3개·안내 링크를 보여주고 버튼을 누르면 onSignIn 이 불린다', (tester) async {
      final signIns = <LoginTypeStatus>[];
      await tester.pumpWidget(_view(onSignIn: signIns.add));

      expect(find.text(Strings.loginTitle), findsOneWidget);
      expect(find.text(Strings.loginDescription), findsOneWidget);
      expect(find.byType(SocialLoginButton), findsNWidgets(3));
      expect(find.byType(LoginFailureCard), findsNothing);

      await tester.tap(find.text(Strings.loginWith(Strings.providerKakao)));
      await tester.tap(find.text(Strings.loginWith(Strings.providerGoogle)));
      expect(signIns, [LoginTypeStatus.kakao, LoginTypeStatus.google]);
    });

    testWidgets('진행 중이면 누른 버튼엔 스피너, 나머지 버튼과 X 는 비활성, 설명이 진행 문구로 바뀐다', (tester) async {
      final signIns = <LoginTypeStatus>[];
      var closed = 0;
      await tester.pumpWidget(_view(
        inProgress: LoginTypeStatus.kakao,
        onSignIn: signIns.add,
        onClose: () => closed++,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(Strings.loginWith(Strings.providerKakao)), findsNothing);
      expect(find.text(Strings.loginInProgress(Strings.providerKakao)), findsOneWidget);

      await tester.tap(find.text(Strings.loginWith(Strings.providerGoogle)), warnIfMissed: false);
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      expect(signIns, isEmpty);
      expect(closed, 0);
    });

    testWidgets('실패하면 실패 카드를 띄우고 그 버튼 라벨이 다시 로그인으로 바뀐다', (tester) async {
      await tester.pumpWidget(_view(
        failed: LoginTypeStatus.kakao,
        failureReason: Strings.loginFailedKakaoReason,
      ));

      expect(find.text(Strings.loginFailedTitle(Strings.providerKakao)), findsOneWidget);
      expect(find.text(Strings.loginFailedKakaoReason), findsOneWidget);
      expect(find.text(Strings.loginRetryWith(Strings.providerKakao)), findsOneWidget);
      expect(find.text(Strings.loginWith(Strings.providerGoogle)), findsOneWidget);
    });

    testWidgets('안내의 이용약관·개인정보 처리방침 링크를 누르면 콜백이 불린다', (tester) async {
      var terms = 0;
      var privacy = 0;
      await tester.pumpWidget(_view(onTerms: () => terms++, onPrivacy: () => privacy++));

      await tester.tap(find.text(Strings.terms));
      await tester.tap(find.text(Strings.privacy));
      expect(terms, 1);
      expect(privacy, 1);
    });

    testWidgets('X 를 누르면 onClose 가 불린다', (tester) async {
      var closed = 0;
      await tester.pumpWidget(_view(onClose: () => closed++));

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, 1);
    });
  });
}
