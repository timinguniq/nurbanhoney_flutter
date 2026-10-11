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
