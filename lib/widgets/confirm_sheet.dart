import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

/// 바텀시트 확인: 제목 + 설명 + [위험 액션] [취소]. 삭제는 반드시 이걸 거친다. 확인하면 true.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = Strings.cancel,
  bool danger = true,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (_) => _ConfirmSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      danger: danger,
    ),
  );
  return result ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.danger,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NbkSpacing.screen,
          NbkSpacing.sm,
          NbkSpacing.screen,
          NbkSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: NbkTypography.title),
            const SizedBox(height: NbkSpacing.sm),
            Text(message, style: NbkTypography.body.copyWith(color: NbkColors.text2)),
            const SizedBox(height: NbkSpacing.xxl),
            NbkButton(
              label: confirmLabel,
              variant: danger ? NbkButtonVariant.danger : NbkButtonVariant.primary,
              size: NbkButtonSize.large,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: NbkSpacing.sm + NbkSpacing.xxs),
            NbkButton(
              label: cancelLabel,
              variant: NbkButtonVariant.secondary,
              size: NbkButtonSize.large,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
