import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 글 작성. [board] 는 진입한 홈 탭의 게시판(1 주식, 2 코인)으로, 게시판 기본값이 된다.
/// 등록에 성공하면 `true` 를 돌려주며 닫힌다.
class ArticleCreatePage extends ConsumerStatefulWidget {
  const ArticleCreatePage({this.board = 1, super.key});

  final int board;

  static Route<bool> route({int board = 1}) {
    return MaterialPageRoute<bool>(
      builder: (_) => ArticleCreatePage(board: board),
    );
  }

  @override
  ConsumerState<ArticleCreatePage> createState() => _ArticleCreatePageState();
}

class _ArticleCreatePageState extends ConsumerState<ArticleCreatePage> {
  @override
  void initState() {
    super.initState();
    // 게시판 Provider 는 '등록위치 선택' 으로 시작하므로 진입 탭의 게시판을 기본값으로 넣는다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(articleCreateBoardNavigationProvider.notifier)
          .select(widget.board == 2 ? '코인' : '너반꿀');
    });
  }

  @override
  Widget build(BuildContext context) {
    final boundaryColor = ref.read(color55000000);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const ArticleCreateAppbar(),
              ArticleCreateDivider(
                thickness: 0.5,
                color: boundaryColor,
              ),
              const ArticleCreateTitle(),
              ArticleCreateDivider(
                thickness: 0.5,
                color: boundaryColor,
              ),
              const ArticleCreateThumbnail(),
              ArticleCreateDivider(
                thickness: 0.5,
                color: boundaryColor,
              ),
              const ArticleCreateLossCut(),
              ArticleCreateDivider(
                thickness: 0.5,
                color: boundaryColor,
              ),
              const ArticleCreateContent(),
            ],
          ),
        ),
      ),
    );
  }
}
