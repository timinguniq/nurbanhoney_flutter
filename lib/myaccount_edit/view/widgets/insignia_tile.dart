import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 휘장 타일(높이 64, 모서리 16). 선택이면 honeyTint + honey 테두리, 아니면 흰 + line.
/// [badge] 가 오른쪽 위에 붙는다(선택 체크 18 또는 제거 X 24).
class InsigniaTile extends StatelessWidget {
  const InsigniaTile({
    required this.url,
    required this.selected,
    required this.onTap,
    this.badge,
    this.width,
    super.key,
  });

  final String url;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? badge;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 그리드 칸(tight)에서는 칸을 채우고, 가로 줄(loose)에서는 [width]×64 로 자기 크기를 갖는다.
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Material(
          color: selected ? NbkColors.honeyTint : NbkColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NbkRadius.cardLg),
            side: BorderSide(color: selected ? NbkColors.honey : NbkColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: width,
              height: NbkSize.insigniaGridTileHeight,
              child: Center(child: InsigniaImage(url: url, size: InsigniaSize.tile)),
            ),
          ),
        ),
        if (badge != null) Positioned(top: NbkSpacing.sm, right: NbkSpacing.sm, child: badge!),
      ],
    );
  }
}

/// 선택 표시: 검정 원 안 흰 체크(18)
class InsigniaCheck extends StatelessWidget {
  const InsigniaCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NbkSize.iconSm,
      height: NbkSize.iconSm,
      decoration: const BoxDecoration(color: NbkColors.text1, shape: BoxShape.circle),
      child: const Icon(Icons.check, size: NbkSize.iconXs - NbkSpacing.xs, color: NbkColors.onDark),
    );
  }
}

/// 제거 버튼: 검정 원 안 흰 X(24)
class InsigniaRemove extends StatelessWidget {
  const InsigniaRemove({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NbkColors.text1,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox.square(
          dimension: NbkSize.icon,
          child: Icon(Icons.close, size: NbkSize.iconXs, color: NbkColors.onDark),
        ),
      ),
    );
  }
}
