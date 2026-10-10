import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 글 상세 본문 스켈레톤(앱바는 그대로 둔다)
class ArticleDetailSkeleton extends StatelessWidget {
  const ArticleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: NbkSpacing.screen, vertical: NbkSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 240, height: NbkSize.icon),
            SizedBox(height: NbkSpacing.lg),
            Row(
              children: [
                SkeletonBox(width: NbkSize.avatarMd, height: NbkSize.avatarMd, radius: NbkRadius.avatarMd),
                SizedBox(width: NbkSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100),
                    SizedBox(height: NbkSpacing.xs),
                    SkeletonBox(width: 160),
                  ],
                ),
              ],
            ),
            SizedBox(height: NbkSpacing.lg),
            SkeletonBox(height: NbkSize.lossInputBox, radius: NbkRadius.card),
            SizedBox(height: NbkSpacing.lg),
            SkeletonBox(height: NbkSize.thumbnailHeight * 2, radius: NbkRadius.thumbnail),
            SizedBox(height: NbkSpacing.lg),
            SkeletonBox(),
            SizedBox(height: NbkSpacing.sm),
            SkeletonBox(),
            SizedBox(height: NbkSpacing.sm),
            SkeletonBox(width: 200),
          ],
        ),
      ),
    );
  }
}
