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
  );

  /// Font size: 28 | Color: white
  static const headline2 = TextStyle(
    fontSize: 28,
    color: NurbanhoneyColors.white,
  );

  /// Font size: 26 | Color: darkBlue
  static const headline3 = TextStyle(
    fontSize: 26,
    color: NurbanhoneyColors.darkBlue,
  );

  /// Font size: 24 | Color: white
  static const headline4 = TextStyle(
    fontSize: 24,
    color: NurbanhoneyColors.white,
  );

  /// Font size: 14| Color: white
  static const headline5 = TextStyle(
    fontSize: 14,
    color: NurbanhoneyColors.white,
  );

  /// Font size: 14 | Color: darkGrey
  static const subtitle1 = TextStyle(
    fontSize: 14,
    color: NurbanhoneyColors.darkGrey,
  );

  /// Font size: 12 | Color: F6B748
  static const appbarBottomSelected = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
  );

  /// Font size: 12 | Color: F6B748
  static const appbarBottomUnSelected = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorBABABA,
  );

  /// Font size: 12 | Color: 222222
  static const rankTabTitle = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.darkGrey,
  );

  /// Font size: 12 | Color: 6F6F6F
  static const rankTabWhole = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color6F6F6F,
  );

  /// Font size: 16 | Color: 212124
  static const rankTabEleTitle = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.color212124,
  );

  /// Font size: 14 | Color: 212124
  static const rankTabEleContent = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.color212124,
  );

  /// Font size: 12 | Color: 4D5159
  static const rankTabEleMoney = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color4D5159,
  );

  /// Font size: 10 | Color: 868B94
  static const rankTabEleAuthor = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
  );

  /// Font size: 10 | Color: 4D5159
  static const homeDividerTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4D5159,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const badgeTitle = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
  );

  /// Font size: 14 | Color: 212124
  static const boardListItemTitle = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color212124,
  );

  /// Font size: 12 | Color: 868B94
  static const boardListItemContent = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
  );

  /// Font size: 10 | Color: 868B94
  static const boardListItemAuthor = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color868B94,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const boardListItemLike = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
  );

  /// Font size: 10 | Color: F6B748
  static const homeBottomNavigationSelected = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.2,
  );

  /// Font size: 22 | Color: 1E1E1E
  static const loginTitle = TextStyle(
    fontSize: 22,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const loginKakao = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 14 | Color: FFFFFF
  static const loginNaver = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.white,
    height: 1.2,
  );

  /// Font size: 12 | Color: D2D2D2
  static const loginNotice = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.colorD2D2D2,
    height: 1.2,
  );

  /// Font size: 12 | Color: FFFFFF
  static const loginNoticeHighlight = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.colorF6B748,
    height: 1.2,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerProfile = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerProfileEdit = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w600,
    color: NurbanhoneyColors.white,
    height: 1.2,
  );

  /// Font size: 12 | Color: FFFFFF
  static const drawerBoard = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color505050,
    height: 1.2,
  );

  /// Font size: 18 | Color: 1E1E1E
  static const articleDetailAppbarTitle = TextStyle(
    fontSize: 18,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 16 | Color: 1E1E1E
  static const articleDetailNurbanTitle = TextStyle(
    fontSize: 16,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 14 | Color: 1E1E1E
  static const articleDetailNurbanAuthor = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1.2,
  );

  /// Font size: 10 | Color: 1E1E1E
  static const articleDetailNurbanElement = TextStyle(
    fontSize: 10,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w400,
    color: NurbanhoneyColors.color1E1E1E,
    height: 1,
  );

  /// Font size: 12 | Color: 4F4F4F
  static const articleDetailNurbanLossCutTitle = TextStyle(
    fontSize: 12,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4F4F4F,
    height: 1.2,
  );

  /// Font size: 14 | Color: 4F4F4F
  static const articleDetailNurbanLossCutValue = TextStyle(
    fontSize: 14,
    package: _fontPackage,
    fontFamily: _primaryFontFamily,
    fontWeight: FontWeight.w500,
    color: NurbanhoneyColors.color4F4F4F,
    height: 1.2,
  );

}
