import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanRankTabView extends StatelessWidget {
  const NurbanRankTabView({
    required VoidCallback? onTap,
    required int? rankLength,
    Key? key
  }) : _onTap = onTap,
       _rankLength = rankLength,
       super(key: key);

  final VoidCallback? _onTap;
  final int? _rankLength;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final rankCount = _rankLength ?? 0;

      final rankTabTitleStyle = ref.watch(rankTabTitle);
      final rankTabWholeStyle = ref.watch(rankTabWhole);

      final getRankTab = ref.watch(getRankTabProvider((offset: 0,limit: 3)));

      return getRankTab.when(
        data: (data) {
          final receiveData = data;
          log('getRankTab data: $data');
          log('getRankTab data receiveData : $receiveData');
          for (var element in receiveData) {
            log('getRankTab data id: ${element.id}');
            log('getRankTab data userId: ${element.userId}');
            log('getRankTab data badge: ${element.badge}');
            log('getRankTab data nickname: ${element.nickname}');
            log('getRankTab data insignia: ${element.insignia}');
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 55,
                      height: 20,
                      child: Assets.images.home.nurbanChar.image(),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 20,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '랭킹',
                          style: rankTabTitleStyle,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    InkWell(
                      onTap: _onTap,
                      child: SizedBox(
                        width: 80,
                        height: 20,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '전체보기',
                            style: rankTabWholeStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var element in data)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: NurbanRankTabElement(
                            rankNumber: element.id,
                            rankTitle: 'title',
                            rankLossCut: element.totalLossCut.toString(),
                            author: element.nickname,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () {
          log('getRankTab loading');
          return const Center(
              child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('getRankTab error: $error');
          return const Text('error');
        },
      );

    });
  }

  void exampleGetRankTab(WidgetRef ref, int offset, int limit){
    final getRankTab = ref.watch(getRankTabProvider((offset: offset,limit: limit)));
    log('getRankTab: $getRankTab');
    getRankTab.when(
      data: (data) {
        final receiveData = data;
        log('getRankTab data: $data');
        log('getRankTab data receiveData : $receiveData');
        for (var element in receiveData) {
          log('getRankTab data id: ${element.id}');
          log('getRankTab data userId: ${element.userId}');
          log('getRankTab data badge: ${element.badge}');
          log('getRankTab data nickname: ${element.nickname}');
          log('getRankTab data insignia: ${element.insignia}');
        }
      },
      loading: () {
        log('getRankTab loading');
      },
      error: (error, stackTrace) {
        log('getRankTab error: $error');
      },
    );
  }
}
