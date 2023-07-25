import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'key_service.g.dart';

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