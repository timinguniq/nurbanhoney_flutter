#!/usr/bin/env python3
"""에이전트 PreToolUse(Bash) 훅 어댑터. Claude Code 와 Codex 가 같은 스크립트를 쓴다.

stdin 으로 받은 훅 입력 JSON 에서 셸 명령을 꺼내 `git commit` 을 찾고 다음을 차단한다.
  - 훅 우회: --no-verify, -n, `-c core.hooksPath=...` 덮어쓰기
  - 커밋 대상 작업 트리에 Git 훅이 등록되지 않은 경우(core.hooksPath != .githooks 등)

공통 게이트(tool/commit_gate.sh)는 여기서 실행하지 않는다. 등록된 Git 훅이 커밋 때
게이트를 실행하므로, 여기서도 실행하면 같은 검사가 두 번 돈다.

명령 해석은 최선 노력이다(변수 확장·eval 등은 따라가지 않는다). 실제 차단은 Git 훅이 맡는다.
종료 코드: 0 허용, 2 차단(사유는 stderr). 내부 오류도 2 로 차단한다.
"""
import json
import os
import re
import shlex
import shutil
import subprocess
import sys

# 따옴표 밖에서 명령을 나누는 셸 연산자 문자. `(` `)` 는 서브셸 범위도 표시한다.
OPERATOR_CHARS = set(";&|\n()")
# 명령 앞에 올 수 있는 셸 키워드. 뒤따르는 단어가 실제 명령이다.
SHELL_KEYWORDS = {"{", "}", "!", "if", "then", "else", "elif", "fi", "do", "done", "while", "until"}
SHELLS = {"bash", "sh", "zsh", "dash", "ksh"}
# 다른 명령을 실행하는 래퍼와, 그 래퍼 옵션 중 값을 받는 것. 다른 옵션은 값 없이 건너뛴다.
WRAPPER_VALUE_OPTIONS = {
    "command": set(), "builtin": set(), "nohup": set(), "time": set(),
    "exec": {"-a"},
    "nice": {"-n", "--adjustment"},
    "env": {"-u", "--unset", "-C", "--chdir", "-S", "--split-string", "-P"},
}
ENV_ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
# here-document 연산자(`<<EOF`, `<<-'EOF'`, `<< "EOF"`, `<<\\EOF`). here-string(`<<<`)은 호출하는 쪽에서 거른다.
HEREDOC_OPERATOR = re.compile(
    r"""<<(-?)[ \t]*(?:'([^'\n]*)'|"([^"\n]*)"|\\?([A-Za-z_][A-Za-z0-9_]*))""")

# git 전역 옵션 중 값을 다음 인자로 받는 것.
GIT_GLOBAL_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
                         "--config-env", "--exec-path", "--super-prefix", "--list-cmds"}
# git commit 의 짧은 옵션 중 값을 받는 것(-S, -u 는 값이 붙어 있을 때만 받는다).
COMMIT_SHORT_WITH_VALUE = set("mFCct")
COMMIT_SHORT_OPTIONAL_VALUE = set("Su")
COMMIT_LONG_WITH_VALUE = {"--message", "--file", "--reuse-message", "--reedit-message",
                          "--template", "--author", "--date", "--cleanup", "--fixup",
                          "--squash", "--trailer", "--pathspec-from-file"}

HOOKS_SETUP_HINT = "git config --local core.hooksPath .githooks"
# 가드 자신의 PATH 로 찾은 git. 명령이 바꾼 PATH 는 펼치지 않은 문자열(예: "$X:$PATH")이라 쓰지 않는다.
GIT = shutil.which("git") or "git"


