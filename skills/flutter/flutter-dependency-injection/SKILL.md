---
name: flutter-dependency-injection
description: "Dependency injection conventions for Flutter using get_it + injectable: lazySingleton-first registration, wrapping third-party SDKs in @module classes, preResolve for async startup dependencies, fakes/mocks for testing, and asdf for pinning CLI tool versions. Invoke when registering a new service, wiring a third-party SDK into DI, or writing a fake/mock for a test."
---

# Flutter Dependency Injection Skill

## 1. Basics

Configure DI once at app startup:

```dart
final GetIt getIt = GetIt.instance;

/// Short alias for [getIt] DI resolution.
T G<T extends Object>() => getIt<T>();

@InjectableInit()
Future<void> configureDependencies({String? environment}) async => getIt.init(environment: environment);
```

## 2. Service Registration Patterns

### Default services (`@lazySingleton` / `@injectable`)

Prefer `@lazySingleton` for stateless services so they initialize only on first retrieval, not at startup:

```dart
@lazySingleton
class GeolocationService {
  Future<Position> getCurrentLocation() async { /* ... */ }
}
```

### Third-party SDKs (`@module`)

External classes (packages, SDKs, native plugins) can't be annotated directly: wrap their instantiation in a `@module` class:

```dart
@module
abstract class ExternalServicesModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio get dio => Dio(BaseOptions(baseUrl: apiBaseUrl));
}
```

## 3. Rules

- **Prefer `@lazySingleton` by default**: eagerly instantiating everything at startup slows app launch.
- **`@preResolve` only for async initialization that must finish before first frame** (e.g. loading `SharedPreferences`, opening a local database): anything else stays lazy.
- **Inject abstractions**: when a service has an interface, register the implementation against it:
  ```dart
  @LazySingleton(as: PaymentService)
  class StripePaymentService implements PaymentService { ... }
  ```
- **Watch `injectable`/`injectable_generator` version pins against `freezed`**: some `injectable_generator` releases conflict with certain `freezed` versions and fail codegen; if a fresh `build_runner` run starts failing after a routine dependency bump, check for a pin mismatch between the two before assuming the code itself is wrong.

## 4. Fakes and Mocks for Testing

Don't invoke real services in unit/widget tests: put mocks/fakes under `test/mocks/`.

### Mocking with mocktail

```dart
import 'package:mocktail/mocktail.dart';

class MockPaymentService extends Mock implements PaymentService {}
```

### Fakes for state control

When mocking is too verbose for a scenario, implement a fake concretion:

```dart
class FakePaymentService implements PaymentService {
  bool shouldSucceed = true;

  @override
  Future<Result<Failure, Transaction>> processPayment(double amount) async {
    if (shouldSucceed) return Result.success(Transaction(id: 'fake_123', amount: amount));
    return Result.error(PaymentFailure.declined());
  }
}
```

## 5. CLI Tool Management (`asdf`)

Use `asdf` to install/pin CLI tools and runtime dependencies (Node, mobile test runners, etc.) for development and CI:

- Declare all project tool versions in `.tool-versions` at the workspace root.
- `asdf plugin add <tool>` · `asdf install <tool> <version>` · `asdf local <tool> <version>`.
