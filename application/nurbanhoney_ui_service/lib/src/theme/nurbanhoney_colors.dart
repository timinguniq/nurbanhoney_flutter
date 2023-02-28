import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_data/nurbanhoney_ui_data.dart';

final primaryColor = Provider<Color>((ref) {
  return NurbanhoneyColors.primary;
});

final primaryWhite = Provider<Color>((ref) {
  return NurbanhoneyColors.white;
});

final primaryBlack = Provider<Color>((ref) {
  return NurbanhoneyColors.black;
});

