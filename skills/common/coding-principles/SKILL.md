---
name: coding-principles
description: "Stack-agnostic coding principles for every Moonlight project: functional style, SOLID, DRY across the codebase, self-documenting code (no inline comments), exception-handling discipline and the common design patterns. Invoke when writing or reviewing code in any language and deciding how to structure it; then load the stack skill (flutter-coding-principles, python-coding-principles) for the idioms of that language."
---

# Coding Principles

These rules hold in every stack. Each stack skill adds only what is specific to its language and names this skill as its base:

| Stack | Skill |
|---|---|
| Dart / Flutter | `flutter-coding-principles` |
| Python | `python-coding-principles` |

## Functional Style

- **Small pure functions** for anything that can be computed from its inputs. They are trivial to test and to reuse.
- **Expression bodies** for single-statement functions.
- **Compose a pipeline** (validate, call, map, wrap in a result) instead of nesting conditionals and `try` blocks.
- **Pass a function reference when a lambda only forwards its arguments.** A lambda that adds, drops, reorders or transforms arguments stays a lambda.
- **Helpers live as top-level (module-level) functions**, not static methods on a class.
- **No empty branches.** When one branch of a result match does nothing, use a guard (`if result is success`) instead; reviewers read an empty branch as a forgotten case.

## SOLID

- **SRP:** split a component that does two jobs into two cohesive pieces.
- **ISP:** small, targeted repository and service interfaces.
- **DIP:** depend on abstractions in constructor parameters, never on concretions.
- **Avoid static methods** for behavior: instance methods on injected dependencies stay mockable and composable.

## DRY Across the Codebase

Before writing a private helper (formatter, mapper, validator), search the codebase for the same logic. If it already exists in another file, extract it to a shared utility module instead of adding another private copy. Don't wait for the third occurrence.

## Self-Documenting Code

- **No inline comments** in production code. Refactor instead: named constants, named variables, smaller well-named functions.
- **Doc comments only on public API** (classes, constructors, public functions and types).
- **No comments in tests.** The test description carries the intent.
- Linter suppression directives (`// ignore:`, `# noqa`) are not comments for this rule, but each one needs a reason the reviewer can see in the code around it.

## Exception Handling

- **Never swallow an exception.** No empty `catch`/`except`.
- **Integrations with hardware, platform or third-party SDKs** catch the error with its stack trace, log it, and propagate it to the caller (stream, callback, result). Never a silent catch.
- **Non-success responses are errors.** On a non-2xx status or a connection failure, raise or return an error result; never return a default value that looks like success.

## Design Patterns

- **Repository:** data sources stay behind abstract repositories (see `repository-pattern-persistence`).
- **Factory:** factory constructors or class methods on value objects and models to encapsulate creation and validation.
- **Strategy:** inject per-platform or per-provider algorithms (e.g. one sign-in strategy per provider).
- **Named variants** over variant flags: `Button.primary()` instead of `Button(variant: Variant.primary)`.