def strip_heredoc_bodies(command):
    """here-document 본문과 셸 주석을 지운다. 본문은 명령이 아니라 데이터라서 셸 문법으로 해석하지 않는다.

    따옴표 안이나 주석 속의 `<<EOF` 는 연산자가 아니다. 큰따옴표 안의 `$(...)` 는 새 명령 문맥이라
    그 안의 `<<EOF` 는 연산자다(커밋 메시지를 `-m "$(cat <<'EOF' ... EOF)"` 로 넘기는 경우).
    """
    out = []
    stack = ["cmd"]  # cmd, sq('...'), dq("..."), subst($(...)), paren((...))
    pending = []  # 본문을 기다리는 (구분자, 탭 제거 여부)
    index, length = 0, len(command)
    while index < length:
        char = command[index]
        context = stack[-1]
        if context == "sq":
            if char == "'":
                stack.pop()
            out.append(char)
            index += 1
            continue
        if char == "\\":
            out.append(command[index:index + 2])
            index += 2
            continue
        if context == "dq":
            if char == '"':
                stack.pop()
            elif command.startswith("$(", index):
                stack.append("subst")
                out.append("$(")
                index += 2
                continue
            out.append(char)
            index += 1
            continue
        if char == "\n" and pending:
            out.append(char)
            index += 1
            for delimiter, strip_tabs in pending:
                while index < length:
                    end = command.find("\n", index)
                    end = length if end < 0 else end
                    line = command[index:end]
                    index = min(end + 1, length)
                    if (line.lstrip("\t") if strip_tabs else line) == delimiter:
                        break
            pending = []
            continue
        if char == "#" and (index == 0 or command[index - 1] in " \t\n;&|()"):
            end = command.find("\n", index)
            index = length if end < 0 else end
            continue
        if char == "'":
            stack.append("sq")
        elif char == '"':
            stack.append("dq")
        elif command.startswith("$(", index):
            stack.append("subst")
            out.append("$(")
            index += 2
            continue
        elif char == "(":
            stack.append("paren")
        elif char == ")" and context in ("subst", "paren"):
            stack.pop()
        elif command.startswith("<<<", index):
            out.append("<<<")
            index += 3
            continue
        elif command.startswith("<<", index):
            match = HEREDOC_OPERATOR.match(command, index)
            if match:
                delimiter = next(group for group in match.groups()[1:] if group is not None)
                pending.append((delimiter, match.group(1) == "-"))
                out.append(match.group(0))
                index = match.end()
                continue
        out.append(char)
        index += 1
    return "".join(out)


class Operator(str):
    """따옴표 밖의 셸 연산자 토큰. 따옴표 안의 같은 문자는 일반 단어(Word)라서 이 타입이 아니다."""


class Word(str):
    """셸 단어. 안에 든 $(...)·`...` 명령을 substitutions 로 갖는다."""
    substitutions = ()


def find_backtick_end(command, index):
    """여는 ` 바로 뒤에서 닫는 ` 의 위치를 찾는다."""
    while index < len(command):
        if command[index] == "\\":
            index += 2
        elif command[index] == "`":
            return index
        else:
            index += 1
    raise ValueError("닫히지 않은 `")


def find_substitution_end(command, index):
    """`$(` 바로 뒤에서 짝이 맞는 `)` 의 위치를 찾는다. 따옴표와 중첩 괄호를 따라간다."""
    depth = 1
    while index < len(command):
        char = command[index]
        if char == "\\":
            index += 2
        elif char == "'":
            end = command.find("'", index + 1)
            if end < 0:
                raise ValueError("닫히지 않은 '")
            index = end + 1
        elif char == '"':
            index = read_double_quoted(command, index + 1, [], [])
        elif char == "`":
            index = find_backtick_end(command, index + 1) + 1
        else:
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    return index
            index += 1
    raise ValueError("닫히지 않은 $(")


def read_double_quoted(command, index, word, substitutions):
    """여는 \" 바로 뒤부터 읽어 word 에 내용을, substitutions 에 $(...)·`...` 명령을 모은다. 닫는 \" 다음 위치를 돌려준다."""
    while index < len(command):
        char = command[index]
        if char == '"':
            return index + 1
        if char == "\\" and index + 1 < len(command):
            following = command[index + 1]
            word.append(following if following in '"\\$`\n' else "\\" + following)
            index += 2
        elif command.startswith("$(", index):
            end = find_substitution_end(command, index + 2)
            substitutions.append(command[index + 2:end])
            word.append(command[index:end + 1])
            index = end + 1
        elif char == "`":
            end = find_backtick_end(command, index + 1)
            substitutions.append(command[index + 1:end])
            word.append(command[index:end + 1])
            index = end + 1
        else:
            word.append(char)
            index += 1
    raise ValueError("닫히지 않은 \"")


