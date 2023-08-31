import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreateAppbar extends StatelessWidget {
  const ArticleCreateAppbar({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => ArticleCreateAppbar(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final boardTextStyle = ref.read(articleCreateBoardStyle);
      final confirmTextStyle = ref.read(articleCreateConfirmStyle);

      return Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: Assets.images.articleCreate.articleCreateClose.image(),
          ),
          const Expanded(
            child: SizedBox(
              width: 1,
            )
          ),
          InkWell(
            onTap: () async{
              await _showPickerDialog(context);
            },
            child: Text('타이틀'),
          )

        ],
      );
    });
  }

  // TODO: 이거 쓰지 말고 그냥 직접 만들기.
  Future<void> _showPickerDialog(BuildContext context) async{
    await Picker(
        adapter: PickerDataAdapter<String>(
            pickerData: const JsonDecoder().convert(pickerData)),
        hideHeader: true,
        //title: const Text("Select Data"),
        selectedTextStyle: const TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          log('picker value : ${value.toString()}');
          log('picker getSelectedValues : ${picker.getSelectedValues()}');
        }).showDialog(context);
  }

  final pickerData = '''
[
   "너반꿀",
   "자유"
]
    ''';
}
