import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 글 본문: 제목 → 작성자(작성 시각 · 조회, 내 글 필) → 손실액 카드 → 첨부 이미지(원본 비율, 최대 폭 500) → 내용
class ArticleBody extends StatelessWidget {
  const ArticleBody({
    required this.title,
    required this.badgeUrl,
    required this.nickname,
    required this.insigniaUrls,
    required this.meta,
    required this.mine,
    required this.lossAmount,
    required this.thumbnailUrl,
    required this.content,
    super.key,
  });

  final String title;
  final String badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;

  /// '2026.10.10 14:30 · 조회 123'
  final String meta;
  final bool mine;
  final int lossAmount;
  final String thumbnailUrl;
  final String content;

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = thumbnailUrl.isNotEmpty && thumbnailUrl != 'null';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NbkSpacing.screen,
        NbkSpacing.xl,
        NbkSpacing.screen,
        NbkSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NbkTypography.title),
          const SizedBox(height: NbkSpacing.md),
          AuthorInfo(
            badgeUrl: badgeUrl,
            nickname: nickname,
            insigniaUrls: insigniaUrls,
            size: AuthorInfoSize.medium,
            subtitle: meta,
            trailing: mine
                ? const NbkPill(label: Strings.myPost, variant: NbkPillVariant.honey)
                : null,
          ),
          const SizedBox(height: NbkSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NbkSpacing.xl,
              vertical: NbkSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: NbkColors.lossTint,
              borderRadius: BorderRadius.circular(NbkRadius.card),
            ),
            child: Row(
              children: [
                Text(
                  Strings.lossLabel,
                  style: NbkTypography.labelStrong.copyWith(color: NbkColors.loss),
                ),
                const Spacer(),
                LossAmount(amount: lossAmount, size: LossAmountSize.detail),
              ],
            ),
          ),
          if (hasThumbnail) ...[
            const SizedBox(height: NbkSpacing.lg),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: NbkSize.detailImageMaxWidth),
                child: NbkThumbnail(url: thumbnailUrl, height: null),
              ),
            ),
          ],
          const SizedBox(height: NbkSpacing.lg),
          Text(content, style: NbkTypography.body),
        ],
      ),
    );
  }
}
