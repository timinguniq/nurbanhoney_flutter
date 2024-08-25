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

    return Column(
      children: [
        Row(
          children: [
            /// TOOD(me): 1위 만들어야됨.
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

            //
            Expanded(
              child: UserInfo(
                onTap: () {
                  log('UserInfo clicked');
                },
                badge: badge,
                nickname: nickname,
                authorTextStyle: authorTextStyle,
                insigniaList: insigniaList,
              ),
            ),
          ],
        ),

        // 간격
        const SizedBox(height: 10),

        Row(
          children: [
            /// TODO: 손실 표시

            /// TODO: 실제 손실액 표시

            /// TODO: 추천 표시

            /// TODO: 실제 추천액 표시
          ],
        ),
      ],
    );
  }
}
