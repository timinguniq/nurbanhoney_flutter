import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/utils/korean_number_utils.dart';

void main() {
  group('toKoreanWon', () {
    test('만 단위 금액을 한글로 읽는다', () {
      expect(toKoreanWon(1250000), '백이십오만 원');
      expect(toKoreanWon(12480000), '천이백사십팔만 원');
      expect(toKoreanWon(20000), '이만 원');
    });

    test('십·백·천·만이 1이면 일을 생략한다', () {
      expect(toKoreanWon(10000), '만 원');
      expect(toKoreanWon(1000), '천 원');
      expect(toKoreanWon(110), '백십 원');
    });

    test('억 이상은 일을 붙이고 네 자리 묶음마다 띄어 쓴다', () {
      expect(toKoreanWon(100000000), '일억 원');
      expect(toKoreanWon(123456789), '일억 이천삼백사십오만 육천칠백팔십구 원');
    });

    test('가운데 묶음이 1만이면 일만으로 읽는다', () {
      expect(toKoreanWon(100010000), '일억 일만 원');
    });

    test('한 자리 숫자는 그대로 읽는다', () {
      expect(toKoreanWon(1), '일 원');
      expect(toKoreanWon(7), '칠 원');
    });

    test('0 이하는 빈 문자열이다', () {
      expect(toKoreanWon(0), '');
      expect(toKoreanWon(-5), '');
    });
  });
}
