---
name: flutter-testing-conventions
description: "Flutter testing conventions: TDD rules, unit/widget test structure with mocktail, mandatory accessibility validation in widget tests, the \"test the real Page, not just the isolated sub-component\" gotcha, Maestro E2E selector gotchas (Semantics identifier vs Key, merged semantics, ASCII-only input), environment-gated fake DI for tests, and the awk-based coverage-threshold workaround since flutter test --coverage has no --cov-fail-under flag. Invoke when writing any Dart unit, widget, or integration test, or setting up Flutter test coverage enforcement."
---

# Flutter Testing Conventions

## TDD Rules

- Business-logic changes and new features are written test-first (Red-Green-Refactor).
- Coverage target: commonly 80% for business logic (UseCases, Cubits, repositories): exclude generated files (`*.g.dart`, `*.freezed.dart`), pure data entities, and JSON models from the count.
- Comments in tests follow `coding-principles` (none); `group()` labels carry the intent along with the test names.
- Failing tests block merges.

## Unit Tests

Pure Dart logic: UseCases, repository implementations, data sources, value objects, mappers.

- **Framework**: `dart:test` + `mocktail`.
- **Mock organization**: consolidate mocks into layer-based files under `test/mocks/` (`domain_mocks.dart`, `data_mocks.dart`, `services_mocks.dart`, barrel-exported via `mocks.dart`) rather than scattering `Mock{Class}` definitions per-file or inline in `*_test.dart`.
- **File location**: mirror `lib/` under `test/` (`lib/features/x/domain/usecases/y.dart` → `test/features/x/domain/usecases/y_test.dart`).

### Mocktail: stub methods with the callable syntax, and with the tearoff only when there are no arguments

```dart
// ✅ a method with arguments or matchers needs the closure
when(() => repository.getUser('u1')).thenAnswer((_) async => user);
when(() => useCase(any())).thenAnswer((_) async => const Success(null));

// ✅ a method without arguments takes the tearoff, which is what `unnecessary_lambdas` ("Closure should be a tearoff") asks for
when(snapshot.data).thenReturn(data);
when(cubit.isUserSignedIn).thenReturn(false);

// ❌ flagged by `unnecessary_lambdas`: the closure just calls the method without arguments
when(() => snapshot.data()).thenReturn(data);

// ❌ a getter is not a method: its tearoff is the value, so write the closure
when(() => cubit.isLoading).thenReturn(false);
```

The same lint applies to the other test closures, for example `blocTest(seed: buildState)` instead of `seed: () => buildState()`.

### Mocktail: `registerFallbackValue` for custom types passed to `any()`

```dart
setUpAll(() {
  registerFallbackValue(MyCustomType(/* dummy values */));
});
```

### Testing `FlutterSecureStorage`-dependent classes

Use the package's own test platform instead of trying to mock the plugin channel:

```dart
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

setUp(() {
  FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({});
});
```

### What to test for every UseCase / Cubit / Repository / Value Object

- **UseCase**: success path returns the expected `Result.success`; failure path returns `Result.failure`; calls the repository with correct arguments; no duplicate repository calls.
- **Cubit**: correct state sequence for the happy path (`blocTest`); error/failure state on UseCase failure; no state emitted after `close()` (`safeEmit`); presentation events fire for side effects.
- **Repository implementation**: mapped entity on success; correct `Failure` type on data-source error; correct arguments passed to the data source.
- **Value Object**: valid input constructs successfully; each invalid case returns the expected `ValueFailure`.

## Widget Tests

Verify a page/component renders and responds to interaction, without a real device or backend.

- **Framework**: `flutter_test` + `mocktail` for mocked Cubits/BLoCs.
- **Test harness**: a shared `pumpApp()`-style extension wrapping the widget with theme, localizations, router, and providers, instead of hand-rolling `MaterialApp` boilerplate per test.

### Mandatory accessibility validation

Every widget test validates accessibility guidelines (see `flutter-accessibility` skill):

```dart
await tester.expectMeetsAccessibilityGuidelines();
```

### Don't mock a Cubit consumed by a widget: build a real one with mocked dependencies

```dart
// ❌ Mock from mocktail doesn't implement Cubit's abstract members
// (stream, state, close), throwing `type 'Null' is not a subtype of type 'Stream<State>'`
class MockMyCubit extends Mock implements MyCubit {}
```

Instead, construct a real Cubit with mocked collaborators, stub the collaborators, and provide the real Cubit instance:

```dart
testWidgets('renders success state', (tester) async {
  final cubit = MyCubit(myUseCase: mockUseCase, myRepo: mockRepo);
  when(() => mockRepo.getData()).thenAnswer((_) async => const Success([data]));

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: BlocProvider<MyCubit>.value(value: cubit, child: MyView())),
  ));
  await tester.pumpAndSettle();

  expect(find.byType(MyWidget), findsOneWidget);
});
```

Note: a page's `initState` often calls a load method immediately, so state moves from `loading` to `success`/`error` during `pumpWidget` itself: the intermediate `loading` state is hard to observe this way (`BlocBuilder` subscribes to the stream after the `emit` inside `initState` already happened). Focus assertions on the final states and the resulting UI.

### Testing the isolated sub-component doesn't replace testing the real Page

