import 'package:flutter/painting.dart';

/// 색 토큰(라이트). `Color(0x…)` 리터럴은 이 파일과 [NbkColorsDark] 에만 쓴다.
abstract class NbkColors {
  // 브랜드 · 꿀색
  /// 채움 전용(버튼·배지·탭 인디케이터·FAB). 흰 배경 위 글자·아이콘에는 쓰지 않는다(대비 1.8:1).
  static const honey = Color(0xFFF6B748);

  /// 흰 배경 위 꿀색 글자·아이콘·링크
  static const honeyDeep = Color(0xFF9A6A10);

  /// 강조 카드 배경
  static const honeyTint = Color(0xFFFEF5E1);

  /// 강조 카드 테두리
  static const honeyLine = Color(0xFFF3DCA6);

  /// 꿀색 버튼 위 글자
  static const onHoney = Color(0xFF2B1F04);

  // 손실 · 시맨틱
  /// 손실액 숫자. 한국 증시 관례상 하락=파랑
  static const loss = Color(0xFF3C54D3);

  /// 손실 카드 배경
  static const lossTint = Color(0xFFEEF1FC);

  static const danger = Color(0xFFD93025);
  static const dangerTint = Color(0xFFFDECEA);
  static const dangerText = Color(0xFFB3261E);
  static const success = Color(0xFF1E8E5A);

  // 그레이 6단계
  static const text1 = Color(0xFF1E1E1E);
  static const text2 = Color(0xFF4D5159);
  static const text3 = Color(0xFF6F747D);
  static const hint = Color(0xFF8A9099);
  static const line = Color(0xFFE6E8EC);
  static const surface = Color(0xFFF4F5F7);
  static const thumbPlaceholder = Color(0xFFEEF0F3);
  static const bg = Color(0xFFFFFFFF);

  /// 스켈레톤 위로 흐르는 하이라이트
  static const skeletonHighlight = Color(0xFFFAFBFC);

  /// 어두운 배경(토스트·text1 버튼·danger 버튼) 위 글자
  static const onDark = Color(0xFFFFFFFF);

  /// 사진 업로드 중 미리보기 위에 덮는 반투명 막
  static const overlay = Color(0x99000000);

  // 소셜 로그인 (각 사 브랜드 가이드)
  static const kakao = Color(0xFFFEE500);
  static const onKakao = Color(0xFF191919);
  static const naver = Color(0xFF03C75A);
  static const onNaver = Color(0xFFFFFFFF);
  static const google = Color(0xFFFFFFFF);
  static const googleLine = Color(0xFFDADCE0);
  static const onGoogle = Color(0xFF1F1F1F);

  // 토스트 아이콘(배경은 항상 text1)
  static const toastSuccess = Color(0xFF5BD38E);
  static const toastInfo = honey;
  static const toastError = Color(0xFFFF8A80);
}

/// 색 토큰(다크). 값만 정의해 두고 아직 적용하지 않는다.
abstract class NbkColorsDark {
  static const honey = NbkColors.honey;
  static const honeyDeep = Color(0xFFE2B45C);
  static const honeyTint = Color(0xFF2E2614);
  static const honeyLine = Color(0xFF4A3C18);
  static const onHoney = NbkColors.onHoney;

  static const loss = Color(0xFF8A9BF2);
  static const lossTint = Color(0xFF1C2140);
  static const danger = Color(0xFFF28B82);
  static const dangerTint = Color(0xFF3A1F1D);
  static const dangerText = Color(0xFFFFB4AB);
  static const success = Color(0xFF5BD38E);

  static const text1 = Color(0xFFF2F2F2);
  static const text2 = Color(0xFFC5C8CF);
  static const text3 = Color(0xFF9A9FA8);
  static const hint = Color(0xFF6F747D);
  static const line = Color(0xFF2C2E33);
  static const surface = Color(0xFF1E1F23);
  static const thumbPlaceholder = Color(0xFF26282D);
  static const bg = Color(0xFF121212);
  static const onDark = NbkColors.onDark;
}
