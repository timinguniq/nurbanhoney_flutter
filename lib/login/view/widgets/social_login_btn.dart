import 'package:flutter/material.dart';

class SocialLoginBtn extends StatelessWidget {
  const SocialLoginBtn({
    required Image icon,
    required String text,
    required Color backgroundColor,
    required int evalutation,
    required VoidCallback? onTap,
    super.key,
  }) : _icon = icon,
      _text = text,
      _backgroundColor = backgroundColor,
      _evalutation = evalutation,
      _onTap = onTap;

  final Image _icon;
  final String _text;
  final Color _backgroundColor;
  final int _evalutation;
  final VoidCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
