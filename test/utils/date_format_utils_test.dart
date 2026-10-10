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
}
