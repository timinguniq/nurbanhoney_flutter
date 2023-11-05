
// 너반꿀 디테일 보드(제목, 작가, 작성일, 손실액)
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

class NurbanTitleBoard extends StatelessWidget {
  const NurbanTitleBoard({required int articleId, Key? key})
      : _articleId = articleId,
        super(key: key);

  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));

      // TextStyle
      final articleDetailNurbanTitleTextStyle =
      ref.read(articleDetailNurbanTitleStyle);
      final articleDetailNurbanAuthorTextStyle =
      ref.read(articleDetailNurbanAuthorStyle);
      final articleDetailNurbanElementTextStyle =
      ref.read(articleDetailNurbanElementStyle);
      final articleDetailNurbanLossCutTitleTextStyle =
      ref.read(articleDetailNurbanLossCutTitleStyle);
      final articleDetailNurbanLossCutValueTextStyle =
      ref.read(articleDetailNurbanLossCutValueStyle);

      final fConvertToInsignia = ref.read(convertToInsignia);

      return nurbanArticle.when(
        data: (data) {
          log('nurbanArticle data: $data');
          // 휘장 리스트
          List<String> insigniaList = fConvertToInsignia(data.insignia);

          // empty처리가 안되서. if문 사용
          if(insigniaList.toString() == '[]'){
            insigniaList = <String>[];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  data.title,
                  style: articleDetailNurbanTitleTextStyle,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                height: 21,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    SizedBox(
                      width: 21,
                      height: 21,
                      child: CachedNetworkImage(
                        imageUrl: data.badge,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      data.nickname,
                      style: articleDetailNurbanAuthorTextStyle,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    for (var ele in insigniaList)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: SizedBox(
                          width: 21,
                          height: 21,
                          child: CachedNetworkImage(
                            imageUrl: ele,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    data.updatedAt.toString(),
                    style: articleDetailNurbanElementTextStyle,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    '조회수',
                    style: articleDetailNurbanElementTextStyle,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    data.count.toString(),
                    style: articleDetailNurbanElementTextStyle,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      '손실액',
                      style: articleDetailNurbanLossCutTitleTextStyle,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Assets.images.articleDetail.lossCutIcon.image(),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      data.lossCut.toString(),
                      style: articleDetailNurbanLossCutValueTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
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
          log('nurbanArticle error: $error');
          return const Text('NurbanTitleBoard Error');
        },
      );
    });
  }
}
