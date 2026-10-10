import 'dart:async';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 프로필 수정 요청만 흉내 내는 저장소
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.result = 'profile_updated', this.gate, this.throws = false});

  final String result;

  /// 있으면 저장 응답을 이 Completer 가 끝날 때까지 미룬다
  final Completer<void>? gate;
  final bool throws;
  Map<String, String>? edited;
  var calls = 0;

  @override
  Future<String> profileEdit({
    required String token,
    required String nickname,
    required String description,
    required String insignia,
  }) async {
    calls++;
    edited = {'nickname': nickname, 'description': description, 'insignia': insignia};
    await gate?.future;
    if (throws) throw Exception('connection error');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _a = 'https://example.com/insignia/0.png';
const _b = 'https://example.com/insignia/1.png';
const _c = 'https://example.com/insignia/2.png';

ProfileType _profile({String show = '[$_a]', String description = '장기투자자였는데'}) => (
      id: 7,
      loginType: 'kakao',
      badge: '',
      nickname: '제희',
      description: description,
      point: 0,
      insigniaShow: show,
      insigniaOwn: '[$_a, $_b, $_c]',
      myArticleCount: 0,
      myCommentCount: 0,
    );

Widget _app({ProfileType? profile, _FakeProfileRepository? repository, List<int>? profileFetches}) {
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      getProfileProvider.overrideWith((ref, token) async {
        profileFetches?.add(1);
        return profile ?? _profile();
      }),
      profileRepositoryProvider.overrideWithValue(repository ?? _FakeProfileRepository()),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MyaccountEditPage.route()),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

/// 폼 전체가 한 화면에 들어오게 세로로 긴 화면을 쓰고(ListView 는 보이는 항목만 만든다), route 전환까지 돌린다.
Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

/// 보유 휘장 그리드의 n 번째 타일
Finder _ownedTile(int index) => find.descendant(
      of: find.byType(GridView),
      matching: find.byType(InsigniaTile),
    ).at(index);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'}));
  tearDown(NbkToast.hide);

  group('MyaccountEditPage', () {
    testWidgets('프로필 값으로 닉네임·소개·보이는 휘장을 채우고 카운터를 보여준다', (tester) async {
      await tester.pumpWidget(_app());
      await _open(tester);

      expect(find.widgetWithText(TextField, '제희'), findsOneWidget);
      expect(find.widgetWithText(TextField, '장기투자자였는데'), findsOneWidget);
      expect(find.text('2/${MyaccountEditPage.nicknameMaxLength}'), findsOneWidget);
      expect(find.text('1/${MyaccountEditPage.maxShownInsignia}'), findsOneWidget);
      expect(find.text(Strings.ownedInsigniaLabel(3)), findsOneWidget);
      expect(find.text(Strings.nicknameAvailable), findsOneWidget);
      expect(find.byType(InsigniaCheck), findsOneWidget);
    });

    testWidgets('서버가 보이는 휘장을 3개 이상 주면 앞 2개만 보이고 저장도 2개만 보낸다', (tester) async {
      final repository = _FakeProfileRepository();
      await tester.pumpWidget(_app(
        profile: _profile(show: '[$_a, $_b, $_c, $_a]'),
        repository: repository,
      ));
      await _open(tester);

      expect(find.text('2/${MyaccountEditPage.maxShownInsignia}'), findsOneWidget);
      expect(find.byType(InsigniaRemove), findsNWidgets(2));
      expect(find.text(Strings.shownInsigniaFull), findsOneWidget);

      await tester.tap(find.text(Strings.save));
      await tester.pumpAndSettle();
      expect(repository.edited!['insignia'], '{$_a, $_b}');
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets("소개가 'null' 이면 빈칸으로 채운다", (tester) async {
      await tester.pumpWidget(_app(profile: _profile(description: 'null')));
      await _open(tester);

      expect(find.text('null'), findsNothing);
      expect(find.text('0/${MyaccountEditPage.introMaxLength}'), findsOneWidget);
    });

    testWidgets('보이는 휘장이 2개 차면 보유 휘장을 눌러도 추가되지 않고 안내가 보인다', (tester) async {
      await tester.pumpWidget(_app(profile: _profile(show: '[$_a, $_b]')));
      await _open(tester);
      expect(find.text(Strings.shownInsigniaFull), findsOneWidget);
      expect(find.byType(InsigniaCheck), findsNWidgets(2));

      await tester.tap(_ownedTile(2));
      await _pumpFrames(tester);

      expect(find.byType(InsigniaCheck), findsNWidgets(2));
      expect(find.text('2/${MyaccountEditPage.maxShownInsignia}'), findsOneWidget);
    });

    testWidgets('보이는 휘장의 X 로 빼면 보유 휘장을 다시 고를 수 있다', (tester) async {
      await tester.pumpWidget(_app(profile: _profile(show: '[$_a, $_b]')));
      await _open(tester);

      await tester.tap(find.byType(InsigniaRemove).first);
      await _pumpFrames(tester);
      expect(find.byType(InsigniaCheck), findsOneWidget);
      expect(find.text(Strings.shownInsigniaFull), findsNothing);

      await tester.tap(_ownedTile(2));
      await _pumpFrames(tester);
      expect(find.byType(InsigniaCheck), findsNWidgets(2));
    });

    testWidgets('저장하면 닉네임·소개·휘장(기존 형식)을 보내고 프로필을 다시 받은 뒤 닫힌다', (tester) async {
      final repository = _FakeProfileRepository();
      final fetches = <int>[];
      await tester.pumpWidget(_app(repository: repository, profileFetches: fetches));
      await _open(tester);
      // 실제 앱에서는 내 계정 탭이 프로필을 계속 구독한다. 저장 후 다시 받는지 보기 위해 구독을 잡아 둔다.
      final container = ProviderScope.containerOf(tester.element(find.byType(MyaccountEditPage)));
      final profile = container.listen(getProfileProvider('token-1'), (_, __) {});
      addTearDown(profile.close);
      final fetchesBefore = fetches.length;

      await tester.enterText(find.widgetWithText(TextField, '제희'), '새이름');
      await tester.tap(_ownedTile(1));
      await _pumpFrames(tester);

      await tester.tap(find.text(Strings.save));
      await tester.pumpAndSettle();

      expect(repository.edited, {
        'nickname': '새이름',
        'description': '장기투자자였는데',
        'insignia': '{$_a, $_b}',
      });
      expect(fetches, hasLength(fetchesBefore + 1));
      expect(find.byType(MyaccountEditPage), findsNothing);
      expect(find.text(Strings.toastProfileSaved), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('닉네임이 비어 있으면 저장하지 않고 오류를 표시한다', (tester) async {
      final repository = _FakeProfileRepository();
      await tester.pumpWidget(_app(repository: repository));
      await _open(tester);
      await tester.enterText(find.widgetWithText(TextField, '제희'), '');
      await _pumpFrames(tester);

      await tester.tap(find.text(Strings.save));
      await _pumpFrames(tester);

      expect(repository.edited, isNull);
      expect(find.text(Strings.nicknameRequired), findsNWidgets(2));
      expect(find.byType(MyaccountEditPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('저장 응답을 기다리는 동안 다시 눌러도 한 번만 보내고, 화면을 떠난 뒤 응답이 와도 예외가 없다', (tester) async {
      final gate = Completer<void>();
      final repository = _FakeProfileRepository(gate: gate);
      await tester.pumpWidget(_app(repository: repository));
      await _open(tester);

      await tester.tap(find.text(Strings.save));
      await _pumpFrames(tester);
      await tester.tap(find.text(Strings.save), warnIfMissed: false);
      await _pumpFrames(tester);
      expect(repository.calls, 1);

      Navigator.of(tester.element(find.byType(MyaccountEditPage))).pop();
      await tester.pumpAndSettle();
      gate.complete();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MyaccountEditPage), findsNothing);
    });

    testWidgets('저장 요청이 예외를 던지면 실패 토스트를 띄우고 다시 저장할 수 있다', (tester) async {
      final repository = _FakeProfileRepository(throws: true);
      await tester.pumpWidget(_app(repository: repository));
      await _open(tester);

      await tester.tap(find.text(Strings.save));
      await _pumpFrames(tester, 6);
      expect(find.text(Strings.toastProfileSaveFailed), findsOneWidget);
      expect(find.byType(MyaccountEditPage), findsOneWidget);

      await tester.tap(find.text(Strings.save));
      await _pumpFrames(tester, 6);
      expect(repository.calls, 2);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('저장에 실패하면 오류 토스트를 띄우고 화면은 그대로다', (tester) async {
      await tester.pumpWidget(_app(repository: _FakeProfileRepository(result: 'error')));
      await _open(tester);

      await tester.tap(find.text(Strings.save));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastProfileSaveFailed), findsOneWidget);
      expect(find.byType(MyaccountEditPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
