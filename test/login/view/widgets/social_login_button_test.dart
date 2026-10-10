import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/login/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 세로 Column 안에 두면 부모가 가로 크기를 강제하지 않는다(디자인에서 버튼은 그래도 화면을 가로로 채운다).
Widget _app(Widget child) {
  return MaterialApp(
    theme: NbkTheme.light,
    home: Scaffold(body: Column(children: [child])),
  );
}

double _screenWidth(WidgetTester tester) => tester.view.physicalSize.width / tester.view.devicePixelRatio;

void main() {
  group('SocialLoginButton', () {
    testWidgets('부모가 너비를 정해 주지 않아도 가로로 꽉 차고(높이 52) 아이콘은 왼쪽 20 에 놓인다', (tester) async {
      await tester.pumpWidget(_app(SocialLoginButton(
        provider: LoginTypeStatus.kakao,
        label: '카카오로 로그인',
        onPressed: () {},
      )));

      final button = tester.getRect(find.byType(SocialLoginButton));
      expect(button.width, _screenWidth(tester));
      expect(button.height, NbkSize.buttonLg);

      final icon = tester.getRect(find.byType(Image));
      expect(icon.left - button.left, NbkSpacing.xl);
      expect(icon.width, NbkSize.iconSm);
      expect(icon.center.dy, button.center.dy);

      // 라벨은 아이콘과 겹치지 않고 버튼 가운데에 온다.
      final label = tester.getRect(find.text('카카오로 로그인'));
      expect(label.left, greaterThan(icon.right));
      expect(label.center.dx, moreOrLessEquals(button.center.dx, epsilon: 1));
    });

    testWidgets('loading 이면 라벨 대신 스피너를 보이고 눌리지 않는다', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_app(SocialLoginButton(
        provider: LoginTypeStatus.google,
        label: 'Google로 로그인',
        loading: true,
        onPressed: () => pressed++,
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Google로 로그인'), findsNothing);
      // 스피너가 있어도 버튼 폭은 그대로 화면을 채운다.
      expect(tester.getRect(find.byType(SocialLoginButton)).width, _screenWidth(tester));

      await tester.tap(find.byType(SocialLoginButton), warnIfMissed: false);
      expect(pressed, 0);
    });

    testWidgets('dimmed 면 0.4 로 흐려지고 눌리지 않는다', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_app(SocialLoginButton(
        provider: LoginTypeStatus.naver,
        label: '네이버로 로그인',
        dimmed: true,
        onPressed: () => pressed++,
      )));

      final opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(SocialLoginButton),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, 0.4);

      await tester.tap(find.byType(SocialLoginButton), warnIfMissed: false);
      expect(pressed, 0);
    });
  });
}
