import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/board/view/nurban_board_item_view.dart';
import 'package:nurbanhoney/board/view/widgets/nurban_board_badge.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/stock/stock.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

part 'stock_tab_viewmodel.dart';

class StockTabPage extends ConsumerWidget {
  const StockTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerColor = ref.read(colorBBBBBB);

    /// TODO: 여기 주식 데이터 받아서 표시해야 됨.
    final getNurbanAll = ref.watch(getNurbanAllProvider((0, -1, 100)));
    final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);
    final fConvertToInsignia = ref.read(convertToInsignia);

    return getNurbanAll.when(
      data: (data) {
        final receiveData = data;
        log('getNurbanAll data: $data');
        log('getNurbanAll data receiveData : $receiveData');
        for (var element in receiveData) {
          log('getNurbanAll data id: ${element.id}');
          log('getNurbanAll data board: ${element.board}');
          log('getNurbanAll data thumbnail: ${element.thumbnail}');
          log('getNurbanAll data title: ${element.title}');
          log('getNurbanAll data content: ${element.content}');
          log('getNurbanAll data commentCount: ${element.commentCount}');
          log('getNurbanAll data likeCount: ${element.likeCount}');
          log('getNurbanAll data createdAt: ${element.createdAt}');
          log('getNurbanAll data nickname: ${element.nickname}');
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              for (var element in receiveData)
                Column(
                  children: [
                    NurbanBoardItemView(
                      badge: const NurbanBoardBadge(),
                      title: element.title,
                      lossCut: element.lossCut,
                      author: element.nickname,
                      date: formattingCreatedAt(element.createdAt),
                      likeCount: element.likeCount,
                      thumbnail: CachedNetworkImage(
                        imageUrl: element.thumbnail ?? '',
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            Assets.images.home.nurbanSymbol.image(),
                      ),
                      onTap: () {
                        Navigator.of(context).push(ArticleDetailPage.route(
                          board: element.board,
                          articleId: element.id,
                        ));
                      },
                    ),
                    const AppbarDivider(),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () {
        log('getNurbanAll loading');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        log('getNurbanAll error: $error');
        return const Text('error');
      },
    );

    return BaseView<StockTabViewModel>(
      viewModel: StockTabViewModel(ref),
      builder: (context, viewModel) {
        //final status = viewModel.fetchState;
        //final stockList = viewModel.stockList;
        return RefreshIndicator(
          onRefresh: () async => viewModel.fetch(isRefresh: true),
          child: Builder(
            builder: (context) {
              log('status: ${viewModel.fetchState}');
              log('stockList: ${viewModel.stockList}');
              log('isBusy: ${viewModel.isBusy}');
              if (viewModel.fetchState is DataFetching) return const SizedBox();

              if (viewModel.fetchState is DataRefetching) return const SizedBox();

              if (viewModel.fetchState is DataFetchError) {
                final error = (viewModel.fetchState as DataFetchError).error;
                return Text('data fetch error: error=${error.toString()}');
              }

              if (viewModel.fetchState is DataFetchError) {
                final error = (viewModel.fetchState as DataFetchError).error;
                return Text('data fetch error: error=$error');
              }

              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 17),
                      const RankPage(
                        title: '이번주 손실액 Top3',
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        thickness: 1,
                        color: dividerColor,
                      ),
                      for (var element in viewModel.stockList)
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: StockListItem(
                                id: element.id,
                                title: element.title,
                                content: element.content,
                                thumbnail: element.thumbnail ?? '',
                                lossCut: element.lossCut,
                                commentCount: element.commentCount.toString(),
                                author: element.nickname,
                                badge: element.badge,
                                insigniaList:
                                    fConvertToInsignia(element.insignia),
                                date: formattingCreatedAt(element.createdAt),
                                likeCount: element.likeCount,
                                onTap: () {
                                  Navigator.of(context)
                                      .push(ArticleDetailPage.route(
                                    board: element.board,
                                    articleId: element.id,
                                  ));
                                },
                              ),
                            ),
                            const AppbarDivider(),
                          ],
                        ),
                    ],
                  ),
                ),
                bottomSheet: const StockTabBottomSheetView(),
              );
            },
          ),
        );
      },
    );
  }
}
