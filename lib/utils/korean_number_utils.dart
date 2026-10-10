const _digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
const _smallUnits = ['', '십', '백', '천'];
const _bigUnits = ['', '만', '억', '조'];
const _pow10 = [1, 10, 100, 1000];

/// 금액을 한글 단위로 읽는다. 예: 1250000 → `백이십오만 원`. 0 이하면 빈 문자열.
/// 십·백·천과 맨 앞의 만은 1 을 생략하고(`만 원`), 억·조와 가운데 만은 `일` 을 붙인다(`일억 일만 원`).
String toKoreanWon(int amount) {
  if (amount <= 0) return '';

  // 낮은 자리부터 네 자리씩 묶는다.
  final groups = <int>[];
  var rest = amount;
  while (rest > 0) {
    groups.add(rest % 10000);
    rest ~/= 10000;
  }

  final parts = <String>[];
  for (var i = groups.length - 1; i >= 0; i--) {
    final group = groups[i];
    if (group == 0) continue;
    var text = _readGroup(group);
    final isLeadingMan = i == 1 && i == groups.length - 1;
    if (text == '일' && isLeadingMan) text = '';
    final unit = i < _bigUnits.length ? _bigUnits[i] : '';
    parts.add('$text$unit');
  }
  return '${parts.join(' ')} 원';
}

/// 네 자리 묶음 하나를 읽는다. 십·백·천 앞의 1 은 생략한다.
String _readGroup(int group) {
  final buffer = StringBuffer();
  for (var pos = 3; pos >= 0; pos--) {
    final digit = (group ~/ _pow10[pos]) % 10;
    if (digit == 0) continue;
    final unit = _smallUnits[pos];
    if (!(digit == 1 && unit.isNotEmpty)) buffer.write(_digits[digit]);
    buffer.write(unit);
  }
  return buffer.toString();
}
