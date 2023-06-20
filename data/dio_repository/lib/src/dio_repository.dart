
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';


typedef BoardAllType = ({int id, int board, String? thumbnail,
  String title, String content, String commentCount, String likeCount, String createdAt,
  String nickname});

class DioRepository {
  /// constructor
  DioRepository._privateConstructor();
  static final DioRepository _instance = DioRepository._privateConstructor();

  factory DioRepository(){
    return _instance;
  }

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

  Future<List<BoardAllType>> getBoardAll() async {
    try {
      final response = await dio.get('${DioApi.mainApi}/board/all');
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoard response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        content: response.data[i]['content'].toString(),
        commentCount: response.data[i]['commentCount'].toString(),
        likeCount: response.data[i]['likeCount'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        nickname: response.data[i]['user']['nickname'].toString());
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
