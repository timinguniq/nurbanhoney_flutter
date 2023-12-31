import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

// Myaccount_dashboard
// Thumbnail,, nickanme, description, article count, comment count, point
class MyaccountDashboardView extends StatelessWidget {
  const MyaccountDashboardView({
    required String thumbnail,
    required String nickname,
    required String insigniaShow,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
    super.key,
  }): _thumbnail = thumbnail,
      _nickname = nickname,
      _insigniaShow = insigniaShow,
      _description = description,
      _articleCount = articleCount,
      _commentCount = commentCount,
      _point = point;

  final String _thumbnail;
  final String _nickname;
  final String _insigniaShow;
  final String _description;
  final int _articleCount;
  final int _commentCount;
  final int _point;

  static Route route({
    required String thumbnail,
    required String nickname,
    required String insigniaShow,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MyaccountDashboardView(
        thumbnail: thumbnail,
        nickname: nickname,
        insigniaShow: insigniaShow,
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

      final nicknameStyle = ref.read(myaccountNicknameStyle);
      final introduceStyle = ref.read(myaccountIntroduceStyle);
      final factorTitleStyle = ref.read(myaccountFactorTitleStyle);
      final factorValueStyle = ref.read(myaccountFactorValueStyle);

      final fConvertToInsignia = ref.read(convertToInsignia);

      // 휘장 리스트
      List<String> insigniaList = fConvertToInsignia(_insigniaShow);

      final description = _description == "null" ? "자기 소개를 입력해주세요." : _description;

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
          const SizedBox(
            height: 20,
          ),
          // Nickname, insignia
          SizedBox(
            width: double.infinity,
            height: 23,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _nickname,
                  style: nicknameStyle,
                ),
                const SizedBox(
                  width: 8,
                ),
                for (var ele in insigniaList)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SizedBox(
                      width: 21,
                      height: 21,
                      child: CachedNetworkImage(
                        imageUrl: ele,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // introduce
          const SizedBox(
            height: 15,
          ),
          Text(
            description,
            style: introduceStyle,
          ),
          const SizedBox(
            height: 38,
          ),
          Row(
            children: [
              const Expanded(
                flex: 45,
                child: SizedBox(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '게시글 수',
                    style: factorTitleStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _articleCount.toString(),
                    style: factorValueStyle,
                  ),
                ],
              ),
              const Expanded(
                flex: 83,
                child: SizedBox(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '댓글 수',
                    style: factorTitleStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _commentCount.toString(),
                    style: factorValueStyle,
                  ),
                ],
              ),
              const Expanded(
                flex: 82,
                child: SizedBox(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '포인트',
                    style: factorTitleStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _point.toString(),
                    style: factorValueStyle,
                  ),
                ],
              ),
              const Expanded(
                flex: 57,
                child: SizedBox(),
              ),
            ],
          )

        ],
      );
    });
  }
}
