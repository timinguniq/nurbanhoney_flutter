"""하네스 설정 파일끼리 어긋나지 않는지 확인한다(훅 등록, 역할 래퍼, secret 목록, 실행 권한)."""
import fnmatch
import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from harness_support import REPO_ROOT, SYSTEM_PATH, gate_secret_files, isolated_env

GUARD_PATH = "tool/agent_commit_guard.py"


def read(rel):
    return (REPO_ROOT / rel).read_text(encoding="utf-8")


class AgentHookRegistrationTest(unittest.TestCase):
    def assertBashGuard(self, config):
        entries = config["hooks"]["PreToolUse"]
        commands = [hook["command"] for entry in entries if entry.get("matcher") == "Bash"
                    for hook in entry["hooks"] if hook.get("type") == "command"]
        self.assertTrue(any(GUARD_PATH in command for command in commands), commands)

    def test_claude_settings_register_commit_guard(self):
        self.assertBashGuard(json.loads(read(".claude/settings.json")))

    def test_codex_hooks_register_commit_guard(self):
        self.assertBashGuard(json.loads(read(".codex/hooks.json")))


class RoleWrapperTest(unittest.TestCase):
    """docs/agents/<역할>.md 가 기준이고, 도구별 래퍼는 같은 역할 집합을 가리켜야 한다."""

    def roles(self, directory, suffix):
        return sorted(path.name[:-len(suffix)] for path in (REPO_ROOT / directory).glob("*" + suffix))

    def test_every_role_has_both_wrappers_and_nothing_extra(self):
        canonical = self.roles("docs/agents", ".md")
        self.assertTrue(canonical)
        self.assertEqual(self.roles(".claude/agents", ".md"), canonical)
        self.assertEqual(self.roles(".codex/agents", ".toml"), canonical)

    def test_wrappers_point_to_canonical_role(self):
        for role in self.roles("docs/agents", ".md"):
            claude = read(".claude/agents/{}.md".format(role))
            frontmatter = claude.split("---")[1]
            self.assertRegex(frontmatter, r"(?m)^name: {}$".format(re.escape(role)))
            self.assertRegex(frontmatter, r"(?m)^description: \S")
            self.assertIn("docs/agents/{}.md".format(role), claude)

            codex = read(".codex/agents/{}.toml".format(role))
            self.assertRegex(codex, r'(?m)^name = "{}"$'.format(re.escape(role)))
            self.assertRegex(codex, r'(?m)^description = "\S')
            self.assertRegex(codex, r'(?m)^developer_instructions = """')
            self.assertIn("docs/agents/{}.md".format(role), codex)

    def test_roles_define_verdict_line(self):
        for role in self.roles("docs/agents", ".md"):
            self.assertIn("VERDICT: PASS | FAIL", read("docs/agents/{}.md".format(role)), role)


class SecretFilesTest(unittest.TestCase):
    def test_gate_secrets_are_copied_to_worktrees(self):
        patterns = [line.strip().lstrip("/") for line in read(".worktreeinclude").splitlines()
                    if line.strip() and not line.startswith("#")]
        for secret in gate_secret_files():
            self.assertTrue(any(fnmatch.fnmatch(secret, p) or secret.startswith(p.rstrip("*"))
                                for p in patterns), secret)

    def test_gate_secrets_are_gitignored(self):
        for secret in gate_secret_files():
            result = subprocess.run(["git", "check-ignore", "-q", "--no-index", secret], cwd=str(REPO_ROOT))
            self.assertEqual(result.returncode, 0, "{} 가 gitignore 대상이 아닙니다".format(secret))

    def test_ci_stubs_every_gate_secret(self):
        stub = read("tool/ci/stub_secrets.sh")
        for secret in gate_secret_files():
            self.assertIn("write_if_missing " + secret, stub)
        workflow = read(".github/workflows/ci.yml")
        self.assertLess(workflow.index("tool/ci/stub_secrets.sh"), workflow.index("tool/commit_gate.sh"))


class StubSecretsTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        (self.root / "tool/ci").mkdir(parents=True)
        shutil.copy2(str(REPO_ROOT / "tool/ci/stub_secrets.sh"), str(self.root / "tool/ci"))

    def tearDown(self):
        self._tmp.cleanup()

    def run_stub(self, ci):
        env = isolated_env(SYSTEM_PATH)
        if ci:
            env["CI"] = "true"
        return subprocess.run(["bash", "tool/ci/stub_secrets.sh"], cwd=str(self.root), env=env,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

    def test_refuses_outside_ci(self):
        self.assertEqual(self.run_stub(ci=False).returncode, 1)
        self.assertFalse((self.root / "lib").exists())

    def test_creates_missing_files_and_keeps_existing(self):
        existing = self.root / "lib/firebase_options.dart"
        existing.parent.mkdir(parents=True)
        existing.write_text("// real\n")
        result = self.run_stub(ci=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        for secret in gate_secret_files():
            self.assertTrue((self.root / secret).is_file(), secret)
        self.assertEqual(existing.read_text(), "// real\n")


class RunnerTest(unittest.TestCase):
    def test_runner_fails_when_no_test_is_found(self):
        result = subprocess.run(["python3", str(REPO_ROOT / "tool/test/run_tests.py"), "-k", "__no_such_test__"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True,
                                env=isolated_env(SYSTEM_PATH))
        self.assertEqual(result.returncode, 1)
        self.assertIn("하네스 테스트를 찾지 못했습니다", result.stderr)


class ExecutableBitTest(unittest.TestCase):
    def test_entry_points_are_executable(self):
        for rel in (".githooks/pre-commit", "tool/commit_gate.sh", "tool/dep_guard.py",
                    "tool/agent_commit_guard.py", "tool/verify_copy.sh", "tool/cross_verify.sh", "tool/setup.sh",
                    "tool/ci/stub_secrets.sh", "tool/test/run_tests.py"):
            self.assertTrue(os.access(str(REPO_ROOT / rel), os.X_OK), rel)


if __name__ == "__main__":
    unittest.main()
