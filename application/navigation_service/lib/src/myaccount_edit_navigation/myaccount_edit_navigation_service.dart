import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// 프로필 수정에 필요한 모든 요건이 채워졌으면 true를 리턴 아니면 false를 리턴
final myaccountEditProvider = AutoDisposeProvider<bool>((ref) {
  var result = true;
  final nickname = ref.watch(myaccountEditNicknameNavigationProvider);
  final description = ref.watch(myaccountEditDescriptionNavigationProvider);

  log('myaccountEditProvider nickname : $nickname');
  log('myaccountEditProvider description : $description');

  if(nickname == '' || description == ''){
    result = false;
  }
  return result;
});