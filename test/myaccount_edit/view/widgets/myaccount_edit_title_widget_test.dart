import 'dart:async';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 저장 요청을 [completer] 로 붙잡아 두는 저장소
class _FakeProfileRepository implements ProfileRepository {
  final completer = Completer<String>();
  var calls = 0;

  @override
  Future<String> profileEdit({
    required String token,
    required String nickname,
    required String description,
    required String insignia,
  }) {
    calls++;
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'});
    // Fluttertoast 는 플랫폼 채널을 쓰므로 테스트에서는 응답만 흉내 낸다.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (_) async => true,
    );
  });

  group('MyaccountEditTitleWidget', () {
    testWidgets('저장 요청 중 화면을 닫아도 성공 응답이 와서 예외가 나지 않는다', (tester) async {
      final repository = _FakeProfileRepository();
      var profileFetches = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          preferenceStorageProvider.overrideWith(
            (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
          ),
          getProfileProvider.overrideWith((ref, token) async {
            profileFetches++;
            throw Exception('not needed');
          }),
        ],
        child: MaterialApp(
          theme: NbkTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: MyaccountEditTitleWidget()),
                  ),
                ),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      // 닉네임·소개가 채워져야 저장 버튼이 요청을 보낸다.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyaccountEditTitleWidget)),
      );
      container.read(myaccountEditNicknameNavigationProvider.notifier).select('제희');
      container.read(myaccountEditDescriptionNavigationProvider.notifier).select('소개');
      await tester.pump();

      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(repository.calls, 1);

      // 응답이 오기 전에 화면을 닫는다.
      Navigator.of(tester.element(find.byType(MyaccountEditTitleWidget))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(MyaccountEditTitleWidget), findsNothing);

      repository.completer.complete('profile_updated');
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(profileFetches, 0);
    });
  });
}
