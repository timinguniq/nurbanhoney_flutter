import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

final standardTheme = Provider<ThemeData>((ref) {
  return NurbanhoneyTheme.standard;
});
