import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/insignia_image.dart';
import 'package:nurbanhoney/widgets/nbk_badge.dart';

enum AuthorInfoSize {
  /// 배지 22, 닉네임 label — 목록·Top3 카드
  small,

  /// 배지 36, 닉네임 14 w700, 아래 캡션 — 글 상세
  medium,

  /// 배지 32, 닉네임 13 w700 — 댓글
  comment,
}

/// 배지 + 닉네임 + 휘장(최대 2개). [trailing] 은 닉네임 줄 끝에 붙는다(예: '내 글' 필).
class AuthorInfo extends StatelessWidget {
  const AuthorInfo({
    required this.badgeUrl,
    required this.nickname,
    this.insigniaUrls = const [],
    this.size = AuthorInfoSize.small,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;
  final AuthorInfoSize size;

  /// medium 에서 닉네임 아래 캡션(작성 시각 · 조회)
  final String? subtitle;
  final Widget? trailing;

  static const _maxInsignia = 2;

  @override
  Widget build(BuildContext context) {
    final insignias = insigniaUrls.where((url) => url.isNotEmpty).take(_maxInsignia);

    return switch (size) {
      AuthorInfoSize.small => _row(
          badge: const (NbkSize.avatarSm, NbkRadius.avatarSm),
          gap: NbkSpacing.sm,
          nameStyle: NbkTypography.label,
          insignias: insignias,
          insigniaSize: InsigniaSize.small,
        ),
      AuthorInfoSize.comment => _row(
          badge: const (NbkSize.avatarComment, NbkRadius.avatarComment),
          gap: NbkSpacing.md,
          nameStyle: NbkTypography.labelStrong,
          insignias: insignias,
          insigniaSize: InsigniaSize.small,
        ),
      AuthorInfoSize.medium => Row(
          children: [
            NbkBadge(
              url: badgeUrl,
              size: NbkSize.avatarMd,
              radius: NbkRadius.avatarMd,
            ),
            const SizedBox(width: NbkSpacing.md),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _nameLine(
                    nameStyle: NbkTypography.nicknameMedium,
                    insignias: insignias,
                    insigniaSize: InsigniaSize.medium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: NbkSpacing.xxs),
                    Text(subtitle!, style: NbkTypography.caption),
                  ],
                ],
              ),
            ),
          ],
        ),
    };
  }

  Widget _row({
    required (double, double) badge,
    required double gap,
    required TextStyle nameStyle,
    required Iterable<String> insignias,
    required InsigniaSize insigniaSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NbkBadge(url: badgeUrl, size: badge.$1, radius: badge.$2),
        SizedBox(width: gap),
        Flexible(
          child: _nameLine(
            nameStyle: nameStyle,
            insignias: insignias,
            insigniaSize: insigniaSize,
          ),
        ),
      ],
    );
  }

  Widget _nameLine({
    required TextStyle nameStyle,
    required Iterable<String> insignias,
    required InsigniaSize insigniaSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            nickname,
            style: nameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        for (final url in insignias) ...[
          const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
          InsigniaImage(url: url, size: insigniaSize),
        ],
        if (trailing != null) ...[
          const SizedBox(width: NbkSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
