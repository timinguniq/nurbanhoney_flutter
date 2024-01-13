import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

// Consumer widget format
// TODO: myaccount tab article view를 구현해야됨.
class MyaccountTabArticleView extends StatelessWidget {
  const MyaccountTabArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      final token = storage?.getToken() ?? '__empty__';

      final profileArticleProvider = ref.watch(getProfileArticleProvider(
          (token, 0, 10)
      ));
      return profileArticleProvider.when(
        data: (data) {
          return Column(
            children: [
              for(var element in data)
                MyaccountArticleItemView(
                    title: element.title,
                    data: formattingCreatedAt(element.createdAt),
                    count: element.count.toString(),
                    commentCount: element.commentCount.toString()
                )
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('error: $error'),
        ),
      );
    });
  }
}
