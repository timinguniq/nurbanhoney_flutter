import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 로그인 화면 하단 안내. '이용약관'·'개인정보 처리방침' 은 밑줄 링크다.
class LoginNotice extends StatelessWidget {
  const LoginNotice({required this.onTerms, required this.onPrivacy, super.key});

  /// null 이면 링크가 눌리지 않는다
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    final linkStyle = NbkTypography.caption.copyWith(
      color: NbkColors.text2,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: NbkTypography.caption,
        children: [
          const TextSpan(text: '${Strings.loginNoticeSignup}\n${Strings.loginNoticeAgreePrefix}'),
          _link(Strings.terms, linkStyle, onTerms),
          const TextSpan(text: Strings.loginNoticeAgreeJoin),
          _link(Strings.privacy, linkStyle, onPrivacy),
          const TextSpan(text: Strings.loginNoticeAgreeSuffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  InlineSpan _link(String text, TextStyle style, VoidCallback? onTap) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: onTap,
        child: Text(text, style: style),
      ),
    );
  }
}
