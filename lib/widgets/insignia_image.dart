import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

enum InsigniaSize { small, medium, tile }

/// 휘장. PNG 는 400×400 이지만 그림이 가운데 가로로 좁게 들어 있어, 박스보다 큰 이미지를
/// `ClipRect` → `OverflowBox` 로 넣어 투명 여백을 잘라낸다.
class InsigniaImage extends StatelessWidget {
  const InsigniaImage({
    required this.url,
    this.size = InsigniaSize.small,
    super.key,
  });

  final String url;
  final InsigniaSize size;

  Size get _box => switch (size) {
        InsigniaSize.small => NbkSize.insigniaSmBox,
        InsigniaSize.medium => NbkSize.insigniaMdBox,
        InsigniaSize.tile => NbkSize.insigniaTileBox,
      };

  double get _image => switch (size) {
        InsigniaSize.small => NbkSize.insigniaSmImage,
        InsigniaSize.medium => NbkSize.insigniaMdImage,
        InsigniaSize.tile => NbkSize.insigniaTileImage,
      };

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return SizedBox(
      width: _box.width,
      height: _box.height,
      child: ClipRect(
        child: OverflowBox(
          minWidth: image,
          maxWidth: image,
          minHeight: image,
          maxHeight: image,
          child: CachedNetworkImage(
            imageUrl: url,
            width: image,
            height: image,
            fit: BoxFit.contain,
            placeholder: (_, __) => const SizedBox(),
            errorWidget: (_, __, ___) => const SizedBox(),
          ),
        ),
      ),
    );
  }
}
