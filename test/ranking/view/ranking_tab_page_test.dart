import 'dart:async';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/ranking/ranking.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/date_format_utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

typedef _Rank = ({
  int id,
  int totalLossCut,
  int totalLikeCount,
  int userId,
  String badge,
  String nickname,
  Object insignia,
});

class _FakeAuthentication extends AuthenticationService {
  _FakeAuthentication(this.initial);

  final AuthenticationStatus initial;

  @override
  AuthenticationStatus build() => initial;
}

_Rank _rank(int userId, {required int loss, required int likes, String insignia = '[]'}) => (
      id: userId,
      totalLossCut: loss,
      totalLikeCount: likes,
      userId: userId,
      badge: '',
      nickname: '유저$userId',
      insignia: insignia,
    );

final _five = [
  _rank(1, loss: 12480000, likes: 128),
  _rank(2, loss: 8900000, likes: 96),
  _rank(3, loss: 6120000, likes: 71),
  _rank(4, loss: 5400000, likes: 54),
  _rank(5, loss: 430000, likes: 3),
];

Widget _app({
  List<_Rank>? ranks,
  Object? error,
  AuthenticationStatus auth = AuthenticationStatus.authenticated,
  int? myUserId,
  Completer<void>? gate,
  List<int>? calls,
}) {
  SharedPreferences.setMockInitialValues({
    if (myUserId != null) '__pref_user_id__': myUserId,
  });
  return ProviderScope(
    overrides: [
      authenticationServiceProvider.overrideWith(() => _FakeAuthentication(auth)),
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      getRankProvider.overrideWith((ref) async {
        calls?.add(1);
        await gate?.future;
        if (error != null) throw error;
        return ranks ?? [];
      }),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: const RankingTabPage(),
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  group('RankingTabPage', () {
    testWidgets('시상대 3칸(축약 손실액)과 4위 이하 행(전체 손실액)을 응답 순서대로 보여준다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five, myUserId: 99));
      await _pumpFrames(tester);

      expect(find.byType(PodiumColumn), findsNWidgets(3));
      expect(find.text(Strings.thisMonth(formatMonthRange(DateTime.now()))), findsOneWidget);
      expect(find.text('-1,248만원'), findsOneWidget);
      expect(find.text('-890만원'), findsOneWidget);
      expect(find.text('-612만원'), findsOneWidget);
      expect(find.text(Strings.recommend('128')), findsOneWidget);
      expect(find.byType(RankRow), findsNWidgets(2));
      expect(find.text('4'), findsOneWidget);
      expect(find.text('-5,400,000원'), findsOneWidget);
      expect(find.text('-430,000원'), findsOneWidget);
      expect(find.text(Strings.recommend('54')), findsOneWidget);
      expect(find.text(Strings.recommend('3')), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('내가 순위 안에 있으면 하단 바에 내 순위·닉네임·손실액을 보여주고, 누르면 내 계정 탭으로 간다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five, myUserId: 5));
      await _pumpFrames(tester);

      expect(find.text(Strings.rankLabel(5)), findsOneWidget);
      expect(find.text('유저5'), findsNWidgets(2));
      expect(find.text('-430,000원'), findsNWidgets(2));
      expect(find.byType(MyRankBar), findsOneWidget);

      await tester.tap(find.text(Strings.myRank));
      final container = ProviderScope.containerOf(tester.element(find.byType(RankingTabPage)));
      expect(container.read(homeBottomNavigationProvider), HomeBottomStatus.myaccount);
    });

    testWidgets('로그인했지만 순위 밖이면 기록 없음 문구를 보여준다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five, myUserId: 99));
      await _pumpFrames(tester);

      expect(find.text(Strings.myRankNone), findsOneWidget);
    });

    testWidgets('비로그인이면 로그인 안내 문구를 보여준다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five, auth: AuthenticationStatus.unauthenticated, myUserId: 5));
      await _pumpFrames(tester);

      expect(find.text(Strings.myRankLoginCta), findsOneWidget);
      expect(find.text(Strings.rankLabel(5)), findsNothing);
    });

    testWidgets('응답을 기다리는 동안 320dp 폭에서도 스켈레톤이 넘치지 않고, 받으면(휘장 있는 행 포함) 시상대로 바뀐다', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final gate = Completer<void>();
      final ranks = [
        ..._five.take(3),
        _rank(4, loss: 5400000, likes: 54, insignia: '[https://example.com/insignia/0.png]'),
        _five.last,
      ];
      await tester.pumpWidget(_app(ranks: ranks, myUserId: 5, gate: gate));
      await _pumpFrames(tester);

      expect(find.byType(PodiumSkeleton), findsOneWidget);
      expect(find.byType(MyRankBar), findsOneWidget);
      expect(tester.takeException(), isNull);

      gate.complete();
      await _pumpFrames(tester);
      expect(find.byType(PodiumColumn), findsNWidgets(3));
      expect(find.text(Strings.rankLabel(5)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('당겨서 새로고침하면 랭킹을 다시 받는다', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(_app(ranks: _five, myUserId: 99, calls: calls));
      await _pumpFrames(tester);
      expect(calls, hasLength(1));

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(calls, hasLength(2));
    });

    testWidgets('비로그인 CTA 를 누르면 로그인 화면이 열린다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five, auth: AuthenticationStatus.unauthenticated));
      await _pumpFrames(tester);

      await tester.tap(find.text(Strings.myRankLoginCta));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('랭킹이 비면 빈 상태를 보여준다', (tester) async {
      await tester.pumpWidget(_app(ranks: [], myUserId: 1));
      await _pumpFrames(tester);

      expect(find.text(Strings.rankingEmptyTitle), findsOneWidget);
      expect(find.byType(PodiumColumn), findsNothing);
    });

    testWidgets('받지 못하면 오류 상태를 보여주고 다시 시도하면 다시 받는다', (tester) async {
      var calls = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authenticationServiceProvider.overrideWith(() => _FakeAuthentication(AuthenticationStatus.unauthenticated)),
          preferenceStorageProvider.overrideWith(
            (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
          ),
          getRankProvider.overrideWith((ref) async {
            calls++;
            if (calls == 1) throw Exception('connection error');
            return _five;
          }),
        ],
        child: MaterialApp(theme: NbkTheme.light, home: const RankingTabPage()),
      ));
      await _pumpFrames(tester);
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(find.text(Strings.retry));
      await _pumpFrames(tester);

      expect(calls, 2);
      expect(find.byType(PodiumColumn), findsNWidgets(3));
    });

    testWidgets('빈 상태에서 당겨서 새로고침하면 다시 받아 시상대를 보여준다', (tester) async {
      var calls = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authenticationServiceProvider.overrideWith(() => _FakeAuthentication(AuthenticationStatus.unauthenticated)),
          preferenceStorageProvider.overrideWith(
            (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
          ),
          getRankProvider.overrideWith((ref) async => ++calls == 1 ? [] : _five),
        ],
        child: MaterialApp(theme: NbkTheme.light, home: const RankingTabPage()),
      ));
      await _pumpFrames(tester);
      expect(find.text(Strings.rankingEmptyTitle), findsOneWidget);

      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(calls, 2);
      expect(find.byType(PodiumColumn), findsNWidgets(3));
    });

    testWidgets('오류 상태에서도 당겨서 새로고침하면 다시 받는다', (tester) async {
      var calls = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authenticationServiceProvider.overrideWith(() => _FakeAuthentication(AuthenticationStatus.unauthenticated)),
          preferenceStorageProvider.overrideWith(
            (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
          ),
          getRankProvider.overrideWith((ref) async {
            calls++;
            if (calls == 1) throw Exception('connection error');
            return _five;
          }),
        ],
        child: MaterialApp(theme: NbkTheme.light, home: const RankingTabPage()),
      ));
      await _pumpFrames(tester);
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await _pumpFrames(tester);

      expect(calls, 2);
      expect(find.byType(PodiumColumn), findsNWidgets(3));
    });

    testWidgets('정확히 3명이면 시상대만 있고 띠와 행은 없다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five.take(3).toList(), myUserId: 99));
      await _pumpFrames(tester);

      expect(find.byType(PodiumColumn), findsNWidgets(3));
      expect(find.text('유저3'), findsOneWidget);
      expect(find.byType(SectionBand), findsNothing);
      expect(find.byType(RankRow), findsNothing);
    });

    testWidgets('3명보다 적으면 있는 칸만 채우고 띠와 행은 없다', (tester) async {
      await tester.pumpWidget(_app(ranks: _five.take(2).toList(), myUserId: 1));
      await _pumpFrames(tester);

      expect(find.byType(PodiumColumn), findsNWidgets(3));
      expect(find.text('유저1'), findsNWidgets(2));
      expect(find.text('유저2'), findsOneWidget);
      expect(find.byType(RankRow), findsNothing);
      expect(find.byType(SectionBand), findsNothing);
    });
  });
}
