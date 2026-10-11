import 'dart:async';
import 'dart:developer';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/home/home.dart';

part 'coin_tab_viewmodel.dart';

/// 홈 코인 탭. 목록 상태는 [CoinTabViewModel](레거시 ChangeNotifier, 유지 결정) 이 갖고 UI 는 [BoardTabView] 가 그린다.
class CoinTabPage extends ConsumerStatefulWidget {
  const CoinTabPage({super.key});

  @override
  ConsumerState<CoinTabPage> createState() => _CoinTabPageState();
}

class _CoinTabPageState extends ConsumerState<CoinTabPage> {
  late final CoinTabViewModel _viewModel = CoinTabViewModel(ref);

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (_, __) => BoardTabView(
        board: 2,
        fetchState: _viewModel.fetchState,
        items: _viewModel.coinList,
        hasNextPage: _viewModel.hasNextPage,
        onRefresh: () => _viewModel.fetch(isRefresh: true),
        onLoadMore: () => unawaited(_viewModel.fetch(isRefresh: false)),
      ),
    );
  }
}
