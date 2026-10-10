import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 로그인 실패 인라인 알림(dangerTint 카드 + dangerLine 테두리): 아이콘(20) + 제목 + 원인 한 줄
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
        border: Border.all(color: NbkColors.dangerLine),
        borderRadius: BorderRadius.circular(NbkRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: NbkSize.alertIcon, color: NbkColors.danger),
          const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
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
