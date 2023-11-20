import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consumer widget format
class CommentDashboardWidget extends StatelessWidget {
  const CommentDashboardWidget({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CommentDashboardWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.blue,
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.cyan,
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.red,
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.yellowAccent,
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.amber,
            ),
          ],
        ),
      );
    });
  }
}
