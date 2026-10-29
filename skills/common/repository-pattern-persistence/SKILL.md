---
name: repository-pattern-persistence
description: "Repository-pattern persistence abstraction across a Python/SQLAlchemy backend and a Flutter/Dio frontend: domain-layer repository interfaces, infrastructure implementations, mappers, and the rule that UseCases never touch a DB session or HTTP client directly. Invoke when adding a new persisted entity or wiring a new data source behind a repository contract."
---

# Repository Pattern Persistence Skill

## Architecture Overview

To keep Clean Architecture principles intact, all data access: database ORM on a backend, REST/WebSocket clients on a frontend, is isolated behind repository contracts defined in the domain layer.

```
Frontend (Flutter/Kotlin/etc.)               Backend (e.g. FastAPI)
┌────────────────────────┐                  ┌────────────────────────┐
│     UseCase / Cubit    │                  │  UseCase / Domain      │
└───────────┬────────────┘                  └───────────┬────────────┘
            ▼                                           ▼
┌────────────────────────┐                  ┌────────────────────────┐
│ OrderRepositoryInterface│                 │ OrderRepositoryInterface│
└───────────┬────────────┘                  └───────────┬────────────┘
            ▼                                           ▼
┌────────────────────────┐                  ┌────────────────────────┐
│   OrderRepositoryImpl   │                 │ SqlAlchemyOrderRepoImpl│
│  (REST / WebSocket)    │                  │ (SQLAlchemy + AsyncPG) │
└────────────────────────┘                  └────────────────────────┘
```

## 1. Backend Persistence (Python + SQLAlchemy async)

### Repository Contract (Domain Layer)

```python
from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID
from app.domain.entities.order import Order

class OrderRepository(ABC):
    @abstractmethod
    async def get_by_id(self, order_id: UUID) -> Optional[Order]:
        """Fetch by primary key."""

    @abstractmethod
    async def get_active_with_lock(self, key: str) -> Optional[Order]:
        """Fetch with row-level locking (SELECT FOR UPDATE) for concurrent-write safety."""

    @abstractmethod
    async def save(self, order: Order) -> Order:
        """Persist new or updated entity."""
```

### Infrastructure Implementation (SQLAlchemy 2.0 + asyncpg)

```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, order_id):
        stmt = select(OrderModel).where(OrderModel.id == order_id)
        result = await self._session.execute(stmt)
        model = result.scalar_one_or_none()
        return OrderMapper.to_entity(model) if model else None

    async def get_active_with_lock(self, key):
        stmt = select(OrderModel).where(OrderModel.key == key, OrderModel.status == "OPEN").with_for_update()
        result = await self._session.execute(stmt)
        model = result.scalar_one_or_none()
        return OrderMapper.to_entity(model) if model else None

    async def save(self, order):
        model = OrderMapper.to_model(order)
        merged = await self._session.merge(model)
        await self._session.flush()
        return OrderMapper.to_entity(merged)
```

## 2. Frontend Persistence (Flutter + Dio)

### Remote DataSource Abstraction

```dart
abstract class OrdersRemoteDataSource {
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder({required String customerId, required List<LineItem> items});
}
```

### Implementation (Dio REST)

```dart
@LazySingleton(as: OrdersRemoteDataSource)
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get('/api/v1/orders/$id');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> createOrder({required String customerId, required List<LineItem> items}) async {
    final response = await _dio.post('/api/v1/orders', data: {
      'customer_id': customerId,
      'items': items.map((i) => i.toJson()).toList(),
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
```

## 3. Monetary Values

If the domain has money, store and transmit it as an integer in the smallest currency unit (cents), never as a float: floating-point rounding error compounds silently across aggregations.

```sql
price_cents INTEGER NOT NULL CHECK (price_cents >= 0)
```

## Rules

- **Strict repository abstraction**: domain UseCases never touch an ORM session or HTTP client directly: only repository interfaces.
- **Error mapping**: catch infrastructure exceptions (`SQLAlchemyError`, `DioException`, etc.) inside the repository implementation and convert them into explicit domain failures: don't let them leak past the repository boundary.
- **Single-responsibility mappers**: keep explicit Model ↔ Entity mapping logic separate from both the model and the repository implementation.
