import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 세그먼트 탭(높이 48). 활성은 text1 w700 + 2px honey 언더라인, 비활성은 text3 w500.
/// [counts] 가 있으면 라벨 뒤에 숫자를 붙인다('내 글 12', 활성이면 숫자가 honeyDeep).
class NbkSegmentTabs extends StatelessWidget {
  const NbkSegmentTabs({
    required this.labels,
    required this.index,
    required this.onChanged,
    this.counts,
    super.key,
  }) : assert(counts == null || counts.length == labels.length);

  final List<String> labels;
  final List<int?>? counts;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NbkSize.segmentTab,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NbkColors.line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(child: _tab(i, labels[i], counts?[i])),
        ],
      ),
    );
  }

  Widget _tab(int i, String label, int? count) {
    final active = i == index;
    final style = active ? NbkTypography.segment : NbkTypography.segmentInactive;
    return InkWell(
      onTap: () => onChanged(i),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? NbkColors.honey : Colors.transparent,
              width: NbkSize.segmentIndicator,
            ),
          ),
        ),
        child: Center(
          child: count == null
              ? Text(label, style: style)
              : Text.rich(
                  TextSpan(
                    text: '$label ',
                    style: style,
                    children: [
                      TextSpan(
                        text: '$count',
                        style: style.copyWith(
                          color: active ? NbkColors.honeyDeep : NbkColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
