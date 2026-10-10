import 'package:flutter/painting.dart';

/// 간격 토큰
abstract class NbkSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// 화면 좌우 여백
  static const screen = 16.0;

  /// 섹션 사이 두꺼운 구분 띠(surface)
  static const sectionBand = 8.0;

  /// 리스트 구분선(line)
  static const divider = 1.0;

  /// 목록 아이템 세로 여백
  static const listItemVertical = 14.0;

  /// 글 작성 폼 항목 사이 간격
  static const formGap = 22.0;
}

/// 모서리 토큰
abstract class NbkRadius {
  static const input = 12.0;
  static const button = 12.0;
  static const card = 12.0;
  static const cardLg = 16.0;
  static const thumbnail = 12.0;
  static const toast = 12.0;
  static const myRankBar = 14.0;
  static const sheet = 20.0;
  static const dialog = 20.0;
  static const emptyTile = 28.0;
  static const avatarSm = 6.0;
  static const avatarComment = 8.0;
  static const avatarMd = 10.0;
  static const avatarLg = 16.0;
  static const avatarXl = 24.0;
  static const skeleton = 8.0;
  static const dialogIconTile = 12.0;

  /// 칩·필
  static const pill = 999.0;
}

/// 크기 토큰(높이·터치 영역·아바타·아이콘)
abstract class NbkSize {
  /// 터치 영역 최소
  static const tapMin = 44.0;

  /// 아이콘 버튼
  static const iconButton = 48.0;

  static const icon = 24.0;
  static const iconSm = 18.0;
  static const iconXs = 16.0;
  static const iconLg = 32.0;

  /// 상단바
  static const appBar = 56.0;

  /// 하단 탭바(안전영역 포함)
  static const bottomTab = 80.0;

  /// 홈 세그먼트 탭
  static const segmentTab = 48.0;

  /// 세그먼트 탭 언더라인
  static const segmentIndicator = 2.0;

  static const button = 48.0;
  static const buttonLg = 52.0;
  static const pillButton = 36.0;
  static const reactionButton = 44.0;
  static const input = 48.0;
  static const fab = 48.0;
  static const commentInput = 44.0;
  static const toast = 46.0;

  /// 입력창 테두리 두께
  static const inputBorder = 1.5;

  // 배지(프로필 이미지)
  static const avatarSm = 22.0;
  static const avatarComment = 32.0;
  static const avatarMd = 36.0;
  static const avatarRank = 48.0;
  static const avatarPodium = 60.0;
  static const avatarProfile = 64.0;
  static const avatarEdit = 88.0;

  // 휘장: PNG 는 400×400 이지만 그림은 가운데 가로로 좁게 들어 있어 여백을 잘라낸다.
  static const insigniaSmBox = Size(34, 18);
  static const insigniaSmImage = 38.0;
  static const insigniaMdBox = Size(40, 22);
  static const insigniaMdImage = 46.0;
  static const insigniaTileBox = Size(80, 40);
  static const insigniaTileImage = 84.0;

  /// 심볼(육각 꿀 아이콘)
  static const symbolSm = 28.0;
  static const symbolLg = 72.0;
  static const symbolTile = 44.0;

  /// 빈 상태·오류 상태 아이콘 타일 안의 아이콘
  static const stateIcon = 44.0;

  /// 다이얼로그 아이콘 타일
  static const dialogIconTile = 48.0;

  /// 하단 탭바 아이콘·내용 높이·최소 하단 여백
  static const tabIcon = 26.0;
  static const bottomTabContent = 56.0;
  static const bottomTabMinInset = 24.0;

  /// 반응 버튼 안쪽 아이콘
  static const reactionIcon = 20.0;

  /// 오류 상태 [다시 시도] 버튼 최소 폭
  static const retryButtonMinWidth = 240.0;

  /// 순위 박스(Top3 카드)
  static const rankBox = 26.0;

  /// 랭킹 행 순위 숫자 폭
  static const rankNumberWidth = 28.0;

  /// 랭킹 4위 이하 행 높이
  static const rankRow = 60.0;

  static const thumbnailHeight = 100.0;
  static const top3CardWidth = 236.0;
  static const top3CardGap = 10.0;
  static const emptyTile = 96.0;
  static const photoDropZone = 96.0;
  static const photoPreview = 160.0;
  static const lossInputBox = 64.0;
  static const insigniaTile = Size(84, 64);
  static const insigniaGridTileHeight = 64.0;
  static const adBanner = Size(320, 50);

  /// 글 상세 첨부 이미지 최대 폭(업로드 시 500px 로 압축되므로 더 키우지 않는다)
  static const detailImageMaxWidth = 500.0;
}
