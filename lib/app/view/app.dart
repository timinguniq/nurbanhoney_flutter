import 'package:flutter/material.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NurbanhoneyTheme.standard,
      home: Container(
        child: Text('test'),
      ),
    );
  }
}

