# How Moonlight Builds Software

The standard every Moonlight project follows, whoever writes the code: a person, an AI agent, or both. Agents read this through the project's `AGENTS.md`; the skills in `skills/` hold the detail.

## 1. Plan before code

- No file changes before an **explicitly approved plan**: scope, affected files, approach. Reading code and researching to build the plan need no approval.
- Size the work first. Small changes get a short plan in the chat; medium and large ones get a spec (`spec-driven-development`).
- The issue is the requirement. Write it with `github-issue-templates` and track it with `github-issue-development`.

## 2. Small, traceable changes

- Trunk-based: a short-lived branch per issue, Conventional Commits, no AI co-author trailers (`git-workflow`).
- One PR per issue, described with `pull-request-description`, always with a manual BDD walkthrough next to the automated checks.
- When a skill and the code disagree, the code wins: fix the skill in the same PR.
- **Language:** issues, PRs and project docs (README, `docs/`, specs and tasks) are written in Brazilian Portuguese (PT-BR). Commit messages are always in English, like code and identifiers. A project may add a second docs language, never replace PT-BR.

## 3. Nothing is done until it is verified

- Run the quality gate before saying "done" or suggesting a commit (`quality-gate-workflow`). Never infer that tests pass: run them.
- Never comment out a failing test or swallow an exception to get a green gate.
- Update the docs (README, architecture notes, project skills) in the same change that makes them stale.

## 4. Review before it leaves the machine

- Two reviews, at different moments:
  1. **Before each commit:** `pair-programming-git-review` on the staged diff, while the work is in progress.
  2. **Before each push:** an independent review of the whole branch with the agent's own command: `/code-review` in Claude Code, `/review` in Codex, or the equivalent in other agents. Push only after its findings are fixed or explicitly accepted.
- Review PRs with inline comments anchored to file and line, in one review, marking blocking findings explicitly and suggesting a fix whenever there is one.

## 5. Code quality

- `coding-principles` applies to every stack; each stack adds its own skill (`flutter-coding-principles`, `python-coding-principles`).
- Self-documenting code: no inline comments, doc comments only on public API.
- Accessibility and localization are part of "done" for any UI (`flutter-accessibility`, `flutter-arb-l10n`).

## 6. Secrets and data

- Secrets live only in `.env` files or a secret manager, never in Git, never in a prompt, never in a skill.
- Keystores, service-account files and signing keys stay out of the repo; CI reads them from repository secrets.
- AI agents work on test data. Client data never goes into a prompt, a fixture or a screenshot committed to a repo.

## 7. Working with AI agents

- The agent follows the same rules as a person: approved plan, branch, gate, review.
- The agent loads the skill for the task before acting. Project skills (`<project>-<topic>`) hold only what is specific to the project and name the shared skill they build on; load both.
- Destructive or outward-facing actions (force push, deleting data, publishing, sending messages, deploying to production) need explicit confirmation every time.
- A lesson learned goes into the right skill or doc right away ("capture this"), not into the chat history.
