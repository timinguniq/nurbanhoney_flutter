import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/utils/date_format_utils.dart';

void main() {
  group('formatToYYYYMMDD', () {
    test('ISO 8601 문자열의 날짜 부분을 점으로 구분해 돌려준다', () {
      expect(formatToYYYYMMDD('2024-03-05T14:07:00.000Z'), '2024.03.05');
    });

    test('시간 부분이 없어도 날짜를 변환한다', () {
      expect(formatToYYYYMMDD('2024-03-05'), '2024.03.05');
    });

    test('구분자가 없는 문자열이면 빈 문자열을 돌려준다', () {
      expect(formatToYYYYMMDD(''), '');
      expect(formatToYYYYMMDD('20240305'), '');
    });
  });

  group('formatDate', () {
    test('DEFAULT_DATE_FORMAT 으로 날짜와 시각을 표시한다', () {
      expect(
        formatDate('2024-03-05T14:07:00', DEFAULT_DATE_FORMAT),
        '2024-03-05 14:07',
      );
    });

    test('지정한 패턴을 따른다', () {
      expect(formatDate('2024-03-05T14:07:00', 'yyyy.MM.dd'), '2024.03.05');
    });

    test('파싱할 수 없는 문자열이면 빈 문자열을 돌려준다', () {
      expect(formatDate('not-a-date', DEFAULT_DATE_FORMAT), '');
    });
  });

  group('formatRelativeTime', () {
    final now = DateTime(2026, 10, 10, 14, 30);

    test('1분 미만이면 방금 전이다', () {
      expect(formatRelativeTime('2026-10-10T14:29:30', now: now), '방금 전');
    });

    test('1시간 미만이면 분 단위다', () {
      expect(formatRelativeTime('2026-10-10T14:00:00', now: now), '30분 전');
    });

    test('하루 미만이면 시간 단위다', () {
      expect(formatRelativeTime('2026-10-10T12:30:00', now: now), '2시간 전');
    });

    test('7일 미만이면 일 단위다', () {
      expect(formatRelativeTime('2026-10-08T14:30:00', now: now), '2일 전');
    });

    test('7일 이상이면 날짜를 점으로 구분해 보여준다', () {
      expect(formatRelativeTime('2026-10-01T14:30:00', now: now), '2026.10.01');
    });

    test('정확히 1분·1시간·1일·7일 전은 큰 단위로 올라간다', () {
      expect(formatRelativeTime('2026-10-10T14:29:00', now: now), '1분 전');
      expect(formatRelativeTime('2026-10-10T13:30:00', now: now), '1시간 전');
      expect(formatRelativeTime('2026-10-09T14:30:00', now: now), '1일 전');
      expect(formatRelativeTime('2026-10-03T14:30:00', now: now), '2026.10.03');
    });

    test('미래 시각은 방금 전으로 본다', () {
      expect(formatRelativeTime('2026-10-10T15:00:00', now: now), '방금 전');
    });

    test('파싱할 수 없는 문자열이면 빈 문자열이다', () {
      expect(formatRelativeTime('', now: now), '');
      expect(formatRelativeTime('not-a-date', now: now), '');
    });
  });

  group('formatWeekRange', () {
    test('그 날이 속한 주의 월요일과 일요일을 M.d 로 보여준다', () {
      expect(formatWeekRange(DateTime(2025, 10, 10)), '10.6 – 10.12');
      expect(formatWeekRange(DateTime(2026, 10, 10)), '10.5 – 10.11');
    });

    test('월요일과 일요일도 같은 주로 본다', () {
      expect(formatWeekRange(DateTime(2025, 10, 6)), '10.6 – 10.12');
      expect(formatWeekRange(DateTime(2025, 10, 12)), '10.6 – 10.12');
    });

    test('해가 바뀌는 주도 처리한다', () {
      expect(formatWeekRange(DateTime(2025, 12, 31)), '12.29 – 1.4');
    });
  });
}
