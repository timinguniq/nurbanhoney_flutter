"""tool/setup.sh(새 clone·worktree 준비)를 임시 저장소에서 검증한다."""
import os
import tempfile
import unittest

from harness_support import SECRET_FILES, Fixture, write


class SetupTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.fx = Fixture(self._tmp.name)
        for rel in ("tool/setup.sh", ".worktreeinclude"):
            self.fx.copy_from_repo(rel)
        self.fx.git("add", "-A")
        self.fx.base_commit()
        # 새 clone 상태: 훅 미등록, secret 없음.
        self.fx.git("config", "--unset", "core.hooksPath")
        for rel in SECRET_FILES:
            os.remove(str(self.fx.repo / rel))
        # secret 이 있는 기존 체크아웃.
        self.source = self.fx.tmp / "existing-checkout"
        for rel in SECRET_FILES:
            write(self.source / rel, "// real secret: {}\n".format(rel))

    def tearDown(self):
        self._tmp.cleanup()

    def setup(self, *args, env=None):
        return self.fx.run(["bash", "tool/setup.sh"] + list(args), env=env)

    def hooks_path(self):
        return self.fx.git("config", "--local", "--get", "core.hooksPath", check=False).stdout.strip()

    def test_prepares_fresh_clone_from_existing_checkout(self):
        result = self.setup("--secrets-from", str(self.source))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.hooks_path(), ".githooks")
        for rel in SECRET_FILES:
            self.assertIn("real secret", (self.fx.repo / rel).read_text(), rel)
        calls = [args for _, args in self.fx.flutter_calls()]
        self.assertEqual(calls, ["pub get --enforce-lockfile"])
        self.assertEqual(self.fx.git("status", "--porcelain").stdout, "", "secret 이 추적 대상으로 보입니다")

    def test_is_idempotent_and_keeps_existing_secrets(self):
        self.assertEqual(self.setup("--secrets-from", str(self.source)).returncode, 0)
        target = self.fx.repo / sorted(SECRET_FILES)[0]
        target.write_text("// local edit\n")
        result = self.setup("--secrets-from", str(self.source))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(target.read_text(), "// local edit\n")
        self.assertEqual(self.hooks_path(), ".githooks")

    def test_missing_required_secret_fails_with_list(self):
        result = self.setup()
        self.assertEqual(result.returncode, 1)
        for rel in SECRET_FILES:
            self.assertIn(rel, result.stderr)
        self.assertEqual(self.hooks_path(), ".githooks", "훅 등록은 secret 과 별개로 끝나야 합니다")

    def test_does_not_override_other_hooks_path(self):
        self.fx.git("config", "core.hooksPath", ".husky")
        result = self.setup("--secrets-from", str(self.source))
        self.assertEqual(result.returncode, 1)
        self.assertIn(".husky", result.stderr)
        self.assertEqual(self.hooks_path(), ".husky")

    def test_never_overwrites_tracked_files_from_source(self):
        write(self.source / "lib/main.dart", "// from source\n")
        with open(str(self.fx.repo / ".worktreeinclude"), "a") as handle:
            handle.write("/lib/main.dart\n")
        os.remove(str(self.fx.repo / "lib/main.dart"))
        result = self.setup("--secrets-from", str(self.source))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.fx.repo / "lib/main.dart").exists(), "추적 파일을 secret 처럼 복사했습니다")

    def test_check_runs_gate(self):
        result = self.setup("--secrets-from", str(self.source), "--check")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("[gate] ✓ 모든 검사 통과", result.stdout)

    def test_pub_get_failure_fails(self):
        result = self.setup("--secrets-from", str(self.source), env={"FAKE_PUB_EXIT": "1"})
        self.assertEqual(result.returncode, 1)
        self.assertIn("pub get", result.stderr)

    def test_unknown_option_is_rejected(self):
        self.assertEqual(self.setup("--force").returncode, 2)


if __name__ == "__main__":
    unittest.main()
