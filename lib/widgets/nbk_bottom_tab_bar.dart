import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

enum NbkTab { home, ranking, account }

/// 하단 탭바(홈 / 랭킹 / 내 계정). 활성은 honey 채움 아이콘 + text1 w700, 비활성은 외곽선 + text3.
/// 높이는 내용 56 + 안전영역(최소 24) = 80 이상.
class NbkBottomTabBar extends StatelessWidget {
  const NbkBottomTabBar({
    required this.current,
    required this.onSelect,
    super.key,
  });

  final NbkTab current;
  final ValueChanged<NbkTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NbkColors.bg,
        border: Border(top: BorderSide(color: NbkColors.line)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: NbkSize.bottomTabMinInset),
        child: SizedBox(
          height: NbkSize.bottomTabContent,
          child: Row(
            children: [
              _item(NbkTab.home, Strings.tabHome, Icons.home_outlined, Icons.home),
              _item(NbkTab.ranking, Strings.tabRanking, Icons.emoji_events_outlined, Icons.emoji_events),
              _item(NbkTab.account, Strings.tabAccount, Icons.person_outline, Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(NbkTab tab, String label, IconData outlined, IconData filled) {
    final active = tab == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? filled : outlined,
              size: NbkSize.tabIcon,
              color: active ? NbkColors.honey : NbkColors.text3,
            ),
            const SizedBox(height: NbkSpacing.xs),
            Text(
              label,
              style: NbkTypography.tabLabel.copyWith(
                color: active ? NbkColors.text1 : NbkColors.text3,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
