import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_symbol.dart';

/// 배지(프로필 이미지). 배경은 surface, URL 이 비었거나 로드에 실패하면 너반꿀 심볼을 보여준다.
class NbkBadge extends StatelessWidget {
  const NbkBadge({
    required this.url,
    required this.size,
    required this.radius,
    super.key,
  });

  /// 배지 이미지 URL. 없으면 null.
  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final imageUrl = url == null || url.isEmpty ? null : url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: NbkColors.surface,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Center(child: NbkSymbol(size: size * 0.6));
}
