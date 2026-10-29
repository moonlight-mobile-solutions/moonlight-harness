---
name: spec-driven-development
description: "Spec-driven development (SDD) workflow for AI-assisted coding: size the work first (small changes skip the spec), treat the tracker issue as the PRD, explore the real code, write a spec anchored in real files with an explicit \"what does not change\" fence, self-review it against a checklist, get explicit approval, then split it into dependency-ordered task files ending in an e2e verification task, and keep the spec in sync with the code until merge. Invoke when starting a medium or large feature or a non-trivial fix, when the user asks for a spec, SDD or a task breakdown, or when a plan would otherwise live only in the chat."
---

# Spec-Driven Development

Adapted from [jjeanjacques10/skills `spec-driven-build`](https://github.com/jjeanjacques10/skills/tree/main/skills/development/spec-driven-build) (MIT, Jean Jacques Barros), with the critiques from [Martin Fowler's review of SDD tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) folded in: match the process to the size of the work, keep the markdown short enough to review, and keep the spec anchored to the code instead of writing it once and abandoning it.

Project skills (`<project>-spec`) layer on top of this one and define the folder, language, diagram format and how the e2e task is run. Load both.

## Size the work first

| Size | Examples | What to produce |
|---|---|---|
| **S** | bug fix, copy change, one-file tweak, dependency bump | No spec. Issue + plan approved in the chat. |
| **M** | one feature slice across 2 to 3 layers, design already approved | Lite spec (sections marked `lite` in the template) + tasks. |
| **L** | new capability across app, backend and data, migrations, security-sensitive flows | Full spec + tasks. |

Say the chosen size and why in one line before writing anything. When in doubt between two sizes, pick the smaller one: a spec that costs more to polish than the ambiguity it removes is too heavy. If one spec starts solving two problems, split it into two specs.

## Phases

Each phase ends at a gate. Never skip a gate, never advance without the user's explicit "ok".

### Phase 0: The issue is the PRD

The tracker issue holds the product side (problem, user stories, acceptance criteria, scenarios, out of scope). Do not copy it into the spec folder: two copies drift. Read the issue and all its comments, then check it against the PRD checklist in [references/checklists.md](references/checklists.md).

- Gaps (no out of scope, vague criteria, scope added in comments but not in the body) are listed back to the user with a proposed fix. The user decides; update the issue body only after they agree.
- Confirm the feature folder name in kebab-case (short, descriptive).
- Ask only what the issue and the code cannot answer.

**Gate:** the issue passes the PRD checklist and the user confirmed the folder name.

### Phase 1: Explore, then write the spec

1. Read the project context the repo already has (`AGENTS.md`, rules, architecture docs). Do not create a separate project-context file when these exist.
2. Explore the real code with tools before writing a line: find the files, classes, functions, routes, rules and tests the change touches. Note versions of the libraries involved.
3. Write `SPEC.md` from [references/spec-template.md](references/spec-template.md). Every acceptance criterion in the issue maps to at least one functional requirement (`FR-NN`) in the spec.

Rules that make the spec useful:

- **Reference real code.** "Add validation to the form" is not a spec. "Add validation in `handleSubmit` in `src/routes/login.tsx` (~line 83) using the existing schema in `src/lib/schemas.ts`" is.
- **"What does not change" is an electric fence.** List the adjacent things the implementation must not refactor, rename, move or redesign. This is the section that cuts the most rework.
- **Snippets compile.** Pseudocode leaves room for guessing. Show contracts, payloads, signatures and data shapes as real code in the project's language.
- **Criteria are true or false.** "Works well" is not a criterion. "The client receives one push titled 'Agendamento confirmado' within 1 minute of the professional accepting" is.
- **Functional and technical stay separate.** Behavior goes in requirements and scenarios; how it is built goes in the design section.
- **Alternatives only when the choice is not obvious.** Record what was rejected and why, in a short table.
- **No parallel refactors.** Anything adjacent that should also change becomes a new issue, named in "What does not change".

### Phase 2: Self-review and approval

1. Run the spec checklist in [references/checklists.md](references/checklists.md) and fix what fails before showing anything.
2. Confirm every file in "Affected files" exists (or is marked new) and every snippet matches the library versions in the project.
3. Present a 3 to 5 line summary, the checklist result (pass count and anything left open) and the open questions.
4. Ask: "A spec está certa? Posso gerar as tasks?" (in the user's language).

**Gate:** explicit approval. Iterate until then.

### Phase 3: Tasks

Only after approval, create one file per task in `tasks/` from [references/task-template.md](references/task-template.md):

- Name: `TASK-N-<kebab-description>.md`, numbered in execution order.
- Each task is one reviewable change (roughly one commit), names its target files, the spec section it implements, and its dependencies.
- Modifying existing code: show before and after.
- Documentation updates go inside the acceptance criteria of the task that changes the behavior, not as separate tasks.
- The last task is always `TASK-N-e2e-verification.md`: run the scenarios from the issue end to end, the way the project skill says.

### Phase 4: Execution map

End with the map, so the order and the parallel work are visible:

```text
SPEC:  <folder>/SPEC.md
Tasks: <folder>/tasks/
  TASK-1  Store the FCM token per user        [independent]
  TASK-2  Cloud Function on booking change    [after TASK-1]
  TASK-3  Open the booking from a push        [after TASK-1, parallel with TASK-2]
  TASK-4  e2e verification                    [last]
Parallel: TASK-2 and TASK-3.
```

## During implementation

- Work one task at a time. Tick its acceptance criteria in the task file as part of the same commit.
- **The spec follows the code.** When implementation or review changes behavior, scope or a contract, update `SPEC.md` in the same commit or PR. The spec in the merged PR describes what shipped, not what was planned.
- A discovery that does not fit the spec goes to the user before the code: either the spec changes (and they approve the delta) or it becomes a new issue.
- The spec and tasks are committed with the code, on the same branch, so review sees intent and implementation side by side.

## After merge

Keep the folder: it is the decision record for the feature. Do not edit it for later features; a later change to the same area gets its own spec that links to the old one.
