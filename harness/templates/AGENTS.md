# AGENTS.md - Agent Guidelines for {{PROJECT_NAME}}

This project follows the Moonlight harness: https://github.com/moonlight-mobile-solutions/moonlight-harness. Read [`harness/principles.md`](https://github.com/moonlight-mobile-solutions/moonlight-harness/blob/main/harness/principles.md) once; the rules below only add what is specific to this project.

## Project Overview

TODO: what the product is, who uses it, the main technical choices (state management, routing, persistence, hosting).

## Rules

Standing rules live in [`.agents/rules/`](.agents/rules/). Read them at the start of every task.

- Plan approved before any code change.
- Branch per issue, Conventional Commits, no AI co-author trailers.
- Quality gate before "done", code review before push.
- Issues, PRs and docs in PT-BR; commit messages, code and identifiers in English.

## Skills

Shared skills come from the harness (stacks: {{STACKS}}). Project skills live in `.agents/skills/`, hold only what is specific to this project, and name the shared skill they build on. Load both.

| I need to... | Project skill | Shared skill it follows |
|---|---|---|
| Plan a medium or large change | none | `spec-driven-development` |
| Write code | none | `coding-principles` + stack skill |
| Write an issue | none | `github-issue-templates` |
| Start or finish an issue | none | `github-issue-development` |
| Branch, commit | none | `git-workflow` |
| Run the gate before done/commit | none | `quality-gate-workflow` |
| Review staged changes | none | `pair-programming-git-review` |
| Write a PR description | none | `pull-request-description` |

When a skill and the code disagree, the code wins: fix the skill in the same PR.

## Key Commands

```bash
# TODO: install, run, analyze, format, test
```

## Code Style

TODO: imports, naming, line length, limits the analyzer enforces.
