import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consumer widget format
// TODO: myaccount comment item view를 구현해야됨.
class MyaccountCommentItemView extends StatelessWidget {
  const MyaccountCommentItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Container();
    });
  }
}
