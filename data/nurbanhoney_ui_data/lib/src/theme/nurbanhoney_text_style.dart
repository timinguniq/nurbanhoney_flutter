import 'package:flutter/widgets.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

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

}
