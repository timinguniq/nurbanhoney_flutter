import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class AppbarBottomIcon extends StatelessWidget {
  const AppbarBottomIcon({
    Key? key,
    required bool isSelected,
    required String text,
    required VoidCallback? onTap,
  })  : _isSelected = isSelected,
        _text = text,
        _onTap = onTap,
        super(key: key);

  final bool _isSelected;
  final String _text;
  final VoidCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final selectColor = ref.read(colorF6B748);
      final unSelectColor = ref.read(colorBABABA);
      final selectTextStyle = ref.read(appbarBottomSelected);
      final unSelectTextStyle = ref.read(appbarBottomUnSelected);

      return InkWell(
        onTap: _onTap,
        child: Container(
          decoration: BoxDecoration(
            // border
            border: Border.all(
              color: _isSelected ? selectColor : unSelectColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(43),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8
            ),
            child: Center(
              child: Text(
                _text,
                style: _isSelected
                    ? selectTextStyle
                    : unSelectTextStyle,
              ),
            ),
          ),
        ),
      );
    });
  }
}
