import 'dart:developer';

import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/home/view/widgets/drawer_profile.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

import 'package:nurbanhoney/stock/stock.dart';
import 'package:nurbanhoney/coin/coin.dart';

class HomePageRefactor extends StatelessWidget {
  const HomePageRefactor({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  static Route route({int initialIndex = 0}) {
    return MaterialPageRoute<void>(
      builder: (_) => HomePageRefactor(initialIndex: initialIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeViewRefactor(initialIndex: initialIndex);
  }
}

class HomeViewRefactor extends ConsumerStatefulWidget {
  const HomeViewRefactor({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  ConsumerState<HomeViewRefactor> createState() => _HomeViewRefactorState();
}

class _HomeViewRefactorState extends ConsumerState<HomeViewRefactor> {
  final List<Widget> _widgetOptions = const <Widget>[
    StockTabPage(),
    CoinTabPage(),
  ];

  // Global key to access HomeBody state
  final GlobalKey<_HomeBodyState> _homeBodyKey = GlobalKey<_HomeBodyState>();

  @override
  void initState() {
    super.initState();
  }

  /// Switch to the tab at the given index
  void switchTab(int index) {
    _homeBodyKey.currentState?.switchTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final tabSelectedColor = ref.read(colorF6B748);
    final tabUnselectedColor = ref.read(color212124);
    final authenticationProvider = ref.watch(authenticationServiceProvider);
    final homeTabTextStyle = ref.read(homeTabStyle);
    final homeBottomNavigation = ref.watch(homeBottomNavigationProvider);

    return Scaffold(
      drawer: const DrawerProfile(),
      body: HomeBody(
        key: _homeBodyKey,
        tabSelectedColor: tabSelectedColor,
        tabUnselectedColor: tabUnselectedColor,
        homeTabTextStyle: homeTabTextStyle,
        widgetOptions: _widgetOptions,
        initialIndex: widget.initialIndex,
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  final Color tabSelectedColor;
  final Color tabUnselectedColor;
  final TextStyle homeTabTextStyle;
  final List<Widget> widgetOptions;
  final int initialIndex;

  const HomeBody({
    Key? key,
    required this.tabSelectedColor,
    required this.tabUnselectedColor,
    required this.homeTabTextStyle,
    required this.widgetOptions,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Switch to the tab at the given index
  void switchTab(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0) {
          // Drawer
          log('Swiping in right direction');
          Future.delayed(Duration.zero, () {
            if (context.mounted) Scaffold.of(context).openDrawer();
          });
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: widget.tabSelectedColor,
              unselectedLabelColor: widget.tabUnselectedColor,
              labelStyle: widget.homeTabTextStyle,
              indicatorWeight: 2,
              tabs: const [
                Tab(
                  text: '주식',
                  height: 50,
                ),
                Tab(
                  text: '코인',
                  height: 50,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  widget.widgetOptions[0],
                  widget.widgetOptions[1],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
