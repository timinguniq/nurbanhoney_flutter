import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class StockListItem extends StatelessWidget {
  const StockListItem({
    required String title,
    required String lossCut,
    required String author,
    required String badge,
    required List<String> insigniaList,
    required String date,
    required String likeCount,
    required CachedNetworkImage thumbnail,
    required VoidCallback onTap,
    super.key,
  })  : _title = title,
        _lossCut = lossCut,
        _author = author,
        _badge = badge,
        _insigniaList = insigniaList,
        _date = date,
        _likeCount = likeCount,
        _thumbnail = thumbnail,
        _onTap = onTap;

  final String _title;
  final String _lossCut;
  final String _author;
  final String _badge;
  final List<String> _insigniaList;
  final String _date;
  final String _likeCount;
  final CachedNetworkImage _thumbnail;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final authorStyle = ref.read(boardListItemAuthor);
      final lossCutStyle = ref.read(stockTabLossCutStyle);
      final titleStyle = ref.read(stockTabTitleStyle);
      final contentStyle = ref.read(stockTabContentStyle);
      final likeStyle = ref.read(stockTabLikeStyle);
      log('lossCut : $_lossCut');
      var f = NumberFormat('###,###,###,###');

      return InkWell(
        onTap: _onTap,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserInfo(
                  onTap: () {
                    log('UserInfo clicked');
                  },
                  badge: _badge,
                  nickname: _author,
                  authorTextStyle: authorStyle,
                  insigniaList: _insigniaList,
                ),

                InkWell(
                  onTap: () {
                    log('delete clicked');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
                    child: SizedBox(
                      width: 6,
                      height: 20,
                      child: Assets.images.common.optionIcon.image(),
                    ),
                  ),
                ),
              ],
            ),

            /// 손실액


          ],
        )
      );
    });
  }
}
