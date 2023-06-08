
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

class DioRepository {
  /// constructor
  DioRepository();

  final dio = Dio();

  Future<List<BoardModel>> getBoard() async {
    try {
      final response = await dio.get('${DioApi.mainApi}/board');
      final result = <BoardModel>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoard response: ${response.data[i]}');
        result.add(BoardModel.fromJson(response.data[i]));
      }
      log('getBoard response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getBoard error : $e');
      throw Exception(e);
    }
  }
}
