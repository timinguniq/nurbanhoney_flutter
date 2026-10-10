"""tool/cross_verify.sh 와 tool/verify_copy.sh 를 가짜 codex/claude CLI 로 검증한다."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from harness_support import (REPO_ROOT, SECRET_FILES, SECRET_GITIGNORE, SYSTEM_PATH, isolated_env, make_executable,
                             write)

FAKE_AGENT = r"""#!/bin/bash
printf '%s\n' "$@" >"$FAKE_AGENT_PROBE.args"
out=""
prompt=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) out="$2"; shift 2 ;;
    -C|-s|--permission-mode) shift 2 ;;
    *) prompt="$1"; shift ;;
  esac
done
{
  echo "pwd=$PWD"
  echo "remotes=$(git remote)"
  git diff --cached --name-only | sed 's/^/staged=/'
  [ -f lib/config/config.dart ] && echo "secret=present"
  grep -q "ci-stub" lib/config/src/secret.dart 2>/dev/null && echo "secret_kind=stub"
  grep -q "fixture secret" lib/config/config.dart 2>/dev/null && echo "secret_kind=real"
  printf '%s' "$prompt" | grep -q '회귀·아키텍처 검증' && echo "role=included"
} >"$FAKE_AGENT_PROBE"
result() { if [ -n "$out" ]; then printf '%s\n' "$1" >"$out"; else printf '%s\n' "$1"; fi; }
# 진짜 codex exec 는 표준 입력이 터미널이 아니면 EOF 까지 읽는다.
cat >/dev/null
case "${FAKE_AGENT_MODE:-pass}" in
  pass) result "$(printf '검증 완료\nVERDICT: PASS')" ;;
  fail) result "$(printf '문제 발견\nVERDICT: FAIL')" ;;
  none) result "판정 줄을 빠뜨림" ;;
  crash) echo "auth error: usage limit" >&2; exit 3 ;;
  touch_original) echo "// touched" >>"$FAKE_ORIGINAL/lib/main.dart"; result "VERDICT: PASS" ;;
  touch_secret) echo "// touched" >>"$FAKE_ORIGINAL/lib/config/config.dart"; result "VERDICT: PASS" ;;
  edit_copy_secret) echo "// mutant" >>lib/config/config.dart; result "VERDICT: PASS" ;;
  hang) exec sleep 60 ;;
  restage_original)
    blob=$(echo "// restaged" | git -C "$FAKE_ORIGINAL" hash-object -w --stdin)
    git -C "$FAKE_ORIGINAL" update-index --cacheinfo "100644,$blob,lib/staged.dart"
    result "VERDICT: PASS" ;;
  hang_ignore_term) trap '' TERM; exec sleep 60 ;;
  edit_copy) echo "// mutant" >>lib/main.dart; result "VERDICT: PASS" ;;
