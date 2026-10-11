# 너반꿀 (nurbanhoney)

주식·코인 손절을 손실액과 함께 인증하고 서로 위로하는 커뮤니티 앱의 도메인 언어다. 서버 와이어 이름(`nurban`, `free`,
`lossCut`, `myRating`)은 용어가 아니라 전송 형식이므로 코드의 개념 이름으로 쓰지 않는다.

## Language

**게시판 (Board)**:
손절 인증 글이 속하는 두 갈래, 주식과 코인. 와이어에서는 주식이 1(`nurban`), 코인이 2(`free`)다.
_Avoid_: nurban, free, 너반꿀 게시판, 자유게시판

**손실액 (Loss amount)**:
손절 인증 글에 적힌 손실 금액. 원 단위 정수이며, `-1,250,000원` 형식은 표시할 때만 만든다.
_Avoid_: lossCut, 손절액, 손실 금액

**반응 (Reaction)**:
한 사용자가 한 글에 남긴 상태로, 없음·좋아요·싫어요 셋 중 하나다. 글의 좋아요 수·싫어요 수(집계)와는 다른 개념이다.
_Avoid_: rating, myRating, like state, 평가
