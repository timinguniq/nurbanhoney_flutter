import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 소셜 로그인 버튼(높이 52, 모서리 12). 아이콘은 왼쪽 18px 에 고정하고 글자는 가운데.
/// [loading] 이면 라벨 대신 스피너, [dimmed] 면 흐리게(opacity 0.4) 하고 누르지 못한다.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.provider,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.dimmed = false,
    super.key,
  });

  final LoginTypeStatus provider;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool dimmed;

  static const _dimmedOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border, icon) = switch (provider) {
      LoginTypeStatus.kakao => (
          NbkColors.kakao,
          NbkColors.onKakao,
          null,
          Assets.images.login.kakaoSymbol,
        ),
      LoginTypeStatus.naver => (
          NbkColors.naver,
          NbkColors.onNaver,
          null,
          Assets.images.login.naverSymbol,
        ),
      _ => (
          NbkColors.google,
          NbkColors.onGoogle,
          NbkColors.googleLine,
          Assets.images.login.googleSymbol,
        ),
    };

    return Opacity(
      opacity: dimmed ? _dimmedOpacity : 1,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NbkRadius.button),
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading || dimmed ? null : onPressed,
          child: SizedBox(
            height: NbkSize.buttonLg,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: NbkSize.iconSm,
                  child: icon.image(width: NbkSize.iconSm, height: NbkSize.iconSm),
                ),
                if (loading)
                  SizedBox.square(
                    dimension: NbkSize.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: NbkSpacing.xxs,
                      color: foreground,
                    ),
                  )
                else
                  Text(
                    label,
                    style: NbkTypography.buttonLarge.copyWith(color: foreground),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
