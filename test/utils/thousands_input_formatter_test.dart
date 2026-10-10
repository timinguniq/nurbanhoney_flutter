import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/utils/thousands_input_formatter.dart';

TextEditingValue _value(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

void main() {
  group('ThousandsInputFormatter', () {
    const formatter = ThousandsInputFormatter();

    test('입력 중 천 단위 콤마를 붙이고 커서를 끝에 둔다', () {
      final result = formatter.formatEditUpdate(_value('125000'), _value('1250000'));
      expect(result.text, '1,250,000');
      expect(result.selection.baseOffset, '1,250,000'.length);
    });

    test('이미 콤마가 있는 값에 숫자를 더 붙여도 다시 묶는다', () {
      final result =
          formatter.formatEditUpdate(_value('1,250,000'), _value('1,250,0000'));
      expect(result.text, '12,500,000');
    });

    test('숫자 외 문자는 지운다', () {
      expect(formatter.formatEditUpdate(_value(''), _value('abc')).text, '');
      expect(formatter.formatEditUpdate(_value(''), _value('12a3')).text, '123');
    });

    test('앞의 0 은 뗀다', () {
      expect(formatter.formatEditUpdate(_value(''), _value('0012')).text, '12');
      expect(formatter.formatEditUpdate(_value(''), _value('0')).text, '');
    });

    test('빈 입력은 빈 문자열이다', () {
      expect(formatter.formatEditUpdate(_value('1'), _value('')).text, '');
    });

    test('최대 자릿수를 넘기면 이전 값을 유지한다', () {
      const limited = ThousandsInputFormatter(maxDigits: 3);
      final old = _value('123');
      final result = limited.formatEditUpdate(old, _value('1234'));
      expect(result.text, '123');
    });
  });
}
