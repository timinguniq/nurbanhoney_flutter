import 'package:flutter/material.dart';
import 'package:nurbanhoney/account/view/widgets/app_info_section.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 비로그인 내 계정: honeyTint 안내 카드([3초 만에 로그인]) + '앱 정보' 섹션. 로그인 화면을 자동으로 띄우지 않는다.
class AccountLoggedOutView extends StatelessWidget {
  const AccountLoggedOutView({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: NbkSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
          child: Container(
            padding: const EdgeInsets.all(NbkSpacing.xl),
            decoration: BoxDecoration(
              color: NbkColors.honeyTint,
              borderRadius: BorderRadius.circular(NbkRadius.sheet),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: NbkSize.emptyTile,
                      height: NbkSize.emptyTile,
                      decoration: BoxDecoration(
                        color: NbkColors.bg,
                        borderRadius: BorderRadius.circular(NbkRadius.emptyTile),
                      ),
                      child: const Center(
                        child: NbkSymbol(size: NbkSize.symbolTile),
                      ),
                    ),
                    const SizedBox(width: NbkSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Strings.accountLoggedOutTitle,
                            style: NbkTypography.title,
                          ),
                          const SizedBox(height: NbkSpacing.xs),
                          Text(
                            Strings.accountLoggedOutSubtitle,
                            style: NbkTypography.body.copyWith(color: NbkColors.text3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NbkSpacing.xl),
                for (final benefit in Strings.accountBenefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: NbkSpacing.md),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: NbkSize.iconSm,
                          color: NbkColors.honeyDeep,
                        ),
                        const SizedBox(width: NbkSpacing.md),
                        Expanded(
                          child: Text(
                            benefit,
                            style: NbkTypography.body.copyWith(color: NbkColors.text2),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: NbkSpacing.sm),
                NbkButton(
                  label: Strings.loginCta,
                  size: NbkButtonSize.large,
                  onPressed: onLogin,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NbkSpacing.xxxl),
        const AppInfoSection(),
      ],
    );
  }
}
