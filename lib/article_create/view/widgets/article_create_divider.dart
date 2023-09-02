import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleCreateDivider extends StatelessWidget {
  const ArticleCreateDivider({
    required double thickness,
    required Color color,
    Key? key
  }): _thickness = thickness,
        _color = color,
        super(key: key);

  final double _thickness;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      return Divider(
        thickness: _thickness,
        color: _color,
      );
    });
  }
}
