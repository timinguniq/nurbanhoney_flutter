import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

/// 다이얼로그 확인: (아이콘 타일) + 제목 + 설명 + (체크박스) + [취소] [위험 액션].
/// [checkboxLabel] 이 있으면 체크 전에는 확인 버튼이 비활성이다. 확인하면 true.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = Strings.cancel,
  bool danger = true,
  IconData? icon,
  String? checkboxLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      danger: danger,
      icon: icon,
      checkboxLabel: checkboxLabel,
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.danger,
    required this.icon,
    required this.checkboxLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;
  final IconData? icon;
  final String? checkboxLabel;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _checked = false;

  bool get _canConfirm => widget.checkboxLabel == null || _checked;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(NbkSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null) ...[
              Container(
                width: NbkSize.dialogIconTile,
                height: NbkSize.dialogIconTile,
                decoration: BoxDecoration(
                  color: widget.danger ? NbkColors.dangerTint : NbkColors.honeyTint,
                  borderRadius: BorderRadius.circular(NbkRadius.dialogIconTile),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.danger ? NbkColors.danger : NbkColors.honeyDeep,
                ),
              ),
              const SizedBox(height: NbkSpacing.lg),
            ],
            Text(widget.title, style: NbkTypography.title),
            const SizedBox(height: NbkSpacing.sm),
            Text(
              widget.message,
              style: NbkTypography.body.copyWith(color: NbkColors.text2),
            ),
            if (widget.checkboxLabel != null) ...[
              const SizedBox(height: NbkSpacing.lg),
              InkWell(
                onTap: () => setState(() => _checked = !_checked),
                borderRadius: BorderRadius.circular(NbkRadius.card),
                child: Row(
                  children: [
                    Checkbox(
                      value: _checked,
                      onChanged: (value) => setState(() => _checked = value ?? false),
                    ),
                    Expanded(
                      child: Text(widget.checkboxLabel!, style: NbkTypography.label),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: NbkSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: NbkButton(
                    label: widget.cancelLabel,
                    variant: NbkButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: NbkSpacing.md),
                Expanded(
                  child: NbkButton(
                    label: widget.confirmLabel,
                    variant: widget.danger
                        ? NbkButtonVariant.danger
                        : NbkButtonVariant.primary,
                    onPressed: _canConfirm
                        ? () => Navigator.of(context).pop(true)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
