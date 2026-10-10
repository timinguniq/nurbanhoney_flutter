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
  static String thisMonth(String range) => '이번 달 · $range';
  static const top3Title = '이번 달 손실 Top 3';
  static const top3Empty = '$rankingEmptyTitle.\n$rankingEmptyMessage';
  static const top3Error = '랭킹을 불러오지 못했어요';
  static String rankLabel(int rank) => '$rank위';
  static String homeEmptyTitle(String board) => '아직 $board 손절 인증이 없어요';
  static const homeEmptyMessage = '오늘의 손실을 기록하고 위로를 받아 보세요.\n손실액이 클수록 랭킹이 올라갑니다.';
  static const firstPostCta = '첫 글 쓰기';

  // 로그인
  static const loginTitle = '손절도 인증하면\n위로가 됩니다';
  static const loginDescription = '글 작성·추천·댓글은 로그인 후 이용할 수 있어요.\n둘러보기는 로그인 없이 가능합니다.';
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
  static const rankingEmptyTitle = '아직 이번 달 랭킹이 없어요';
  static const rankingEmptyMessage = '첫 손절 인증이 1위가 됩니다.';
  static const myRank = '내 순위';
  static const myRankLoginCta = '로그인하고 내 순위 확인하기';
  static const myRankNone = '아직 이번 달 기록이 없어요';

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
  static const pointsRule = '글을 쓰거나 댓글을 달면 포인트가 쌓여요.\n포인트를 쓰는 곳은 따로 없고, 많이 모으면 휘장을 받아요.';
  static const myArticles = '내 글';
  static const myComments = '내 댓글';
  static const emptyMyArticlesTitle = '아직 쓴 글이 없어요';
  static const emptyMyArticlesMessage = '첫 손절 인증을 남겨 보세요.';
  static const emptyMyCommentsTitle = '아직 쓴 댓글이 없어요';
  static const emptyMyCommentsMessage = '다른 사람의 손절에 위로를 남겨 보세요.';
  static String views(String count) => '조회 $count';
  static const deleteCommentTitle = '이 댓글을 삭제할까요?';
  static const deleteCommentMessage = '삭제한 댓글은 되돌릴 수 없어요.';

  // 내 정보(설정)
  static const accountSection = '계정';
  static const kakaoAccount = '카카오 계정';
  static const googleAccount = 'Google 계정';
  static String joinedCaption(String nickname, String date) => '$nickname · $date 가입';
  static const logout = '로그아웃';
  static const profileEdit = '프로필 수정';
  static const withdraw = '탈퇴하기';
  static const withdrawConfirmTitle = '정말 탈퇴할까요?';
  static String withdrawConfirmMessage(String articles, String comments, String points) =>
      '탈퇴하면 내가 쓴 글 $articles개와 댓글 $comments개, 모은 휘장과 포인트 $points이 모두 삭제되고 되돌릴 수 없어요.';
  static const withdrawCheckbox = '위 내용을 확인했어요';
  static const withdrawAction = '탈퇴';

  // 프로필 수정
  static const profileEditTitle = '프로필 수정';
  static const badgeAutoNote = '프로필 배지는 활동에 따라 자동으로 바뀌어요';
  static const nicknameLabel = '닉네임';
  static const nicknameHint = '닉네임을 입력해 주세요';
  static const nicknameAvailable = '사용할 수 있는 닉네임이에요';
  static const nicknameRequired = '닉네임을 입력해 주세요.';
  static const introLabel = '소개';
  static const introHint = '자기 소개를 입력해 주세요';
  static const shownInsigniaLabel = '닉네임 옆에 보이는 휘장';
  static const shownInsigniaFull = '최대 2개까지 보일 수 있어요. 바꾸려면 먼저 하나를 빼 주세요.';
  static String ownedInsigniaLabel(int count) => '보유 휘장 $count';

  // 앱 정보
  static const appInfo = '앱 정보';
  static const terms = '이용약관';
  static const privacy = '개인정보 처리방침';
  static const appVersion = '앱 버전';
  static const errorPolicyLoad = '내용을 불러오지 못했어요';

  // 글 작성
  static const composeTitle = '손절 인증';
  static const boardLabel = '게시판';
  static const titleLabel = '제목';
  static const titleHint = '어떤 손절이었나요?';
  static const lossHelper = '숫자만 입력하면 콤마가 자동으로 붙어요. 손실은 마이너스로 기록됩니다.';
  static const photoLabel = '사진';
  static const photoAdd = '손절 화면 사진 1장 추가';
  static const photoCompressNote = '업로드 시 500px로 압축돼요';
  static const photoUploading = '사진 올리는 중…';
  static const contentLabel = '내용';
  static const contentHint = '무엇을 사서 어디서 손절했는지, 지금 기분은 어떤지 적어 주세요.';
  static const errorTitleRequired = '제목을 입력해 주세요.';
  static const errorLossRequired = '손실액을 입력해 주세요. 랭킹 집계에 꼭 필요해요.';
  static const errorPhotoRequired = '인증 사진 1장이 필요해요.';
  static const errorContentRequired = '내용을 입력해 주세요.';
  static const cancelComposeTitle = '작성을 취소할까요?';
  static const cancelComposeMessage = '입력한 내용이 사라져요.';
  static const leave = '나가기';
  static const keepWriting = '계속 쓰기';
  static const change = '바꾸기';

  // 글 상세
  static const lossLabel = '손실액';
  static const commentsHeader = '댓글';
  static const commentHint = '댓글을 입력해주세요';
  static const emptyCommentsTitle = '아직 댓글이 없어요';
  static const emptyCommentsMessage = '첫 위로를 남겨 보세요.';
  static const deleteArticleTitle = '이 글을 삭제할까요?';
  static const deleteArticleMessage = '삭제한 글과 달린 댓글은 되돌릴 수 없어요. 랭킹에 반영된 손실액도 함께 빠집니다.';

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
  static String toastMissingFields(int count) => '아직 입력하지 않은 항목이 $count개 있어요.';
  static const toastPostCreated = '글이 등록되었습니다.';
  static const toastPostCreateFailed = '글을 등록하지 못했어요. 다시 시도해 주세요.';
  static const toastPhotoUploadFailed = '사진을 올리지 못했어요. 다시 시도해 주세요.';
  static const toastPhotoPickFailed = '사진을 불러오지 못했어요. 다시 시도해 주세요.';
  static const toastArticleNotFound = '글이 존재하지 않습니다.';
  static const toastArticleDeleted = '글이 삭제되었습니다.';
  static const toastArticleDeleteFailed = '글을 삭제하지 못했어요. 다시 시도해 주세요.';
  static const toastCommentEmpty = '댓글 내용을 입력해 주세요.';
  static const toastCommentCreateFailed = '댓글을 등록하지 못했어요. 다시 시도해 주세요.';
  static const toastReactionFailed = '반응을 반영하지 못했어요. 다시 시도해 주세요.';
  static const toastProfileSaved = '프로필이 저장되었습니다.';
  static const toastProfileSaveFailed = '프로필을 저장하지 못했어요.';
  static const toastLoggedOut = '로그아웃 되었습니다.';
  static const toastWithdrawn = '탈퇴가 완료되었습니다.';
  static const toastWithdrawFailed = '탈퇴하지 못했어요. 다시 시도해 주세요.';
  static const toastCommentDeleted = '댓글이 삭제되었습니다.';
  static const toastCommentDeleteFailed = '댓글을 삭제하지 못했어요. 다시 시도해 주세요.';
}
