---
name: pytest-backend-testing-conventions
description: "Python backend testing conventions: TDD rules, pytest/pytest-asyncio/pytest-cov setup with a native coverage-fail-under threshold, AsyncMock vs MagicMock for SQLAlchemy sessions, a SQLAlchemy result-proxy mock helper, and contract testing a live backend via a Postman/Newman-style collection run. Invoke when writing a backend unit or integration test, or wiring up backend coverage enforcement."
---

# Python Backend Testing Conventions

## TDD Rules

- Business-logic changes and new endpoints/services are written test-first (Red-Green-Refactor).
- Coverage target: commonly 80% for business logic (use cases, services, repositories): exclude migrations, `tests/`, and virtualenv paths from the measured source.
- Comments in tests follow `coding-principles` (none).
- Failing tests block merges.

## Framework

- **pytest** + `pytest-asyncio` for async tests.
- **pytest-cov** for coverage, with a native fail-under threshold (unlike Flutter's `flutter test --coverage`, which has no such flag: see `flutter-testing-conventions` for that workaround):
  ```bash
  python -m pytest --cov=app --cov-fail-under=80 --cov-report=term-missing --cov-config=.coveragerc
  ```
- **mutmut** for mutation testing, when line coverage alone isn't a strong enough signal.
- **`unittest.mock`**: `AsyncMock` for async DB session methods (`execute`, `flush`, `refresh`), `MagicMock` for sync ones (`add`, `delete`).
- **`httpx.AsyncClient`** with `ASGITransport` for integration tests that exercise the app directly, without a running server process.

## Coverage Config

A `.coveragerc` (or `pyproject.toml [tool.coverage]`) that scopes `source` to the app package and excludes `alembic/`/`migrations/`/`tests/`/`__pycache__/`/the virtualenv keeps local runs comparable to CI.

## SQLAlchemy Mock Patterns

For async session methods, use `AsyncMock`; for sync ones, `MagicMock`. For result proxies:

```python
def _make_result(value):
    result = MagicMock()
    result.scalar_one_or_none.return_value = value
    result.scalars.return_value.all.return_value = [value]
    return result
```

## Contract Testing Against a Live Backend

A Postman/Newman-style collection run against a live instance (migrations applied, seed data loaded) validates API contracts end-to-end, independent of any frontend test suite. Wire it into CI as its own step, and into a pre-commit/pre-push hook where feasible: skip it gracefully (not blocking the commit) when the required services (e.g. Docker) aren't running locally, rather than making it a hard local gate.
