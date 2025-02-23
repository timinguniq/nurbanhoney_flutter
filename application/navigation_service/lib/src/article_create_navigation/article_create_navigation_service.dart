import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// 글 작성에 필요한 모든 요건이 채워졌으면 true를 리턴 아니면 false를 리턴
final articleCreateProvider = AutoDisposeProvider<bool>((ref) {
  var result = false;
  final board = ref.watch(articleCreateBoardNavigationProvider);
  final title = ref.watch(articleCreateTitleNavigationProvider);
  final thumbnail = ref.watch(articleCreateThumbnailNavigationProvider);
  final lossCut = ref.watch(articleCreateLossCutNavigationProvider);
  final content = ref.watch(articleCreateContentNavigationProvider);

  log('articleCreateProvider board : $board');
  log('articleCreateProvider title : $title');
  log('articleCreateProvider thumbnail : $thumbnail');
  log('articleCreateProvider lossCut : $lossCut');
  log('articleCreateProvider content : $content');

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
  }else if(board == '코인'){
    // title, content, lossCut, content
    if(title != '제목을 입력하세요.' && title.isNotEmpty
        && thumbnail != ''
        && lossCut != '₩ 손실액을 입력하세요.' && lossCut.isNotEmpty
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