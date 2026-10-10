import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

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

      // 나머지 버튼과 X 는 0.4 로 흐려진다.
      final googleOpacity = tester.widget<Opacity>(find.ancestor(
        of: find.text(Strings.loginWith(Strings.providerGoogle)),
        matching: find.byType(Opacity),
      ).first);
      expect(googleOpacity.opacity, 0.4);
      final closeOpacity = tester.widget<Opacity>(find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(Opacity),
      ).first);
      expect(closeOpacity.opacity, 0.4);
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

    testWidgets('버튼 3개와 실패 카드는 좌우 20 여백으로 화면 너비를 채운다', (tester) async {
      await tester.pumpWidget(_view(failed: LoginTypeStatus.kakao));
      final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;

      final buttons = find.byType(SocialLoginButton);
      expect(buttons, findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        final rect = tester.getRect(buttons.at(i));
        expect(rect.left, NbkSpacing.xl, reason: '$i번째 버튼 왼쪽');
        expect(rect.right, width - NbkSpacing.xl, reason: '$i번째 버튼 오른쪽');
        expect(rect.height, NbkSize.buttonLg, reason: '$i번째 버튼 높이');
      }
      // 버튼 사이 간격 10
      expect(
        tester.getRect(buttons.at(1)).top - tester.getRect(buttons.at(0)).bottom,
        NbkSpacing.sm + NbkSpacing.xxs,
      );

      final card = tester.getRect(find.byType(LoginFailureCard));
      expect(card.left, NbkSpacing.xl);
      expect(card.right, width - NbkSpacing.xl);
    });

    testWidgets('X 를 누르면 onClose 가 불린다', (tester) async {
      var closed = 0;
      await tester.pumpWidget(_view(onClose: () => closed++));

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, 1);
    });

    testWidgets('390×844 에서 중앙 블록은 아래 24 여백만큼 가운데보다 위에, 안내는 바닥에서 24 위에 놓인다', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_view());

      // design/login.png 문구 그대로
      expect(
        find.text('글 작성·추천·댓글은 로그인 후 이용할 수 있어요.\n둘러보기는 로그인 없이 가능합니다.'),
        findsOneWidget,
      );

      final close = tester.getRect(find.byType(NbkIconButton));
      final logo = tester.getRect(find.byType(NbkLogo));
      final description = tester.getRect(find.text(Strings.loginDescription));
      final kakao = tester.getRect(find.byType(SocialLoginButton).first);
      final notice = tester.getRect(find.byType(LoginNotice));

      // X 행(위아래 4) 아래부터 하단 블록(위 여백 16) 위까지가 중앙 영역. 블록은 그 안에서 아래 24 여백을 두고 가운데.
      final topGap = logo.top - (close.bottom + 4);
      final bottomGap = (kakao.top - 16) - description.bottom;
      expect(bottomGap - topGap, moreOrLessEquals(24, epsilon: 0.5));
      expect(notice.bottom, 844 - 24);
    });

    testWidgets('X 는 48 터치 영역으로 왼쪽 8·위 4 에 놓인다', (tester) async {
      await tester.pumpWidget(_view());

      final button = tester.getRect(find.byType(NbkIconButton));
      expect(button.size, const Size(NbkSize.iconButton, NbkSize.iconButton));
      expect(button.left, NbkSpacing.sm);
      expect(button.top, NbkSpacing.xs);
    });
  });
}
