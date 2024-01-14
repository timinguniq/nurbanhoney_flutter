import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

import 'myaccount_comment_item_view.dart';

// Consumer widget format
class MyaccountTabCommentView extends StatelessWidget {
  const MyaccountTabCommentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      final token = storage?.getToken() ?? '__empty__';

      final profileCommentProvider = ref.watch(getProfileCommentProvider(
          (token, 0, 10)
      ));
      return profileCommentProvider.when(
        data: (data) {
          return Column(
            children: [
              for(var element in data)
                MyaccountCommentItemView(
                    title: element.title,
                    data: formattingCreatedAt(element.createdAt),
                ),
              const SizedBox(
                height: 60,
              ),
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
