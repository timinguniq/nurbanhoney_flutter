import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class FreeBoardItemView extends StatelessWidget {
  const FreeBoardItemView({
    required String title,
    required String content,
    required String author,
    required String date,
    required String likeCount,
    required VoidCallback onTap,
    Key? key,
  })  : _title = title,
        _content = content,
        _author = author,
        _date = date,
        _likeCount = likeCount,
        _onTap = onTap,
        super(key: key);

  final String _title;
  final String _content;
  final String _author;
  final String _date;
  final String _likeCount;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(boardListItemTitle);
      final contentStyle = ref.read(boardListItemContent);
      final authorStyle = ref.read(boardListItemAuthor);
      final likeStyle = ref.read(boardListItemLike);

      return InkWell(
        onTap: _onTap,
        child: SizedBox(
          width: double.infinity,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const FreeBoardBadge(),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      _title,
                      style: titleStyle,
                    )
                  ],
                ),
                Text(
                  _content,
                  style: contentStyle,
                ),
                Row(
                  children: [
                    Text(
                      _author,
                      style: authorStyle,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      _date,
                      style: authorStyle,
                    ),
                    const SizedBox(
                      width: 9,
                    ),
                    Text(
                      '추천',
                      style: likeStyle,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      _likeCount,
                      style: likeStyle,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
