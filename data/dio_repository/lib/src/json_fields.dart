import 'package:dio_domain/dio_domain.dart';

// 응답 JSON 필드 읽기. 형식이 다르면 FormatException 을 던지고, 저장소가 ApiClient.decode 로 감싸
// ApiFormatFailure 로 바꾼다. 패키지 내부용이라 배럴에서 export 하지 않는다.

/// JSON 객체.
Map<String, Object?> jsonMap(Object? value) {
  if (value is Map) return value.cast<String, Object?>();
  throw FormatException('object expected, got ${value.runtimeType}');
}

/// JSON 배열.
List<Object?> jsonList(Object? value) {
  if (value is List) return value;
  throw FormatException('array expected, got ${value.runtimeType}');
}

/// 정수. 서버가 숫자 문자열(`"123"`)로 주는 필드도 있어 둘 다 받는다.
int jsonInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.parse(value.trim());
  throw FormatException('int expected, got $value');
}

/// 필수 문자열. 숫자·목록 등 다른 값은 문자열 표현으로 읽고(기존 형식 유지), null 이면 형식 오류다.
String jsonString(Object? value) {
  if (value == null) throw const FormatException('string expected, got null');
  return value is String ? value : value.toString();
}

/// 없을 수 있는 문자열. null 은 문자열 `'null'` 이 아니라 null 로 읽는다.
String? jsonStringOrNull(Object? value) => value == null ? null : jsonString(value);

/// 손실액(원 단위 정수, CONTEXT.md "손실액"). 서버가 정수·숫자 문자열·콤마나 부호가 섞인 문자열로 줄 수 있어
/// 숫자 외 문자를 버리고 읽는다. 숫자가 없거나 null 이면 0 이다(기존 화면의 `parseLossAmount` 와 같은 규칙).
int jsonLossAmount(Object? value) {
  if (value is int) return value.abs();
  final digits = (value?.toString() ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

/// 없을 수 있는 손실액. 필드가 없거나 null 이면 null, 있으면 [jsonLossAmount] 와 같은 규칙.
int? jsonLossAmountOrNull(Object? value) => value == null ? null : jsonLossAmount(value);

/// 내 반응(CONTEXT.md "반응"). 와이어 필드 `myRating` 의 'like'·'dislike' 외 값(null·'null' 등)은 반응 없음이다.
Reaction jsonReaction(Object? value) => switch (value) {
      'like' => Reaction.like,
      'dislike' => Reaction.dislike,
      _ => Reaction.none,
    };
