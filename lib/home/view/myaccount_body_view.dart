import 'package:flutter/material.dart';
import 'package:nurbanhoney/home/home.dart';

class MyaccountBodyView extends StatelessWidget {
  const MyaccountBodyView({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppbarDivider(),
        Expanded(
          child: MyaccountView(
            userId: userId,
          ),
        ),
      ],
    );
  }
}
