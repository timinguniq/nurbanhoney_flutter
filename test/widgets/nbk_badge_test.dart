import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_badge.dart';
import 'package:nurbanhoney/widgets/nbk_symbol.dart';

Widget _app(String? url) => MaterialApp(
      theme: NbkTheme.light,
      home: Scaffold(body: NbkBadge(url: url, size: 36, radius: 10)),
    );

void main() {
  group('NbkBadge', () {
    testWidgets('URL 이 없으면(null) 너반꿀 심볼을 보여준다', (tester) async {
      await tester.pumpWidget(_app(null));

      expect(find.byType(NbkSymbol), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('빈 문자열도 URL 이 없는 것으로 본다', (tester) async {
      await tester.pumpWidget(_app(''));

      expect(find.byType(NbkSymbol), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('URL 이 있으면 네트워크 이미지를 그린다', (tester) async {
      await tester.pumpWidget(_app('https://example.test/badge/1.png'));

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
