import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Myaccount_dashboard
// Thumbnail,, nickanme, description, article count, comment count, point
class MyaccountDashboardView extends StatelessWidget {
  const MyaccountDashboardView({
    required String thumbnail,
    required String nickname,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
    super.key,
  }): _thumbnail = thumbnail,
      _nickname = nickname,
      _description = description,
      _articleCount = articleCount,
      _commentCount = commentCount,
      _point = point;

  final String _thumbnail;
  final String _nickname;
  final String _description;
  final int _articleCount;
  final int _commentCount;
  final int _point;

  static Route route({
    required String thumbnail,
    required String nickname,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MyaccountDashboardView(
        thumbnail: thumbnail,
        nickname: nickname,
        description: description,
        articleCount: articleCount,
        commentCount: commentCount,
        point: point,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Column(
        children: [
          // Thumbnail
          CachedNetworkImage(
            imageUrl: _thumbnail,
            imageBuilder: (context, imageProvider) => Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

        ],
      );
    });
  }
}
