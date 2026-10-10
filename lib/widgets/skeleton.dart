import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 반짝이는 하이라이트를 자식 위로 흘려보낸다. 안쪽에는 [SkeletonBox] 를 둔다.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              NbkColors.thumbPlaceholder,
              NbkColors.skeletonHighlight,
              NbkColors.thumbPlaceholder,
            ],
            stops: const [0.3, 0.5, 0.7],
            begin: const Alignment(-1, -0.2),
            end: const Alignment(1, 0.2),
            transform: _SlidingGradientTransform(_controller.value * 3 - 1.5),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

/// 스켈레톤 블록
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = NbkSpacing.md,
    this.radius = NbkRadius.skeleton,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NbkColors.thumbPlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 홈 목록 아이템 스켈레톤
class PostItemSkeleton extends StatelessWidget {
  const PostItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.listItemVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              SkeletonBox(width: NbkSize.avatarSm, height: NbkSize.avatarSm, radius: NbkRadius.avatarSm),
              SizedBox(width: NbkSpacing.sm),
              SkeletonBox(width: 100),
              Spacer(),
              SkeletonBox(width: 60),
            ],
          ),
          SizedBox(height: NbkSpacing.md),
          SkeletonBox(width: 200, height: NbkSize.icon),
          SizedBox(height: NbkSpacing.md),
          SkeletonBox(width: 260, height: NbkSize.iconSm),
          SizedBox(height: NbkSpacing.sm),
          SkeletonBox(),
          SizedBox(height: NbkSpacing.sm),
          SkeletonBox(width: 280),
          SizedBox(height: NbkSpacing.md),
          SkeletonBox(height: NbkSize.thumbnailHeight, radius: NbkRadius.thumbnail),
          SizedBox(height: NbkSpacing.md),
          Row(
            children: [
              SkeletonBox(width: 50, height: NbkSize.iconSm),
              SizedBox(width: NbkSpacing.md),
              SkeletonBox(width: 50, height: NbkSize.iconSm),
            ],
          ),
        ],
      ),
    );
  }
}

/// 홈 Top3 카드 스켈레톤
class Top3CardSkeleton extends StatelessWidget {
  const Top3CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NbkSize.top3CardWidth,
      padding: const EdgeInsets.all(NbkSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: NbkColors.line),
        borderRadius: BorderRadius.circular(NbkRadius.card),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SkeletonBox(width: NbkSize.rankBox, height: NbkSize.rankBox),
              SizedBox(width: NbkSpacing.sm),
              SkeletonBox(width: NbkSize.avatarSm, height: NbkSize.avatarSm, radius: NbkRadius.avatarSm),
              SizedBox(width: NbkSpacing.sm),
              SkeletonBox(width: 90),
            ],
          ),
          SizedBox(height: NbkSpacing.lg),
          Row(
            children: [
              SkeletonBox(width: 130, height: NbkSize.icon),
              Spacer(),
              SkeletonBox(width: 50),
            ],
          ),
        ],
      ),
    );
  }
}

/// 랭킹 4위 이하 행 스켈레톤
class RankRowSkeleton extends StatelessWidget {
  const RankRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NbkSize.rankRow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
        child: Row(
          children: const [
            SkeletonBox(width: NbkSize.rankNumberWidth, height: NbkSize.iconSm),
            SizedBox(width: NbkSpacing.md),
            SkeletonBox(width: NbkSize.avatarMd, height: NbkSize.avatarMd, radius: NbkRadius.avatarMd),
            SizedBox(width: NbkSpacing.md),
            // 닉네임 자리는 남는 폭을 쓰므로 좁은 화면에서도 넘치지 않는다.
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 100),
              ),
            ),
            SizedBox(width: NbkSpacing.md),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: 110, height: NbkSize.iconSm),
                SizedBox(height: NbkSpacing.xs),
                SkeletonBox(width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 랭킹 시상대 스켈레톤(2위 / 1위 / 3위)
class PodiumSkeleton extends StatelessWidget {
  const PodiumSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _column(first: false)),
          const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
          Expanded(child: _column(first: true)),
          const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
          Expanded(child: _column(first: false)),
        ],
      ),
    );
  }

  Widget _column({required bool first}) {
    final avatar = first ? NbkSize.avatarPodium : NbkSize.avatarRank;
    return Container(
      padding: EdgeInsets.fromLTRB(
        NbkSpacing.md,
        first ? NbkSpacing.xxxl + NbkSpacing.lg : NbkSpacing.xxl,
        NbkSpacing.md,
        NbkSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: first ? NbkColors.honeyTint : NbkColors.surface,
        border: first ? Border.all(color: NbkColors.honeyLine) : null,
        borderRadius: BorderRadius.circular(NbkRadius.cardLg),
      ),
      child: Column(
        children: [
          SkeletonBox(width: avatar, height: avatar, radius: NbkRadius.avatarLg),
          const SizedBox(height: NbkSpacing.md),
          const SkeletonBox(width: 64),
          const SizedBox(height: NbkSpacing.sm),
          const SkeletonBox(width: 80, height: NbkSize.iconSm),
          const SizedBox(height: NbkSpacing.sm),
          const SkeletonBox(width: 44),
        ],
      ),
    );
  }
}
