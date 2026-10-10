import 'package:dio_domain/dio_domain.dart';
import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/view/widgets/login_failure_card.dart';
import 'package:nurbanhoney/login/view/widgets/login_notice.dart';
import 'package:nurbanhoney/login/view/widgets/social_login_button.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 로그인 화면 UI(상태는 밖에서 받는다). X(48, 왼쪽 8) / 로고 + 제목 + 설명(남는 공간 가운데) /
/// (실패 카드) / 소셜 버튼 3개 / 안내. 하단 블록은 좌우 20 여백으로 가로를 채운다.
/// [inProgress] 가 있으면 그 버튼에 스피너, 나머지 버튼과 X 는 흐려지고 설명이 '…로그인하고 있어요' 로 바뀐다.
/// [failed] 가 있으면 버튼 위에 실패 카드가 뜨고 그 버튼 라벨이 '…로 다시 로그인' 이 된다.
class LoginView extends StatelessWidget {
  const LoginView({
    required this.onClose,
    required this.onSignIn,
    required this.onTerms,
    required this.onPrivacy,
    this.inProgress,
    this.failed,
    this.failureReason,
    super.key,
  });

  final VoidCallback onClose;
  final ValueChanged<LoginTypeStatus> onSignIn;

  /// null 이면 링크가 눌리지 않는다(로그인 진행 중)
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final LoginTypeStatus? inProgress;
  final LoginTypeStatus? failed;
  final String? failureReason;

  static const _providers = [LoginTypeStatus.kakao, LoginTypeStatus.naver, LoginTypeStatus.google];

  static const _dimmedOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final busy = inProgress != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.sm, vertical: NbkSpacing.xs),
                child: Opacity(
                  opacity: busy ? _dimmedOpacity : 1,
                  child: NbkIconButton(
                    icon: Icons.close,
                    tooltip: Strings.cancel,
                    onTap: busy ? null : onClose,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  // 아래 여백만큼 블록이 가운데보다 조금 위에 놓인다(디자인).
                  padding: const EdgeInsets.fromLTRB(NbkSpacing.xxxl, 0, NbkSpacing.xxxl, NbkSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NbkLogo.vertical(),
                      const SizedBox(height: NbkSpacing.xxl),
                      const Text(
                        Strings.loginTitle,
                        style: NbkTypography.title,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: NbkSpacing.md),
                      Text(
                        busy
                            ? Strings.loginInProgress(Strings.providerName(inProgress!))
                            : Strings.loginDescription,
                        style: NbkTypography.listBody.copyWith(color: NbkColors.text3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NbkSpacing.xl,
                NbkSpacing.lg,
                NbkSpacing.xl,
                NbkSpacing.xxl,
              ),
              child: Column(
                children: [
                  if (failed != null) ...[
                    LoginFailureCard(
                      title: Strings.loginFailedTitle(Strings.providerName(failed!)),
                      reason: failureReason ?? Strings.loginFailedServerReason,
                    ),
                    const SizedBox(height: NbkSpacing.lg),
                  ],
                  for (final provider in _providers) ...[
                    SocialLoginButton(
                      provider: provider,
                      label: failed == provider
                          ? Strings.loginRetryWith(Strings.providerName(provider))
                          : Strings.loginWith(Strings.providerName(provider)),
                      loading: inProgress == provider,
                      dimmed: busy && inProgress != provider,
                      onPressed: () => onSignIn(provider),
                    ),
                    if (provider != _providers.last) const SizedBox(height: NbkSpacing.sm + NbkSpacing.xxs),
                  ],
                  const SizedBox(height: NbkSpacing.xl),
                  LoginNotice(onTerms: onTerms, onPrivacy: onPrivacy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
