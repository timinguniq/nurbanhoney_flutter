import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_icon_button.dart';

enum NbkAppBarLeading {
  /// 스택 이동 화면(상세·내 정보·랭킹)
  back,

  /// 모달·폼(로그인·글 작성·프로필 수정)
  close,

  /// 탭 루트 화면. [NbkAppBar.root] 로만 만든다.
  none,
}

/// 높이 56 상단바. leading 은 enum 으로 강제하고, 오른쪽 액션은 [NbkIconButton] 이나 필 버튼을 넣는다.
class NbkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NbkAppBar({
    required this.leading,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.onLeadingTap,
    this.showBorder = true,
    super.key,
  }) : assert(leading != NbkAppBarLeading.none, '탭 루트는 NbkAppBar.root 를 쓴다');

  /// 탭 루트용: 왼쪽 타이틀(20 w700) + 오른쪽 액션, leading 없음
  const NbkAppBar.root({
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.showBorder = false,
    super.key,
  })  : leading = NbkAppBarLeading.none,
        onLeadingTap = null;

  final NbkAppBarLeading leading;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;

  /// 기본은 `Navigator.maybePop`
  final VoidCallback? onLeadingTap;
  final bool showBorder;

  @override
  Size get preferredSize => const Size.fromHeight(NbkSize.appBar);

  @override
  Widget build(BuildContext context) {
    final isRoot = leading == NbkAppBarLeading.none;

    return AppBar(
      toolbarHeight: NbkSize.appBar,
      automaticallyImplyLeading: false,
      leadingWidth: isRoot ? null : NbkSize.iconButton + NbkSpacing.xs,
      leading: isRoot
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: NbkSpacing.xs),
              child: NbkIconButton(
                icon: leading == NbkAppBarLeading.back
                    ? Icons.arrow_back_ios_new
                    : Icons.close,
                size: leading == NbkAppBarLeading.back
                    ? NbkSize.icon - NbkSpacing.xxs
                    : NbkSize.icon,
                onTap: onLeadingTap ?? () => Navigator.of(context).maybePop(),
              ),
            ),
      titleSpacing: isRoot ? NbkSpacing.screen : 0,
      centerTitle: !isRoot,
      title: titleWidget ??
          (title == null
              ? null
              : Text(
                  title!,
                  style: isRoot ? NbkTypography.title : NbkTypography.heading,
                )),
      actions: [...actions, const SizedBox(width: NbkSpacing.xs)],
      shape: showBorder
          ? const Border(bottom: BorderSide(color: NbkColors.line))
          : null,
    );
  }
}
