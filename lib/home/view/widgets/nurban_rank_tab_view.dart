import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanRankTabView extends StatelessWidget {
  const NurbanRankTabView({
    required VoidCallback? onTap,
    required int? rankLength,
    Key? key
  }) : _onTap = onTap,
       _rankLength = rankLength,
       super(key: key);

  final VoidCallback? _onTap;
  final int? _rankLength;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final rankCount = _rankLength ?? 0;

      final rankTabTitleStyle = ref.watch(rankTabTitle);
      final rankTabWholeStyle = ref.watch(rankTabWhole);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  height: 20,
                  child: Assets.images.home.nurbanChar.image(),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  height: 20,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '랭킹',
                      style: rankTabTitleStyle,
                    ),
                  ),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                InkWell(
                  onTap: _onTap,
                  child: SizedBox(
                    width: 80,
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '전체보기',
                        style: rankTabWholeStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for(var i = 0 ; i < rankCount ; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: NurbanRankTabElement(
                        rankNumber: i,
                        rankTitle: 'title',
                        rankLossCut: 'lossCut',
                        author: 'author',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
