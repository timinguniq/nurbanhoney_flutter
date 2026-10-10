import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 내 글·내 댓글 한 행 스켈레톤
class AccountListRowSkeleton extends StatelessWidget {
  const AccountListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 40, height: NbkSize.iconSm, radius: NbkRadius.pill),
              SizedBox(width: NbkSpacing.sm),
              SkeletonBox(width: 180, height: NbkSize.iconSm),
            ],
          ),
          SizedBox(height: NbkSpacing.sm),
          SkeletonBox(width: 140),
        ],
      ),
    );
  }
}

/// 로그인한 내 계정 전체 스켈레톤: 프로필 블록 + 활동 요약 카드 + 탭 + 목록 3행
class AccountProfileSkeleton extends StatelessWidget {
  const AccountProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: NbkSpacing.screen,
              vertical: NbkSpacing.lg,
            ),
            child: Row(
              children: [
                SkeletonBox(
                  width: NbkSize.avatarProfile,
                  height: NbkSize.avatarProfile,
                  radius: NbkRadius.avatarLg,
                ),
                SizedBox(width: NbkSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: NbkSize.icon),
                      SizedBox(height: NbkSpacing.sm),
                      SkeletonBox(width: 200),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
            child: SkeletonBox(
              height: NbkSize.avatarEdit,
              radius: NbkRadius.cardLg,
            ),
          ),
          const SizedBox(height: NbkSpacing.xl),
          const SizedBox(
            height: NbkSize.segmentTab,
            child: Row(
              children: [
                Expanded(child: Center(child: SkeletonBox(width: 60, height: NbkSize.iconSm))),
                Expanded(child: Center(child: SkeletonBox(width: 60, height: NbkSize.iconSm))),
              ],
            ),
          ),
          for (var i = 0; i < 3; i++) const AccountListRowSkeleton(),
        ],
      ),
    );
  }
}
