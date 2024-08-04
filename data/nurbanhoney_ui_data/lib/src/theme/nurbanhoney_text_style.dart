import 'package:flutter/widgets.dart';
import 'package:nurbanhoney_ui_data/gen/fonts.gen.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

const _fontPackage = 'nurbanhoney_ui';
const _primaryFontFamily = FontFamily.pretendardStd;

/// Different [TextStyle] used in the game
abstract class NurbanhoneyTextStyle {

  /// Font size: 30 | Color: white
  static const headline1 = TextStyle(
    fontSize: 30,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 28 | Color: white
  static const headline2 = TextStyle(
    fontSize: 28,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 26 | Color: darkBlue
  static const headline3 = TextStyle(
    fontSize: 26,
    color: NurbanhoneyColors.darkBlue,
    height: 1.0,
  );

  /// Font size: 24 | Color: white
  static const headline4 = TextStyle(
    fontSize: 24,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 14| Color: white
  static const headline5 = TextStyle(
    fontSize: 14,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 14 | Color: darkGrey
  static const subtitle1 = TextStyle(
    fontSize: 14,
    color: NurbanhoneyColors.darkGrey,
    height: 1.0,
  );

  /// Font size: 12 | Color: F6B748
  static const appbarBottomSelected = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 12 | Color: F6B748
  static const appbarBottomUnSelected = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorBABABA,
    height: 1.0,
  );

  /// Font size: 12 | Color: 222222
  static const rankTabTitle = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.darkGrey,
    height: 1.0,
  );

  /// Font size: 12 | Color: 6F6F6F
  static const rankTabWhole = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color6F6F6F,
    height: 1.0,
  );

  /// Font size: 16 | Color: 212124
  static const rankTabEleTitle = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.color212124,
    height: 1.0,
  );

  /// Font size: 14 | Color: 212124
  static const rankTabEleContent = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.color212124,
    height: 1.0,
  );

  /// Font size: 12 | Color: 4D5159
  static const rankTabEleMoney = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color4D5159,
    height: 1.0,
  );

  /// Font size: 10 | Color: 868B94
  static const rankTabEleAuthor = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
    height: 1.0,
  );

  /// Font size: 10 | Color: 4D5159
  static const homeDividerTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4D5159,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const badgeTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: FFFFFF
  static const rankMajorTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 10 | Color: 212124
  static const rankMinorTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color212124,
    height: 1.0,
  );

  /// Font size: 14 | Color: 212124
  static const boardListItemTitle = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color212124,
    height: 1.0,
  );

  /// Font size: 12 | Color: 868B94
  static const boardListItemContent = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
    height: 1.0,
  );

  /// Font size: 10 | Color: 868B94
  static const boardListItemAuthor = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const boardListItemLike = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: F6B748
  static const homeBottomNavigationSelected = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 22 | Color: 1E1E1E
  static const loginTitle = TextStyle(
    fontSize: 22,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const loginKakao = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: FFFFFF
  static const loginNaver = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 12 | Color: D2D2D2
  static const loginNotice = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.colorD2D2D2,
    height: 1.0,
  );

  /// Font size: 12 | Color: FFFFFF
  static const loginNoticeHighlight = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerProfile = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerProfileEdit = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerBoard = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color505050,
    height: 1.0,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const articleDetailAppbarTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 16 | Color: 1E1E1E
  static const articleDetailNurbanTitle = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const articleDetailNurbanAuthor = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const articleDetailNurbanElement = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 12 | Color: 4F4F4F
  static const articleDetailNurbanLossCutTitle = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4F4F4F,
    height: 1.0,
  );

  /// Font size: 14 | Color: 4F4F4F
  static const articleDetailNurbanLossCutValue = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4F4F4F,
    height: 1.0,
  );

  /// Font size: 12 | Color: 1E1E1E
  static const articleDetailNurbanContent = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 21 / 12,
  );

  /// Font size: 12 | Color: 000000
  static const articleDetailLike = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.black,
    height: 1.0,
  );

  /// Font size: 16 | Color: 1E1E1E
  static const articleCreateBoard = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const articleCreateConfirm = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 18 | Color: 858585
  static const articleCreateTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color858585,
    height: 1.0,
  );

  /// Font size: 14 | Color: 858585
  static const articleCreateLossCut = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color858585,
    height: 1.0,
  );

  /// Font size: 12 | Color: 858585
  static const articleCreateContent = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color858585,
    height: 1.0,
  );

  /// Font size: 14 | Color: C4C4C4
  static const articleDetailCommentEmpty = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorC4C4C4,
    height: 1.0,
  );

  /// Font size: 12 | Color: 808080
  static const articleDetailCommentInputHint = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color808080,
    height: 1.0,
  );

  /// Font size: 12 | Color: F6B748
  static const articleDetailCommentRegister = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 12 | Color: 1E1E1E
  static const articleDetailCommentInput = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 12 | Color: 121214
  static const articleDetailCommentContent = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color121214,
    height: 1.0,
  );

  /// Font size: 14 | Color: 121214
  static const articleDetailCommentDelete = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color121214,
    height: 1.0,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const myaccountTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 12 | Color: FFFFFF
  static const myaccountRevise = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.white,
    height: 1.0,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const myaccountNickname = myaccountTitle;

  /// Font size: 12 | Color: 1E1E1E
  static const myaccountIntroduce = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const myaccountFactorTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 16 | Color: 1E1E1E
  static const myaccountFactorValue = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const myaccountArticleTitle = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const myaccountArticleDate = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const myaccountArticleCount = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const myaccountArticleItemTitle = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const myaccountArticleItemDate = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const myaccountArticleItemCommentCount = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const myaccountSettingTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const myaccountSettingType = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: F6B748
  static const myaccountSettingLogout = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 16 | Color: 505050
  static const myaccountSettingWithdrawal = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color505050,
    height: 1.0,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const myaccountEditTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 14 | Color: F6B748
  static const myaccountEditConfirm = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const myaccountEditSubTitle = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 16 | Color: 1E1E1E
  static const myaccountEditSubValue = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.0,
  );

  /// Font size: 12 | Color: FF0000
  static const myaccountEditWarn = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w300,
    color: NurbanhoneyColors.colorFF0000,
    height: 1.0,
  );

  /// Font size: 20 | Color: FF
  static const homeTab = TextStyle(
    fontSize: 20,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.0,
  );

}
