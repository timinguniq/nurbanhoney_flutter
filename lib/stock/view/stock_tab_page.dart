import 'dart:async';
import 'dart:developer';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/common/common.dart';
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

    final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);
    final fConvertToInsignia = ref.read(convertToInsignia);
    return BaseView<StockTabViewModel>(
      viewModel: StockTabViewModel(ref),
      builder: (context, viewModel) {
        return RefreshIndicator(
          onRefresh: () async => viewModel.fetch(isRefresh: true),
          child: Builder(
            builder: (context) {
              log('status: ${viewModel.fetchState}');
              log('stockList: ${viewModel.stockList}');
              log('isBusy: ${viewModel.isBusy}');
              if (viewModel.fetchState is DataFetching) return const SizedBox();

              if (viewModel.fetchState is DataRefetching) {
                return const SizedBox();
              }

              if (viewModel.fetchState is DataFetchError) {
                final error = (viewModel.fetchState as DataFetchError).error;
                return Text('data fetch error: error=${error.toString()}');
              }

              if (viewModel.fetchState is DataFetchError) {
                final error = (viewModel.fetchState as DataFetchError).error;
                return Text('data fetch error: error=$error');
              }

              return Scaffold(
                body: Column(
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.stockList.length,
                          itemBuilder: (_, index) {
                            final item = viewModel.stockList[index];

                            log('viewModel.isBusy: ${viewModel.isBusy}');
                            log('viewModel.hasNextPage: ${viewModel.hasNextPage}');
                            log('viewModel index: $index');

                            if (!viewModel.isBusy &&
                                viewModel.hasNextPage &&
                                index == viewModel.stockList.length - 10) {
                              Future(() =>
                                  unawaited(viewModel.fetch(isRefresh: false)));
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                  ),
                                  child: StockListItem(
                                    id: item.id,
                                    title: item.title,
                                    content: item.content,
                                    thumbnail: item.thumbnail ?? '',
                                    lossCut: item.lossCut,
                                    commentCount: item.commentCount.toString(),
                                    author: item.nickname,
                                    badge: item.badge,
                                    insigniaList:
                                        fConvertToInsignia(item.insignia),
                                    date: formattingCreatedAt(item.createdAt),
                                    likeCount: item.likeCount,
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(ArticleDetailPage.route(
                                        board: item.board,
                                        articleId: item.id,
                                      ));
                                    },
                                  ),
                                ),
                                const AppbarDivider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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
