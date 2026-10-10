import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 점선 테두리 상자(모서리 12). 홈 Top3 가 비었을 때 안내, 글 작성의 사진 추가 자리에 쓴다.
class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.child,
    this.height,
    this.color = NbkColors.line,
    this.radius = NbkRadius.card,
    this.onTap,
    super.key,
  });

  final Widget child;
  final double? height;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(width: double.infinity, height: height, child: child),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 6.0;
  static const _gap = 4.0;
  static const _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_stroke / 2, _stroke / 2, size.width - _stroke, size.height - _stroke),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
