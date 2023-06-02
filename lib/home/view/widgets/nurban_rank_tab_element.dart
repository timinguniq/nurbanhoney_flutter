import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanRankTabElement extends StatelessWidget {
  const NurbanRankTabElement({
    required int rankNumber,
    required String rankTitle,
    required String rankLossCut,
    required String author,
    Key? key,
  }) : _rankNumber = rankNumber,
       _rankTitle = rankTitle,
        _rankLossCut = rankLossCut,
        _author = author,
        super(key: key);

  final int _rankNumber;
  final String _rankTitle;
  final String _rankLossCut;
  final String _author;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {

      final rankTabBackgroundColor = ref.read(color33F6B748);

      final rankTabTitleStyle = ref.read(rankTabEleTitle);
      final rankTabContentStyle = ref.read(rankTabEleContent);
      final rankTabMoneyStyle = ref.read(rankTabEleMoney);
      final rankTabAuthorStyle = ref.read(rankTabEleAuthor);

      return Container(
        width: 200,
        height: 120,
        // rounded corner
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: rankTabBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_rankNumber위',
                  style: rankTabTitleStyle,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _rankTitle,
                  style: rankTabContentStyle,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Assets.images.home.nurbanRankTabMoney.image(),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    _rankLossCut,
                    style: rankTabMoneyStyle,
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _author,
                  style: rankTabAuthorStyle,
                ),
              ),
            ],
          ),
        ),
      );
    });


  }
}
