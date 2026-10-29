# Checklists

## PRD checklist (run on the issue)

- [ ] The problem is concrete (not "improve the experience").
- [ ] The goal is observable after delivery.
- [ ] Every acceptance criterion is true or false, measurable or reproducible in a test.
- [ ] There is at least one Given / When / Then scenario per main flow.
- [ ] Out of scope is explicit.
- [ ] Scope added later in comments (design approvals, review notes) is either in the body or explicitly moved out.
- [ ] No technical design that belongs in the spec.

## Spec checklist (run before asking for approval)

- [ ] Every acceptance criterion of the issue maps to at least one FR.
- [ ] The current state cites real files, functions or rules, checked with tools.
- [ ] Every file in "Affected files" exists or is marked Create.
- [ ] Snippets compile against the library versions in the project.
- [ ] "What does not change" lists the adjacent areas at risk, not just the obvious ones.
- [ ] Edge cases cover permission, offline, missing data and duplicate events where relevant.
- [ ] Criteria are true or false; no "works well", "fast", "intuitive".
- [ ] Functional behavior and technical design are in separate sections.
- [ ] Non-functional requirements and rollout appear when the change touches security, data, deploy order or more than one runtime (size L).
- [ ] The spec solves one problem. Anything adjacent became a new issue.
- [ ] Short enough to review in about 10 minutes (size M) or 20 minutes (size L).

## Task checklist

- [ ] Each task is one reviewable change with target files named.
- [ ] Dependencies are explicit and the order matches them.
- [ ] Every FR is covered by at least one task.
- [ ] No documentation-only task.
- [ ] The last task is the e2e verification.
