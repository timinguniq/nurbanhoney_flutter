import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consumer widget format
class CommentInputWidget extends StatelessWidget {
  const CommentInputWidget({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CommentInputWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Container(
        width: double.infinity,
        height: 50,
        color: Colors.yellow,
      );
    });
  }
}
