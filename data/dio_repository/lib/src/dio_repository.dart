
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

class DioRepository {
  /// constructor
  DioRepository();

  final dio = Dio();

  final _mainApi = 'http://3.37.182.144:8128';

  Future<List<BoardModel>> getBoard() async {
    try {
      final response = await dio.get('$_mainApi/board');
      final result = <BoardModel>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('DioRepository response: ${response.data[i]}');
        result.add(BoardModel.fromJson(response.data[i]));
      }
      log('DioRepository response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('DioRepository e : $e');
      throw Exception(e);
    }
  }
}
