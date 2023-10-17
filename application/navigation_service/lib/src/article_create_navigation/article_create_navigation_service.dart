import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// 글 작성에 필요한 모든 요건이 채워졌으면 true를 리턴 아니면 false를 리턴
final articleCreateProvider = Provider<bool>((ref) {
  var result = false;
  final board = ref.read(articleCreateBoardNavigationProvider);
  final title = ref.read(articleCreateTitleNavigationProvider);
  final thumbnail = ref.read(articleCreateThumbnailNavigationProvider);
  final lossCut = ref.read(articleCreateLossCutNavigationProvider);
  final content = ref.read(articleCreateContentNavigationProvider);

  if(board == '너반꿀'){
    // title, thumbnail, lossCut, content
    if(title != '제목을 입력하세요.'
      && thumbnail != ''
      && lossCut != '₩ 손실액을 입력하세요.'
      && content != '내용을 입력하세요.'){
      result = true;
    }else{
      result = false;
    }
  }else if(board == '자유'){
    // title, content
    if(title != '제목을 입력하세요.'
      && content != '내용을 입력하세요.') {
      result = true;
    }else{
      result = false;
    }
  }else{
    result = false;
  }
  return result;
});