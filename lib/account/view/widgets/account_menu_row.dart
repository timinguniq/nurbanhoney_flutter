import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 설정·앱 정보 목록의 한 행(높이 56). 오른쪽에는 [trailing] 이나, 누를 수 있으면 › 아이콘이 붙는다.
class AccountMenuRow extends StatelessWidget {
  const AccountMenuRow({
    required this.title,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: NbkSize.appBar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
          child: Row(
            children: [
              Expanded(child: Text(title, style: NbkTypography.body)),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: NbkSize.iconXs,
                  color: NbkColors.text3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
