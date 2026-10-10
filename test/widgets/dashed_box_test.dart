import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/dashed_box.dart';

/// 그려진 화면의 픽셀 중 [color] 와 같은 것의 수. toImage 는 실제 비동기 작업이라 runAsync 안에서 돈다.
Future<int> _countPixels(WidgetTester tester, Color color) async {
  final bytes = await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data;
  });
  var count = 0;
  final data = bytes!;
  for (var i = 0; i < data.lengthInBytes; i += 4) {
    if (data.getUint8(i) == (color.r * 255).round() &&
        data.getUint8(i + 1) == (color.g * 255).round() &&
        data.getUint8(i + 2) == (color.b * 255).round() &&
        data.getUint8(i + 3) == 255) {
      count++;
    }
  }
  return count;
}

void main() {
  group('DashedBox', () {
    testWidgets('테두리를 점선으로 실제로 그린다(테두리 색 픽셀이 있고, 실선보다는 적다)', (tester) async {
      const border = Color(0xFFFF0000);
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: const Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 200,
                height: 100,
                child: DashedBox(color: border, child: SizedBox()),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final painted = await _countPixels(tester, border);
      // 둘레 600px × 두께 1.5 를 전부 칠하면 900 가까이 되지만, 점선(6 그리기 / 4 띄움)이라 그보다 적다.
      expect(painted, greaterThan(100));
      expect(painted, lessThan(800));
    });

    testWidgets('누르면 onTap 이 불린다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        theme: NbkTheme.light,
        home: Scaffold(
          body: DashedBox(height: 96, onTap: () => taps++, child: const Text('사진 추가')),
        ),
      ));

      await tester.tap(find.text('사진 추가'));
      expect(taps, 1);
    });
  });
}
