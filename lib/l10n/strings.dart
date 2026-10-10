import 'package:dio_domain/dio_domain.dart';

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

  /// board=1 → 주식, board=2 → 코인
  static String boardName(int board) => board == 2 ? boardCoin : boardStock;

  // 하단 탭
  static const tabHome = '홈';
  static const tabRanking = '랭킹';
  static const tabAccount = '내 계정';

  // 홈
  static const lossCutCta = '손절 인증하기';
  static String thisWeek(String range) => '이번 주 · $range';
  static const top3Title = '이번 주 손실 Top 3';
  static const top3Empty = '$rankingEmptyTitle.\n$rankingEmptyMessage';
  static const top3Error = '랭킹을 불러오지 못했어요';
  static String rankLabel(int rank) => '$rank위';
  static String homeEmptyTitle(String board) => '아직 $board 손절 인증이 없어요';
  static const homeEmptyMessage = '오늘의 손실을 기록하고 위로를 받아 보세요.\n손실액이 클수록 랭킹이 올라갑니다.';
  static const firstPostCta = '첫 글 쓰기';

  // 로그인
  static const loginTitle = '손절도 인증하면\n위로가 됩니다';
  static const loginDescription = '글 작성·추천·댓글은 로그인 후 이용할 수 있어요.\n둘러보기는 로그인 없이도 가능합니다.';
  static const providerKakao = '카카오';
  static const providerNaver = '네이버';
  static const providerGoogle = 'Google';
  static String providerName(LoginTypeStatus type) => switch (type) {
        LoginTypeStatus.naver => providerNaver,
        LoginTypeStatus.google => providerGoogle,
        LoginTypeStatus.kakao || LoginTypeStatus.init => providerKakao,
      };
  static String loginWith(String provider) => '$provider로 로그인';
  static String loginRetryWith(String provider) => '$provider로 다시 로그인';
  static String loginInProgress(String provider) => '$provider 계정으로 로그인하고 있어요…';
  static String loginFailedTitle(String provider) => '$provider 로그인에 실패했어요';
  static const loginFailedKakaoReason = '카카오톡 앱에서 로그인을 취소했거나 네트워크가 끊겼어요. 다시 시도해 주세요.';
  static const loginFailedGoogleReason = 'Google 로그인을 취소했거나 네트워크가 끊겼어요. 다시 시도해 주세요.';
  static const loginFailedServerReason = '서버에 로그인하지 못했어요. 잠시 후 다시 시도해 주세요.';
  static const loginFailedStorageReason = '로그인 정보를 저장하지 못했어요. 다시 시도해 주세요.';
  static const loginNoticeSignup = '별도 회원가입 없이 첫 로그인으로 가입됩니다.';
  static const loginNoticeAgreePrefix = '로그인 시 ';
  static const loginNoticeAgreeJoin = '과 ';
  static const loginNoticeAgreeSuffix = '에 동의하게 됩니다.';

  // 랭킹
  static const rankingTitle = '손실 랭킹';
  static const rankingEmptyTitle = '아직 이번 주 랭킹이 없어요';
  static const rankingEmptyMessage = '첫 손절 인증이 1위가 됩니다.';

  // 내 계정
  static const accountLoggedOutTitle = '로그인하면 내 손절 기록이 모여요';
  static const accountLoggedOutSubtitle = '둘러보기는 로그인 없이도 가능합니다.';
  static const accountBenefits = [
    '손절 인증 글 작성 · 추천 · 댓글',
    '주간 랭킹에서 내 순위 확인',
    '휘장 수집 · 프로필 꾸미기',
  ];
  static const loginCta = '3초 만에 로그인';
  static const settingsTitle = '내 정보';
  static const descriptionPlaceholder = '자기 소개를 입력해 주세요';
  static const statArticles = '게시글';
  static const statComments = '댓글';
  static const statPoints = '포인트';
  static const pointsRuleTitle = '포인트 안내';
  static const pointsRulePlaceholder = '[포인트 적립·사용 규칙 — 기획 확인 후 채움]';
  static const myArticles = '내 글';
  static const myComments = '내 댓글';
  static const emptyMyArticlesTitle = '아직 쓴 글이 없어요';
  static const emptyMyArticlesMessage = '첫 손절 인증을 남겨 보세요.';
  static const emptyMyCommentsTitle = '아직 쓴 댓글이 없어요';
  static const emptyMyCommentsMessage = '다른 사람의 손절에 위로를 남겨 보세요.';
  static String views(String count) => '조회 $count';
  static const deleteCommentTitle = '이 댓글을 삭제할까요?';
  static const deleteCommentMessage = '삭제한 댓글은 되돌릴 수 없어요.';

  // 앱 정보
  static const appInfo = '앱 정보';
  static const terms = '이용약관';
  static const privacy = '개인정보 처리방침';
  static const appVersion = '앱 버전';
  static const errorPolicyLoad = '내용을 불러오지 못했어요';

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
  static const toastNaverNotReady = '네이버 로그인은 준비 중이에요.';
  static const toastLikeFailed = '좋아요를 반영하지 못했어요. 다시 시도해 주세요.';
  static const toastCommentDeleted = '댓글이 삭제되었습니다.';
  static const toastCommentDeleteFailed = '댓글을 삭제하지 못했어요. 다시 시도해 주세요.';
}
