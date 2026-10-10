#!/usr/bin/env bash
# CI 전용: gitignore 대상 secret 파일이 없을 때 analyze·test 용 더미 파일을 만든다.
# 이미 있는 파일은 건드리지 않는다. 로컬에서 실수로 실행하지 않도록 CI=true 일 때만 동작한다.
#   CI=true bash tool/ci/stub_secrets.sh
# 앱 코드가 secret 식별자를 새로 쓰면 이 파일도 함께 고친다(CI analyze 가 실패해 알려준다).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

if [ "${CI:-}" != "true" ]; then
  echo "[stub-secrets] ✗ CI=true 일 때만 실행합니다. 로컬에서는 실제 secret 파일을 받아 두세요." >&2
  exit 1
fi

write_if_missing() {
  local path="$ROOT/$1"
  if [ -e "$path" ]; then
    echo "[stub-secrets] - 이미 있음: $1"
    cat >/dev/null
    return
  fi
  mkdir -p "$(dirname "$path")"
  cat >"$path"
  echo "[stub-secrets] ✓ 생성: $1"
}

write_if_missing lib/config/config.dart <<'DART'
export 'src/secret.dart';
DART

write_if_missing lib/config/src/secret.dart <<'DART'
// CI 더미 값. 실제 키가 아니다.
const kakaoNativeAppKey = 'ci-stub';
const banner1key = 'ci-stub';
const String webClientId = 'ci-stub';
DART

write_if_missing domain/dio_domain/lib/src/models/dio_main_api.dart <<'DART'
// CI 더미 값. 실제 API 주소가 아니다.
class DioMainApi {
  static final mainApi = 'https://ci-stub.invalid';
}
DART

write_if_missing lib/firebase_options.dart <<'DART'
// CI 더미 값. 실제 Firebase 설정이 아니다.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'ci-stub',
        appId: 'ci-stub',
        messagingSenderId: 'ci-stub',
        projectId: 'ci-stub',
      );
}
DART
