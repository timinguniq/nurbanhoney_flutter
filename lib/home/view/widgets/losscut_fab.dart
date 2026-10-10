import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';

/// 글 작성 흐름. 비로그인이면 로그인 화면으로 보내고, 로그인이면 글 작성 화면을 연다(기본 게시판 [board]).
/// 글이 등록되면 [onCreated] 로 목록을 새로고침한다. FAB 와 빈 상태의 [첫 글 쓰기] 가 같이 쓴다.
Future<void> startLossCutCreate(
  BuildContext context,
  WidgetRef ref, {
  required int board,
  required Future<void> Function() onCreated,
}) async {
  final navigator = Navigator.of(context);
  if (ref.read(authenticationServiceProvider) != AuthenticationStatus.authenticated) {
    await navigator.push(LoginPage.route());
    return;
  }
  final created = await navigator.push<bool>(ArticleCreatePage.route(board: board));
  if (created == true) await onCreated();
}

/// 홈 탭바 위 오른쪽의 꿀색 확장 FAB '손절 인증하기'. [board] 는 글 작성의 기본 게시판(1 주식, 2 코인).
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
    return FloatingActionButton.extended(
      heroTag: 'losscut-fab-$board',
      icon: const Icon(Icons.edit_outlined),
      label: const Text(Strings.lossCutCta),
      onPressed: () => startLossCutCreate(context, ref, board: board, onCreated: onCreated),
    );
  }
}
