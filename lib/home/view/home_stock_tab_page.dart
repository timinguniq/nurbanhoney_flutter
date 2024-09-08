import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

class HomeStockTabPage extends ConsumerWidget {
  const HomeStockTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerColor = ref.read(colorBBBBBB);
    /// TODO: 여기 주식 데이터 받아서 표시해야 됨.
    final getNurbanAll =
      ref.watch(getNurbanAllProvider((0, -1, 100)));
    final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

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

            ],
          ),
          bottomSheet: const HomeStockTabBottomSheetView(),
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

  }
}
