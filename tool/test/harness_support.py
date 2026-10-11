"""하네스 테스트 공용 도구: 임시 Git 저장소, 가짜 flutter, 격리된 git 환경."""
import os
import re
import shutil
import stat
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SYSTEM_PATH = "/usr/bin:/bin:/usr/sbin:/sbin"

FAKE_FLUTTER = r"""#!/bin/bash
printf '%s\t%s\n' "$PWD" "$*" >> "$FAKE_FLUTTER_LOG"
# 진짜 flutter 는 SDK 버전을 git 으로 읽는다. 훅의 GIT_DIR 등을 물려받으면 엉뚱한 저장소를 읽으므로 실패시킨다.
for var in GIT_DIR GIT_INDEX_FILE GIT_WORK_TREE GIT_COMMON_DIR; do
  if [ -n "$(printenv "$var")" ]; then echo "fake flutter: 훅의 $var 를 물려받았습니다" >&2; exit 70; fi
done
case "$1" in
  pub)
    case " $* " in
      *" --offline "*) [ -z "${FAKE_PUB_OFFLINE_EXIT:-}" ] || exit "$FAKE_PUB_OFFLINE_EXIT" ;;
    esac
    [ -z "${FAKE_PUB_TOUCH:-}" ] || echo "# touched by fake pub" >> "$FAKE_PUB_TOUCH"
    # 특정 디렉터리(패키지)에서만 실패시킨다.
    [ "${FAKE_PUB_FAIL_DIR:-}" != "$PWD" ] || { echo "fake pub failed in $PWD" >&2; exit 1; }
    exit "${FAKE_PUB_EXIT:-0}" ;;
  analyze)
    if [ -n "${FAKE_ANALYZE_EXIT:-}" ]; then echo "fake analyzer crashed" >&2; exit "$FAKE_ANALYZE_EXIT"; fi
    if grep -rqs --include='*.dart' FAKE_ANALYZER_ERROR .; then echo "  error • fake analyzer error"; exit 1; fi
    if grep -rqs --include='*.dart' FAKE_ANALYZER_WARNING .; then
      case " $* " in
        *" --no-fatal-warnings "*) echo "warning • fake warning" ;;
        *) echo "warning treated as fatal"; exit 1 ;;
      esac
    fi
    exit 0 ;;
  test)
    exit "${FAKE_TEST_EXIT:-0}" ;;
esac
echo "fake flutter: unexpected args: $*" >&2
exit 64
"""

FAKE_SELFTEST = """import os, sys
with open(os.environ["FAKE_SELFTEST_LOG"], "a") as log:
    log.write(os.getcwd() + "\\n")
sys.exit(int(os.environ.get("FAKE_SELFTEST_EXIT", "0")))
"""



def gate_secret_files():
    """tool/commit_gate.sh 의 REQUIRED_SECRET_FILES 목록. 테스트가 같은 목록을 쓰도록 여기서 읽는다."""
    text = (REPO_ROOT / "tool" / "commit_gate.sh").read_text(encoding="utf-8")
    block = re.search(r"^REQUIRED_SECRET_FILES=\(([^)]*)\)", text, re.MULTILINE).group(1)
    return re.findall(r'"([^"]+)"', block)


SECRET_FILES = {rel: "// fixture secret\n" for rel in gate_secret_files()}
SECRET_GITIGNORE = "".join("/{}\n".format(rel) for rel in SECRET_FILES)


def gate_test_targets():
    """tool/commit_gate.sh 의 TEST_TARGETS 목록. 테스트가 같은 목록을 쓰도록 여기서 읽는다."""
    text = (REPO_ROOT / "tool" / "commit_gate.sh").read_text(encoding="utf-8")
    block = re.search(r"^TEST_TARGETS=\(([^)]*)\)", text, re.MULTILINE).group(1)
    return re.findall(r'"([^"]+)"', block)


# 루트가 아닌 테스트 대상 패키지. 픽스처가 같은 경로에 pubspec 과 테스트 파일을 만든다.
PACKAGE_TEST_TARGETS = [target for target in gate_test_targets() if target != "."]


def package_fixture_files():
    files = {}
    for target in PACKAGE_TEST_TARGETS:
        name = target.rstrip("/").rsplit("/", 1)[-1]
        files["{}/pubspec.yaml".format(target)] = "name: {}\n".format(name)
        files["{}/lib/{}.dart".format(target, name)] = "class Fixture {}\n"
        files["{}/test/{}_test.dart".format(target, name)] = "void main() {}\n"
    return files


