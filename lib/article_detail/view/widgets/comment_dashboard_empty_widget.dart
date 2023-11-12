import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consumer widget format
class CommentDashboardEmptyWidget extends StatelessWidget {
  const CommentDashboardEmptyWidget({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CommentDashboardEmptyWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Container(
        width: double.infinity,
        height: 500,
        color: Colors.grey,
      );
    });
  }
}
