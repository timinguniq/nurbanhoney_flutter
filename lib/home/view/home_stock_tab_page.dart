import 'package:flutter/material.dart';
import 'package:nurbanhoney/common/common.dart';

class HomeStockTabPage extends StatelessWidget {
  const HomeStockTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 17),

          RankPage(
            title: '이번주 손실액 Top3',
          ),
        ],
      ),
    );
  }
}
