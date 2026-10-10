"""tool/commit_gate.sh 와 .githooks/pre-commit 을 임시 Git 저장소에서 검증한다."""
import os
import shutil
import tempfile
import unittest

from harness_support import SECRET_FILES, Fixture


class CommitGateTestCase(unittest.TestCase):
    with_flutter = True

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.fx = Fixture(self._tmp.name, with_flutter=self.with_flutter)

    def tearDown(self):
        self._tmp.cleanup()

    def assertBlocked(self, result, *messages):
        self.assertNotEqual(result.returncode, 0, "커밋이 차단되지 않았습니다:\n" + result.stdout)
        output = result.stdout + result.stderr
        for message in messages:
            self.assertIn(message, output)

    def assertPassed(self, result):
        self.assertEqual(result.returncode, 0, "커밋이 차단됐습니다:\n" + result.stdout + result.stderr)

    def analyze_dirs(self):
        return [cwd for cwd, args in self.fx.flutter_calls() if args.startswith("analyze")]


class FirstCommitTest(CommitGateTestCase):
    def test_clean_first_commit_runs_every_check(self):
        result = self.fx.commit("first")
        self.assertPassed(result)
        calls = [args for _, args in self.fx.flutter_calls()]
        self.assertEqual(calls, [
            "pub get --enforce-lockfile --offline",
            "analyze --no-pub --no-fatal-warnings --no-fatal-infos",
            "test --no-pub",
        ])
        self.assertTrue(self.fx.selftest_log.exists(), "하네스 파일이 staged 됐는데 하네스 테스트가 돌지 않았습니다")

    def test_first_commit_without_head_blocks_staged_error(self):
        self.fx.write("lib/broken.dart", "// FAKE_ANALYZER_ERROR\n")
        self.fx.git("add", "lib/broken.dart")
        self.assertBlocked(self.fx.commit("first"), "flutter analyze 실패")
        self.assertEqual(self.fx.commit_count(), 0)


class ToolFailureTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()
        self.fx.write("lib/feature.dart", "void feature() {}\n")
        self.fx.git("add", "lib/feature.dart")

    def test_analyzer_crash_blocks(self):
        result = self.fx.commit(env={"FAKE_ANALYZE_EXIT": "3"})
        self.assertBlocked(result, "flutter analyze 실패", "fake analyzer crashed")

    def test_pub_get_failure_blocks(self):
        self.assertBlocked(self.fx.commit(env={"FAKE_PUB_EXIT": "1"}), "의존성 설치 실패")

    def test_pub_get_falls_back_to_network_when_cache_is_missing(self):
        self.assertPassed(self.fx.commit(env={"FAKE_PUB_OFFLINE_EXIT": "69"}))
        pub_calls = [args for _, args in self.fx.flutter_calls() if args.startswith("pub")]
        self.assertEqual(pub_calls, ["pub get --enforce-lockfile --offline", "pub get --enforce-lockfile"])

    def test_pub_get_changing_tracked_file_blocks(self):
        result = self.fx.commit(env={"FAKE_PUB_TOUCH": str(self.fx.repo / "pubspec.lock")})
        self.assertBlocked(result, "의존성 설치가 추적 파일을 변경했습니다", "pubspec.lock")

    def test_zero_tests_blocks(self):
        self.assertBlocked(self.fx.commit(env={"FAKE_TEST_EXIT": "79"}), "테스트가 0개")

    def test_failing_tests_block(self):
        self.assertBlocked(self.fx.commit(env={"FAKE_TEST_EXIT": "1"}), "flutter test 실패")

    def test_missing_secret_file_blocks_with_reason(self):
        os.remove(str(self.fx.repo / "lib/firebase_options.dart"))
        self.assertBlocked(self.fx.commit(), "secret 파일이 없습니다: lib/firebase_options.dart")

    def test_missing_gate_in_target_tree_blocks(self):
        self.fx.git("rm", "-q", "tool/commit_gate.sh")
        self.assertBlocked(self.fx.commit(), "게이트가 없습니다")


class MissingFlutterTest(CommitGateTestCase):
    with_flutter = False

    def test_missing_flutter_blocks_with_reason(self):
        self.assertIsNone(shutil.which("flutter", path=self.fx.env["PATH"]))
        self.assertBlocked(self.fx.commit("first"), "필수 도구 'flutter'")
        self.assertEqual(self.fx.commit_count(), 0)


class AnalyzerPolicyTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()

    def test_real_error_blocks(self):
        self.fx.write("lib/broken.dart", "// FAKE_ANALYZER_ERROR\n")
        self.fx.git("add", "lib/broken.dart")
        self.assertBlocked(self.fx.commit(), "fake analyzer error")

    def test_warnings_and_infos_pass_by_policy(self):
        self.fx.write("lib/warn.dart", "// FAKE_ANALYZER_WARNING\n")
        self.fx.git("add", "lib/warn.dart")
        self.assertPassed(self.fx.commit())


class StagedVersusWorkingTreeTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()

    def test_staged_error_hidden_by_unstaged_fix_blocks(self):
        self.fx.write("lib/feature.dart", "// FAKE_ANALYZER_ERROR\n")
        self.fx.git("add", "lib/feature.dart")
        self.fx.write("lib/feature.dart", "void feature() {}\n")
        self.assertBlocked(self.fx.commit(), "staged)과 작업 트리가 다릅니다", "lib/feature.dart")
        self.assertEqual(self.analyze_dirs(), [], "불일치를 확인하기 전에 분석기를 돌렸습니다")

    def test_unstaged_change_to_other_dart_file_blocks(self):
        self.fx.write("lib/a.dart", "void a() {}\n")
        self.fx.git("add", "lib/a.dart")
        self.fx.write("lib/main.dart", "void main() { /* unstaged */ }\n")
        self.assertBlocked(self.fx.commit(), "unstaged 변경: lib/main.dart")

    def test_untracked_dart_file_blocks(self):
        self.fx.write("lib/a.dart", "import 'b.dart';\n")
        self.fx.git("add", "lib/a.dart")
        self.fx.write("lib/b.dart", "void b() {}\n")
        self.assertBlocked(self.fx.commit(), "untracked 파일: lib/b.dart")

    def test_staged_harness_config_must_match_working_tree(self):
        self.fx.write(".codex/hooks.json", "{ broken\n")
        self.fx.git("add", ".codex/hooks.json")
        self.fx.write(".codex/hooks.json", "{}\n")
        self.assertBlocked(self.fx.commit(), "unstaged 변경: .codex/hooks.json")

    def test_staged_ci_workflow_triggers_harness_tests(self):
        self.fx.write(".github/workflows/ci.yml", "name: CI\n")
        self.fx.git("add", ".github/workflows/ci.yml")
        self.assertPassed(self.fx.commit())
        self.assertTrue(self.fx.selftest_log.exists(), "CI 워크플로를 바꿨는데 하네스 테스트가 돌지 않았습니다")

    def test_unrelated_untracked_file_does_not_block(self):
        self.fx.write("lib/a.dart", "void a() {}\n")
        self.fx.git("add", "lib/a.dart")
        self.fx.write("NOTES.md", "scratch\n")
        self.assertPassed(self.fx.commit())

    def test_commit_with_paths_checks_only_when_tree_matches(self):
        self.fx.write("lib/a.dart", "void a() {}\n")
        self.fx.write("lib/main.dart", "// FAKE_ANALYZER_ERROR\n")
        self.fx.git("add", "lib/a.dart")
        result = self.fx.git("commit", "-q", "-m", "only a", "lib/a.dart", check=False)
        self.assertBlocked(result, "unstaged 변경: lib/main.dart")

    def test_commit_all_includes_tracked_changes(self):
        self.fx.write("lib/main.dart", "// FAKE_ANALYZER_ERROR\n")
        result = self.fx.git("commit", "-q", "-a", "-m", "all", check=False)
        self.assertBlocked(result, "fake analyzer error")


class GitInvocationTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()
        self.fx.write("lib/broken.dart", "// FAKE_ANALYZER_ERROR\n")
        self.fx.git("add", "lib/broken.dart")

    def test_git_dash_C_runs_hook(self):
        result = self.fx.git("-C", str(self.fx.repo), "commit", "-q", "-m", "x",
                             cwd=self.fx.tmp, check=False)
        self.assertBlocked(result, "fake analyzer error")
        self.assertEqual(self.analyze_dirs(), [str(self.fx.repo)])

    def test_git_dash_c_runs_hook(self):
        result = self.fx.commit(git_args=["-c", "user.name=Other"])
        self.assertBlocked(result, "fake analyzer error")

    def test_alias_runs_hook(self):
        self.fx.git("config", "alias.ci", "commit")
        result = self.fx.git("ci", "-q", "-m", "x", check=False)
        self.assertBlocked(result, "fake analyzer error")

    def test_subdirectory_commit_checks_tree_root(self):
        result = self.fx.commit(cwd=self.fx.repo / "lib")
        self.assertBlocked(result, "fake analyzer error")
        self.assertEqual(self.analyze_dirs(), [str(self.fx.repo)])

    def test_read_commands_do_not_run_gate(self):
        for args in (["log", "--oneline"], ["status"], ["diff", "--cached"], ["show", "--stat"]):
            self.fx.git(*args)
        self.assertEqual(self.fx.flutter_calls(), [])


class WorktreeTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()
        self.worktree = self.fx.tmp / "feature-tree"
        self.fx.git("worktree", "add", "-q", "-b", "feature", str(self.worktree))
        for rel, content in SECRET_FILES.items():
            self.fx.write(rel, content, root=self.worktree)

    def test_violation_only_in_worktree_blocks_that_tree(self):
        self.fx.write("lib/broken.dart", "// FAKE_ANALYZER_ERROR\n", root=self.worktree)
        self.fx.git("add", "lib/broken.dart", cwd=self.worktree)
        self.assertBlocked(self.fx.commit(cwd=self.worktree), "fake analyzer error")
        self.assertEqual(self.analyze_dirs(), [str(self.worktree)])

        self.fx.reset_logs()
        self.fx.write("lib/ok.dart", "void ok() {}\n")
        self.fx.git("add", "lib/ok.dart")
        self.assertPassed(self.fx.commit())
        self.assertEqual(self.analyze_dirs(), [str(self.fx.repo)])

    def test_worktree_without_gate_blocks(self):
        self.fx.git("rm", "-q", "tool/commit_gate.sh", cwd=self.worktree)
        result = self.fx.commit(cwd=self.worktree)
        self.assertBlocked(result, "게이트가 없습니다", str(self.worktree))

    def test_worktree_without_secrets_blocks_with_copy_hint(self):
        os.remove(str(self.worktree / "lib/config/config.dart"))
        self.fx.write("lib/ok.dart", "void ok() {}\n", root=self.worktree)
        self.fx.git("add", "lib/ok.dart", cwd=self.worktree)
        result = self.fx.commit(cwd=self.worktree)
        self.assertBlocked(result, "secret 파일이 없습니다", str(self.fx.repo))


class DependencyAndSelftestTest(CommitGateTestCase):
    def setUp(self):
        super().setUp()
        self.fx.base_commit()

    def test_forbidden_dependency_blocks(self):
        self.fx.write("domain/sample_domain/lib/ui.dart", "import 'package:flutter/material.dart';\n")
        self.fx.git("add", "-A")
        self.assertBlocked(self.fx.commit(), "레이어 의존성 검사 실패", "domain/sample_domain/lib/ui.dart:1")

    def test_selftest_skipped_when_no_harness_file_staged(self):
        self.fx.write("lib/a.dart", "void a() {}\n")
        self.fx.git("add", "lib/a.dart")
        self.assertPassed(self.fx.commit())
        self.assertFalse(self.fx.selftest_log.exists())

    def test_selftest_runs_and_blocks_when_harness_file_staged(self):
        with open(str(self.fx.repo / "tool/dep_guard.py"), "a") as handle:
            handle.write("# touched\n")
        self.fx.git("add", "tool/dep_guard.py")
        self.assertBlocked(self.fx.commit(env={"FAKE_SELFTEST_EXIT": "1"}), "하네스 테스트 실패")
        self.assertTrue(self.fx.selftest_log.exists())

    def test_full_mode_always_runs_selftest(self):
        result = self.fx.run(["bash", "tool/commit_gate.sh"])
        self.assertPassed(result)
        self.assertTrue(self.fx.selftest_log.exists())

    def test_unknown_argument_is_rejected(self):
        result = self.fx.run(["bash", "tool/commit_gate.sh", "--fast"])
        self.assertEqual(result.returncode, 2)


if __name__ == "__main__":
    unittest.main()
