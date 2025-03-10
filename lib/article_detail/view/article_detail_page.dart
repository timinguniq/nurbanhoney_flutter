import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/config/config.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage(
      {required int board, required int articleId, super.key})
      : _board = board,
        _articleId = articleId;

  final int _board;
  final int _articleId;

  static Route route({
    required int articleId,
    required int board,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ArticleDetailPage(
        articleId: articleId,
        board: board,
      ),
    );
  }

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;

  AdManagerBannerAd? _adManagerBannerAd;
  bool _adManagerBannerAdIsLoaded = false;

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final thinDividerColor = ref.read(color55000000);
      final thickDividerColor = ref.read(color55C4C4C4);

      final appBarTitleStyle = ref.read(articleDetailAppbarTitleStyle);

      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;

      final androidId = prefStorage?.getDeviceId();

      final nurbanArticle = ref.watch(getNurbanArticleProvider(widget._articleId));

      return nurbanArticle.when(
        data: (data) {
          return Scaffold(
            appBar: ArticleDetailAppBar(
              board: widget._board,
              articleId: widget._articleId,
              appBarTitleStyle: appBarTitleStyle,
              authorId: data.userId,
              uuid: data.uuid,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ArticleDetailDivider(
                    thickness: 0.5,
                    color: thinDividerColor,
                  ),
                  // TitleBoard
                  widget._board == 1
                      ? NurbanTitleBoard(
                    articleId: widget._articleId,
                  )
                      : widget._board == 2
                      ? FreeTitleBoard(
                    articleId: widget._articleId,
                  )
                      : FreeTitleBoard(
                    articleId: widget._articleId,
                  ),
                  ArticleDetailDivider(
                    thickness: 0.5,
                    color: thinDividerColor,
                  ),
                  // Content
                  widget._board == 1
                      ? NurbanContentBoard(
                    articleId: widget._articleId,
                  )
                      : widget._board == 2
                      ? FreeContentBoard(
                    articleId: widget._articleId,
                  )
                      : FreeContentBoard(
                    articleId: widget._articleId,
                  ),
                  // 광고 banner
                  if(_bannerAdIsLoaded && _bannerAd != null)
                    Container(
                      alignment: Alignment.center,
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  //
                  ArticleDetailDivider(
                    thickness: 0.5,
                    color: thinDividerColor,
                  ),
                  LikeDislikeBoard(
                    articleId: widget._articleId,
                  ),
                  ArticleDetailDivider(
                    thickness: 8,
                    color: thickDividerColor,
                  ),
                  ArticleDetailCommentPage(
                    articleId: widget._articleId,
                  ),

                ],
              ),
            ),
          );

        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('nurbanArticle error: $error');
          //Navigator.of(context).pop();
          /// TODO: 서버에서 에러 처리하고 팝업 띄우고 뒤로가기 처리

          final errorMessage = error.toString();
          if(errorMessage.contains('404')){
            Fluttertoast.showToast(
              msg: "글이 존재하지 않습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.of(context).pop();
          }
          return Text('data fetch error: error=$error');
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? banner1key
            : banner1key,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            log('$BannerAd loaded.');
            setState(() {
              _bannerAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            log('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => log('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => log('$BannerAd onAdClosed.'),
        ),
        request: const AdRequest())
      ..load();

  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }
}
