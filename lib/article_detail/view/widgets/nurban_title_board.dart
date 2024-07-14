// 너반꿀 디테일 보드(제목, 작가, 작성일, 손실액)
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

import 'package:nurbanhoney/common/common.dart';

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

      var f = NumberFormat('###,###,###,###');

      return nurbanArticle.when(
        data: (data) {
          log('nurbanArticle data: $data');
          // 휘장 리스트
          List<String> insigniaList = fConvertToInsignia(data.insignia);

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
              UserInfo(
                onTap: () {
                  log('UserInfo clicked');
                },
                badge: data.badge,
                nickname: data.nickname,
                authorTextStyle: articleDetailNurbanAuthorTextStyle,
                insigniaList: insigniaList,
              ),
              /*
              SizedBox(
                width: double.infinity,
                height: 21,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    CachedNetworkImage(
                      imageUrl: data.badge,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 21,
                        height: 21,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

               */
              const SizedBox(
                height: 7,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    '손실액',
                    style: articleDetailNurbanLossCutTitleTextStyle,
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
                  Text(
                    '${f.format(int.parse(data.lossCut))}원',
                    style: articleDetailNurbanLossCutValueTextStyle,
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
