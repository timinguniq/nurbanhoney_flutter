import 'package:flutter/material.dart';
import 'package:nurbanhoney/coin/coin.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/stock/stock.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 홈 탭: 로고 상단바 → 세그먼트 탭(주식 | 코인) → 게시판 목록
class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  var _board = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NbkAppBar.root(
        titleWidget: const NbkLogo.horizontal(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: NbkSpacing.md),
            child: Center(
              child: Text(
                Strings.thisMonth(formatMonthRange(DateTime.now())),
                style: NbkTypography.caption,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          NbkSegmentTabs(
            labels: const [Strings.boardStock, Strings.boardCoin],
            index: _board,
            onChanged: (index) => setState(() => _board = index),
          ),
          Expanded(
            child: LazyIndexedStack(
              index: _board,
              children: const [StockTabPage(), CoinTabPage()],
            ),
          ),
        ],
      ),
    );
  }
}
