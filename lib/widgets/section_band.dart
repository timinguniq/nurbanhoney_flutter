import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 섹션 사이 두꺼운 구분 띠(8, surface)
class SectionBand extends StatelessWidget {
  const SectionBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: NbkSpacing.sectionBand, color: NbkColors.surface);
  }
}
