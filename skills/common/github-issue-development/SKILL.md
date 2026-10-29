---
name: github-issue-development
description: "Start or finalize work on a GitHub issue tracked via GitHub Projects (v2): sync main, create a branch, discover the project board's Status field and options via gh CLI, move the issue through In Progress/In Review/Done, and clean up assignees after merge. Invoke whenever the user says something like \"let's implement issue #N\", \"start working on issue N\", \"pick up issue N\", \"PR #N was merged\", \"issue #N is done\", or gives an issue number with intent to start or finish coding. Uses discovery commands, not hardcoded IDs, works for any repo/project on first use."
---

# GitHub Issue Development Workflow

Start work on an issue by running three steps in order: sync, branch, move. Finalize it by syncing, moving to Done, and unassigning after the user merges the PR.

## Prerequisites

- `gh` is authenticated and has access to the target repo. Project-board writes (`gh project item-add`/`item-edit`) require the `project` OAuth scope: check `gh auth status`; if `project` isn't listed, run `gh auth refresh -h github.com -s project` (interactive device-code flow) before attempting any board step. This scope requirement is easy to miss because the underlying commands can fail silently or with an unhelpful error instead of a clear scope message.
- The repo tracks issues via a GitHub Projects (v2) board with at least a "Status" field. If the repo uses Jira/Linear/another tracker instead, this skill doesn't apply.
- The working tree is clean, or the user has confirmed they're ready to start fresh work.

## Workflow

### 1. Resolve the issue

```bash
gh issue view <number> --json number,title,state,body,labels,assignees
gh issue edit <number> --add-assignee @me
```

### 2. Sync main branch

```bash
git fetch origin
git switch main
git pull --ff-only origin main
```

Stop and alert the user on merge conflict or pull failure.

### 3. Create a descriptive branch

```bash
git switch -c <type>/<short-slug>
```

Derive `<type>` from the issue's labels/type (adapt to the repo's actual taxonomy):
- `feature`/`enhancement` → `feature`
- `bug` → `fix`
- `improvement`/`refactor` → `refactor`
- `chore`/`docs` → `chore`

Derive `<short-slug>` from the issue title: lowercase, spaces→hyphens, strip non-alphanumerics (keep hyphens), truncate to ~40 chars.

### 4. Discover the project board (first time in a repo)

```bash
gh project list --owner <owner>
```

Add the issue and find its item id:

```bash
gh project item-add <project-number> --owner <owner> --url <issue-url>
gh project item-list <project-number> --owner <owner> --format json | jq '.items[] | select(.content.number==<number>) | .id'
```

Discover the Status field's id and its option ids: **never hardcode these**, they differ per project:

```bash
gh project field-list <project-number> --owner <owner> --format json | jq '.fields[] | select(.name=="Status") | {id, options}'
```

Cache the discovered field id, option ids, and project id in a project-local skill/note after the first discovery, so subsequent runs skip straight to step 5 instead of re-discovering every time.

### 5. Move the issue to In Progress

```bash
gh project item-edit \
  --id <item-id> \
  --field-id <status-field-id> \
  --single-select-option-id <in-progress-option-id> \
  --project-id <project-id>
```

Verify: `gh issue view <number> --json title,projectItems` should show `"status":{"name":"In progress"}` (or the repo's equivalent column name).

### 6. Read relevant skills

Check the project's skill index (`AGENTS.md`, `CLAUDE.md`, or equivalent) for skills relevant to the issue's implementation area before writing code.

### 7. Move to In Review when a PR is opened

```bash
gh project item-edit --id <item-id> --field-id <status-field-id> --single-select-option-id <in-review-option-id> --project-id <project-id>
```

> [!CAUTION]
> Never run `gh pr merge` or any automated merge. Provide the PR link and let the user review and merge manually on GitHub.

### 8. Finalize after the user merges the PR (mandatory: don't skip)

1. Sync local `main`:
   ```bash
   git switch main
   git pull --ff-only origin main
   ```
2. Confirm/set the issue's Status to Done:
   ```bash
   gh project item-list <project-number> --owner <owner> --format json | jq '.items[] | select(.content.number==<number>) | {status}'
   gh project item-edit --id <item-id> --field-id <status-field-id> --single-select-option-id <done-option-id> --project-id <project-id>
   ```
3. Unassign:
   ```bash
   gh issue edit <number> --remove-assignee @me
   ```
4. Sweep for stale assignees on other Done items (cheap to run every time, catches drift):
   ```bash
   gh project item-list <project-number> --owner <owner> --format json | \
     jq -r '.items[] | select(.status == "Done") | .content.number' | \
     while read num; do
       assignees=$(gh issue view "$num" --json assignees --jq '[.assignees[].login] | join(",")')
       if [ -n "$assignees" ]; then
         for user in $(echo "$assignees" | tr "," " "); do
           gh issue edit "$num" --remove-assignee "$user"
         done
       fi
     done
   ```

## Output

Report back: issue number/title, the status transition applied, and confirmation of local branch sync.
