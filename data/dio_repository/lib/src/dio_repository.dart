
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

class DioRepository {
  /// constructor
  DioRepository();

  final dio = Dio();

  Future<List<({int id, int type, String name, String address})>> getBoard() async {
    try {
      final response = await dio.get('${DioApi.mainApi}/board');
      final result = <({int id, int type, String name, String address})>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoard response: ${response.data[i]}');
        final records =
          (id: int.parse(response.data[i]['id'].toString()),
          type: int.parse(response.data[i]['type'].toString()),
          name: response.data[i]['name'].toString(),
          address: response.data[i]['address'].toString());
       // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
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
