import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class AppbarBottomIcon extends StatelessWidget {
  const AppbarBottomIcon({
    Key? key,
    required bool isSelected,
    required String text,
  })  : _isSelected = isSelected,
        _text = text,
        super(key: key);

  final bool _isSelected;
  final String _text;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final selectColor = ref.read(colorF6B748);
      final unSelectColor = ref.read(colorE5E5E5);

      return Container(
        height: 30,
        decoration: BoxDecoration(
          // border
          border: Border.all(
            color: _isSelected ? selectColor : unSelectColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(43),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Text(
              _text,
              style: TextStyle(color: _isSelected ? selectColor : unSelectColor),
            ),
          ),
        ),
      );
    });
  }
}
