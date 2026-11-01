---
name: subagent-delegation
description: "Coordinator/executor pattern for coding agents: the main model plans, delegates operational work to cheaper sub-agents (Haiku in Claude Code) and reviews what comes back. Covers when to delegate and when not to, how to write a self-contained brief, mandatory review, what never goes to an executor, and the Claude Code setup (agent file with model: haiku, CLAUDE_CODE_SUBAGENT_MODEL). Invoke when deciding whether to spawn a sub-agent, writing a delegation brief, or setting up executor agents on a machine or project."
---

# Subagent Delegation

Based on the video "O NOVO JEITO de usar o Claude Code: o Opus vira o chefe (e o Haiku trabalha)". The video measured 1.3x to 1.6x fewer tokens than Opus alone, with similar quality; total time went up on tasks where the coordinator had to send work back many times. The sections on cold starts, small tasks and decisions are additions from Moonlight's own use.

## Roles

| Role | Model | Does | Never does |
|---|---|---|---|
| Coordinator | Main session (Opus) | Understands the request, plans, splits work, writes briefs, reviews results, talks to the user | Bulk operational work it could brief out |
| Executor | Sub-agent (Haiku) | Writes scoped code, scaffolds files, reads and summarizes many files, runs builds and tests, reports back | Architecture decisions, plan changes, anything destructive or outward-facing |

## When to delegate

Delegate when the work is operational, well defined and big enough to pay for a fresh agent:

- Reading or searching many files when only the conclusion matters.
- Scaffolding or mechanical edits across several files, once the design is decided.
- Running builds, test suites or linters and summarizing failures.
- Independent subtasks that can run in parallel (one executor per subtask, sent in the same turn).

Do it yourself when:

- The task takes a few reads or edits. A sub-agent starts cold; below that size the brief and the review cost more than the work.
- The next step depends on judgment: a design choice, an ambiguous requirement, a trade-off the user must hear about.
- The work touches secrets, production, git history, or sends anything outside the machine.

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
- **Coordinator instructions:** add to the project's `AGENTS.md` (or the user's global `CLAUDE.md`) a line telling the main agent to load this skill and use the `executor` agent for operational work.
- Keep the main session on the strong model (`"model": "opus"` or `/model`).

Other agents (Codex, Gemini CLI, Cursor) follow the same roles with their own sub-agent mechanism; only the setup differs.
