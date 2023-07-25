import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class KeyService extends _$KeyService{
  @override
  String build() {
    state = '';
    return state;
  }

  void set(String key){
    state = key;
  }
}