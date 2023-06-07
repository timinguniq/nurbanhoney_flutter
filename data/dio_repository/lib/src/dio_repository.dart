
import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

class DioRepository {
  /// constructor
  DioRepository();

  final dio = Dio();

  final _mainApi = 'http://3.37.182.144:8128';

  Future<BoardModel> getBoard() async {
    try {
      final response = await dio.get('$_mainApi/board');
      return BoardModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
