import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/home/view/widgets/home_tab_view.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/date_format_utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 목록 요청은 모두 빈 목록으로 답한다. 이 테스트는 홈 탭의 상단바와 세그먼트만 본다.
class _EmptyNurbanRepository implements NurbanRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(<BoardAllType>[]);
}

Widget _app() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      nurbanRepositoryProvider.overrideWithValue(_EmptyNurbanRepository()),
      getRankTabProvider.overrideWith((ref, arg) async => []),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: const HomeTabView(),
    ),
  );
}

void main() {
  group('HomeTabView', () {
    testWidgets('상단바에 이번 달 기간 캡션을, 그 아래 주식|코인 세그먼트를 보여준다', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.pump();

      expect(find.text(Strings.thisMonth(formatMonthRange(DateTime.now()))), findsOneWidget);
      expect(find.text(Strings.boardStock), findsOneWidget);
      expect(find.text(Strings.boardCoin), findsOneWidget);
    });
  });
}
