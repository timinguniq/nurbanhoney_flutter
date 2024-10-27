import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

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

    /// TODO: 여기 주식 데이터 받아서 표시해야 됨.
    //final getNurbanAll = ref.watch(getNurbanAllProvider((0, -1, 100)));
    final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);
    final fConvertToInsignia = ref.read(convertToInsignia);

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
