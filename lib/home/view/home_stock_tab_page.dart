import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class HomeStockTabPage extends ConsumerWidget {
  const HomeStockTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerColor = ref.read(colorBBBBBB);

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 17),

          RankPage(
            title: '이번주 손실액 Top3',
          ),

          const SizedBox(height: 12),

          Divider(
            thickness: 1,
            color: dividerColor,
          )

        ],
      ),
    );
  }
}
