import 'package:flutter/services.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

/// Nurbanhoney overlay style
abstract class NurbanhoneyOverlayStyle {
  static SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    systemNavigationBarColor: NurbanhoneyColors.white.withOpacity(0.002),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    statusBarColor: NurbanhoneyColors.transparent,
  );
}
