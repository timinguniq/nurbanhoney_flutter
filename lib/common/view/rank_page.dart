import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

class RankPage extends ConsumerStatefulWidget {
  const RankPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  ConsumerState<RankPage> createState() => _RankPageState();
}

class _RankPageState extends ConsumerState<RankPage> {
  int _current = 0;

  final CarouselSliderController _controller = CarouselSliderController();

  List imageList = [
    "https://cdn.pixabay.com/photo/2014/04/14/20/11/pink-324175_1280.jpg",
    "https://cdn.pixabay.com/photo/2014/02/27/16/10/flowers-276014_1280.jpg",
    "https://cdn.pixabay.com/photo/2012/03/01/00/55/flowers-19830_1280.jpg",
    "https://cdn.pixabay.com/photo/2015/06/19/20/13/sunset-815270_1280.jpg",
    "https://cdn.pixabay.com/photo/2016/01/08/05/24/sunflower-1127174_1280.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = ref.read(rankTitleStyle);
    final primaryColor = ref.read(colorF6B748);
    final greyColor = ref.read(colorC4C4C4);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Assets.images.common.rankIcon.image(
                  width: 12,
                  height: 26,
                ),

                const SizedBox(width: 8),

                Text(
                  widget.title,
                  style: titleStyle,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Column(
              children: [
                sliderWidget(),
                sliderIndicator(
                  selectColor: primaryColor,
                  unselectColor: greyColor,
                ),
              ],
            )

          ],
        ));
  }

  Widget sliderWidget() {

    final getRankTab = ref.watch(getRankTabProvider((offset: 0, limit: 3)));

    final fConvertToInsignia = ref.read(convertToInsignia);

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

        return CarouselSlider(
          carouselController: _controller,
          items: receiveData.map(
              (ele) {
                log('insigniaList before');
                // 휘장 리스트
                List<String> insigniaList = fConvertToInsignia(ele.insignia.toString());
                log('insigniaList after');

                return RankCard(
                  rankNumber: '1위',
                  badge: ele.badge,
                  nickname: ele.nickname,
                  totalLossCut: ele.totalLossCut.toString(),
                  totalLikeCount: ele.totalLossCut.toString(),
                  insigniaList: insigniaList,
                );
            }
          ).toList(),
          options: CarouselOptions(
            height: 100,
            viewportFraction: 1.0,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
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
  }

  Widget sliderIndicator({
    required Color selectColor,
    required Color unselectColor,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == entry.key
                  ? selectColor
                  : unselectColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
