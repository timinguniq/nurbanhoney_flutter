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
      final badgeTitleStyle = ref.read(badgeTitle);
      final badgeBackgroundColor = ref.read(colorD9D9D9);
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: badgeBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            '너반꿀',
            style: badgeTitleStyle,
          ),
        ),
      );
    });
  }
}
