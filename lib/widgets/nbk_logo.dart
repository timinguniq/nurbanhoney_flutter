import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_symbol.dart';

/// 로고. 가로형(상단바)은 심볼 + 워드마크, 세로형(로그인)은 큰 심볼 아래 워드마크.
class NbkLogo extends StatelessWidget {
  const NbkLogo.horizontal({super.key}) : _vertical = false;

  const NbkLogo.vertical({super.key}) : _vertical = true;

  final bool _vertical;

  @override
  Widget build(BuildContext context) {
    if (_vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NbkSymbol(size: NbkSize.symbolLg),
          const SizedBox(height: NbkSpacing.lg),
          _Wordmark(style: NbkTypography.wordmarkLarge),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NbkSymbol(size: NbkSize.symbolSm),
        const SizedBox(width: NbkSpacing.sm),
        _Wordmark(style: NbkTypography.wordmark),
      ],
    );
  }
}

/// '너반꿀' 글자 + 꿀색 반짝이(✦)
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: Strings.appName,
        style: style,
        children: [
          TextSpan(text: '✦', style: style.copyWith(color: NbkColors.honey)),
        ],
      ),
    );
  }
}
