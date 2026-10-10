import 'package:flutter/material.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/date_format_utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 로그인 수단 행: 아이콘 타일 36 + '카카오 계정'/'Google 계정' + 닉네임 캡션 + [로그아웃].
/// loginType 문자열('kakao'/'google')을 그대로 보여주지 않는다. 캡션은 '닉네임 · 가입일' 이고,
/// 프로필에 [createdAt] 이 없거나 날짜로 읽을 수 없으면 닉네임만 적는다.
class LoginMethodRow extends StatelessWidget {
  const LoginMethodRow({
    required this.loginType,
    required this.nickname,
    required this.onLogout,
    this.createdAt,
    super.key,
  });

  final String loginType;
  final String nickname;
  final VoidCallback? onLogout;

  /// 가입 시각(ISO 8601). 서버가 주기 전에는 null.
  final String? createdAt;

  bool get _isGoogle => loginType == 'google';

  String get _caption {
    final joined = createdAt == null ? '' : formatDate(createdAt!, dotDateFormat);
    return joined.isEmpty ? nickname : Strings.joinedCaption(nickname, joined);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: NbkSize.avatarMd,
            height: NbkSize.avatarMd,
            decoration: BoxDecoration(
              color: _isGoogle ? NbkColors.google : NbkColors.kakao,
              borderRadius: BorderRadius.circular(NbkRadius.avatarMd),
              border: _isGoogle ? Border.all(color: NbkColors.googleLine) : null,
            ),
            child: Center(
              child: _isGoogle
                  ? Assets.images.login.googleSymbol.image(width: NbkSize.iconSm, height: NbkSize.iconSm)
                  : const Icon(Icons.chat_bubble, size: NbkSize.iconSm, color: NbkColors.onKakao),
            ),
          ),
          const SizedBox(width: NbkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isGoogle ? Strings.googleAccount : Strings.kakaoAccount,
                  style: NbkTypography.itemTitle,
                ),
                const SizedBox(height: NbkSpacing.xxs),
                Text(
                  _caption,
                  style: NbkTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: NbkSpacing.md),
          NbkPillButton(
            label: Strings.logout,
            variant: NbkPillButtonVariant.outline,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
