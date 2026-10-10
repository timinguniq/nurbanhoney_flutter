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

    test('최대 자릿수를 넘기면 넘친 자리를 잘라낸다', () {
      const limited = ThousandsInputFormatter(maxDigits: 3);
      final old = _value('123');
      final result = limited.formatEditUpdate(old, _value('1234'));
      expect(result.text, '123');
      expect(limited.formatEditUpdate(_value(''), _value('98765')).text, '987');
    });

    test('조합 중 넘긴 자릿수는 조합이 끝날 때 잘라내고 조합 상태를 남기지 않는다', () {
      const limited = ThousandsInputFormatter(maxDigits: 3);
      const composing = TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 0, end: 4),
      );
      expect(limited.formatEditUpdate(_value('123'), composing), composing);

      final committed = limited.formatEditUpdate(composing, _value('1234'));
      expect(committed.text, '123');
      expect(committed.composing.isValid, isFalse);
    });

    test('최대 자릿수와 같은 길이까지는 받아들인다', () {
      const limited = ThousandsInputFormatter(maxDigits: 3);
      final result = limited.formatEditUpdate(_value('12'), _value('123'));
      expect(result.text, '123');
    });

    test('IME 조합 중인 입력은 조합 범위를 지우지 않고 그대로 둔다', () {
      const composing = TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 0, end: 4),
      );
      final result = formatter.formatEditUpdate(_value('123'), composing);
      expect(result, composing);
    });

    test('조합이 끝나면 콤마를 붙인다', () {
      const composing = TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 0, end: 4),
      );
      final result = formatter.formatEditUpdate(composing, _value('1234'));
      expect(result.text, '1,234');
    });
  });
}
