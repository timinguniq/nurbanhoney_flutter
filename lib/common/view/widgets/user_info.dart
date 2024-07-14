import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({
    required VoidCallback? onTap,
    required String badge,
    required String nickname,
    required TextStyle authorTextStyle,
    required List<String> insigniaList,
    super.key,
  }): _onTap = onTap,
      _badge = badge,
      _nickname = nickname,
      _authorTextStyle = authorTextStyle,
      _insigniaList = insigniaList;

  final VoidCallback? _onTap;
  final String _badge;
  final String _nickname;
  final TextStyle _authorTextStyle;
  final List<String> _insigniaList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 21,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          CachedNetworkImage(
            imageUrl: _badge,
            imageBuilder: (context, imageProvider) => Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
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
            width: 8,
          ),
          Text(
            _nickname,
            style: _authorTextStyle,
          ),
          const SizedBox(
            width: 16,
          ),
          for (var ele in _insigniaList)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: SizedBox(
                width: 21,
                height: 21,
                child: CachedNetworkImage(
                  imageUrl: ele,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
