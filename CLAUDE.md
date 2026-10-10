# CLAUDE.md

공통 지침은 AGENTS.md 에 있다. 이 파일에는 Claude Code 에만 해당하는 사항만 쓴다.

@AGENTS.md

## Claude Code 전용

- **훅:** `.claude/settings.json` 이 모든 Bash 호출 전에 `tool/agent_commit_guard.py` 를 실행한다. 훅을 우회하는
  `git commit` 이나 Git 훅이 등록되지 않은 트리로의 커밋을 차단한다(exit 2). 게이트 자체는 실행하지 않는다.
  커밋 시 Git pre-commit 훅이 게이트를 실행하므로 같은 검사가 두 번 돌지 않게 하기 위해서다.
- **교차 검증:** Claude Code 가 구현했다면 검증은 Codex 가 한다: `bash tool/cross_verify.sh codex <역할>`.
- **서브에이전트:** `verifier`, `code-reviewer`, `mutation-verifier` (`.claude/agents/`). 구현 중 빠르게 확인할 때
  쓰며, 교차 검증을 대신하지 않는다. `mutation-verifier` 는 `tool/verify_copy.sh` 로 만든 복제본에서만 파일을 바꾼다.
- **worktree:** Claude Code 가 만드는 worktree 에는 `.worktreeinclude` 에 적힌 secret 이 복사된다.
  worktree 는 HEAD 기준이라 커밋되지 않은 변경은 들어가지 않는다. 그런 변경을 검증할 때는 `tool/verify_copy.sh` 를 쓴다.
