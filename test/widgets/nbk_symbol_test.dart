import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 심볼을 1:1 로 래스터화해 픽셀 색을 돌려준다. 골든 파일 없이 도형 크기를 확인하기 위한 것이다.
Future<Color Function(int x, int y)> _rasterize(
  WidgetTester tester,
  double size, {
  double pixelRatio = 1,
}) async {
  final key = GlobalKey();
  await tester.pumpWidget(Center(
    child: RepaintBoundary(key: key, child: NbkSymbol(size: size)),
  ));

  late Uint8List rgba;
  late int width;
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    width = image.width;
    rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
  });
  return (x, y) {
    final i = (y * width + x) * 4;
    return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
  };
}

bool _isHoney(Color c) =>
    c.a > 0.9 &&
    (c.r * 255 - NbkColors.honey.r * 255).abs() < 8 &&
    (c.g * 255 - NbkColors.honey.g * 255).abs() < 8 &&
    (c.b * 255 - NbkColors.honey.b * 255).abs() < 8;

void main() {
  group('NbkSymbol', () {
    testWidgets('72 상자에 육각형은 높이 60(위아래 6 여백)·폭 52(좌우 10 여백)로 그리고 가운데는 물방울로 비운다',
        (tester) async {
      final at = await _rasterize(tester, NbkSize.symbolLg);

      // 세로: 꼭짓점 위아래 여백 6
      expect(_isHoney(at(36, 3)), isFalse, reason: '위 여백 안');
      expect(_isHoney(at(36, 9)), isTrue, reason: '위 꼭짓점 안쪽');
      expect(_isHoney(at(36, 62)), isTrue, reason: '아래 꼭짓점 안쪽');
      expect(_isHoney(at(36, 68)), isFalse, reason: '아래 여백 안');

      // 가로: 평평한 변 좌우 여백 10
      expect(_isHoney(at(5, 36)), isFalse, reason: '왼쪽 여백 안');
      expect(_isHoney(at(13, 36)), isTrue, reason: '왼쪽 변 안쪽');
      expect(_isHoney(at(58, 36)), isTrue, reason: '오른쪽 변 안쪽');
      expect(_isHoney(at(66, 36)), isFalse, reason: '오른쪽 여백 안');

      // 물방울(bg 색)이 가운데를 비운다
      expect(_isHoney(at(36, 36)), isFalse, reason: '물방울 안');
      expect(at(36, 36).a, greaterThan(0.9), reason: '물방울은 투명이 아니라 bg 색');
    });

    testWidgets('물방울은 가장 넓은 곳(육각형 가운데서 5.1 아래)에서 폭 17.4 다(10배 래스터)', (tester) async {
      final at = await _rasterize(tester, NbkSize.symbolLg, pixelRatio: 10);

      // 72 상자 → 육각형 60. 물방울 아래 반원의 중심은 y 36 + 60×0.085 = 41.1, 반지름 60×0.145 = 8.7.
      const row = 411;
      const centerX = 360;
      const radius = 87;
      expect(_isHoney(at(centerX - radius + 2, row)), isFalse, reason: '왼쪽 가장자리 안쪽은 물방울');
      expect(_isHoney(at(centerX + radius - 2, row)), isFalse, reason: '오른쪽 가장자리 안쪽은 물방울');
      expect(_isHoney(at(centerX - radius - 2, row)), isTrue, reason: '왼쪽 가장자리 바깥은 육각형');
      expect(_isHoney(at(centerX + radius + 1, row)), isTrue, reason: '오른쪽 가장자리 바깥은 육각형');

      // 꼭짓점은 가운데서 60×0.21 = 12.6 위(y 23.4), 아래 끝은 반원 중심 + 반지름 = 49.8.
      expect(_isHoney(at(centerX, 228)), isTrue, reason: '꼭짓점 바로 위는 육각형');
      expect(_isHoney(at(centerX, 262)), isFalse, reason: '꼭짓점 아래는 물방울');
      expect(_isHoney(at(centerX, 494)), isFalse, reason: '아래 끝 바로 위는 물방울');
      expect(_isHoney(at(centerX, 502)), isTrue, reason: '아래 끝 아래는 육각형');
    });

    testWidgets('작은 크기(28)에서도 같은 비율로 여백을 둔다', (tester) async {
      final at = await _rasterize(tester, NbkSize.symbolSm);

      // 28 상자 → 육각형 높이 23.3, 위 여백 2.3
      expect(_isHoney(at(14, 0)), isFalse);
      expect(_isHoney(at(14, 5)), isTrue);
      expect(_isHoney(at(14, 27)), isFalse);
    });
  });
}
