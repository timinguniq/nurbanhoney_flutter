import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

enum NbkButtonVariant {
  /// honey / onHoney
  primary,

  /// danger / 흰
  danger,

  /// surface / text1
  secondary,

  /// 흰 / line 테두리, 필
  outline,

  /// text1 / 흰 — ErrorState [다시 시도]
  dark,
}

enum NbkButtonSize {
  /// 52
  large,

  /// 48
  medium,

  /// 36, 상단바용 필
  small,
}

/// 버튼. [onPressed] 가 null 이면 비활성(line 배경 + hint 글자), [loading] 이면 라벨 대신 스피너를 보이고
/// 색은 유지한 채 눌리지 않는다.
class NbkButton extends StatelessWidget {
  const NbkButton({
    required this.label,
    required this.onPressed,
    this.variant = NbkButtonVariant.primary,
    this.size = NbkButtonSize.medium,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.pill = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final NbkButtonVariant variant;
  final NbkButtonSize size;
  final IconData? icon;

  /// 가로로 꽉 채운다
  final bool expand;
  final bool loading;

  /// 모서리를 완전히 둥글린다(small·outline 은 항상 필)
  final bool pill;

  double get _height => switch (size) {
        NbkButtonSize.large => NbkSize.buttonLg,
        NbkButtonSize.medium => NbkSize.button,
        NbkButtonSize.small => NbkSize.pillButton,
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      NbkButtonVariant.primary => (NbkColors.honey, NbkColors.onHoney, null),
      NbkButtonVariant.danger => (NbkColors.danger, NbkColors.onDark, null),
      NbkButtonVariant.secondary => (NbkColors.surface, NbkColors.text1, null),
      NbkButtonVariant.outline => (NbkColors.bg, NbkColors.text1, NbkColors.line),
      NbkButtonVariant.dark => (NbkColors.text1, NbkColors.onDark, null),
    };
    final isSmall = size == NbkButtonSize.small;
    final isPill = pill || isSmall || variant == NbkButtonVariant.outline;
    final side = border == null ? BorderSide.none : BorderSide(color: border);
    final shape = isPill
        ? StadiumBorder(side: side)
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NbkRadius.button),
            side: side,
          );

    final style = ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: loading ? background : NbkColors.line,
      disabledForegroundColor: loading ? foreground : NbkColors.hint,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: shape,
      minimumSize: Size(expand ? double.infinity : 0, _height),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? NbkSpacing.lg : NbkSpacing.xl,
      ),
      textStyle: isSmall ? NbkTypography.buttonSmall : NbkTypography.buttonLarge,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return SizedBox(
      height: _height,
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: loading
            ? SizedBox.square(
                dimension: NbkSize.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: NbkSpacing.xxs,
                  color: foreground,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: NbkSize.iconSm),
                    const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
