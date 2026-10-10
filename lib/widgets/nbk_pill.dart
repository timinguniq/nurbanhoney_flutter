import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

enum NbkPillVariant {
  /// lossTint / loss — '손실'
  loss,

  /// honeyTint / honeyDeep — '추천 128', '내 글'
  honey,

  /// surface / text2 — '주식', '코인'
  neutral,
}

/// 작은 필 배지
class NbkPill extends StatelessWidget {
  const NbkPill({
    required this.label,
    this.variant = NbkPillVariant.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final NbkPillVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      NbkPillVariant.loss => (NbkColors.lossTint, NbkColors.loss),
      NbkPillVariant.honey => (NbkColors.honeyTint, NbkColors.honeyDeep),
      NbkPillVariant.neutral => (NbkColors.surface, NbkColors.text2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.sm,
        vertical: NbkSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(NbkRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: NbkSize.iconXs, color: foreground),
            const SizedBox(width: NbkSpacing.xs),
          ],
          Text(label, style: NbkTypography.pill.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
