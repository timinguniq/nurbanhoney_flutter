import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력에 천 단위 콤마를 자동으로 붙인다. 숫자 외 문자는 지우고 앞의 0 은 떼며 커서는 끝에 둔다.
/// [maxDigits] 를 넘는 자리는 잘라낸다. IME 조합 중인 입력은 조합이 끝날 때까지 건드리지 않고,
/// 조합이 끝난 값에 제한을 적용한다(조합 상태를 되돌려 주지 않는다).
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDigits = 15});

  final int maxDigits;

  static final _comma = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }
    var digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final text = _comma.format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
