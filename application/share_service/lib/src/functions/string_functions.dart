import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_repository/share_repository.dart';

final funcFormattingToCreatedAt = Provider.family<String, String>((ref, input) {
  final stringFunctions = StringFunctions();
  return stringFunctions.formattingToCreatedAt(input);
});
