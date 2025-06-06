
// 자유게시판 디테일 보드(제목, 작가, 작성일)
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

import '../../../common/common.dart';

class FreeTitleBoard extends StatelessWidget {
  const FreeTitleBoard({required int articleId, Key? key})
      : _articleId = articleId,
        super(key: key);

  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      final token = storage?.getToken() ?? '__empty__';
      log('like_dislike_board token: $token');

      final freeArticle = ref.watch(getFreeArticleProvider((token, _articleId)));

      // TextStyle
      final articleDetailFreeTitleTextStyle =
      ref.read(articleDetailNurbanTitleStyle);
      final articleDetailFreeAuthorTextStyle =
      ref.read(articleDetailNurbanAuthorStyle);
      final articleDetailFreeElementTextStyle =
      ref.read(articleDetailNurbanElementStyle);

      final fConvertToInsignia = ref.read(convertToInsignia);

      return freeArticle.when(
        data: (data) {
          log('freeArticle data: $data');
          // 휘장 리스트
          final insigniaList = fConvertToInsignia(data.insignia);
          final date = formatDate(data.updatedAt.toString(), DEFAULT_DATE_FORMAT);

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
                  style: articleDetailFreeTitleTextStyle,
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
                authorTextStyle: articleDetailFreeAuthorTextStyle,
                insigniaList: insigniaList,
              ),
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
                    date,
                    style: articleDetailFreeElementTextStyle,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    '조회수',
                    style: articleDetailFreeElementTextStyle,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    data.count.toString(),
                    style: articleDetailFreeElementTextStyle,
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
          log('freeArticle error: $error');
          return Container(
            child: Text('FreeTitleBoard Error'),
          );
        },
      );
    });
  }
}
