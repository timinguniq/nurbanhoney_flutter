import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// 프로필 수정에 필요한 모든 요건이 채워졌으면 true를 리턴 아니면 false를 리턴
final myaccountEditProvider = AutoDisposeProvider<bool>((ref) {
  var result = false;
  final nickname = ref.watch(myaccountEditNicknameNavigationProvider);
  final description = ref.watch(myaccountEditDescriptionNavigationProvider);

  log('myaccountEditProvider nickname : $nickname');
  log('myaccountEditProvider description : $description');

  if(board == '너반꿀'){
    // title, thumbnail, lossCut, content
    if(title != '제목을 입력하세요.' && title.isNotEmpty
        && thumbnail != ''
        && lossCut != '₩ 손실액을 입력하세요.' && lossCut.isNotEmpty
        && content != '내용을 입력하세요.' && content.isNotEmpty){
      result = true;
    }else{
      result = false;
    }
  }else if(board == '자유'){
    // title, content
    if(title != '제목을 입력하세요.' && title.isNotEmpty
        && content != '내용을 입력하세요.' && content.isNotEmpty){
      result = true;
    }else{
      result = false;
    }
  }else{
    result = false;
  }
  return result;
});