/// 사용자에게 보이는 문구. 화면 코드에 문자열 리터럴을 두지 않고 여기서 가져다 쓴다.
abstract class Strings {
  static const appName = '너반꿀';

  // 공통 액션
  static const cancel = '취소';
  static const delete = '삭제';
  static const confirm = '확인';
  static const retry = '다시 시도';
  static const register = '등록';
  static const edit = '수정';
  static const save = '저장';
  static const done = '완료';
  static const seeAll = '전체보기';

  // 게시판
  static const boardStock = '주식';
  static const boardCoin = '코인';

  // 하단 탭
  static const tabHome = '홈';
  static const tabRanking = '랭킹';
  static const tabAccount = '내 계정';

  // 반응
  static const like = '좋아요';
  static const dislike = '싫어요';
  static const loss = '손실';
  static const myPost = '내 글';
  static String recommend(String count) => '추천 $count';

  // 상태
  static const offline = '인터넷에 연결되어 있지 않아요';
  static const errorLoadTitle = '글을 불러오지 못했어요';
  static const errorNetworkMessage = '네트워크 상태를 확인한 뒤\n다시 시도해 주세요.';
  static String errorCode(String code, String time) => '오류 코드 $code · $time';

  // 토스트
  static const toastLoginRequired = '로그인 후 이용할 수 있어요.';
  static const toastNetworkError = '네트워크 상태를 확인한 뒤 다시 시도해 주세요.';
}