A widget test that mounts a sub-component directly, wrapped in a `BlocProvider` the *test file itself* creates, doesn't exercise the parent Page's real `build()`: including a case where the parent Page is the one that (in production) creates that `BlocProvider` and passes the wrong `context` into a callback. This produces a `ProviderNotFoundException` at runtime that's completely invisible to a test suite that only ever mounts the isolated sub-component, hundreds of green sub-component tests can coexist with this bug.

**Rule**: for any interaction that triggers navigation (`Navigator.push`, `context.push`, or a `BlocProvider.value` wrapping a pushed route), have at least one test that mounts the real Page: via the app's actual DI path (`getIt.registerFactory<Cubit>(...)`), not a hand-rolled provider around the isolated sub-component:

```dart
setUp(() async {
  await getIt.reset();
  getIt.registerFactory<MyCubit>(() => MyCubit(useCase: mockUseCase));
});

testWidgets('tapping the CTA navigates without a ProviderNotFoundException', (tester) async {
  await tester.pumpWidget(MaterialApp(home: const MyRealPage()));
  await tester.pumpAndSettle();
  // ... real interactions ...
  expect(tester.takeException(), isNull);
});
```

The sub-component test recreates the provider tree correctly from scratch, which is exactly what masks a scoping bug that only exists in the real production tree: only mounting the real Page (or manual on-device verification) exposes it.

## Integration/E2E Tests (Maestro or similar)

### Conventions

- Flow files named `{feature}_flow.yaml`.
- A flow needing a logged-in starting state should reuse a shared login flow (`runFlow:`) rather than duplicating the login sequence.

### Selectors: `Semantics(identifier:)`, not `Key`

A plain Flutter `Key('foo')` never surfaces as the platform accessibility id (Android `resource-id`/iOS accessibility identifier) that Maestro-style `id:` selectors read: confirm with the tool's element-hierarchy dump before trusting any selector. To make a widget targetable, wrap it in `Semantics(identifier: 'foo', child: ...)` (Flutter 3.19+); keep the `Key` too, since widget tests still use `find.byKey`, `identifier` is additive, not a replacement.

- Data-driven widgets keyed by a backend-generated id (e.g. a card keyed by a DB UUID) are **not** safe `id:` selectors across a real-backend run and a mock-server run, since the underlying id differs between the two. Select by visible content that's deliberately kept identical in both fixtures instead.
- Adjacent `Text` widgets under a shared `Semantics` ancestor get merged into one multi-line accessibility node: a text selector matching just one of them needs a full-match-tolerant pattern (e.g. a DOTALL-style regex `"(?s).*Target Text.*"`) if the selector engine does full-string matching rather than "contains".
- `input text`-style automation is typically ASCII-only: search/type by an accent-free substring rather than the literal accented string.

### Test-Environment DI (fakes for hardware/external services)

A test-only entrypoint (e.g. `main_test.dart`) configures DI with a `test` environment, registering `@LazySingleton(env: [Environment.test])` fakes in place of hardware-backed implementations (e.g. a fake NFC/Bluetooth/payment-SDK service registered only for `dev`/`prod`). If the project bans `String.fromEnvironment` project-wide (a common lint to prevent scattered environment reads), centralize the one legitimate use: reading a mock-server base URL dart-define, at this single test entrypoint, applied via `getIt<Dio>().options.baseUrl = ...` after DI configures, rather than reading it anywhere else in the app.

## Flutter Coverage Threshold (no native `--cov-fail-under`)

Unlike `pytest-cov`, `flutter test --coverage` has no fail-under flag: the threshold has to be computed by parsing `coverage/lcov.info` manually.

**Exclude from the count**: `*.freezed.dart` (already `coverage:ignore-file`-tagged by the generator), `*.g.dart` (needs manual filtering: not tagged), `*_model.dart`, DI codegen output, generated l10n.

```bash
awk -F',' '
  /^SF:/ {
    skip = 0
    if ($0 ~ /\.freezed\.dart/ || $0 ~ /\.g\.dart/ || $0 ~ /injection\.config\.dart/ || $0 ~ /\/l10n\/generated\// || $0 ~ /_model\.dart/) {
      skip = 1
    }
  }
  /^DA:/ && !skip {
    if ($2+0 > 0) hit++
    total++
  }
  END {
    if (total > 0) {
      coverage = hit * 100 / total
      printf "Coverage: %.1f%% (%d/%d lines)\n", coverage, hit, total
      if (coverage < 80) { exit 1 }
    } else {
      print "No lines found"
    }
  }
' coverage/lcov.info
```

**Important**: a plain `lcov --summary` includes generated files in the count, understating true coverage relative to a CI pipeline that excludes them: always use the `awk` filter above (or an equivalent) to get a locally-comparable number, not raw `lcov`/`genhtml` output.

## Test Coverage Checklist for New Features

Before a feature PR merges:

- [ ] Unit tests for all UseCases (happy + failure paths).
- [ ] Unit tests for the Cubit (all state transitions + side effects).
- [ ] Unit tests for the repository implementation (success + failure).
- [ ] Widget tests for the page (initial, loading, loaded, error states + interactions), including the accessibility-guideline assertion.
- [ ] An E2E test for the primary happy-path user flow, if the project has E2E coverage.
- [ ] For any feature that changes navigation (new route, a Page wrapping its own `BlocProvider`): at least one test mounts the real Page, not just an isolated sub-component: **and** the golden path was run manually on a real device/emulator/browser, since provider-scoping bugs are invisible to isolated widget tests.
- [ ] Coverage for the new module is at or above the project's threshold.
