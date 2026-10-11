import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/insignia_image.dart';
import 'package:nurbanhoney/widgets/nbk_badge.dart';

enum AuthorInfoSize {
  /// 배지 22, 닉네임 label — 목록·Top3 카드
  small,

  /// 배지 36, 닉네임 14 w700, 아래 캡션 — 글 상세
  medium,

  /// 배지 32, 닉네임 13 w700, 아래 댓글 내용(여러 줄) — 댓글
  comment,

  /// 배지 64, 닉네임 18 w700, 아래 소개 1줄 — 내 계정 프로필 블록
  profile,
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

  /// 배지 이미지 URL. 없으면 null(심볼로 대신한다).
  final String? badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;
  final AuthorInfoSize size;

  /// medium 에서 닉네임 아래 캡션(작성 시각 · 조회), profile 에서 소개 1줄, comment 에서 댓글 내용
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
      AuthorInfoSize.comment => _column(
          badge: const (NbkSize.avatarComment, NbkRadius.avatarComment),
          gap: NbkSpacing.md,
          nameStyle: NbkTypography.labelStrong,
          subtitleStyle: NbkTypography.commentText,
          subtitleMaxLines: null,
          insignias: insignias,
          insigniaSize: InsigniaSize.small,
        ),
      AuthorInfoSize.medium => _column(
          badge: const (NbkSize.avatarMd, NbkRadius.avatarMd),
          gap: NbkSpacing.md,
          nameStyle: NbkTypography.nicknameMedium,
          subtitleStyle: NbkTypography.caption,
          insignias: insignias,
          insigniaSize: InsigniaSize.medium,
        ),
      AuthorInfoSize.profile => _column(
          badge: const (NbkSize.avatarProfile, NbkRadius.avatarLg),
          gap: NbkSpacing.lg,
          nameStyle: NbkTypography.profileName,
          subtitleStyle: NbkTypography.label.copyWith(
            color: NbkColors.text3,
            fontWeight: FontWeight.w400,
          ),
          insignias: insignias,
          insigniaSize: InsigniaSize.medium,
        ),
    };
  }

  /// 배지 옆에 닉네임 줄과 [subtitle] 을 세로로 쌓는다(medium · profile · comment).
  /// [subtitleMaxLines] 가 null 이면 줄 수 제한 없이 모두 보여준다(댓글 내용).
  Widget _column({
    required (double, double) badge,
    required double gap,
    required TextStyle nameStyle,
    required TextStyle subtitleStyle,
    required Iterable<String> insignias,
    required InsigniaSize insigniaSize,
    int? subtitleMaxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NbkBadge(url: badgeUrl, size: badge.$1, radius: badge.$2),
        SizedBox(width: gap),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _nameLine(
                nameStyle: nameStyle,
                insignias: insignias,
                insigniaSize: insigniaSize,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: NbkSpacing.xxs),
                Text(
                  subtitle!,
                  style: subtitleStyle,
                  maxLines: subtitleMaxLines,
                  overflow: subtitleMaxLines == null ? null : TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
