import 'package:flutter/material.dart';

class SocialLoginBtn extends StatelessWidget {
  const SocialLoginBtn({
    required Image icon,
    required String text,
    required TextStyle textStyle,
    required Color backgroundColor,
    required double elevation,
    required VoidCallback? onTap,
    super.key,
  })  : _icon = icon,
        _text = text,
        _textStyle = textStyle,
        _backgroundColor = backgroundColor,
        _elevation = elevation,
        _onTap = onTap;

  final Image _icon;
  final String _text;
  final TextStyle _textStyle;
  final Color _backgroundColor;
  final double _elevation;
  final VoidCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: _elevation,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          height: 46,
          // rounded corner
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _backgroundColor,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 15,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: _icon,
                ),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      _text,
                      style: _textStyle,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
