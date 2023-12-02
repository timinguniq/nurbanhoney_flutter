import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class RankBoardBadge extends StatelessWidget {
  const RankBoardBadge({
    required int rank,
    Key? key
  }) : _rank = rank,
       super(key: key);

  final int _rank;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final badgeMajorTitleStyle = ref.read(rankMajorTitle);
      final badgeMinorTitleStyle = ref.read(rankMinorTitle);

      final badge1BackgroundColor = ref.read(colorF19F39);
      final badge2BackgroundColor = ref.read(colorB3B3B3);
      final badge3BackgroundColor = ref.read(colorA57117);
      final badge4BackgroundColor = ref.read(colorD9D9D9);

      var titleStyle = badgeMajorTitleStyle;
      var backgroundColor = badge1BackgroundColor;

      switch(_rank) {
        case 1:
          titleStyle = badgeMajorTitleStyle;
          backgroundColor = badge1BackgroundColor;
          break;
        case 2:
          titleStyle = badgeMajorTitleStyle;
          backgroundColor = badge2BackgroundColor;
          break;
        case 3:
          titleStyle = badgeMajorTitleStyle;
          backgroundColor = badge3BackgroundColor;
          break;
        default:
          titleStyle = badgeMinorTitleStyle;
          backgroundColor = badge4BackgroundColor;
          break;
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            '$_rank 위',
            style: titleStyle,
          ),
        ),
      );
    });
  }
}