def tokenize(command):
    """토큰 목록을 돌려준다. 토큰은 단어(Word) 또는 따옴표 밖의 연산자(Operator)다.

    따옴표·이스케이프 안의 연산자 문자는 단어의 일부다. $(...)·`...` 안의 명령은 그 단어의 substitutions 에 담는다.
    닫히지 않은 따옴표·치환이 있으면 ValueError.
    """
    tokens = []
    word, in_word, substitutions = [], False, []

    def finish_word():
        token = Word("".join(word))
        token.substitutions = tuple(substitutions)
        tokens.append(token)
    index, length = 0, len(command)
    while index < length:
        char = command[index]
        if char in " \t\r" or char in OPERATOR_CHARS:
            if in_word:
                finish_word()
            word, in_word, substitutions = [], False, []
            if char in OPERATOR_CHARS:
                tokens.append(Operator(char))
            index += 1
            continue
        in_word = True
        if char == "\\":
            if command.startswith("\\\n", index):  # 줄 이어 쓰기
                index += 2
                continue
            word.append(command[index + 1:index + 2])
            index += 2
        elif char == "'":
            end = command.find("'", index + 1)
            if end < 0:
                raise ValueError("닫히지 않은 '")
            word.append(command[index + 1:end])
            index = end + 1
        elif char == '"':
            index = read_double_quoted(command, index + 1, word, substitutions)
        elif command.startswith("$(", index):
            end = find_substitution_end(command, index + 2)
            substitutions.append(command[index + 2:end])
            word.append(command[index:end + 1])
            index = end + 1
        elif char == "`":
            end = find_backtick_end(command, index + 1)
            substitutions.append(command[index + 1:end])
            word.append(command[index:end + 1])
            index = end + 1
        else:
            word.append(char)
            index += 1
    if in_word:
        finish_word()
    return tokens


def strip_prefixes(words):
    """앞쪽의 환경 변수 대입, 셸 키워드, 래퍼와 그 옵션을 걷어낸다.

    (나머지 단어, 접두 정보) 를 돌려준다. 접두 정보: assignments(대입), unset(env -u 로 지운 변수),
    clear(env -i), chdir(env -C 디렉터리 또는 None).
    """
    prefix = {"assignments": {}, "unset": set(), "clear": False, "chdir": None}
    words = list(words)
    index = 0
    while index < len(words):
        word = words[index]
        if ENV_ASSIGNMENT.match(word):
            name, value = word.split("=", 1)
            prefix["assignments"][name] = value
            index += 1
        elif word in SHELL_KEYWORDS:
            index += 1
        elif word in WRAPPER_VALUE_OPTIONS:
            wrapper, value_options = word, WRAPPER_VALUE_OPTIONS[word]
            index += 1
            while index < len(words) and words[index].startswith("-"):
                option = words[index]
                index += 1
                if option == "--":
                    break
                if option == "-":  # env - == env -i
                    name, attached = "-i", ""
                elif option.startswith("--"):
                    name, has_value, attached = option.partition("=")
                    if name in value_options and not has_value and index < len(words):
                        attached = words[index]
                        index += 1
                else:  # 짧은 옵션: 값이 붙어 있을 수 있다(-C/path, -uNAME, -n5).
                    name, attached = option[:2], option[2:]
                    if name in value_options and not attached and index < len(words):
                        attached = words[index]
                        index += 1
                if wrapper != "env":
                    continue
                if name in ("-C", "--chdir") and attached:
                    prefix["chdir"] = attached
                elif name in ("-u", "--unset") and attached:
                    prefix["unset"].add(attached)
                elif name in ("-i", "--ignore-environment"):
                    prefix["clear"] = True
                elif name in ("-S", "--split-string"):
                    # env -S 는 값을 단어로 쪼개 나머지 인자 앞에 놓고 실행한다.
                    split = [token for token in tokenize(attached) if not isinstance(token, Operator)]
                    words[index:index] = split
            if wrapper == "env":
                while index < len(words) and ENV_ASSIGNMENT.match(words[index]):
                    name, value = words[index].split("=", 1)
                    prefix["assignments"][name] = value
                    index += 1
        else:
            break
    return words[index:], prefix


def run_git(global_options, cwd, env, *args):
    """커밋 명령과 같은 전역 옵션·환경으로 git 을 실행해 stdout 을 돌려준다(실패하면 None).

    -c, --config-env, GIT_CONFIG_*, -C, --git-dir 같은 설정 출처를 가드가 흉내 내지 않고 git 이 직접 해석하게 한다.
    """
    result = subprocess.run([GIT] + list(global_options) + list(args), cwd=cwd, env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, universal_newlines=True)
    if result.returncode != 0:
        return None
    # 출력 끝의 개행 하나만 뗀다. 설정값 자체의 공백(예: '.githooks ')은 다른 경로라서 남긴다.
    return result.stdout[:-1] if result.stdout.endswith("\n") else result.stdout


def sq_quote(text):
    """git 의 GIT_CONFIG_PARAMETERS 형식에 맞는 작은따옴표 인용."""
    return "'" + text.replace("'", "'\\''") + "'"


