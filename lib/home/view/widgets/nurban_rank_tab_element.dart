import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class NurbanRankTabElement extends StatelessWidget {
  const NurbanRankTabElement({
    required int rankNumber,
    required String rankTitle,
    required String rankLossCut,
    required String author,
    Key? key,
  }) : _rankNumber = rankNumber,
       _rankTitle = rankTitle,
        _rankLossCut = rankLossCut,
        _author = author,
        super(key: key);

  final int _rankNumber;
  final String _rankTitle;
  final String _rankLossCut;
  final String _author;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {

      final rankTabBackgroundColor = ref.read(color33F6B748);

      final rankTabTitleStyle = ref.watch(rankTabTitle);
      final rankTabWholeStyle = ref.watch(rankTabWhole);

      return Container(
        width: 200,
        height: 120,
        // rounded corner
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: rankTabBackgroundColor,
        ),
      );
    });


  }
}
