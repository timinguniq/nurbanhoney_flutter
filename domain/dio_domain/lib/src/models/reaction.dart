/// 한 사용자가 한 글에 남긴 반응. 글의 좋아요 수·싫어요 수(집계)와는 다른 개념이다(CONTEXT.md "반응").
/// 와이어 필드 `myRating` 의 `'like'`·`'dislike'`·그 외(없음)를 저장소가 이 값으로 바꾼다.
enum Reaction {
  /// 반응 없음
  none,

  /// 좋아요
  like,

  /// 싫어요
  dislike,
}
