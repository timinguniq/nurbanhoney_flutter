#!/usr/bin/env python3
"""레이어 의존성 검사기.

docs/architecture.md 의 "금지 의존성" 규칙을 import/export 문 기준으로 검사한다.
각 패키지의 lib/ 아래 .dart 파일만 검사한다(test/ 는 제외).

종료 코드: 0 통과, 1 규칙 위반, 2 설정·실행 오류(레이어 디렉터리 없음, pubspec name 없음 등).
"""
import argparse
import os
import re
import sys
from pathlib import Path

# 하위 레이어일수록 앞에 둔다. 루트 pubspec 패키지(lib/)는 "app" 레이어다.
PACKAGE_LAYERS = ("domain", "data", "application")

# 레이어별로 import 하면 안 되는 레이어(역방향 의존 금지).
FORBIDDEN_LAYERS = {
    "domain": {"data", "application", "app"},
    "data": {"application", "app"},
    "application": {"app"},
    "app": set(),
}

# domain 은 Flutter/Riverpod 를 import 하지 않는다.
RIVERPOD_PACKAGES = {"riverpod", "flutter_riverpod", "hooks_riverpod", "riverpod_annotation"}

# import/export 지시문의 시작: 키워드 바로 뒤에 문자열이 온다. 코드 마스크(주석·문자열 내용을 지운 텍스트)에서
# 찾으므로 문자열 속 `import '...'` 는 걸리지 않고, 한 줄에 지시문이 여럿이어도 모두 찾는다.
DIRECTIVE_START_RE = re.compile(r"""(?<![\w$.])(?:import|export)\s+(?=r?['"])""")
# 지시문 안의 URI 문자열(조건부 import 의 `if (...) 'uri'` 포함).
URI_RE = re.compile(r"""(['"])([^'"]+)\1""")
NAME_RE = re.compile(r"^name:\s*([A-Za-z0-9_]+)\s*$", re.MULTILINE)


class ConfigError(Exception):
    pass


def read_package_name(pubspec):
    match = NAME_RE.search(pubspec.read_text(encoding="utf-8"))
    if not match:
        raise ConfigError("pubspec.yaml 에 name 이 없습니다: {}".format(pubspec))
    return match.group(1)


def discover_packages(root):
    """{패키지명: (레이어, 패키지 루트)} 를 돌려준다."""
    packages = {}
    root_pubspec = root / "pubspec.yaml"
    if not root_pubspec.is_file():
        raise ConfigError("루트 pubspec.yaml 이 없습니다: {}".format(root_pubspec))
    packages[read_package_name(root_pubspec)] = ("app", root)
    for layer in PACKAGE_LAYERS:
        layer_dir = root / layer
        if not layer_dir.is_dir():
            raise ConfigError("레이어 디렉터리가 없습니다: {}".format(layer_dir))
        pubspecs = sorted(layer_dir.glob("*/pubspec.yaml"))
        if not pubspecs:
            raise ConfigError("레이어에 패키지가 없습니다: {}".format(layer_dir))
        for pubspec in pubspecs:
            name = read_package_name(pubspec)
            if name in packages:
                raise ConfigError("패키지 이름이 중복됩니다: {}".format(name))
            packages[name] = (layer, pubspec.parent)
    return packages


