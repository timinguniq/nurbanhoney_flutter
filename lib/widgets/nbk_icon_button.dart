import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 48×48 터치 영역의 아이콘 버튼
class NbkIconButton extends StatelessWidget {
  const NbkIconButton({
    required this.icon,
    required this.onTap,
    this.color = NbkColors.text1,
    this.size = NbkSize.icon,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: size),
      style: IconButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: NbkColors.hint,
        fixedSize: const Size.square(NbkSize.iconButton),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
