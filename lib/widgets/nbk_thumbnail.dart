import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/thumbnail_placeholder.dart';

/// 네트워크 썸네일. 로드 전·실패 시 [ThumbnailPlaceholder]. [height] 가 null 이면 원본 비율로 가로를 채운다.
class NbkThumbnail extends StatelessWidget {
  const NbkThumbnail({
    required this.url,
    this.height = NbkSize.thumbnailHeight,
    this.radius = NbkRadius.thumbnail,
    super.key,
  });

  final String url;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholderHeight = height ?? NbkSize.thumbnailHeight * 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: height,
        fit: height == null ? BoxFit.fitWidth : BoxFit.cover,
        placeholder: (_, __) =>
            ThumbnailPlaceholder(height: placeholderHeight, radius: radius),
        errorWidget: (_, __, ___) =>
            ThumbnailPlaceholder(height: placeholderHeight, radius: radius),
      ),
    );
  }
}
