import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_repository/share_repository.dart';

final funcFormattingToCreatedAt = Provider<Function>((ref) {
  final stringFunctions = StringFunctions();
  return stringFunctions.formattingToCreatedAt;
});

final convertToInsignia = Provider<Function>((ref) {
  final stringFunctions = StringFunctions();
  return stringFunctions.convertToInsignia;
});
