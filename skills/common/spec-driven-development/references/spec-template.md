# SPEC: <Feature title>

Sections marked `lite` are the only ones required for a size M spec. Size L fills every section that applies; delete the ones that do not, never leave placeholders.

**Issue:** <link> · **Requirement:** <id, if the project uses them> · **Size:** <M | L> · **Status:** <draft | approved | shipped>

## 1. Context and problem `lite`

<Current state and why it matters now, in at most 3 short paragraphs. Link the issue instead of repeating it.>

## 2. Scope `lite`

### 2.1 What changes

| Area | Today | After |
|---|---|---|
| `<file or component>` | <current behavior> | <expected behavior> |

### 2.2 What does not change

- <adjacent behavior, file or flow the implementation must leave alone>
- <scope that moved to another issue: #N>

### 2.3 Constraints and assumptions

- <library version, platform limit, decision already taken, deadline>

## 3. Functional requirements `lite`

| ID | Requirement | Covers |
|---|---|---|
| FR-01 | <The system must...> | <issue acceptance criterion> |

## 4. Scenarios and edge cases `lite`

- **Main:** Given <state>, when <action>, then <observable result>.
- **Edge:** <permission denied, offline, missing data, duplicate event, partial failure...>

## 5. Solution design

### 5.1 Overview

<How the parts fit, in a few lines.>

### 5.2 <Module or layer>

<Change with references to real files, functions and approximate lines.>

### 5.3 Contracts and data

```text
<Compilable snippet in the project's language: payloads, schemas, signatures, rules>
```

## 6. Flow

<Diagram of the new data or user flow, in the format the project skill requires.>

## 7. Alternatives considered

| Alternative | Why not |
|---|---|
| <option> | <trade-off that ruled it out> |

## 8. Affected files `lite`

| File | Type | Change |
|---|---|---|
| `<path>` | Modify | <short description> |
| `<path>` | Create | <short description> |

## 9. Non-functional requirements

| Category | Requirement | How to check |
|---|---|---|
| Security / privacy | | |
| Reliability | | |
| Accessibility | | |
| Observability | | |

## 10. Rollout

<Flag, migration, backward compatibility, deploy order across app and backend, fallback.>

## 11. Validation and acceptance criteria `lite`

- Unit / widget: <scope>
- Integration / backend: <scope>
- e2e or manual: <scenarios from section 4>

- [ ] <true-or-false criterion>
- [ ] Error and fallback cases from section 4 behave as described.
- [ ] Analyzer, build and the relevant tests pass with no regression.

## 12. Open questions

- <pending decision, owner>
