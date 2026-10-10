import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';
import 'package:nurbanhoney/widgets/nbk_symbol.dart';

/// 빈 상태: 아이콘 타일(96, 모서리 28) + 제목 + 설명 + 선택적 CTA.
/// [icon] 이 없으면 너반꿀 심볼을, [showTile] 이 false 면 타일 없이 아이콘만 보여준다(댓글 빈 상태).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.message,
    this.icon,
    this.showTile = true,
    this.ctaLabel,
    this.ctaIcon,
    this.onCta,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final bool showTile;
  final String? ctaLabel;
  final IconData? ctaIcon;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final glyph = icon == null
        ? const NbkSymbol(size: NbkSize.symbolTile)
        : Icon(icon, size: NbkSize.stateIcon, color: showTile ? NbkColors.honeyDeep : NbkColors.hint);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NbkSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTile)
              Container(
                width: NbkSize.emptyTile,
                height: NbkSize.emptyTile,
                decoration: BoxDecoration(
                  color: NbkColors.honeyTint,
                  borderRadius: BorderRadius.circular(NbkRadius.emptyTile),
                ),
                child: Center(child: glyph),
              )
            else
              glyph,
            const SizedBox(height: NbkSpacing.xl),
            Text(title, style: NbkTypography.heading, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: NbkSpacing.sm),
              Text(
                message!,
                style: NbkTypography.body.copyWith(color: NbkColors.text3),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: NbkSpacing.xxl),
              NbkButton(
                label: ctaLabel!,
                icon: ctaIcon,
                expand: false,
                onPressed: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
