import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanBoardItemView extends StatelessWidget {
  const NurbanBoardItemView({
    required String title,
    required String lossCut,
    required String author,
    required String date,
    required String likeCount,
    required CachedNetworkImage thumbnail,
    required VoidCallback onTap,
    Key? key,
  })  : _title = title,
        _lossCut = lossCut,
        _author = author,
        _date = date,
        _likeCount = likeCount,
        _thumbnail = thumbnail,
        _onTap = onTap,
        super(key: key);

  final String _title;
  final String _lossCut;
  final String _author;
  final String _date;
  final String _likeCount;
  final CachedNetworkImage _thumbnail;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(boardListItemTitle);
      final lossCutStyle = ref.read(rankTabEleMoney);
      final authorStyle = ref.read(boardListItemAuthor);
      final likeStyle = ref.read(boardListItemLike);

      return InkWell(
        onTap: _onTap,
        child: SizedBox(
          width: double.infinity,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const NurbanBoardBadge(),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _title,
                          style: titleStyle,
                        )
                      ],
                    ),
                    Row(
                        children:[
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: Assets.images.home.nurbanRankTabMoney.image(),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            _lossCut,
                            style: lossCutStyle,
                          ),
                        ]
                    ),
                    Row(
                      children: [
                        Text(
                          _author,
                          style: authorStyle,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          _date,
                          style: authorStyle,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Text(
                          '추천',
                          style: likeStyle,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          _likeCount,
                          style: likeStyle,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              _thumbnail,
            ]),
          ),
        ),
      );
    });
  }
}
