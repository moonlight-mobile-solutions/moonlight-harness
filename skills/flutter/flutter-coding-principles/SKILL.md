---
name: flutter-coding-principles
description: "Dart/Flutter idioms on top of coding-principles: Future chains with Result, tearoffs (unnecessary_lambdas), no private methods returning Widget, doc comments, bloc_presentation events, and Cubit state-getter conventions (derived getters, recoverable rollback, emit-vs-return errors). Invoke when writing new Dart or Flutter code; load coding-principles too."
---

# Flutter Coding Principles

Builds on `coding-principles`. Load both: that skill holds the rules shared by every stack, this one only the Dart/Flutter idioms.

## Functional Style in Dart

- **Expression functions** for single-statement methods: `int add(int a, int b) => a + b;`
- **Chain with `.then`/`.catchError`** instead of verbose `try-catch`:
  ```dart
  Future<Result<Failure, User>> loginUser(LoginDetails details) {
    return Future.value(details)
        .then(_validateDetails)
        .then(_authenticateWithBackend)
        .then(Result.success)
        .catchError((error) => Result.failure(_mapToFailure(error)));
  }
  ```
- **Tearoffs** (lint `unnecessary_lambdas`, "Closure should be a tearoff"): `seed: filledIn` instead of `seed: () => filledIn()`, `.map(_parse)` instead of `.map((value) => _parse(value))`, `onPressed: cubit.submit` instead of `onPressed: () => cubit.submit()`. `() => goToLogin(context)` and `(user) => _toEntity(user, now)` stay closures.
- **No `Result.when(...)` with a no-op branch** such as `(_) async {}`. Use `if (result.isSuccess()) { ... }` and return the `Result` unchanged.
- **Shared helpers** go to `lib/core/utils/` as top-level functions.

## Widget Composition

- **Never a private method that returns `Widget`** (`Widget _buildHeader() => ...`). Methods get no `Element`/`BuildContext`, can't be `const` and rebuild with the parent. Extract a private widget class (`class _Header extends StatelessWidget`) that takes what it needs as constructor params and reads `Theme.of(context)`/`AppLocalizations.of(context)` itself.
- This holds for per-state bodies too (a dialog with confirming/success/error steps): one private widget class per state, selected in `build()`.
- **Named constructors for variants:** `AppButton.primary()`, `AppCard.filled()`, `AppChip.error()`.

## Comments

- No `//` comments in production code or tests; analyzer `// ignore:` directives excepted.
- `///` only on public classes, constructors, methods and types.

## Exceptions

- Platform-integration services (NFC, Bluetooth, payment SDKs) catch `(error, stackTrace)`, log, and propagate with `_controller.addError(error)`.
- On a non-success HTTP status:
  ```dart
  if (response.statusCode == 200) return _parseUser(response.body);
  throw Exception('Failed to sign in: HTTP ${response.statusCode}');
  ```
- With `bloc_presentation` there is no required `BlocPresentationEvent` base class: presentation events can be plain (often `freezed`) classes.

## State Getters and Cubit Patterns

- **Derived UI getters on the State** (`shouldShow*`, `isReadyTo*`, `canSubmit`) instead of repeating conditions in widgets:
  ```dart
  bool get shouldShowEmptyState => !isLoading && items.isEmpty;
  ```
- **Recoverable error rollback:** restore the previous state before emitting the error, so the UI keeps the data it already loaded.
- **Emit an error state or return the `Result`, depending on who shows the error.** If the Cubit method runs with no modal or dialog of its own (e.g. triggered by an NFC scan), emit an error state so the page renders the failure. If it runs from a dialog that already renders success/error/retry, return the `Result` and leave the Cubit state alone; emitting there would replace unrelated UI (a whole dashboard) over a failure scoped to the dialog. State which one a method uses in a one-line doc comment.
