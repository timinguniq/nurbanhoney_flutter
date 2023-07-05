import 'dart:developer';

import 'package:flutter/material.dart';

class LoginNotice extends StatelessWidget {
  const LoginNotice(
      {required String text1,
      required String text2,
      required String text3,
      required String text4,
      required String text5,
      required TextStyle textStyle,
      required TextStyle highlightTextStyle,
      required VoidCallback? termsOfUseOnTap,
      required VoidCallback? privacyPolicyOnTap,
      super.key})
      : _text1 = text1,
        _text2 = text2,
        _text3 = text3,
        _text4 = text4,
        _text5 = text5,
        _textStyle = textStyle,
        _highlightTextStyle = highlightTextStyle,
        _termsOfUseOnTap = termsOfUseOnTap,
        _privacyPolicyOnTap = privacyPolicyOnTap;

  final String _text1;
  final String _text2;
  final String _text3;
  final String _text4;
  final String _text5;
  final TextStyle _textStyle;
  final TextStyle _highlightTextStyle;
  final VoidCallback? _termsOfUseOnTap;
  final VoidCallback? _privacyPolicyOnTap;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text1,
                style: _textStyle,
              ),
              InkWell(
                onTap: _termsOfUseOnTap,
                child: Text(
                  _text2,
                  style: _highlightTextStyle,
                ),
              ),
              Text(
                _text3,
                style: _textStyle,
              ),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _privacyPolicyOnTap,
                child: Text(
                  _text4,
                  style: _highlightTextStyle,
                ),
              ),
              Text(
                _text5,
                style: _textStyle,
              ),
            ],
          ),
        ],
    );
  }
}
