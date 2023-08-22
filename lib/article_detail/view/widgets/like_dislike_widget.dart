import 'dart:developer';

import 'package:dio_service/dio_service.dart';
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

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;

      log('like_dislike_widget storage: $storage');

      final token = storage?.getToken() ?? '__empty__';
      log('like_dislike_widget token: $token');

      return InkWell(
        onTap: () async {
          // TODO: 이렇게 하면 통신이 실행되나 테스트 해봐야 됨.
          final nurbanRepository = ref.read(nurbanRepositoryProvider);
          final result = await nurbanRepository.nurbanLikeCreate(token: token, articleId: _articleId);
          log('result : $result');
          if(result == '1'){
            log('result == 1');
          }
        },
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
              height: 10,
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
