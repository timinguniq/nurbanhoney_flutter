import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 로그인 실패 인라인 알림(dangerTint 카드): 아이콘 + 제목 + 원인 한 줄
class LoginFailureCard extends StatelessWidget {
  const LoginFailureCard({required this.title, required this.reason, super.key});

  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NbkSpacing.lg),
      decoration: BoxDecoration(
        color: NbkColors.dangerTint,
        borderRadius: BorderRadius.circular(NbkRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: NbkSpacing.xxs),
            child: Icon(Icons.error_outline, size: NbkSize.icon, color: NbkColors.danger),
          ),
          const SizedBox(width: NbkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NbkTypography.labelStrong.copyWith(color: NbkColors.dangerText),
                ),
                const SizedBox(height: NbkSpacing.xs),
                Text(reason, style: NbkTypography.label.copyWith(color: NbkColors.text2, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
