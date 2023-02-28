import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

final overlayStyle = Provider<SystemUiOverlayStyle>((ref) {
  return NurbanhoneyOverlayStyle.dark;
});

