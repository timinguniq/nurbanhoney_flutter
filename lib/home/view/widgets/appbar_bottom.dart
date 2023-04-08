import 'package:flutter/material.dart';
import 'package:nurbanhoney/home/home.dart';

class AppbarBottom extends StatelessWidget implements PreferredSizeWidget {
  const AppbarBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppbarDivider(),
          Expanded(
            child: Row(
              children: [
                AppbarBottomIcon(
                  isSelected: false,
                  text: '전체',
                )
              ],
            ),
          ),
          const AppbarDivider(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 50);
}
