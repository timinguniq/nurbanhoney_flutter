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

  /// Font size: 12 | Color: red
  static const subtitle2error = TextStyle(
    fontSize: 12,
    color: NurbanhoneyColors.error,
  );

  /// Font size: 12 | Color: red
  static const temp1 = TextStyle(
    fontSize: 24,
    color: NurbanhoneyColors.text222222,
  );

  /// Font size: 12 | Color: red
  static const temp2 = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: NurbanhoneyColors.text424242,
  );

  /// Font size: 12 | Color: red
  static const temp3 = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: NurbanhoneyColors.text222222,
  );

  /// Font size: 12 | Color: red
  static const appbarTitle = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    color: NurbanhoneyColors.text222222,
  );

  /// Font size: 12 | Color: red
  static const temp4 = TextStyle(
    fontSize: 20,
    height: 3 / 2,
    letterSpacing: -0.2,
    color: NurbanhoneyColors.text222222,
  );

  /// Font size: 12 | Color: red
  static const temp5 = TextStyle(
    fontSize: 14,
    height: 10 / 7,
    letterSpacing: -0.2,
    color: NurbanhoneyColors.text424242,
  );
}
