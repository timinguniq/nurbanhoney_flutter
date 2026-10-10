import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/utils/loss_format_utils.dart';

void main() {
  group('formatLossAmount', () {
    test('마이너스 기호와 천 단위 콤마, 원을 붙인다', () {
      expect(formatLossAmount(1250000), '-1,250,000원');
      expect(formatLossAmount(430000), '-430,000원');
      expect(formatLossAmount(999), '-999원');
    });

    test('0 이면 기호 없이 0원이다', () {
      expect(formatLossAmount(0), '0원');
    });

    test('음수가 들어와도 크기만 쓴다', () {
      expect(formatLossAmount(-430000), '-430,000원');
    });

    test('compact 는 1만 원 이상을 만원 단위로 줄인다', () {
      expect(formatLossAmount(12480000, compact: true), '-1,248만원');
      expect(formatLossAmount(8900000, compact: true), '-890만원');
      expect(formatLossAmount(15000, compact: true), '-1만원');
    });

    test('compact 는 만 원 미만의 끝자리를 버린다', () {
      expect(formatLossAmount(12485000, compact: true), '-1,248만원');
    });

    test('compact 는 1억 원 이상을 소수 한 자리 억원으로 줄인다', () {
      expect(formatLossAmount(120000000, compact: true), '-1.2억원');
      expect(formatLossAmount(100000000, compact: true), '-1억원');
      expect(formatLossAmount(123456789, compact: true), '-1.2억원');
      expect(formatLossAmount(123400000000, compact: true), '-1,234억원');
    });

    test('compact 라도 1만 원 미만은 그대로 쓴다', () {
      expect(formatLossAmount(9999, compact: true), '-9,999원');
      expect(formatLossAmount(0, compact: true), '0원');
    });
  });

  group('parseLossAmount', () {
    test('숫자 문자열을 정수로 바꾼다', () {
      expect(parseLossAmount('1250000'), 1250000);
    });

    test('콤마와 기호 같은 숫자 외 문자는 무시한다', () {
      expect(parseLossAmount('1,250,000'), 1250000);
      expect(parseLossAmount('-430000'), 430000);
      expect(parseLossAmount('1,250,000원'), 1250000);
    });

    test('비어 있거나 숫자가 없으면 0 이다', () {
      expect(parseLossAmount(''), 0);
      expect(parseLossAmount('null'), 0);
      expect(parseLossAmount('abc'), 0);
    });
  });
}
