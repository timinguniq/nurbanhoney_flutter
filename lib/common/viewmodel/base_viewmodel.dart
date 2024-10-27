import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  //Setters
  set isBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}