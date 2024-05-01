import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class FreeBoardBadge extends StatelessWidget {
  const FreeBoardBadge({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Text(
            '자게',
            style: badgeTitleStyle,
          ),
        ),
      );
    });
  }
}
