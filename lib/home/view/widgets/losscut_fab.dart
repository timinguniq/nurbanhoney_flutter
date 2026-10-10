import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';

/// 홈 탭바 위 오른쪽의 꿀색 확장 FAB '손절 인증하기'. 비로그인이면 로그인 화면으로 보낸다.
/// 글이 등록되면 [onCreated] 로 목록을 새로고침한다. [board] 는 글 작성의 기본 게시판(1 주식, 2 코인).
class LossCutFab extends ConsumerWidget {
  const LossCutFab({
    required this.board,
    required this.onCreated,
    super.key,
  });

  final int board;
  final Future<void> Function() onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authentication = ref.watch(authenticationServiceProvider);

    return FloatingActionButton.extended(
      heroTag: 'losscut-fab-$board',
      icon: const Icon(Icons.edit_outlined),
      label: const Text(Strings.lossCutCta),
      onPressed: () async {
        if (authentication != AuthenticationStatus.authenticated) {
          await Navigator.of(context).push(LoginPage.route());
          return;
        }
        final created = await Navigator.of(context)
            .push<bool>(ArticleCreatePage.route(board: board));
        if (created == true) await onCreated();
      },
    );
  }
}
