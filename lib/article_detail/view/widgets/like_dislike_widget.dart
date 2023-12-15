import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

// Consumer widget format
class LikeDislikeWidget extends StatelessWidget {
  const LikeDislikeWidget({
    required VoidCallback? onTap,
    required int articleId,
    required int count,
    required Image icon,
    required String title,
    required TextStyle textStyle,
    super.key,
  }): _onTap = onTap,
      _articleId = articleId,
      _count = count,
      _icon = icon,
      _title = title,
      _textStyle = textStyle;

  final VoidCallback? _onTap;
  final int _articleId;
  final int _count;
  final Image _icon;
  final String _title;
  final TextStyle _textStyle;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return InkWell(
        onTap: _onTap,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: _icon,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _title,
              style: _textStyle,
            ),
            const SizedBox(
              width: 4,
            ),
            SizedBox(
              height: 12,
              child: Text(
                _count.toString(),
                style: _textStyle,
              ),
            ),
          ],
        ),
      );
    });
  }
}
