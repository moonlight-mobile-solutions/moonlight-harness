---
name: flutter-clean-architecture
description: "Clean Architecture / DDD folder layout for Flutter features: domain layer (entities, value objects, repository interfaces, usecases), data layer (data sources, models, repository implementations, mappers), and presentation layer (Cubits, Pages, Widgets), with the strict dependency direction between them. Invoke when creating a new feature module, a UseCase, a domain entity, or deciding which layer a piece of code belongs in."
---

# Flutter Clean Architecture Skill

## Directory Layout

Each feature follows a strict Clean Architecture / DDD folder organization:

```
lib/features/<feature>/
├── data/           # Data sources, models, repository implementations
│   ├── datasources/   # Remote (REST API/HTTP) and local (Hive/preferences) data sources
│   ├── models/        # JSON-serializable model classes (*_model.dart)
│   └── repositories/  # Repository implementations delegating to datasources
├── domain/         # Pure business logic and contracts
│   ├── entities/      # Domain entities (immutable data models)
│   ├── value_objects/ # Domain value validation objects
│   ├── repositories/  # Repository interfaces (abstract classes)
│   └── usecases/      # UseCase classes (+ mixins/)
└── presentation/   # UI layer (Cubits, Pages, Widgets)
    ├── cubits/        # Cubit classes and State classes (freezed)
    ├── pages/         # Page widgets (full-screen routes)
    └── widgets/       # Reusable sub-widgets and components
```

## 1. Domain Layer (Pure Dart)

Contains pure business logic and does not depend on any external frameworks (except helper packages like Freezed and Equatable).

### Entities

Immutable data models representing core business concepts.
- **Placement**: strictly under `domain/entities/`: never `data/entities/` or `domain/models/`.
- No raw JSON serialization logic in entities.
- Use `@freezed` for immutability and equality.
- **Freezed 3.x**: the class annotated `@freezed` must be an **`abstract class`** (the concrete implementation lives in the generated `.freezed.dart` file). A non-abstract `class` causes `Missing concrete implementations` in the analyzer.

```dart
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
  }) = _Profile;
}
```

### Value Objects

Encapsulate validation directly inside value classes to guarantee valid domain models.

### Repository Interfaces

```dart
abstract class CustomerRepositoryInterface {
  Future<Result<List<CustomerEntity>, Exception>> getCustomers();
  Future<Result<CustomerEntity, Exception>> addCustomer(CustomerEntity customer);
}
```

### Use Cases

Single-responsibility classes executing one specific business action.
- Return a `Result<T, Exception>` (e.g. from the `multiple_result` package).
- A single `call` method.
- Cubits depend on UseCases, never on Repositories directly.

### Layer Dependency Rule

```
Widget (BlocConsumer/BlocBuilder)
    → Cubit (manages state, coordinates UseCases)
        → UseCase (executes one business action)
            → RepositoryInterface (abstract contract)
                → RepositoryImpl (implementation, maps models)
                    → DataSource (API/local storage access)
```

- **Widget/View**: never accesses repositories, data sources, or use cases directly: only consumes state via `BlocBuilder`/`BlocConsumer` and dispatches actions via `context.read<Cubit>().action()`.
- **Cubit**: manages UI state, depends on UseCases, never on repositories directly.
- **UseCase**: executes one business action; may depend on repositories or other use cases.
- **RepositoryImpl**: implements the contract, maps `Model` → `Entity`, handles exceptions, returns `Result<T, Exception>`.
- **DataSource**: raw access to HTTP API, Hive, or local storage.

## 2. Data Layer (Frameworks, Drivers & Mappers)

Implements the domain layer's repository contracts and handles data access + serialization.

### Data Sources

Wrap external REST APIs, Hive boxes, or local storage. Define an abstract interface plus a `@LazySingleton` implementation under `data/datasources/`.

```dart
abstract class CustomersRemoteDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel> addCustomer(CustomerModel customer);
}

@LazySingleton(as: CustomersRemoteDataSource)
class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  const CustomersRemoteDataSourceImpl();

  @override
  Future<List<CustomerModel>> getCustomers() async => const [];

  @override
  Future<CustomerModel> addCustomer(CustomerModel customer) async => customer;
}
```

### Data Models

JSON-serializable representations under `data/models/`, using `@JsonSerializable()` or `@freezed` for codegen. Provide explicit mappers:
- `toEntity()`: Data Model → Domain Entity.
- `fromEntity()`: Domain Entity → Data Model.

```dart
@JsonSerializable()
class CustomerModel {
  const CustomerModel({required this.id, required this.name, required this.email});

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
  factory CustomerModel.fromEntity(CustomerEntity entity) =>
      CustomerModel(id: entity.id, name: entity.name, email: entity.email);

  final String id;
  final String name;
  final String email;

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  CustomerEntity toEntity() => CustomerEntity(id: id, name: name, email: email);
}
```

### Repository Implementations

Under `data/repositories/`, registered with `@LazySingleton(as: FeatureRepositoryInterface)`, depending on Data Sources via constructor injection. Catch raw exceptions and return `Result<T, Exception>`; perform the Model ↔ Entity mapping.

```dart
@LazySingleton(as: CustomersRepositoryInterface)
class CustomersRepositoryImpl implements CustomersRepositoryInterface {
  const CustomersRepositoryImpl({required CustomersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CustomersRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<CustomerEntity>, Exception>> getCustomers() async {
    try {
      final models = await _remoteDataSource.getCustomers();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(Exception(e.toString()));
    }
  }
}
```

## 3. View Layer

The presentation layer uses Cubits for page/feature state management by default (an app-root event-driven Bloc is only justified for genuinely global, event-driven state such as an app-wide session: see the project's own auth skill if it has one) and `bloc_presentation` for one-shot UI actions (snackbars, navigation).