def commit_bypasses_hooks(args):
    for index, arg in enumerate(args):
        if arg == "--":
            return False
        # git 은 모호하지 않은 긴 옵션 축약을 받아들인다(--no-veri). 모호한 축약은 git 이 거부하지만 함께 막는다.
        if arg.startswith("--no-v") and "--no-verify".startswith(arg):
            return True
        if arg.startswith("--"):
            if arg in COMMIT_LONG_WITH_VALUE:
                return commit_bypasses_hooks(args[index + 2:])
            continue
        if arg.startswith("-") and len(arg) > 1:
            for position, flag in enumerate(arg[1:], start=1):
                if flag == "n":
                    return True
                if flag in COMMIT_SHORT_WITH_VALUE:
                    if position == len(arg) - 1:
                        return commit_bypasses_hooks(args[index + 2:])
                    break
                if flag in COMMIT_SHORT_OPTIONAL_VALUE:
                    break
    return False


def check_hooks(global_options, cwd, env):
    """이 커밋에 실제로 적용될 훅 설정을 git 에 물어 확인한다."""
    top = run_git(global_options, cwd, env, "rev-parse", "--show-toplevel")
    if top is None:
        return []  # git 이 이 옵션·환경으로 실행되지 않으면 커밋도 실패한다.
    effective = run_git(global_options, cwd, env, "config", "--get", "core.hooksPath") or ""
    registered = run_git([], top, dict(os.environ), "config", "--get", "core.hooksPath") or ""
    reasons = []
    if effective != ".githooks":
        if registered == ".githooks":
            reasons.append("이 커밋은 -c·--config-env·GIT_CONFIG_* 로 Git 훅 경로를 덮어써(core.hooksPath='{}') "
                           "훅을 우회합니다.".format(effective))
        else:
            reasons.append("커밋 대상 작업 트리({})에 Git 훅이 등록되지 않았습니다"
                           "(core.hooksPath='{}'). 등록: {}".format(top, registered, HOOKS_SETUP_HINT))
    hook = os.path.join(top, ".githooks", "pre-commit")
    if not os.access(hook, os.X_OK):
        reasons.append("실행 가능한 pre-commit 훅이 없습니다: {}".format(hook))
    if not os.path.isfile(os.path.join(top, "tool", "commit_gate.sh")):
        reasons.append("커밋 대상 작업 트리에 tool/commit_gate.sh 가 없습니다: {}".format(top))
    return reasons


def check_git(words, cwd, depth, env):
    if not os.path.isdir(cwd):
        return []  # 없는 디렉터리에서는 명령이 실패한다.
    run_env = dict(os.environ)
    for name, value in env.items():
        if value is None:
            run_env.pop(name, None)
        else:
            run_env[name] = value
    global_options = []
    passed_config = []  # 셸 별칭에 GIT_CONFIG_PARAMETERS 로 물려줄 (키, 값)
    index = 1
    while index < len(words):
        word = words[index]
        if word in GIT_GLOBAL_WITH_VALUE and index + 1 < len(words):
            option, value = word, words[index + 1]
            global_options += [option, value]
            index += 2
        elif word.startswith("-"):
            option, _, value = word.partition("=")
            global_options.append(word)
            index += 1
        else:
            break
        if option == "-c" and value:
            key, has_value, setting = value.partition("=")
            passed_config.append((key, setting if has_value else "true"))
        elif option == "--config-env" and "=" in value:
            key, _, variable = value.partition("=")
            passed_config.append((key, run_env.get(variable, "")))
    if index >= len(words):
        return []
    name, args = words[index], words[index + 1:]
    seen = set()
    while name != "commit":
        if name in seen:
            return []  # 별칭 순환은 git 이 거부한다.
        seen.add(name)
        alias = run_git(global_options, cwd, run_env, "config", "--get", "alias." + name)
        if not alias:
            return []
        if alias.startswith("!"):
            # git 은 셸 별칭을 저장소 최상위에서 실행하고, -c·--config-env 설정을 GIT_CONFIG_PARAMETERS 로 물려준다.
            child_env = dict(env)
            inherited = [sq_quote(key) + "=" + sq_quote(value) for key, value in passed_config]
            if inherited:
                child_env["GIT_CONFIG_PARAMETERS"] = " ".join(
                    filter(None, [env.get("GIT_CONFIG_PARAMETERS", "")] + inherited))
            top = run_git(global_options, cwd, run_env, "rev-parse", "--show-toplevel") or cwd
            script = alias[1:] + " " + " ".join(shlex.quote(a) for a in args)
            return analyze(script, top, depth + 1, child_env)
        try:
            alias_words = shlex.split(alias)
        except ValueError:
            return ["별칭 alias.{} 을 해석할 수 없어 커밋 여부를 확인하지 못했습니다.".format(name)]
        if not alias_words:
            return []
        name, args = alias_words[0], alias_words[1:] + args
    if commit_bypasses_hooks(args):
        return ["에이전트는 Git 훅을 우회하는 커밋(--no-verify / -n)을 할 수 없습니다. "
                "게이트 실패 원인을 고치세요 (docs/harness.md 참고)."]
    return check_hooks(global_options, cwd, run_env)


