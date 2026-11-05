---
name: subagent-delegation
description: "Coordinator/executor pattern for coding agents: the main model plans, delegates operational work to cheaper sub-agents (Haiku in Claude Code) by default and reviews what comes back. Covers the size thresholds for delegating, how to write a self-contained brief, mandatory review, what stays with the strong model, and the Claude Code setup (agent file with model: haiku, reminder hook, CLAUDE_CODE_SUBAGENT_MODEL). Invoke before reading many files, running a full test suite or build, or repeating a mechanical edit across files, and when writing a delegation brief or setting up executor agents on a machine or project."
---

# Subagent Delegation

Based on the video "O NOVO JEITO de usar o Claude Code: o Opus vira o chefe (e o Haiku trabalha)". The video measured 1.3x to 1.6x fewer tokens than Opus alone, with similar quality; total time went up on tasks where the coordinator had to send work back many times. The sections on cold starts, small tasks and decisions are additions from Moonlight's own use.

## Roles

| Role | Model | Does | Never does |
|---|---|---|---|
| Coordinator | Main session, strongest model (Opus in Claude Code, Gemini Argon in Antigravity) | Understands the request, plans, splits work, writes briefs, reviews results, talks to the user | Bulk operational work it could brief out |
| Executor | Sub-agent, cheaper model (Haiku in Claude Code, Flash in Antigravity) | Writes scoped code, scaffolds files, reads and summarizes many files, runs builds and tests, reports back | Architecture decisions, plan changes, anything destructive or outward-facing |

## When to delegate

Delegating is the default for operational work. Doing it in the main session is the exception and needs one of the reasons below.

| Delegate to the executor | Do it yourself |
|---|---|
| Reading or searching more than 3 files when only the conclusion matters | Up to 3 files, or one quick command. A sub-agent starts cold; below that size the brief and the review cost more than the work |
| A full test suite, build or linter run, with failures summarized | A single test or check whose output decides your next step |
| The same mechanical edit in 3 or more files, once the design is decided | Edits that need a judgment call on each file |
| Independent subtasks that can run in parallel (one executor per subtask, sent in the same turn) | Work where the next step depends on the previous result |

Tie-breaks: work below a threshold stays in the main session. A single `grep` counts as one quick command, however many files it scans. A full suite is delegated even when its result decides the next step. Reading that a decision depends on stays with the coordinator, whatever its size.

## Strong model only

These stay with the coordinator, or with sub-agents on the strong model. Never send them to the executor:

- **Review:** code review (`/code-review`), security review and audit, and the review of what an executor returns.
- **Planning:** plans, specs, design choices, ambiguous requirements and trade-offs the user must hear about.
- **Money:** tax and financial calculations, and checking them. The executor may gather the files; the numbers stay with the coordinator.
- **Risk:** secrets, production, git history, and anything sent outside the machine.

## Writing the brief

The executor sees none of the conversation. A thin brief makes it rebuild context, and the savings disappear.

Every brief states:

1. **Goal:** one sentence with the outcome.
2. **Context:** the decisions already made and why, the files and functions involved (exact paths), the conventions and skills to load.
3. **Scope:** what to change and what to leave alone.
4. **Done when:** the check that proves it (command to run, expected output).
5. **Report:** what to return (changed files, command output, open questions), kept short.

## Reviewing the result

- Read the diff or the evidence, not only the summary. Executors on smaller models make more isolated mistakes.
- Send back with a specific correction when something is off; after two rounds on the same issue, do it yourself.
- The project rules still apply to delegated work: approved plan, quality gate, review before push. The coordinator owns the result.

## Claude Code setup

Prefer a dedicated agent file over a global switch:

- **Agent file (recommended):** copy [`executor.md`](executor.md) to `~/.claude/agents/executor.md` (every project) or `.claude/agents/executor.md` (one project). Its `model: haiku` applies only to that agent, so review, planning and audit sub-agents keep the stronger model.
- **Global switch:** `"env": { "CLAUDE_CODE_SUBAGENT_MODEL": "haiku" }` in `settings.json` forces every sub-agent to Haiku, including code review and security audit agents. Use it only on a machine where cost matters more than review depth.
- **Coordinator instructions:** add to the project's `AGENTS.md` (or the user's global `CLAUDE.md`) a rule that makes delegation the default, not just allowed: Claude Code tells the main agent not to spawn sub-agents unless the user asks, so a rule that only authorizes delegation rarely fires. State the thresholds and that this is the user's standing request.
- **Reminder hook:** a skill only applies once loaded, so point a `UserPromptSubmit` hook at [`delegation-reminder.sh`](delegation-reminder.sh) ([`delegation-reminder.ps1`](delegation-reminder.ps1) on Windows). It repeats the thresholds on every prompt and costs about 60 words each time. It reminds, it does not enforce: the model still decides. It assumes the `executor` agent is installed (first bullet); `scripts/install.sh` does not install it.

  ```json
  { "hooks": { "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "sh /path/to/subagent-delegation/delegation-reminder.sh" }] }] } }
  ```

  On Windows, the command is `powershell -ExecutionPolicy Bypass -File C:\path\to\subagent-delegation\delegation-reminder.ps1`.

- **Strong-model skills:** state it in the skill's body with a "Strong model only" line, not with `model: opus` in the frontmatter. That field lasts only until the end of the turn, can replace a stronger session model, and means nothing to other agents that read the same skill. Bundled skills such as `/code-review` document no model override: leaving the global switch off is what keeps them away from Haiku.
- Keep the main session on the strong model (`"model": "opus"` or `/model`).

## Antigravity setup

- **Agent file:** copy [`executor-antigravity.md`](executor-antigravity.md) to `~/.gemini/config/agents/executor.md` (every project) or `.agents/agents/executor.md` (one project). The `model` field takes a tier, not a model ID: `flash` for the executor. `mainAgent: false` keeps it out of the model picker, and `commandExecutionPolicy: sandbox` runs its commands in the sandbox.
- **Tool names differ from Claude Code** (`view_file`, `grep_search`, `replace_file_content`, `run_command`...). A misspelled name in `tools` can hang the sub-agent.
- **Coordinator:** pick Gemini Argon (or Claude Opus) in the conversation's model picker; it is not set in any agent file.
- **Coordinator instructions:** Antigravity reads `~/.gemini/AGENTS.md` (global) and the project's `AGENTS.md`, not `CLAUDE.md`. Put the delegation rule there.
- Delegation shows up in the Subagents pane of the auxiliary panel.

Other agents (Codex, Gemini CLI, Cursor) follow the same roles with their own sub-agent mechanism; only the setup differs.
