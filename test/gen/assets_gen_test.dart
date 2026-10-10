import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Assets', () {
    // FlutterGen 의 package_parameter_enabled 가 켜지면 루트 앱인데도 packages/nurbanhoney/... 경로를 요청해
    // 로그인 심볼이 로드되지 않는다. 생성 파일이 루트 앱 에셋 경로를 가리키는지 번들에서 직접 읽어 확인한다.
    test('로그인 심볼은 루트 앱 에셋 경로를 가리키고 번들에서 읽힌다', () async {
      final symbols = Assets.images.login.values;
      expect(symbols, hasLength(3));
      for (final image in symbols) {
        expect(image.keyName, startsWith('assets/images/login/'));
        expect(image.keyName, isNot(contains('packages/')));
        final data = await rootBundle.load(image.keyName);
        expect(data.lengthInBytes, greaterThan(0), reason: image.keyName);
      }
    });
  });
}
