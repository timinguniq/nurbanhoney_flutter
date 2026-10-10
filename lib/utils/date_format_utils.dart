import 'package:intl/intl.dart';

const DEFAULT_DATE_FORMAT = 'yyyy-MM-dd HH:mm';

/// 글 상세의 작성 시각 (`2026.10.10 14:30`)
const dotDateTimeFormat = 'yyyy.MM.dd HH:mm';

/// 내 글 목록의 날짜 (`2026.10.10`)
const dotDateFormat = 'yyyy.MM.dd';

/// 내 댓글 목록의 날짜 (`10.10`)
const shortDateFormat = 'MM.dd';

/// ISO 8601 문자열을 [now] 기준 상대 시간으로 바꾼다. 1분 미만 `방금 전`, 1시간 미만 `N분 전`,
/// 하루 미만 `N시간 전`, 7일 미만 `N일 전`, 그 이상은 `yyyy.MM.dd`. 미래 시각은 `방금 전`, 파싱 실패는 ''.
String formatRelativeTime(String dateString, {DateTime? now}) {
  final date = DateTime.tryParse(dateString);
  if (date == null) return '';
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return DateFormat(dotDateFormat).format(date.toLocal());
}

/// [date] 가 속한 달(1일~말일)을 `M.d – M.d` 로 보여준다. 예: 2025-10-10 → `10.1 – 10.31`.
/// 랭킹·Top3 집계 기준이 월 단위라 기간 필에 쓴다.
String formatMonthRange(DateTime date) {
  final lastDay = DateTime(date.year, date.month + 1, 0).day;
  return '${date.month}.1 – ${date.month}.$lastDay';
}

/// Formats a date string from "YYYY-MM-DDT..." format to "YYYY.MM.DD"
String formatToYYYYMMDD(String dateString) {
  try {
    final inputArray = dateString.split('T')[0].split('-');
    return '${inputArray[0]}.${inputArray[1]}.${inputArray[2]}';
  } catch (e) {
    print('formatToYYYYMMDD error: $e');
    return '';
  }
}

/// Formats a date string to a custom format using the intl package
String formatDate(String dateString, String format) {
  try {
    final date = DateTime.parse(dateString);
    final formatter = DateFormat(format);
    return formatter.format(date);
  } catch (e) {
    print('formatDate error: $e');
    return '';
  }
}