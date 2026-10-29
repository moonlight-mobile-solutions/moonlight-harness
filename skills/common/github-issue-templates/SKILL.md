---
name: github-issue-templates
description: "Writing structured GitHub issues: native Issue Type usage (Feature/Bug/Enhancement/Task) instead of labels, BDD-format test scenarios, mandatory acceptance criteria and priority justification, and a template per issue type with a worked example. Invoke when creating a new GitHub issue for a feature, bug, or improvement."
---

# GitHub Issue Templates Skill

## Rules

- **No emojis** anywhere in the title or body.
- **Titles are concise and specific**: describe the problem/feature in one sentence, skip verbs like "fix"/"add" unless they clarify meaning.
- **Plain English**, present tense, active voice.
- **Use GitHub's native Issue Type** (`Feature`, `Bug`, `Enhancement`, `Task`) via `--type` at creation time: don't rely on labels for type; reserve labels for area/priority tagging.
- **Acceptance criteria are mandatory**: they define when the issue is done.
- **Priority is mandatory** in the description (`P0 - Critical` / `P1 - Medium` / `P2 - Low`, or the repo's equivalent scale) with a brief justification.
- **Test scenarios in BDD (Given/When/Then)** format: context, action, outcome.

## Issue Types

| Type | Native definition | When to use |
|---|---|---|
| `Feature` | A request, idea, or new functionality | A capability that doesn't exist yet |
| `Bug` | An unexpected problem or behavior | A behavior deviating from the expected outcome |
| `Enhancement` | An improvement to existing functionality | Refactor, performance, UX polish, code quality on existing functionality |
| `Task` | A specific piece of work | Dependency updates, CI config, tooling, docs, chore-style work |

```bash
gh issue create --title "<concise, specific title>" --type "Bug" --label "priority:p1-high,backend" --body-file <path-to-body.md>
```

If `--type` reports the type doesn't exist, list what's actually provisioned before guessing:

```bash
gh api graphql -f query='query { organization(login: "<org>") { issueTypes(first: 20) { nodes { name description } } } }'
```

Creating a *new* org-level issue type changes shared, org-wide configuration: confirm with the user first, and check whether an existing type already covers the need.

## Feature Issue Template

```markdown
## Description

<One paragraph: what this feature is, why it's needed, the user need or business requirement it addresses.>

## Acceptance criteria

- [ ] <Criterion 1: observable, testable behaviour>
- [ ] <Criterion 2>

## Test scenarios

**Unit**
- Given <precondition>, When <action>, Then <expected result>.

**Widget**
- Given <initial rendering>, When <interaction>, Then <expected rendering/trigger>.

**Integration**
- Given <starting screen>, When <end-to-end flow>, Then <expected final state>.

## Priority
**<P0/P1/P2>** - <Brief justification>

## Out of scope

<Explicitly excluded scope, if any.>
```

## Bug Issue Template

```markdown
## Description

<What happens, where, and the impact.>

## Steps to reproduce

1. <Step 1>
2. Observe: <what actually happens>

## Expected behaviour

<What should happen.>

## Actual behaviour

<What currently happens: be specific, include error messages/wrong values.>

## Environment

- Device / OS version / app version, as applicable

## Priority
**<P0/P1/P2>** - <Brief justification>

## Acceptance criteria

- [ ] The bug no longer occurs under the stated reproduction steps.
```

## Enhancement Issue Template

```markdown
## Description

<What currently exists, its limitation, and the proposed improvement.>

## Motivation

<Why this matters: performance, DX, UX, tech debt.>

## Acceptance criteria

- [ ] <Criterion 1>

## Priority
**<P0/P1/P2>** - <Brief justification>
```

## Task (Chore) Issue Template

```markdown
## Description

<One sentence describing the task.>

## Motivation

<Why: security fix, deprecated API, tooling improvement, etc.>

## Priority
**<P0/P1/P2>** - <Brief justification>

## Acceptance criteria

- [ ] <Criterion 1>
```

## Worked Example

```bash
gh issue create \
  --title "Category filter chips on the product catalog screen" \
  --type "Feature" \
  --label "priority:p1-high,frontend" \
  --body-file feature_body.md
```

```markdown
## Description

Users currently cannot filter items by category in the catalog view. Adding category chips allows quickly locating items without scrolling the full catalog.

## Acceptance criteria

- [ ] Category filter chips are visible at the top of the catalog screen.
- [ ] Selecting a category filters the list to that category.
- [ ] Selecting "All" restores the full list.
- [ ] Unit tests cover the category filter logic in the catalog cubit.

## Test scenarios

**Unit**
- Given a loaded catalog, When `applyCategoryFilter(categoryId)` is called, Then the state's filtered list contains only matching items.

**Widget**
- Given the catalog page rendered with items, When a category chip is tapped, Then only matching cards are rendered.

## Priority
**P1 - Medium** - Speeds up browsing but doesn't block the core flow.

## Out of scope

- Multi-category select (single active filter only).
```
