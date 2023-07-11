import 'package:flutter/material.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

class DrawerBoardWidget extends StatelessWidget {
  const DrawerBoardWidget({
    required String title,
    required TextStyle textStyle,
    required VoidCallback? onTap,
    super.key})
      : _title = title,
        _textStyle = textStyle,
        _onTap = onTap;

  final String _title;
  final TextStyle _textStyle;
  final VoidCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: SizedBox(
            height: 30,
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Assets.images.home.drawerBoardIcon.image(),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  _title,
                  style: _textStyle,
                ),
              ],
            )
        ),
      ),
    );
  }
}
