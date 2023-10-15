import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// 글 작성에 필요한 모든 요건이 채워졌으면 true를 리턴 아니면 false를 리턴
final articleCreateProvider = Provider<bool>((ref) {
  var result = false;
  final articleCreateBoardNavigation = ref.read(articleCreateBoardNavigationProvider);
  final articleCreateTitleNavigation = ref.read(articleCreateTitleNavigationProvider);
  final articleCreateThumbnailNavigation = ref.read(articleCreateThumbnailNavigationProvider);
  final articleCreateLossCutNavigation = ref.read(articleCreateLossCutNavigationProvider);
  final articleCreateContentNavigation = ref.read(articleCreateContentNavigationProvider);

  if(articleCreateBoardNavigation == '너반꿀'){
    // title, thumbnail, lossCut, content
  }else if(articleCreateBoardNavigation == '자유'){
    // title, content
  }else{
    result = false;
  }
  return result;

});