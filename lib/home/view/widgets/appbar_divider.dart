import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class AppbarDivider extends StatelessWidget {
  const AppbarDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final borderColor = ref.read(appbarBorderColor);
      return Divider(
        thickness: 1,
        color: borderColor,
      );
    });
  }
}
