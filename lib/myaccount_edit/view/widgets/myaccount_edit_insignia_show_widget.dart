import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/myaccount_edit/view/myaccount_edit_page.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 보이는 휘장
/// TODO: 만약에 테스트 해봐서 되면 여기 stateless로 바꿔서 해보기!
class MyaccountEditInsigniaShowWidget extends StatefulWidget {
  const MyaccountEditInsigniaShowWidget({
    required Function(String) insigniaShowRemove,
    super.key,
  }) : _insigniaShowRemove = insigniaShowRemove;

  final Function(String) _insigniaShowRemove;

  @override
  State<MyaccountEditInsigniaShowWidget> createState() =>
      _MyaccountEditInsigniaShowWidgetState();
}

class _MyaccountEditInsigniaShowWidgetState
    extends State<MyaccountEditInsigniaShowWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      if(insigniaShowList.contains('')){
        insigniaShowList.remove('');
      }

      log('insigniaShowList : $insigniaShowList');

      return SizedBox(
          width: double.infinity,
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 16),
                child: Text(
                  '보이는 휘장',
                  style: subTitleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 9),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var ele in insigniaShowList)
                        if (ele != '')
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: InkWell(
                              onTap: () {
                                // TODO: 클릭시 삭제
                                log('insigniaShow click ele : $ele');
                                widget._insigniaShowRemove(ele);
                              },
                              child: CachedNetworkImage(
                                imageUrl: ele,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                      if(insigniaShowList.contains(''))
                        const SizedBox(
                          width: 40,
                          height: 40,
                        )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Visibility(
                  visible: insigniaShowList.length >= 2,
                  child: Text(
                    '2개 이상은 선택할 수 없습니다.',
                    style: warnStyle,
                  ),
                ),
              ),

            ],
          ));
    });
  }
}
