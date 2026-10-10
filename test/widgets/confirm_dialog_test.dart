import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/confirm_dialog.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

/// 버튼을 누르면 다이얼로그를 띄우고 결과를 [onResult] 로 돌려주는 테스트용 화면
Widget _host({String? checkboxLabel, required ValueChanged<bool> onResult}) {
  return MaterialApp(
    theme: NbkTheme.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showConfirmDialog(
              context,
              title: '정말 탈퇴할까요?',
              message: '되돌릴 수 없어요.',
              confirmLabel: '탈퇴',
              icon: Icons.warning_amber_rounded,
              checkboxLabel: checkboxLabel,
            );
            onResult(result);
          },
          child: const Text('열기'),
        ),
      ),
    ),
  );
}

void main() {
  group('showConfirmDialog', () {
    testWidgets('확인을 누르면 true 를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(onResult: (r) => result = r));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('탈퇴'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('취소를 누르면 false 를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(onResult: (r) => result = r));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('바깥을 눌러 닫으면 false 를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(onResult: (r) => result = r));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('체크박스가 있으면 체크 전에는 확인 버튼이 비활성이다', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _host(checkboxLabel: '위 내용을 확인했어요', onResult: (r) => result = r),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      final confirm = find.widgetWithText(NbkButton, '탈퇴');
      expect(tester.widget<NbkButton>(confirm).onPressed, isNull);

      await tester.tap(find.text('위 내용을 확인했어요'));
      await tester.pumpAndSettle();
      expect(tester.widget<NbkButton>(confirm).onPressed, isNotNull);

      await tester.tap(find.text('탈퇴'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });
}
