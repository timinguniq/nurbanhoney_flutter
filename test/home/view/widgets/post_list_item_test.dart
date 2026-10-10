import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/home/view/widgets/post_list_item.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

Widget _item({
  String thumbnailUrl = '',
  bool liked = false,
  int likeCount = 34,
  Future<void> Function({required bool like})? onToggleLike,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    theme: NbkTheme.light,
    home: Scaffold(
      body: PostListItem(
        badgeUrl: '',
        nickname: '삼전홀더',
        insigniaUrls: const [],
        timeLabel: '2시간 전',
        lossAmount: 1250000,
        title: '삼전 물타기 실패했습니다',
        body: '7만전자에서 물 타고 6만전자에서 또 탔는데',
        thumbnailUrl: thumbnailUrl,
        likeCount: likeCount,
        liked: liked,
        commentCount: 12,
        onTap: onTap ?? () {},
        onToggleLike: onToggleLike ?? ({required bool like}) async {},
      ),
    ),
  );
}

void main() {
  group('PostListItem', () {
    testWidgets('작성자·상대 시간·손실액·제목·본문·카운트를 보여준다', (tester) async {
      await tester.pumpWidget(_item());

      expect(find.text('삼전홀더'), findsOneWidget);
      expect(find.text('2시간 전'), findsOneWidget);
      expect(find.text('-1,250,000원'), findsOneWidget);
      expect(find.text('삼전 물타기 실패했습니다'), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets("썸네일 URL 이 비었거나 'null' 이면 썸네일을 그리지 않는다", (tester) async {
      await tester.pumpWidget(_item(thumbnailUrl: 'null'));
      expect(find.byType(NbkThumbnail), findsNothing);

      await tester.pumpWidget(_item(thumbnailUrl: 'https://example.com/a.png'));
      expect(find.byType(NbkThumbnail), findsOneWidget);
    });

    testWidgets('좋아요를 누르면 현재 상태의 반대로 onToggleLike 를 부른다', (tester) async {
      final requested = <bool>[];
      await tester.pumpWidget(_item(onToggleLike: ({required bool like}) async => requested.add(like)));
      await tester.tap(find.byType(ReactionButton));
      expect(requested, [true]);

      await tester.pumpWidget(_item(liked: true, onToggleLike: ({required bool like}) async => requested.add(like)));
      await tester.tap(find.byType(ReactionButton));
      expect(requested, [true, false]);
    });

    testWidgets('응답을 기다리는 동안 다시 눌러도 한 번만 부른다', (tester) async {
      final completer = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(_item(onToggleLike: ({required bool like}) {
        calls++;
        return completer.future;
      }));

      await tester.tap(find.byType(ReactionButton));
      await tester.tap(find.byType(ReactionButton));
      expect(calls, 1);

      completer.complete();
      await tester.pump();
      await tester.tap(find.byType(ReactionButton));
      expect(calls, 2);
    });

    testWidgets('아이템을 누르면 onTap 이 불린다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_item(onTap: () => taps++));

      await tester.tap(find.text('삼전 물타기 실패했습니다'));
      expect(taps, 1);
    });
  });
}
