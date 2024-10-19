import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/common/common.dart';

class StockTabViewModel extends BaseViewModel {
  StockTabViewModel(
    this.ref,
  );

  WidgetRef ref;

  @override
  FutureOr<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  // fetch
  Future<void> fetchStockData() async {
    isLoading = true;



    notifyListeners();

    isLoading = false;
  }


}
