import 'package:flutter/material.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 랭킹 탭. 4단계에서 시상대·리스트·내 순위 바로 다시 그린다. 지금은 기존 [RankView] 를 그대로 보여준다.
class RankingTabPage extends StatelessWidget {
  const RankingTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NbkAppBar.root(title: Strings.rankingTitle),
      body: RankView(),
    );
  }
}