def isolated_env(path):
    """사용자 전역 git 설정과 상위 훅의 GIT_* 변수를 걷어낸 환경."""
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_") and k != "CI"}
    env.update({
        "PATH": path,
        "GIT_CONFIG_GLOBAL": os.devnull,
        "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_AUTHOR_NAME": "Harness Test",
        "GIT_AUTHOR_EMAIL": "harness@example.com",
        "GIT_COMMITTER_NAME": "Harness Test",
        "GIT_COMMITTER_EMAIL": "harness@example.com",
    })
    return env


def make_executable(path):
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return path


class Fixture:
    """가짜 Flutter 모노레포와 실제 하네스 파일을 담은 임시 Git 저장소."""

    def __init__(self, tmp, with_flutter=True):
        self.tmp = Path(os.path.realpath(str(tmp)))
        self.repo = self.tmp / "repo"
        self.bin = self.tmp / "bin"
        self.flutter_log = self.tmp / "flutter.log"
        self.selftest_log = self.tmp / "selftest.log"
        self.bin.mkdir()
        os.symlink(sys.executable, str(self.bin / "python3"))
        os.symlink(shutil.which("git"), str(self.bin / "git"))
        if with_flutter:
            make_executable(write(self.bin / "flutter", FAKE_FLUTTER))
        self.env = isolated_env("{}:{}".format(self.bin, SYSTEM_PATH))
        self.env["FAKE_FLUTTER_LOG"] = str(self.flutter_log)
        self.env["FAKE_SELFTEST_LOG"] = str(self.selftest_log)
        self.env["TMPDIR"] = str(self.tmp)  # 실패한 게이트가 남기는 로그도 픽스처와 함께 지운다.
        self._build_repo()

    def _build_repo(self):
        files = {
            ".gitignore": SECRET_GITIGNORE,
            "pubspec.yaml": "name: fixture_app\n",
            "pubspec.lock": "packages: {}\n",
            "lib/main.dart": "void main() {}\n",
            "test/main_test.dart": "void main() {}\n",
            "domain/sample_domain/pubspec.yaml": "name: sample_domain\n",
            "domain/sample_domain/lib/sample_domain.dart": "class Sample {}\n",
            "data/sample_repository/pubspec.yaml": "name: sample_repository\n",
            "data/sample_repository/lib/sample_repository.dart":
                "import 'package:sample_domain/sample_domain.dart';\n",
            "application/sample_service/pubspec.yaml": "name: sample_service\n",
            "application/sample_service/lib/sample_service.dart":
                "import 'package:sample_repository/sample_repository.dart';\n",
            "tool/test/run_tests.py": FAKE_SELFTEST,
        }
        files.update(package_fixture_files())
        files.update(SECRET_FILES)
        for rel, content in files.items():
            write(self.repo / rel, content)
        for rel in ("tool/commit_gate.sh", "tool/dep_guard.py", ".githooks/pre-commit"):
            self.copy_from_repo(rel)
        self.git("init", "-q", "-b", "main")
        self.git("config", "core.hooksPath", ".githooks")
        self.git("add", "-A")

    def copy_from_repo(self, rel, root=None):
        target = (root or self.repo) / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(REPO_ROOT / rel), str(target))
        make_executable(target)

    def run(self, args, cwd=None, env=None):
        merged = dict(self.env)
        merged.update(env or {})
        return subprocess.run(args, cwd=str(cwd or self.repo), env=merged,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              universal_newlines=True)

    def git(self, *args, cwd=None, env=None, check=True):
        result = self.run(["git"] + list(args), cwd=cwd, env=env)
        if check and result.returncode != 0:
            raise AssertionError("git {} 실패:\n{}{}".format(" ".join(args), result.stdout, result.stderr))
        return result

    def write(self, rel, content, root=None):
        return write((root or self.repo) / rel, content)

    def commit(self, message="change", cwd=None, env=None, git_args=()):
        return self.git(*(list(git_args) + ["commit", "-q", "-m", message]),
                        cwd=cwd, env=env, check=False)

    def base_commit(self):
        self.git("commit", "-q", "--no-verify", "-m", "base")
        self.reset_logs()

    def reset_logs(self):
        for log in (self.flutter_log, self.selftest_log):
            if log.exists():
                log.unlink()

    def flutter_calls(self):
        if not self.flutter_log.exists():
            return []
        return [line.split("\t", 1) for line in self.flutter_log.read_text().splitlines()]

    def commit_count(self, cwd=None):
        result = self.git("rev-list", "--count", "HEAD", cwd=cwd, check=False)
        return int(result.stdout.strip()) if result.returncode == 0 else 0
