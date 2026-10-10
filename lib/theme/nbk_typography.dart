import 'package:flutter/painting.dart';

import 'nbk_colors.dart';

/// 글꼴 토큰(Pretendard). `fontSize:` 리터럴은 이 파일에만 쓴다.
/// 숫자(손실액·카운트)는 [tabular] 를 적용한 스타일을 쓴다.
abstract class NbkTypography {
  static const fontFamily = 'Pretendard';

  /// 숫자 폭을 고정한다. 손실액·카운트에 쓴다.
  static const tabular = [FontFeature.tabularFigures()];

  // 기본 6단계 ------------------------------------------------------------

  /// 24 / w700 / 1.3 — 손실액 큰 숫자
  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: NbkColors.text1,
  );

  /// 20 / w700 / 1.3 — 화면 타이틀
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: NbkColors.text1,
  );

  /// 17 / w700 / 1.35 — 섹션 헤더, 글 제목
  static const heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: NbkColors.text1,
  );

  /// 15 / w400 / 1.6 — 본문
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: NbkColors.text1,
  );

  /// 13 / w500 / 1.4 — 닉네임, 라벨, 보조 탭
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: NbkColors.text1,
  );

  /// 12 / w400 / 1.4 — 시간, 메타
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: NbkColors.text3,
  );

  // 손실액 (loss 색, tabular) ------------------------------------------------

  /// 26 — 글 작성 손실액 입력
  static const lossInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 24 — 글 상세 손실액 카드
  static const lossDetail = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 22 — 홈 목록 아이템
  static const lossList = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 20 — 홈 Top3 카드, 내 순위 바
  static const lossTop3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 17 — 랭킹 시상대 1위
  static const lossPodiumFirst = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 15 — 랭킹 4위 이하 행
  static const lossRank = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 14 — 랭킹 시상대 2·3위
  static const lossPodium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  /// 12 — 내 글 목록 캡션
  static const lossCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.loss,
    fontFeatures: tabular,
  );

  // 숫자 카운트 (tabular) ----------------------------------------------------

  /// 13 / w600 — 좋아요·댓글 카운트
  static const countLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: NbkColors.text3,
    fontFeatures: tabular,
  );

  /// 12 / w400 — '추천 N' 캡션
  static const countCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: NbkColors.text3,
    fontFeatures: tabular,
  );

  /// 20 / w700 — 활동 요약 숫자, '27위'
  static const statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.text1,
    fontFeatures: tabular,
  );

  /// 15 / w700 — 랭킹 행 순위 숫자(28폭)
  static const rankNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.text2,
    fontFeatures: tabular,
  );

  // 화면·컴포넌트 변형 ---------------------------------------------------------

  /// 16 / w700 — 홈 목록 글 제목(1줄)
  static const listTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: NbkColors.text1,
  );

  /// 14 / w400 / text2 — 홈 목록 본문 2줄
  static const listBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: NbkColors.text2,
  );

  /// 15 / w700 — 내 글 아이템 제목
  static const itemTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: NbkColors.text1,
  );

  /// 15 / w400 / 1.5 — 내 댓글 내용
  static const commentBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: NbkColors.text1,
  );

  /// 14 / w400 / 1.5 — 글 상세 댓글 내용
  static const commentText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: NbkColors.text1,
  );

  /// 14 / w700 — AuthorInfo.medium 닉네임
  static const nicknameMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: NbkColors.text1,
  );

  /// 13 / w700 — 댓글 닉네임, 손실액 카드 라벨, 섹션 라벨
  static const labelStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: NbkColors.text1,
  );

  /// 18 / w700 — 마이페이지 닉네임
  static const profileName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: NbkColors.text1,
  );

  /// 16 / w700 — 세그먼트 탭(활성), 텍스트 탭(활성)
  static const segment = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: NbkColors.text1,
  );

  /// 16 / w500 / text3 — 세그먼트 탭(비활성)
  static const segmentInactive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: NbkColors.text3,
  );

  /// 11 / w500 — 하단 탭바 라벨
  static const tabLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: NbkColors.text3,
  );

  /// 16 / w700 — 큰 버튼(높이 48~52)
  static const buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.text1,
  );

  /// 14 / w700 — 필 버튼(높이 36), 반응 버튼
  static const buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: NbkColors.text1,
  );

  /// 12 / w600 — NbkPill 글자
  static const pill = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: NbkColors.text2,
  );

  /// 15 / w400 / 1.4 — 입력창 글자(본문보다 줄간격이 좁다)
  static const inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: NbkColors.text1,
  );

  /// 14 / w500 / 흰색 — 토스트
  static const toast = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: NbkColors.onDark,
  );

  /// 22 / w700 — 상단바 워드마크 '너반꿀'
  static const wordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: NbkColors.text1,
  );

  /// 28 / w700 — 로그인 화면 워드마크
  static const wordmarkLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: NbkColors.text1,
  );
}