def analyze_simple(words, state, depth):
    """단순 명령 하나를 분석한다. state 의 cwd·env 는 cd·export 로 바뀐다."""
    words, prefix = strip_prefixes(words)
    if not words:
        state["env"].update(prefix["assignments"])
        return []
    program = os.path.basename(words[0])
    # 이 명령이 보는 환경. 값이 None 인 변수는 지워진 것이다(env -u, env -i, unset).
    if prefix["clear"]:
        env = {name: None for name in list(os.environ) + list(state["env"])}
    else:
        env = dict(state["env"])
    env.update({name: None for name in prefix["unset"]})
    env.update(prefix["assignments"])
    # `env -C dir 명령` 은 그 명령만 dir 에서 실행한다.
    chdir = prefix["chdir"]
    command_cwd = os.path.normpath(os.path.join(state["cwd"], os.path.expanduser(chdir))) if chdir else state["cwd"]
    if program == "export":
        state["env"].update(strip_prefixes(words[1:])[1]["assignments"])
    elif program == "unset":
        state["env"].update({name: None for name in words[1:] if not name.startswith("-")})
    elif program == "cd":
        destination = words[1] if len(words) > 1 else "~"
        new_cwd = os.path.normpath(os.path.join(state["cwd"], os.path.expanduser(destination)))
        # cd 가 실패하면(없는 디렉터리) 셸은 원래 위치에서 다음 줄을 실행한다.
        if destination != "-" and os.path.isdir(new_cwd):
            state["cwd"] = new_cwd
    elif program in SHELLS:
        for position, word in enumerate(words[1:], start=1):
            if re.match(r"^-[A-Za-z]*c[A-Za-z]*$", word) and position + 1 < len(words):
                return analyze(words[position + 1], command_cwd, depth + 1, env)
    elif program == "git":
        return check_git(words, command_cwd, depth, env)
    return []


def analyze(command, cwd, depth=0, inherited_env=None):
    """차단 사유 목록을 돌려준다. 빈 목록이면 허용. inherited_env 는 바깥 명령이 물려준 환경이다."""
    if depth > 3:
        return []
    command = strip_heredoc_bodies(command)
    try:
        tokens = tokenize(command)
    except ValueError:
        if re.search(r"\bgit\b", command) and "commit" in command:
            return ["명령을 해석할 수 없어 git commit 의 훅 우회 여부를 확인하지 못했습니다."]
        return []
    # 물려받은 환경 + 같은 명령 안에서 export 하거나 단독 대입한 변수. ( ) 서브셸 안의 cd·export 는 밖으로 새지 않는다.
    state = {"cwd": cwd, "env": dict(inherited_env or {})}
    scopes = []
    reasons = []
    words = []
    for token in tokens + [Operator(";")]:
        if not isinstance(token, Operator):
            words.append(token)
            continue
        if words:
            # 명령 치환은 그 명령이 실행되기 전에, 그 위치의 경로·환경을 물려받은 서브셸에서 돈다.
            for word in words:
                for inner in word.substitutions:
                    reasons += analyze(inner, state["cwd"], depth + 1, dict(state["env"]))
            reasons += analyze_simple(words, state, depth)
            words = []
        if token == "(":
            scopes.append((state["cwd"], dict(state["env"])))
        elif token == ")" and scopes:
            state["cwd"], state["env"] = scopes.pop()
    return reasons


def main():
    try:
        payload = json.load(sys.stdin)
        tool_input = payload.get("tool_input") or {}
        command = tool_input.get("command") if isinstance(tool_input, dict) else None
        if payload.get("tool_name") in ("apply_patch", "Edit", "Write"):
            return 0
        if isinstance(command, list):
            command = " ".join(shlex.quote(str(part)) for part in command)
        if not isinstance(command, str) or not command.strip():
            return 0
        cwd = payload.get("cwd") or os.getcwd()
        reasons = analyze(command, cwd)
    except Exception as error:  # 가드가 판단하지 못하면 통과시키지 않는다.
        print("[commit-guard] ✗ 가드 실행 오류로 차단합니다: {!r}".format(error), file=sys.stderr)
        return 2
    if reasons:
        for reason in reasons:
            print("[commit-guard] ✗ " + reason, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
