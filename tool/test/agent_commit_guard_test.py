"""tool/agent_commit_guard.py (Claude Code·Codex PreToolUse 어댑터)를 훅 입력 JSON 으로 검증한다."""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from harness_support import REPO_ROOT, SYSTEM_PATH, isolated_env, make_executable, write

GUARD = REPO_ROOT / "tool" / "agent_commit_guard.py"


class AgentCommitGuardTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(os.path.realpath(self._tmp.name))
        self.env = isolated_env(os.path.dirname(shutil.which("git")) + ":" + SYSTEM_PATH)
        self.repo = self.make_repo("repo", register_hooks=True)

    def tearDown(self):
        self._tmp.cleanup()

    def make_repo(self, name, register_hooks):
        repo = self.tmp / name
        make_executable(write(repo / ".githooks/pre-commit", "#!/bin/sh\n"))
        write(repo / "tool/commit_gate.sh", "")
        subprocess.check_call(["git", "init", "-q", str(repo)], env=self.env)
        if register_hooks:
            subprocess.check_call(["git", "-C", str(repo), "config", "core.hooksPath", ".githooks"],
                                  env=self.env)
        return repo

    def guard(self, command, cwd=None, extra=None, raw=None):
        payload = {
            "session_id": "test",
            "hook_event_name": "PreToolUse",
            "tool_name": "Bash",
            "tool_input": {"command": command},
            "cwd": str(cwd or self.repo),
        }
        payload.update(extra or {})
        return subprocess.run([sys.executable, str(GUARD)],
                              input=raw if raw is not None else json.dumps(payload),
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              universal_newlines=True, env=self.env)

    def assertAllowed(self, command, **kwargs):
        result = self.guard(command, **kwargs)
        self.assertEqual(result.returncode, 0, "{!r} 가 차단됐습니다: {}".format(command, result.stderr))

    def assertBlocked(self, command, message, **kwargs):
        result = self.guard(command, **kwargs)
        self.assertEqual(result.returncode, 2, "{!r} 가 차단되지 않았습니다".format(command))
        self.assertIn(message, result.stderr)

    def test_read_commands_are_allowed_without_checks(self):
        for command in ("git log --oneline", "git status", "git diff --cached", "ls -la",
                        "flutter analyze", "echo 'git commit -n'"):
            self.assertAllowed(command)

    def test_plain_commit_in_registered_tree_is_allowed(self):
        self.assertAllowed("git commit -m 'feat: x'")
        self.assertAllowed("git commit -am \"msg\"")
        self.assertAllowed("git add -A && git commit -m x && git log -1")

    def test_no_verify_is_blocked(self):
        self.assertBlocked("git commit --no-verify -m x", "훅을 우회")

    def test_short_n_is_blocked_alone_and_in_clusters(self):
        self.assertBlocked("git commit -n -m x", "훅을 우회")
        self.assertBlocked("git commit -anm x", "훅을 우회")

    def test_abbreviated_no_verify_is_blocked(self):
        # git 은 모호하지 않은 긴 옵션 축약을 받아들인다(--no-veri == --no-verify).
        for option in ("--no-veri", "--no-verif", "--no-v"):
            self.assertBlocked("git commit {} -m x".format(option), "훅을 우회")
        self.assertAllowed("git commit --verify -m x")

    def test_n_inside_message_value_is_not_a_flag(self):
        self.assertAllowed("git commit -m -n")
        self.assertAllowed("git commit -mn")
        self.assertAllowed("git commit --message --no-verify")
        self.assertAllowed("git commit -m \"docs: --no-verify 사용 금지 안내\"")

    def test_heredoc_message_mentioning_no_verify_is_allowed(self):
        command = "git commit -m \"$(cat <<'EOF'\n[Update] it's --no-verify 금지\nEOF\n)\""
        self.assertAllowed(command)

    def test_heredoc_body_is_data_not_commands(self):
        script = "python3 - <<'EOF'\nprint(\"it's not git commit -n\")\nEOF\necho done"
        self.assertAllowed(script)
        self.assertAllowed("cat > notes.md <<EOF\ngit commit --no-verify 금지\nEOF")

    def test_commands_after_heredoc_are_still_checked(self):
        self.assertBlocked("cat > a.txt <<'EOF'\nit's data\nEOF\ngit commit -n -m x", "훅을 우회")
        self.assertBlocked("git commit -m \"$(cat <<'EOF'\nmsg\nEOF\n)\" --no-verify", "훅을 우회")

    def test_quoted_or_commented_heredoc_marker_does_not_hide_commands(self):
        self.assertBlocked("echo '<<EOF'\ngit commit --no-verify -m x", "훅을 우회")
        self.assertBlocked("echo \"<<EOF\"\ngit commit -n -m x", "훅을 우회")
        self.assertBlocked("true # <<EOF\ngit commit -n -m x", "훅을 우회")

    def test_heredoc_inside_command_substitution_in_double_quotes(self):
        message = "git commit -m \"$(cat <<'EOF'\nsay \"hi\" and it's fine\nEOF\n)\""
        self.assertAllowed(message)
        self.assertBlocked(message + " --no-verify", "훅을 우회")

    def test_here_string_is_not_a_heredoc(self):
        self.assertBlocked("cat <<<\"word\"\ngit commit -n -m x", "훅을 우회")

    def test_hooks_path_override_is_blocked(self):
        self.assertBlocked("git -c core.hooksPath=/dev/null commit -m x", "훅 경로를 덮어써")
        self.assertBlocked("git -c CORE.HOOKSPATH= commit -m x", "훅 경로를 덮어써")
        self.assertBlocked("EMPTY= git --config-env=core.hooksPath=EMPTY commit -m x", "훅 경로를 덮어써")
        # 변수가 없으면 git 이 실행을 거부하므로 우회가 아니다.
        self.assertAllowed("git --config-env=core.hooksPath=UNSET_VARIABLE commit -m x")

    def test_hooks_path_override_through_environment_is_blocked(self):
        self.assertBlocked("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null "
                           "git commit -m x", "훅 경로를 덮어써")
        self.assertBlocked("GIT_CONFIG_PARAMETERS=\"'core.hooksPath'='/dev/null'\" git commit -m x",
                           "훅 경로를 덮어써")
        self.assertBlocked("export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=CORE.HOOKSPATH GIT_CONFIG_VALUE_0=x; "
                           "git commit -m x", "훅 경로를 덮어써")
        self.assertAllowed("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=user.name GIT_CONFIG_VALUE_0=Bot git commit -m x")

    def test_inline_alias_definition_is_resolved(self):
        self.assertBlocked("git -c alias.ci='commit -n' ci -m x", "훅을 우회")
        self.assertBlocked("git -c alias.ci='!git commit --no-verify' ci -m x", "훅을 우회")
        self.assertAllowed("git -c alias.ci=commit ci -m x")

    def test_hooks_path_override_reaches_nested_commands(self):
        # git 은 -c 설정을 셸 별칭의 하위 git 에, 셸은 환경 변수를 bash -c 의 하위 명령에 물려준다.
        self.assertBlocked("git -c core.hooksPath=/dev/null -c alias.ci='!git commit' ci -m x", "훅 경로를 덮어써")
        self.assertBlocked("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null "
                           "git -c alias.ci='!git commit' ci -m x", "훅 경로를 덮어써")
        self.assertBlocked("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null "
                           "bash -c 'git commit -m x'", "훅 경로를 덮어써")
        self.assertAllowed("git -c alias.ci='!git commit' ci -m x")

    def test_aliases_defined_through_environment_are_resolved(self):
        self.assertBlocked("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=alias.ci GIT_CONFIG_VALUE_0='commit -n' git ci -m x",
                           "훅을 우회")
        self.assertBlocked("GIT_CONFIG_PARAMETERS=\"'alias.ci'='commit --no-verify'\" git ci -m x", "훅을 우회")
        self.assertAllowed("GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=alias.ci GIT_CONFIG_VALUE_0=commit git ci -m x")

    def test_git_quoted_config_parameters_are_decoded(self):
        # git 은 GIT_CONFIG_PARAMETERS 를 셸 인용으로 만든다: ' 는 '\'', ! 는 '\!' 가 된다.
        self.assertBlocked("GIT_CONFIG_PARAMETERS=\"'alias.ci'=''\\!'git commit -n'\" git ci -m x", "훅을 우회")
        self.assertBlocked("GIT_CONFIG_PARAMETERS=\"'user.name'='it'\\''s me' 'core.hooksPath'='/dev/null'\" "
                           "git commit -m x", "훅 경로를 덮어써")

    def test_config_env_override_reaches_shell_alias(self):
        self.assertBlocked("BYPASS=/dev/null git --config-env=core.hooksPath=BYPASS -c alias.ci='!git commit' ci -m x",
                           "훅 경로를 덮어써")

    def test_alias_chains_are_followed(self):
        self.assertBlocked("git -c alias.ci=save -c alias.save='commit -n' ci -m x", "훅을 우회")
        subprocess.check_call(["git", "-C", str(self.repo), "config", "alias.c1", "c2"], env=self.env)
        subprocess.check_call(["git", "-C", str(self.repo), "config", "alias.c2", "commit --no-verify"], env=self.env)
        self.assertBlocked("git c1 -m x", "훅을 우회")

    def test_alias_cycles_terminate(self):
        self.assertAllowed("git -c alias.a=b -c alias.b=a a")

    def test_hooks_path_with_trailing_space_is_a_different_path(self):
        self.assertBlocked("git -c 'core.hooksPath=.githooks ' commit -m x", "훅 경로를 덮어써")

    def test_glued_shell_operators_separate_commands(self):
        for command in ("(git status); git commit -n -m x", "(git status)&&git commit -n -m x",
                        "git log|cat;git commit -n -m x"):
            self.assertBlocked(command, "훅을 우회")

    def test_quoted_or_escaped_operators_are_part_of_words(self):
        for command in ("git commit -m ';' -n", "git commit -m '&&' --no-verify", 'git commit -m "a|b" -n',
                        "git commit -m a\\;b -n"):
            self.assertBlocked(command, "훅을 우회")
        self.assertAllowed("git commit -m 'x; git commit -n'")

    def test_subshell_cd_does_not_leak_to_outer_commands(self):
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("(cd {}); git commit -m x".format(self.repo), "Git 훅이 등록되지 않았습니다", cwd=other)
        self.assertBlocked("(cd {} && git commit -m x)".format(other), "Git 훅이 등록되지 않았습니다")
        self.assertAllowed("(cd {}); git commit -m x".format(other))

    def test_command_substitutions_are_checked(self):
        self.assertBlocked("echo $(git commit -n -m x)", "훅을 우회")
        self.assertBlocked("echo \"$(git commit --no-verify -m x)\"", "훅을 우회")
        self.assertBlocked("echo `git commit -n -m x`", "훅을 우회")
        self.assertAllowed("echo '$(git commit -n -m x)'")

    def test_commands_after_shell_keywords_are_checked(self):
        for command in ("if true; then git commit -n -m x; fi", "{ git commit -n -m x; }",
                        "! git commit --no-verify -m x", "while false; do git commit -n -m x; done"):
            self.assertBlocked(command, "훅을 우회")

    def test_command_substitution_uses_state_at_its_position(self):
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("cd {}; echo \"$(git commit -m x)\"".format(other), "Git 훅이 등록되지 않았습니다")
        self.assertBlocked("export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null; "
                           "echo \"$(git commit -m x)\"", "훅 경로를 덮어써")

    def test_wrapper_options_are_skipped(self):
        for command in ("command -- git commit -n -m x", "command -p git commit --no-verify -m x",
                        "nice -n 5 git commit --no-verify -m x", "nice -10 git commit -n -m x",
                        "exec -a name git commit -n -m x", "time -p git commit -n -m x",
                        "env -u FOO git commit -n -m x", "nohup -- git commit -n -m x"):
            self.assertBlocked(command, "훅을 우회")
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("env -C {} git commit -m x".format(other), "Git 훅이 등록되지 않았습니다")

    def test_env_split_string_is_a_command(self):
        self.assertBlocked("env -S 'git commit --no-verify -m x'", "훅을 우회")
        self.assertBlocked("env --split-string='git commit -n -m x'", "훅을 우회")
        self.assertBlocked("env -S 'FOO=1 git commit -n' -m x", "훅을 우회")
        self.assertAllowed("env -S 'git status'")

    def test_env_unset_and_clear_change_what_git_sees(self):
        other = self.make_repo("unregistered", register_hooks=False)
        setup = "export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=.githooks; "
        self.assertAllowed(setup + "git commit -m x", cwd=other)  # 환경 설정으로 훅이 실제로 돈다
        self.assertBlocked(setup + "env -u GIT_CONFIG_COUNT git commit -m x", "Git 훅이 등록되지 않았습니다", cwd=other)
        self.assertBlocked(setup + "env --unset=GIT_CONFIG_COUNT git commit -m x", "Git 훅이 등록되지 않았습니다",
                           cwd=other)
        self.assertBlocked(setup + "env -i git commit -m x", "Git 훅이 등록되지 않았습니다", cwd=other)
        self.assertBlocked(setup + "unset GIT_CONFIG_COUNT; git commit -m x", "Git 훅이 등록되지 않았습니다", cwd=other)

    def test_attached_short_option_values(self):
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("env -C{} git commit -m x".format(other), "Git 훅이 등록되지 않았습니다")
        self.assertBlocked("env -uFOO git commit -n -m x", "훅을 우회")
        self.assertBlocked("nice -n5 git commit -n -m x", "훅을 우회")

    def test_command_path_changes_do_not_break_git_lookup(self):
        # 가드는 변수를 펼치지 않으므로 PATH 값이 '$SHIM:$PATH' 같은 문자 그대로 들어온다.
        self.assertAllowed('export PATH="$SHIM:$PATH"; git commit -m x')
        self.assertAllowed("PATH=/nonexistent git commit -m x")
        self.assertBlocked('export PATH="$SHIM:$PATH"; git commit -n -m x', "훅을 우회")

    def test_other_config_overrides_are_allowed(self):
        self.assertAllowed("git -c user.name=Bot commit -m x")

    def test_hooks_path_override_on_non_commit_command_is_allowed(self):
        self.assertAllowed("git -c core.hooksPath=/tmp/x config --get core.hooksPath")
        self.assertAllowed("git -c core.hooksPath=/tmp/x log --oneline")

    def test_commit_after_newline_or_cd_is_checked(self):
        self.assertBlocked("cd lib\ngit commit -n -m x", "훅을 우회")  # 없는 디렉터리로 cd 가 실패해도 다음 줄은 실행된다
        (self.repo / "lib").mkdir()
        self.assertBlocked("cd lib\ngit commit -n -m x", "훅을 우회")
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("cd {} && git commit -m x".format(other), "Git 훅이 등록되지 않았습니다")

    def test_dash_C_targets_other_tree(self):
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("git -C {} commit -m x".format(other), "Git 훅이 등록되지 않았습니다",
                           cwd=self.tmp)
        self.assertAllowed("git -C repo commit -m x", cwd=self.tmp)

    def test_unregistered_tree_is_blocked_with_setup_hint(self):
        other = self.make_repo("unregistered", register_hooks=False)
        self.assertBlocked("git commit -m x", "git config --local core.hooksPath .githooks", cwd=other)

    def test_missing_or_non_executable_hook_is_blocked(self):
        (self.repo / ".githooks/pre-commit").chmod(0o644)
        self.assertBlocked("git commit -m x", "실행 가능한 pre-commit 훅이 없습니다")

    def test_missing_gate_is_blocked(self):
        (self.repo / "tool/commit_gate.sh").unlink()
        self.assertBlocked("git commit -m x", "tool/commit_gate.sh 가 없습니다")

    def test_wrapped_commands_are_checked(self):
        self.assertBlocked("bash -lc 'git commit -n -m x'", "훅을 우회")
        self.assertBlocked("FOO=1 env BAR=2 git commit --no-verify -m x", "훅을 우회")
        self.assertBlocked("command git commit -n -m x", "훅을 우회")

    def test_aliases_are_resolved(self):
        subprocess.check_call(["git", "-C", str(self.repo), "config", "alias.ci", "commit --no-verify"],
                              env=self.env)
        subprocess.check_call(["git", "-C", str(self.repo), "config", "alias.save", "!git commit -n"],
                              env=self.env)
        subprocess.check_call(["git", "-C", str(self.repo), "config", "alias.lg", "log --oneline"],
                              env=self.env)
        self.assertBlocked("git ci -m x", "훅을 우회")
        self.assertBlocked("git save -m x", "훅을 우회")
        self.assertAllowed("git lg")

    def test_unparseable_commit_command_is_blocked(self):
        self.assertBlocked("git commit -m 'unterminated", "해석할 수 없어")
        self.assertAllowed("echo 'unterminated")

    def test_codex_payload_with_argv_command(self):
        extra = {"turn_id": "t1", "model": "gpt", "tool_use_id": "u1"}
        result = self.guard("", extra=dict(extra, tool_input={"command": ["bash", "-lc", "git commit -n"]}))
        self.assertEqual(result.returncode, 2)
        self.assertAllowed("git status", extra=extra)

    def test_non_shell_tools_are_ignored(self):
        result = self.guard("", extra={"tool_name": "apply_patch",
                                       "tool_input": {"command": "*** Begin Patch\ngit commit -n"}})
        self.assertEqual(result.returncode, 0)

    def test_invalid_input_blocks(self):
        result = self.guard("", raw="{not json")
        self.assertEqual(result.returncode, 2)
        self.assertIn("가드 실행 오류", result.stderr)


if __name__ == "__main__":
    unittest.main()
