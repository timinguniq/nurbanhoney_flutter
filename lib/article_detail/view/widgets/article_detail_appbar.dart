import 'package:flutter/material.dart';

class ArticleDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ArticleDetailAppBar({
    required int board,
    required TextStyle appBarTitleStyle,
    super.key,
  })  : _board = board,
        _appBarTitleStyle = appBarTitleStyle;

  final int _board;
  final TextStyle _appBarTitleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 0,
      title: SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          children: [
            // back key icon
            SizedBox(
              width: 42,
              height: 48,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _board == 1
                  ? Text(
                '너반꿀',
                style: _appBarTitleStyle,
              )
                  : _board == 2
                  ? Text(
                '자유게시판',
                style: _appBarTitleStyle,
              )
                  : Text(
                '자유게시판',
                style: _appBarTitleStyle,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}