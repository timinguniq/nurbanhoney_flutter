import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력에 천 단위 콤마를 자동으로 붙인다. 숫자 외 문자는 지우고 앞의 0 은 떼며 커서는 끝에 둔다.
/// [maxDigits] 를 넘는 입력은 이전 값을 유지한다.
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDigits = 15});

  final int maxDigits;

  static final _comma = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) return oldValue;
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
