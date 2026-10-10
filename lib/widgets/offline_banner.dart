import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 오프라인 안내 배너(surface, 모서리 12)
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.lg,
        vertical: NbkSpacing.md,
      ),
      decoration: BoxDecoration(
        color: NbkColors.surface,
        borderRadius: BorderRadius.circular(NbkRadius.card),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: NbkSize.reactionIcon, color: NbkColors.text2),
          SizedBox(width: NbkSpacing.md),
          Expanded(child: Text(Strings.offline, style: NbkTypography.label)),
        ],
      ),
    );
  }
}
