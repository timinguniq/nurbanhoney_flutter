
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

class FreeRepository {
  /// constructor
  FreeRepository._privateConstructor();
  static final FreeRepository _instance = FreeRepository._privateConstructor();

  factory FreeRepository(){
    return _instance;
  }
}
