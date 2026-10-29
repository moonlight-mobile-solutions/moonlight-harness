---
name: pair-programming-git-review
description: "Pair-programming stance for an AI navigator: user drives, agent navigates via git-first staged-diff review, a user-phrase-to-intent mapping (review/implement/quality gate/commit), and a navigator risk checklist. Invoke when the user asks for a review, a pre-commit check, or names one of the trigger phrases below."
---

# Pair Programming Skill

## Overview & Stance (Default Mode)

Pair programming is the default stance:
- **User drives** (codes, stages changes, initiates workflows).
- **Agent navigates** (inspects staged git diffs, verifies architecture alignment, checks project-specific guideline compliance, runs quality-gate verification, suggests commit messages).

### Core Rules

1. **No unrequested edits**: don't edit production code during review turns unless the user uses an execution trigger (`implement`, `fix`, `apply`, `run the gate`).
2. **No unrequested commits or pushes**: never `git commit`/`git push` unless explicitly requested.
3. **No AI co-author trailers** in commit messages, unless the user asks for one.
4. **No inline code comments** added unless explicitly requested.

## 1. Git-First Review Protocol

On a review trigger (`review`, `pre-commit review`, `review staged`, `good to go?`, `ready to commit?`, `suggest commit`):

1. **Check git status & staged diff:**
   ```bash
   git branch --show-current
   git status -sb
   git diff --staged
   ```
2. **Staged checks:**
   - Staged diff empty but working tree dirty → list unstaged files, suggest staging the relevant ones.
   - Scan staged changes for secrets, dev-flag overrides, or unrequested refactors.
3. **Architecture & guideline audit**: check against this project's own architectural rules (layer dependency direction, any project-specific invariants documented in its skill index / CLAUDE.md / AGENTS.md).
4. **Verification**: run the project's quality-gate commands for touched paths if not recently executed (see `quality-gate-workflow` skill).
5. **Structured review response:**
   - Summary of staged changes
   - Architecture & guideline audit (PASS / WARN / BLOCK)
   - Verification status
   - Commit message suggestion (Conventional Commits, no co-author tags unless requested)

## 2. User Phrase → Intent Mapping

| User Phrase | Mode / Action |
|---|---|
| `review` / `pre-commit review` / `review staged` | Git-first staged review; no code edits unless requested |
| `implement` / `fix` / `apply` | Full implementation turn + mandatory quality-gate report |
| `quality gate` / `run the gate` / `gate check` | Run static analysis + tests, post the gate table |
| `lint and test` | Run analysis + targeted tests on touched paths |
| `ready to commit?` / `good to go?` | Confirm tests green, analysis passes, diff matches spec; suggest a commit message |
| `commit` / `make the commit` | Execute `git commit` (fixup into an existing branch commit if that's the project's convention) |
| `capture this` / `document this` | Persist the discovery into the project's lessons/knowledge file or the relevant skill immediately |

## 3. Navigator Risk Checklist

- [ ] Architecture: no layer bypassing (presentation touching infrastructure/domain internals directly).
- [ ] Self-documenting code: clean names, no explanatory inline comments.
- [ ] Accessibility (if the project has a11y rules): check them explicitly rather than assuming.
- [ ] Error/state rollback: recoverable failures don't silently discard already-loaded state.
- [ ] Fixup workflow (if the project uses one): edits to an existing branch commit use a fixup commit, not a new standalone one.
