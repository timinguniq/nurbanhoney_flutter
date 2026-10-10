import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 썸네일 자리: thumbPlaceholder 배경 + 이미지 아이콘, 모서리 12
class ThumbnailPlaceholder extends StatelessWidget {
  const ThumbnailPlaceholder({
    this.height = NbkSize.thumbnailHeight,
    this.radius = NbkRadius.thumbnail,
    super.key,
  });

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: NbkColors.thumbPlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: NbkSize.iconLg,
        color: NbkColors.hint,
      ),
    );
  }
}
