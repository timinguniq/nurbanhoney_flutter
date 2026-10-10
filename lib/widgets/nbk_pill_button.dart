import 'package:flutter/material.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

enum NbkPillButtonVariant { primary, outline }

/// 상단바 오른쪽·프로필 [수정] 같은 작은 필 버튼(높이 36)
class NbkPillButton extends StatelessWidget {
  const NbkPillButton({
    required this.label,
    required this.onPressed,
    this.variant = NbkPillButtonVariant.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final NbkPillButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return NbkButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: NbkButtonSize.small,
      expand: false,
      pill: true,
      variant: variant == NbkPillButtonVariant.primary
          ? NbkButtonVariant.primary
          : NbkButtonVariant.outline,
    );
  }
}
