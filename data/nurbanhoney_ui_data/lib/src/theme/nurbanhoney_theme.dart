import 'package:flutter/material.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

/// Nurbanhoney theme
class NurbanhoneyTheme {
  /// Standard [ThemeData] for Nurbanhoney UI
  static ThemeData get standard {
    return ThemeData(
      useMaterial3: false,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: NurbanhoneyOverlayStyle.dark,
      ),
      scaffoldBackgroundColor: NurbanhoneyColors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: NurbanhoneyColors.primary,
        onPrimary: NurbanhoneyColors.white,
        secondary: NurbanhoneyColors.primary,
        onSecondary: NurbanhoneyColors.white,
        onSurface: NurbanhoneyColors.black,
        background: NurbanhoneyColors.white,
      ),
      textTheme: _textTheme,
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: NurbanhoneyTextStyle.headline1,
      displayMedium: NurbanhoneyTextStyle.headline2,
      displaySmall: NurbanhoneyTextStyle.headline3,
      headlineMedium: NurbanhoneyTextStyle.headline4,
      headlineSmall: NurbanhoneyTextStyle.headline5,
      titleMedium: NurbanhoneyTextStyle.subtitle1,
    );
  }
}
