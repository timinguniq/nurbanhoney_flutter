import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_storage/preference_storage.dart';

final preferenceStorageProvider = FutureProvider.autoDispose<PreferenceStorage>((ref) async {
  final sharedPreference = await SharedPreferences.getInstance();
  return PreferenceStorage(plugin: sharedPreference);
});