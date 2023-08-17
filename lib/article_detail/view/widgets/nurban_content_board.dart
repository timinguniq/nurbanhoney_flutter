
// 너반꿀 디테일 보드(썸네일 컨텐츠)
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanContentBoard extends StatelessWidget {
  const NurbanContentBoard({required int articleId, Key? key})
      : _articleId = articleId,
        super(key: key);

  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));

      // TextStyle
      final articleDetailNurbanContentTextStyle =
      ref.read(articleDetailNurbanContentStyle);

      return nurbanArticle.when(
        data: (data) {
          log('NurbanContentBoard data: $data');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: CachedNetworkImage(
                  imageUrl: data.thumbnail,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.content,
                    style: articleDetailNurbanContentTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('NurbanContentBoard error: $error');
          return const Text('NurbanContentBoard Error');
        },
      );
    });
  }
}
