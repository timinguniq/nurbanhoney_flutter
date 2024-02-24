
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 소유한 휘장
/// TODO: 만약에 테스트 해봐서 되면 여기 stateless로 바꿔서 해보기!
class MyaccountEditInsigniaOwnWidget extends StatefulWidget {
  const MyaccountEditInsigniaOwnWidget({
    required String insigniaOwn,
    required Function(String) insigniaShowAdd,
    super.key,
  }) : _insigniaOwn = insigniaOwn,
       _insigniaShowAdd = insigniaShowAdd;

  final String _insigniaOwn;
  final Function(String) _insigniaShowAdd;

  @override
  State<MyaccountEditInsigniaOwnWidget> createState() => _MyaccountEditInsigniaOwnWidgetState();
}

class _MyaccountEditInsigniaOwnWidgetState extends State<MyaccountEditInsigniaOwnWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      final insigniaOwnList = widget._insigniaOwn.substring(1, widget._insigniaOwn.length-1).split(',');

      return SizedBox(
          width: double.infinity,
          height: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 31, left: 16),
                child: Text(
                  '보유 휘장',
                  style: subTitleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 9),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var ele in insigniaOwnList)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: InkWell(
                            onTap: () {
                              // TODO: 클릭시 삭제
                              log('insigniaOwn click ele : $ele');
                              widget._insigniaShowAdd(ele);
                            },
                            child: CachedNetworkImage(
                              imageUrl: ele.trim(),
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
                    ],
                  ),
                ),
              ),
            ],
          ));
    });
  }
}
