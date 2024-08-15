import 'package:flutter/material.dart';
import 'package:nurbanhoney/common/common.dart';

class HomeStockTabPage extends StatelessWidget {
  const HomeStockTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          RankPage(),
        ],
      ),
    );
  }
}
