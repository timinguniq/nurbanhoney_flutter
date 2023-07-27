
import 'package:dio/dio.dart';

/// TODO 여기서 부터고 insigniaShow, insighinaOwn 아마 List로 안 받아질 듯.
typedef ProfileType = ({int id, String loginType,
  String badge, String nickname, String description,
  int point, String insigniaShow, String insigniaOwn,
  int myArticleCount, int myCommentCount});


class ProfileRepository {
  /// constructor
  ProfileRepository._privateConstructor();
  static final ProfileRepository _instance = ProfileRepository._privateConstructor();

  factory ProfileRepository(){
    return _instance;
  }

  final dio = Dio();

  // 참고해서 getProfile 만들기
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

  Future<List<BoardAllType>> getBoardAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/board/all',
        queryParameters: {
          'flag': flag,
          'articleId': articleId,
          'limit': limit,
        },
      );
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoardAll response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        lossCut: response.data[i]['lossCut'].toString(),
        content: response.data[i]['content'].toString(),
        commentCount: response.data[i]['commentCount'].toString(),
        likeCount: response.data[i]['likeCount'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        nickname: response.data[i]['user']['nickname'].toString());
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getBoardAll response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getBoardAll error : $e');
      throw Exception(e);
    }
  }

}