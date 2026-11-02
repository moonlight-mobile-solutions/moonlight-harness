---
name: git-workflow
description: "Trunk-based git workflow: Conventional Commits format, branch naming, when to commit, fixup/autosquash for revising an existing branch commit, no AI co-author trailers, what never to commit, and typical pre-commit/pre-push hook tiers. Invoke when creating a branch, writing a commit message, or revising an already-committed change on a feature branch."
---

# Git Workflow & Commit Guidelines

## Goal

Clean, standardized git history: Conventional Commits syntax, behavior-focused messages, strict staging discipline, fixup/autosquash for revisions, no automated co-author trailers unless requested.

## Branching Strategy

Simplified trunk-based: one long-lived `main`, all feature branches originate from it and merge back via PR.

- Never push directly to `main`: even for docs/config changes, branch + PR.
- Naming: `feature/{task-description}`, `fix/{task-description}`, `chore/{task-description}`, etc., matching the change's Conventional Commit type.
- After a PR merges, delete local and remote branches:
  ```bash
  git branch -d <branch-name>
  git push origin --delete <branch-name>          # if not auto-deleted
  git branch --merged main | grep -v "main" | grep -v "\*" | xargs -r git branch -d
  ```

## When to Commit

- Only when explicitly asked, or when finalizing a planned task slice.
- Format code before committing (run the project's formatter).
- One commit = one logical change (a feature slice, a bugfix, or the tests for that same change).
- Stage only the files belonging to that change.

## Conventional Commits Format

```text
{type}({scope}): {description} (#issue-number)

Optional body describing delivered behavior.
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

**Title guidelines:**
- Always in English, title and body, even when the issue, PR and docs are in PT-BR (`harness/principles.md`).
- Focus on user-visible or architectural outcome (component/scope + behavior), e.g. `feat(customers): add pagination and loading state to customer list (#23)`.
- Under ~72 characters where possible.
- Don't reference the review process (~~`fix: address PR feedback`~~), list modified files (~~`refactor: update customers_cubit and page`~~), or use a vague title (~~`fix`~~, ~~`wip`~~).

## Creating Commits

Use a heredoc for multi-line messages:

```bash
git add <relevant-files>
git commit -m "$(cat <<'EOF'
feat(customers): add pagination to customer list (#23)

Add customer list pagination in CustomersCubit.
Update CustomersRemoteDataSource to support offset and limit query parameters.
EOF
)"
```

**No AI co-author trailers** unless the user asks for one: commits list only the human author. If a hook or environment injects one anyway, rewrite the commit with `git commit-tree` + `git reset --hard` to strip it without changing the tree content.

## What NOT to Commit

- AI/tool co-author trailers, unless requested.
- Local feature-flag overrides meant only for testing.
- Unrelated lockfile/manifest churn.
- Secrets, credentials, `.env` files.
- Bulk-generated files unless the task specifically requires regenerating them.
- Editor-specific configs (`.vscode/`, `.idea/`, `*.iml`): these configure local IDE behavior and belong in `.gitignore`; if already tracked, remove with `git rm --cached`. Exception: a genuinely shared workspace-wide setting the whole team needs may be committed deliberately, by team consensus.

## Fixup Commits and Autosquash

To revise a change already committed earlier in the branch's history:

```bash
git add <relevant-files>
git commit --fixup <commit-hash-or-HEAD~N>
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base-commit-or-HEAD~N>
```

Fixups can be applied immediately or accumulated across iterations: run `--autosquash` once at the end to clean up history before pushing.

**Fixup rules by change type:**
- Code changes (`feat`/`fix`/`refactor`): fixup into the target feature commit.
- Docs/skills changes: **separate, independent commits**: never fixed up into a code commit, since they're logically independent of the code diff.

```bash
# Code change → fixup
git commit --fixup <feature-commit-hash>

# Docs/skills change → separate commit, no fixup
git commit -m "docs: ..."
```

## Amend and Push

- `git commit --amend` only when the user requests it, or a hook auto-fixed files on an unpushed commit.
- `git push --force-with-lease` only when explicitly requested, or right after a rebase/autosquash the user asked for.

## Typical Pre-Commit / Pre-Push Hook Tiers

Scope checks to the changed area of the repo (e.g. only run a package's checks if that package's files changed) rather than the whole monorepo on every commit:

- **Pre-commit**: static analysis, formatter, tests with coverage, for the touched scope.
- **Pre-push**: full test suite for the touched scope.