esac
"""


class CrossVerifyTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(os.path.realpath(self._tmp.name))
        self.repo = self.tmp / "repo"
        self.bin = self.tmp / "bin"
        self.probe = self.tmp / "probe.txt"
        for name in ("codex", "claude"):
            make_executable(write(self.bin / name, FAKE_AGENT))
        self.env = isolated_env("{}:{}".format(self.bin, SYSTEM_PATH))
        self.env.update({"FAKE_AGENT_PROBE": str(self.probe), "FAKE_ORIGINAL": str(self.repo),
                         "TMPDIR": str(self.tmp)})

        files = {
            ".gitignore": SECRET_GITIGNORE + "/.harness/\n",
            "lib/main.dart": "void main() {}\n",
        }
        files.update(SECRET_FILES)
        for rel, content in files.items():
            write(self.repo / rel, content)
        for rel in ("tool/verify_copy.sh", "tool/cross_verify.sh", "tool/ci/stub_secrets.sh",
                    "docs/agents/verifier.md", ".worktreeinclude"):
            target = self.repo / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(str(REPO_ROOT / rel), str(target))
        self.git("init", "-q", "-b", "main")
        self.git("add", "-A")
        self.git("commit", "-q", "-m", "base")
        self.git("remote", "add", "origin", "https://example.invalid/repo.git")
        # 커밋되지 않은 변경 세 종류: unstaged 수정, staged 추가, untracked 추가.
        write(self.repo / "lib/main.dart", "void main() { /* unstaged */ }\n")
        write(self.repo / "lib/staged.dart", "void staged() {}\n")
        self.git("add", "lib/staged.dart")
        write(self.repo / "lib/untracked.dart", "void untracked() {}\n")

    def tearDown(self):
        self._tmp.cleanup()

    def git(self, *args, cwd=None):
        subprocess.check_call(["git"] + list(args), cwd=str(cwd or self.repo), env=self.env,
                              stdout=subprocess.DEVNULL)

    def cross_verify(self, tool="codex", role="verifier", mode="pass", path=None):
        env = dict(self.env, FAKE_AGENT_MODE=mode)
        if path is not None:
            env["PATH"] = path
        return subprocess.run(["bash", "tool/cross_verify.sh", tool, role], cwd=str(self.repo), env=env,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

    def report(self):
        reports = sorted((self.repo / ".harness/reports").glob("*.md"))
        self.assertEqual(len(reports), 1, "보고서가 하나 남아야 합니다")
        return reports[0].read_text(encoding="utf-8")

    def read_probe(self):
        return dict(line.split("=", 1) for line in self.probe.read_text().splitlines()
                    if not line.startswith("staged=")), [
            line[len("staged="):] for line in self.probe.read_text().splitlines()
            if line.startswith("staged=")]

    def test_pass_runs_in_isolated_copy_with_all_changes(self):
        result = self.cross_verify("codex")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("판정: PASS", result.stdout)
        report = self.report()
        self.assertIn("- 판정: PASS", report)
        self.assertIn("- 원본 무결성: 유지", report)
        info, staged = self.read_probe()
        self.assertNotEqual(info["pwd"], str(self.repo))
        self.assertFalse(os.path.exists(info["pwd"]), "임시 복제본이 지워지지 않았습니다")
        self.assertEqual(info["remotes"], "", "복제본에 push 가능한 원격이 남아 있습니다")
        self.assertEqual(sorted(staged), ["lib/main.dart", "lib/staged.dart", "lib/untracked.dart"])
        self.assertEqual(info.get("secret"), "present")
        self.assertEqual(info.get("secret_kind"), "stub", "검증 도구에 실제 secret 이 넘어갔습니다")
        self.assertEqual(info.get("role"), "included")

    def test_codex_may_write_flutter_caches(self):
        # 가짜 flutter 를 두면 SDK 루트는 그 bin 의 부모가 된다. flutter 는 실행 때마다 SDK bin/cache 에 쓴다.
        make_executable(write(self.bin / "flutter", "#!/bin/sh\n"))
        (self.tmp / "bin" / "cache").mkdir()
        result = self.cross_verify("codex")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        args = (self.tmp / "probe.txt.args").read_text().splitlines()
        self.assertIn(str(self.tmp / "bin" / "cache"), args)
        self.assertEqual(args[args.index(str(self.tmp / "bin" / "cache")) - 1], "--add-dir")

    def test_codex_sandbox_allows_network_for_flutter_test(self):
        # flutter test 는 127.0.0.1 에 서버 소켓을 연다. 샌드박스 네트워크가 꺼져 있으면 테스트가 실패한다.
        self.assertEqual(self.cross_verify("codex").returncode, 0)
        args = (self.tmp / "probe.txt.args").read_text().splitlines()
        self.assertIn("sandbox_workspace_write.network_access=true", args)
        self.assertEqual(args[args.index("sandbox_workspace_write.network_access=true") - 1], "-c")

    def test_verify_copy_without_flag_copies_real_secrets(self):
        destination = self.tmp / "copy"
        result = subprocess.run(["bash", "tool/verify_copy.sh", str(destination)], cwd=str(self.repo),
                                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("fixture secret", (destination / "lib/config/config.dart").read_text())

    def test_open_stdin_does_not_block_the_cli(self):
        env = dict(self.env, FAKE_AGENT_MODE="pass")
        process = subprocess.Popen(["bash", "tool/cross_verify.sh", "codex", "verifier"], cwd=str(self.repo),
                                   env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, universal_newlines=True)
        try:
            process.wait(timeout=30)
        except subprocess.TimeoutExpired:
            process.kill()
            process.communicate()
            self.fail("열린 표준 입력 때문에 검증 도구가 멈췄습니다")
        finally:
            process.stdin.close()
        output = process.stdout.read() + process.stderr.read()
        self.assertEqual(process.returncode, 0, output)

    def test_hung_cli_times_out_as_not_run(self):
        env = dict(self.env, FAKE_AGENT_MODE="hang", CROSS_VERIFY_TIMEOUT="2")
        result = subprocess.run(["bash", "tool/cross_verify.sh", "codex", "verifier"], cwd=str(self.repo),
                                env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True, timeout=40)
        self.assertEqual(result.returncode, 1)
        report = self.report()
        self.assertIn("- 판정: 미실행", report)
        self.assertIn("시간 초과", report)

    def test_cli_ignoring_sigterm_is_killed_after_grace_period(self):
        env = dict(self.env, FAKE_AGENT_MODE="hang_ignore_term", CROSS_VERIFY_TIMEOUT="1")
        result = subprocess.run(["bash", "tool/cross_verify.sh", "codex", "verifier"], cwd=str(self.repo),
                                env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True, timeout=40)
        self.assertEqual(result.returncode, 1)
        self.assertIn("시간 초과", self.report())

    def test_claude_runs_the_same_protocol(self):
        result = self.cross_verify("claude")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("- 판정: PASS", self.report())

    def test_fail_verdict_fails(self):
        result = self.cross_verify(mode="fail")
        self.assertEqual(result.returncode, 1)
        self.assertIn("- 판정: FAIL", self.report())

    def test_missing_verdict_is_not_pass(self):
        result = self.cross_verify(mode="none")
        self.assertEqual(result.returncode, 1)
        self.assertIn("- 판정: 판정 없음", self.report())

    def test_cli_failure_is_recorded_as_not_run(self):
        result = self.cross_verify(mode="crash")
        self.assertEqual(result.returncode, 1)
        report = self.report()
        self.assertIn("- 판정: 미실행", report)
        self.assertIn("auth error: usage limit", report)

    def test_missing_cli_is_recorded_as_not_run(self):
        result = self.cross_verify(path=SYSTEM_PATH)
        self.assertEqual(result.returncode, 1)
        self.assertIn("CLI 를 PATH 에서 찾을 수 없습니다", self.report())

    def test_touching_original_invalidates_result(self):
        before = (self.repo / "lib/main.dart").read_text()
        result = self.cross_verify(mode="touch_original")
        self.assertEqual(result.returncode, 1)
        report = self.report()
        self.assertIn("- 판정: 무효", report)
        self.assertIn("- 원본 무결성: 변경됨", report)
        self.assertNotEqual((self.repo / "lib/main.dart").read_text(), before)

    def test_touching_original_secret_invalidates_result(self):
        result = self.cross_verify(mode="touch_secret")
        self.assertEqual(result.returncode, 1)
        report = self.report()
        self.assertIn("- 판정: 무효", report)
        self.assertIn("- 원본 무결성: 변경됨", report)

    def link_secret_outside_repo(self):
        """secret 을 저장소 밖 파일을 가리키는 절대 경로 심볼릭 링크로 바꾼다."""
        outside = self.tmp / "outside" / "config.dart"
        outside.parent.mkdir()
        os.rename(str(self.repo / "lib/config/config.dart"), str(outside))
        os.symlink(str(outside), str(self.repo / "lib/config/config.dart"))
        return outside

    def test_secret_symlink_target_change_invalidates_result(self):
        self.link_secret_outside_repo()
        result = self.cross_verify(mode="touch_secret")
        self.assertEqual(result.returncode, 1)
        self.assertIn("- 원본 무결성: 변경됨", self.report())

    def test_copy_gets_independent_secret_even_when_original_is_symlink(self):
        outside = self.link_secret_outside_repo()
        before = outside.read_text()
        result = self.cross_verify(mode="edit_copy_secret")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(outside.read_text(), before, "복제본 수정이 원본 secret 에 반영됐습니다")

    def test_index_only_change_in_original_invalidates_result(self):
        # staged 내용과 작업 트리가 다른 파일(AM)에서 staged 내용만 바뀌면 status·작업 트리 diff 는 그대로다.
        write(self.repo / "lib/staged.dart", "void staged() { /* worktree */ }\n")
        result = self.cross_verify(mode="restage_original")
        self.assertEqual(result.returncode, 1)
        self.assertIn("- 원본 무결성: 변경됨", self.report())

    def test_editing_copy_keeps_original_intact(self):
        before = (self.repo / "lib/main.dart").read_text()
        result = self.cross_verify(mode="edit_copy")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.repo / "lib/main.dart").read_text(), before)

    def test_unknown_role_is_rejected(self):
        result = self.cross_verify(role="nonexistent")
        self.assertEqual(result.returncode, 2)
        self.assertIn("역할 문서가 없습니다", result.stderr)

    def test_verify_copy_preserves_untracked_symlinks(self):
        os.symlink("main.dart", str(self.repo / "lib/link.dart"))
        destination = self.tmp / "copy"
        result = subprocess.run(["bash", "tool/verify_copy.sh", str(destination)], cwd=str(self.repo),
                                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((destination / "lib/link.dart").is_symlink())
        self.assertEqual(os.readlink(str(destination / "lib/link.dart")), "main.dart")

    def test_verify_copy_requires_head(self):
        empty = self.tmp / "empty"
        self.git("init", "-q", str(empty))
        shutil.copytree(str(self.repo / "tool"), str(empty / "tool"))
        result = subprocess.run(["bash", "tool/verify_copy.sh", str(self.tmp / "out")], cwd=str(empty),
                                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("HEAD 가 없습니다", result.stderr)

    def test_verify_copy_refuses_existing_destination(self):
        existing = self.tmp / "exists"
        existing.mkdir()
        result = subprocess.run(["bash", "tool/verify_copy.sh", str(existing)], cwd=str(self.repo),
                                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                universal_newlines=True)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(existing.is_dir(), "기존 디렉터리를 지웠습니다")


if __name__ == "__main__":
    unittest.main()
