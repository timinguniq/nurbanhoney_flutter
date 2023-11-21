import 'dart:developer';

import 'package:dio_repository/dio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

// Consumer widget format
class CommentDashboardWidget extends StatelessWidget {
  const CommentDashboardWidget({
    required List<NurbanComment> comments,
    super.key}): _comments = comments;

  final List<NurbanComment> _comments;

  static Route route({
    required List<NurbanComment> comments,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => CommentDashboardWidget(
        comments: comments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final preferenceStorage = ref.watch(preferenceStorageProvider);

      final storage = preferenceStorage.asData?.value;
      final userId = storage?.getUserId();

      log('userId: $userId');

      return SingleChildScrollView(
        child: Column(
          children: [
            for(var comment in _comments)
              CommentItemView(
                thumbnail: comment.badge,
                nickname: comment.nickname,
                content: comment.content,
                isAuthor: comment.userId == userId,
              ),
          ],
        ),
      );
    });
  }
}
