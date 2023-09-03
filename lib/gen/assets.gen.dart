/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  $AssetsImagesArticleCreateGen get articleCreate =>
      const $AssetsImagesArticleCreateGen();
  $AssetsImagesArticleDetailGen get articleDetail =>
      const $AssetsImagesArticleDetailGen();
  $AssetsImagesHomeGen get home => const $AssetsImagesHomeGen();
  $AssetsImagesLoginGen get login => const $AssetsImagesLoginGen();
  $AssetsImagesSplashGen get splash => const $AssetsImagesSplashGen();
}

class $AssetsImagesArticleCreateGen {
  const $AssetsImagesArticleCreateGen();

  /// File path: assets/images/article_create/article_create_close.png
  AssetGenImage get articleCreateClose => const AssetGenImage(
      'assets/images/article_create/article_create_close.png');

  /// File path: assets/images/article_create/article_create_downdrop.png
  AssetGenImage get articleCreateDowndrop => const AssetGenImage(
      'assets/images/article_create/article_create_downdrop.png');

  /// List of all assets
  List<AssetGenImage> get values => [articleCreateClose, articleCreateDowndrop];
}

class $AssetsImagesArticleDetailGen {
  const $AssetsImagesArticleDetailGen();

  /// File path: assets/images/article_detail/loss_cut_icon.png
  AssetGenImage get lossCutIcon =>
      const AssetGenImage('assets/images/article_detail/loss_cut_icon.png');

  /// List of all assets
  List<AssetGenImage> get values => [lossCutIcon];
}

class $AssetsImagesHomeGen {
  const $AssetsImagesHomeGen();

  /// File path: assets/images/home/drawer_board_icon.png
  AssetGenImage get drawerBoardIcon =>
      const AssetGenImage('assets/images/home/drawer_board_icon.png');

  /// File path: assets/images/home/drawer_profile_edit.png
  AssetGenImage get drawerProfileEdit =>
      const AssetGenImage('assets/images/home/drawer_profile_edit.png');

  /// File path: assets/images/home/floating_button.png
  AssetGenImage get floatingButton =>
      const AssetGenImage('assets/images/home/floating_button.png');

  /// File path: assets/images/home/home_toolbar.png
  AssetGenImage get homeToolbar =>
      const AssetGenImage('assets/images/home/home_toolbar.png');

  /// File path: assets/images/home/navi_home_active.png
  AssetGenImage get naviHomeActive =>
      const AssetGenImage('assets/images/home/navi_home_active.png');

  /// File path: assets/images/home/navi_home_inactive.png
  AssetGenImage get naviHomeInactive =>
      const AssetGenImage('assets/images/home/navi_home_inactive.png');

  /// File path: assets/images/home/navi_myaccount_active.png
  AssetGenImage get naviMyaccountActive =>
      const AssetGenImage('assets/images/home/navi_myaccount_active.png');

  /// File path: assets/images/home/navi_myaccount_inactive.png
  AssetGenImage get naviMyaccountInactive =>
      const AssetGenImage('assets/images/home/navi_myaccount_inactive.png');

  /// File path: assets/images/home/navi_rank_active.png
  AssetGenImage get naviRankActive =>
      const AssetGenImage('assets/images/home/navi_rank_active.png');

  /// File path: assets/images/home/navi_rank_inactive.png
  AssetGenImage get naviRankInactive =>
      const AssetGenImage('assets/images/home/navi_rank_inactive.png');

  /// File path: assets/images/home/nurban_char.png
  AssetGenImage get nurbanChar =>
      const AssetGenImage('assets/images/home/nurban_char.png');

  /// File path: assets/images/home/nurban_rank_tab_money.png
  AssetGenImage get nurbanRankTabMoney =>
      const AssetGenImage('assets/images/home/nurban_rank_tab_money.png');

  /// File path: assets/images/home/nurban_symbol.png
  AssetGenImage get nurbanSymbol =>
      const AssetGenImage('assets/images/home/nurban_symbol.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        drawerBoardIcon,
        drawerProfileEdit,
        floatingButton,
        homeToolbar,
        naviHomeActive,
        naviHomeInactive,
        naviMyaccountActive,
        naviMyaccountInactive,
        naviRankActive,
        naviRankInactive,
        nurbanChar,
        nurbanRankTabMoney,
        nurbanSymbol
      ];
}

class $AssetsImagesLoginGen {
  const $AssetsImagesLoginGen();

  /// File path: assets/images/login/google_symbol.png
  AssetGenImage get googleSymbol =>
      const AssetGenImage('assets/images/login/google_symbol.png');

  /// File path: assets/images/login/kakao_symbol.png
  AssetGenImage get kakaoSymbol =>
      const AssetGenImage('assets/images/login/kakao_symbol.png');

  /// File path: assets/images/login/login_close.png
  AssetGenImage get loginClose =>
      const AssetGenImage('assets/images/login/login_close.png');

  /// File path: assets/images/login/naver_symbol.png
  AssetGenImage get naverSymbol =>
      const AssetGenImage('assets/images/login/naver_symbol.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [googleSymbol, kakaoSymbol, loginClose, naverSymbol];
}

class $AssetsImagesSplashGen {
  const $AssetsImagesSplashGen();

  /// File path: assets/images/splash/splash.png
  AssetGenImage get splash =>
      const AssetGenImage('assets/images/splash/splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [splash];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => _assetName;
}
