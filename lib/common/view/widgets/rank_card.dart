import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class RankCard extends ConsumerWidget {
  const RankCard({
    required this.rankNumber,
    required this.badge,
    required this.nickname,
    required this.totalLossCut,
    required this.totalLikeCount,
    required this.insigniaList,
    super.key,
  });

  final String rankNumber;
  final String badge;
  final String nickname;
  final String totalLossCut;
  final String totalLikeCount;
  final List<String> insigniaList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorTextStyle = ref.read(articleDetailNurbanAuthorStyle);
    final grayColor = ref.read(colorD9D9D9);
    final rankNumberTextStyle = ref.read(rankNumberStyle);
    log('badge: $badge, nickname: $nickname, insigniaList: $insigniaList');

    final rankLossCutTitleTextStyle = ref.read(rankLossCutTitleStyle);
    final rankLossCutValueTextStyle = ref.read(rankLossCutValueStyle);

    final colorLossCut = ref.read(color3C54D3);
    final colorLike = ref.read(colorF6B748);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: grayColor,
              ),
              child: Center(
                child: Text(
                  rankNumber,
                  style: rankNumberTextStyle,
                ),
              ),
            ),

            const SizedBox(width: 8),

            UserInfo(
              onTap: () {
                log('UserInfo clicked');
              },
              badge: badge,
              nickname: nickname,
              authorTextStyle: authorTextStyle,
              insigniaList: insigniaList,
            ),
          ],
        ),

        // 간격
        const SizedBox(height: 10),

        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorLossCut,
                borderRadius: BorderRadius.circular(30)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '손실',
                  style: rankLossCutTitleTextStyle,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '-${totalLossCut}원',
              style: rankLossCutValueTextStyle,
            ),

            const SizedBox(width: 12),

            Container(
              decoration: BoxDecoration(
                  color: colorLike,
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '추천',
                  style: rankLossCutTitleTextStyle,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '$totalLikeCount',
              style: rankLossCutValueTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}