def lex(text):
    """(코드, 마스크) 를 돌려준다. 둘 다 원문과 길이·줄바꿈 위치가 같다.

    코드: 주석을 공백으로 바꾼 텍스트(문자열은 그대로). 마스크: 주석과 문자열 내용까지 공백으로 바꾼 텍스트
    (따옴표는 남긴다). Dart 블록 주석은 중첩될 수 있다. 문자열 보간 안의 같은 종류 따옴표는 따라가지 않는다.
    """
    code, mask = [], []

    def emit(original, masked):
        code.append(original)
        mask.append(masked)

    def blank(chunk):
        return "".join("\n" if ch == "\n" else " " for ch in chunk)

    index, length = 0, len(text)
    depth = 0
    quote = None
    raw = False
    while index < length:
        char = text[index]
        if depth:
            if text.startswith("/*", index) or text.startswith("*/", index):
                depth += 1 if text[index] == "/" else -1
                emit("  ", "  ")
                index += 2
            else:
                emit(blank(char), blank(char))
                index += 1
        elif quote:
            if char == "\\" and not raw:
                chunk = text[index:index + 2]
                emit(chunk, blank(chunk))
                index += 2
            elif text.startswith(quote, index):
                emit(quote, quote)
                index += len(quote)
                quote = None
            else:
                emit(char, blank(char))
                index += 1
        elif text.startswith("//", index):
            end = text.find("\n", index)
            end = length if end < 0 else end
            emit(" " * (end - index), " " * (end - index))
            index = end
        elif text.startswith("/*", index):
            depth = 1
            emit("  ", "  ")
            index += 2
        elif char in "'\"":
            triple = text[index:index + 3]
            quote = triple if triple in ("'''", '"""') else char
            raw = index > 0 and text[index - 1] in "rR"
            emit(quote, quote)
            index += len(quote)
        else:
            emit(char, char)
            index += 1
    return "".join(code), "".join(mask)


def directive_uris(text):
    """(URI, 줄 번호) 를 import/export 지시문 순서대로 돌려준다."""
    code, mask = lex(text)
    for start in DIRECTIVE_START_RE.finditer(mask):
        end = mask.find(";", start.end())
        end = len(mask) if end < 0 else end
        for match in URI_RE.finditer(code, start.start(), end):
            yield match.group(2), code.count("\n", 0, match.start()) + 1


def dart_files(lib_dir):
    for dirpath, dirnames, filenames in os.walk(str(lib_dir)):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
        for filename in sorted(filenames):
            if filename.endswith(".dart"):
                yield Path(dirpath) / filename


def check_uri(uri, layer, lib_dir, source, packages):
    """위반 사유를 돌려준다. 문제가 없으면 None."""
    if uri == "dart:ui":
        return "domain 은 Flutter(dart:ui) 를 import 하지 않습니다" if layer == "domain" else None
    if uri.startswith("dart:"):
        return None
    if uri.startswith("package:"):
        target = uri[len("package:"):].split("/", 1)[0]
        if layer == "domain" and (target == "flutter" or target.startswith("flutter_")):
            return "domain 은 Flutter 패키지({}) 를 import 하지 않습니다".format(target)
        if layer == "domain" and target in RIVERPOD_PACKAGES:
            return "domain 은 Riverpod 패키지({}) 를 import 하지 않습니다".format(target)
        if target in packages:
            target_layer = packages[target][0]
            if target_layer in FORBIDDEN_LAYERS[layer]:
                return "{} 레이어는 {} 레이어({}) 를 import 하지 않습니다".format(
                    layer, target_layer, target)
        return None
    if ":" in uri.split("/", 1)[0]:
        return None  # file:, http: 등 다른 스킴은 검사 대상이 아니다.
    resolved = (source.parent / uri).resolve()
    try:
        resolved.relative_to(lib_dir.resolve())
    except ValueError:
        return "상대 경로 import 가 패키지 lib/ 경계를 넘습니다"
    return None


def scan(root):
    packages = discover_packages(root)
    violations = []
    for name, (layer, package_root) in sorted(packages.items()):
        lib_dir = package_root / "lib"
        if not lib_dir.is_dir():
            continue
        for source in dart_files(lib_dir):
            for uri, line in directive_uris(source.read_text(encoding="utf-8")):
                reason = check_uri(uri, layer, lib_dir, source, packages)
                if reason:
                    rel = source.relative_to(root)
                    violations.append("{}:{}: '{}' — {}".format(rel, line, uri, reason))
    return packages, violations


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        packages, violations = scan(root)
    except (ConfigError, OSError, UnicodeDecodeError) as error:
        print("[dep_guard] ✗ 설정·실행 오류: {}".format(error), file=sys.stderr)
        return 2
    if violations:
        for violation in violations:
            print(violation, file=sys.stderr)
        print("[dep_guard] ✗ 금지 의존성 {}건 (docs/architecture.md 참고)".format(len(violations)),
              file=sys.stderr)
        return 1
    print("[dep_guard] ✓ 패키지 {}개 검사, 위반 없음".format(len(packages)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
