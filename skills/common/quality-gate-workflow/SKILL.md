---
name: quality-gate-workflow
description: "Mandatory pre-completion verification workflow: an intent card for non-trivial tasks, tiered verification (static analysis, tests, codegen, formatting), a structured PASS/FAIL report table, and a user-phrase-to-action mapping (\"quality gate\", \"ready to commit?\", \"implement\"). Invoke before claiming any implementation or fix turn done, or before suggesting a commit."
---

# Quality Gate Workflow

## Overview

No task is "done," and no code is suggested for commit, without passing every applicable verification tier for the project's stack. Never infer test/analysis status without actually running the commands.

## 1. Intent Card (Phase 0: non-trivial tasks)

Before writing code for a non-trivial request, establish intent:

| Check | Question |
|---|---|
| **Goal** | What is the single user-visible outcome? |
| **Scope** | What is explicitly out of scope? |
| **Constraints** | What project-specific invariants apply (safety rules, feature flags, accessibility, no-comments policy, etc.)? |
| **Proof** | What are the exact commands that will verify this (analyzer, test runner, ...)? |
| **Ambiguity** | Any unresolved design decision before writing code? |

## 2. Verification Tiers (Phase 3: mandatory)

Adapt the concrete commands to the project's stack (e.g. `flutter analyze`/`pytest`/`eslint`/`go test`); the tiers themselves are what matters:

- **Tier A: Static analysis**, mandatory whenever source is modified.
- **Tier B: Automated unit/widget/integration tests**, mandatory whenever behavior changed. If the project has an accessibility-guideline test helper, run it as part of this tier.
- **Tier C: Code generation**, mandatory whenever a change affects generated code (DI registration, serialization, immutable-state codegen, etc.).
- **Tier D: Formatting**, mandatory before commit.

Default commands per stack (the project's `AGENTS.md` wins when it lists its own):

| Stack | Tier A | Tier B | Tier C | Tier D |
|---|---|---|---|---|
| Flutter | `flutter analyze` | `flutter test` | `dart run build_runner build -d` | `dart format .` |
| Python | `ruff check .` | `pytest` | n/a | `ruff format --check .` |

## 3. Required Quality Gate Report

Every implementation/fix turn outputs this table before claiming completion:

```markdown
### Quality Gate Report
| Gate | Command | Result |
|------|---------|--------|
| Static Analysis | `<analyzer command>` | ✅ Pass / ❌ Fail |
| Formatting | `<formatter command>` | ✅ Pass / ❌ Fail |
| Tests | `<test command>` | ✅ Pass / ❌ Fail |
| Accessibility (if applicable) | `<a11y check>` | ✅ Pass / ❌ Fail |
| Code Generation (if applicable) | `<codegen command>` | N/A / ✅ Pass |
| **Verdict** | | **PASS / FAIL** |
```

If any tier fails, fix the underlying issue before completing the turn: never comment out a failing test or swallow an exception to force a pass.

## 4. User Phrase → Action Mapping

| User request | Action |
|---|---|
| `quality gate` / `run the gate` / `gate check` | Run Tier A + B, post the report table |
| `lint and test` | Run static analysis + targeted tests immediately |
| `implement` / `fix` / `apply` | Full implementation + Tier A/B verification + report table |
| `ready to commit?` / `good to go?` | Verify tests green, diff matches spec, confirm gate PASS |
| `capture this` | Document the discovery/rule in the relevant skill or doc immediately |
