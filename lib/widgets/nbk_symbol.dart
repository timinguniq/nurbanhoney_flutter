import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 너반꿀 심볼: 모서리가 둥근 육각형 안의 물방울. 래스터 에셋 대신 그려서 어느 크기에서도 선명하다.
class NbkSymbol extends StatelessWidget {
  const NbkSymbol({
    this.size = NbkSize.symbolSm,
    this.color = NbkColors.honey,
    this.dropColor = NbkColors.bg,
    super.key,
  });

  final double size;
  final Color color;
  final Color dropColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _NbkSymbolPainter(color: color, dropColor: dropColor),
    );
  }
}

class _NbkSymbolPainter extends CustomPainter {
  const _NbkSymbolPainter({required this.color, required this.dropColor});

  final Color color;
  final Color dropColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);

    // 꼭짓점이 위아래로 향하는 육각형. 작은 육각형을 둥근 join 으로 두껍게 그려 모서리를 둥글린다.
    final corner = s * 0.08;
    final radius = s / 2 - corner;
    final hexagon = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        hexagon.moveTo(point.dx, point.dy);
      } else {
        hexagon.lineTo(point.dx, point.dy);
      }
    }
    hexagon.close();
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = corner * 2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hexagon, fill);
    canvas.drawPath(hexagon, stroke);

    // 물방울: 위가 뾰족하고 아래가 둥글다.
    final dropRadius = s * 0.15;
    final tip = center + Offset(0, -s * 0.24);
    final bottom = center + Offset(0, s * 0.07);
    final drop = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(
        tip.dx + s * 0.03, tip.dy + s * 0.12,
        bottom.dx + dropRadius, bottom.dy - dropRadius * 0.6,
        bottom.dx + dropRadius, bottom.dy,
      )
      ..arcToPoint(
        Offset(bottom.dx - dropRadius, bottom.dy),
        radius: Radius.circular(dropRadius),
        clockwise: true,
      )
      ..cubicTo(
        bottom.dx - dropRadius, bottom.dy - dropRadius * 0.6,
        tip.dx - s * 0.03, tip.dy + s * 0.12,
        tip.dx, tip.dy,
      )
      ..close();
    canvas.drawPath(drop, Paint()..color = dropColor);
  }

  @override
  bool shouldRepaint(_NbkSymbolPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dropColor != dropColor;
}
