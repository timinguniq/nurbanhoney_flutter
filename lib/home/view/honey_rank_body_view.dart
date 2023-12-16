import 'package:flutter/material.dart';
import 'package:nurbanhoney/home/home.dart';

class HoneyRankBodyView extends StatelessWidget {
  const HoneyRankBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppbarDivider(),
        Expanded(
          child: RankView(),
        ),
      ],
    );
  }
}
