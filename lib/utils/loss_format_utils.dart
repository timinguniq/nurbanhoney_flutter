import 'package:intl/intl.dart';

final _comma = NumberFormat('#,###');
const _man = 10000;
const _eok = 100000000;

/// 손실액을 `-1,250,000원` 형식으로 만든다. 0 이면 `0원`, 음수가 와도 크기만 쓴다.
/// [compact] 면 1만 원 이상은 만원 단위(`-1,248만원`), 1억 원 이상은 소수 한 자리 억원(`-1.2억원`)으로
/// 줄이고 그 아래 자리는 버린다.
String formatLossAmount(int amount, {bool compact = false}) {
  final value = amount.abs();
  if (value == 0) return '0원';
  if (compact && value >= _eok) {
    final whole = _comma.format(value ~/ _eok);
    final tenth = (value % _eok) ~/ (_eok ~/ 10);
    return tenth == 0 ? '-$whole억원' : '-$whole.$tenth억원';
  }
  if (compact && value >= _man) {
    return '-${_comma.format(value ~/ _man)}만원';
  }
  return '-${_comma.format(value)}원';
}

/// API 가 문자열로 주는 손실액을 정수로 바꾼다. 숫자 외 문자는 무시하고 숫자가 없으면 0 이다.
int parseLossAmount(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return int.tryParse(digits) ?? 0;
}
