---
name: python-coding-principles
description: "Python idioms on top of coding-principles: module-level pure functions, typed signatures, dependency injection through constructors, explicit exceptions, plus Python 3.13 + Pydantic V2 compatibility gotchas (bcrypt instead of passlib, EmailStr needs email-validator, SettingsConfigDict from pydantic-settings). Invoke when writing new Python code; load coding-principles too."
---

# Python Coding Principles

Builds on `coding-principles`. Load both: that skill holds the rules shared by every stack, this one only the Python idioms.

## Style

- **Type every signature** (parameters and return). Local variables only when the type isn't obvious.
- **Module-level functions** for pure helpers, never `@staticmethod` on a class just to group them.
- **Comprehensions and generator expressions** over manual append loops; a function reference over a lambda that only forwards (`map(parse, values)`, not `map(lambda v: parse(v), values)`).
- **Dependencies come in through `__init__`** (or framework DI such as FastAPI `Depends`), typed against a `Protocol` or ABC, so tests can pass fakes.
- **Docstrings only on public modules, classes and functions.** No `#` comments; `# noqa` and `# type: ignore[...]` are directives and need a visible reason.

## Exceptions

- No bare `except:` and no `except Exception: pass`.
- Catch the narrowest exception, add context and re-raise with `raise ... from error` so the original traceback survives.
- Map infrastructure errors to domain errors at the repository boundary; the use case never sees driver or HTTP-client exceptions.

## Python 3.13 + Pydantic V2 Gotchas

- **Direct bcrypt hashing:** avoid `passlib.context.CryptContext` under Python 3.13. `passlib` is unmaintained and throws `ValueError: password cannot be longer than 72 bytes` against modern `bcrypt` releases. Use `bcrypt.hashpw` and `bcrypt.checkpw` directly.
- **Pydantic `EmailStr`** needs `email-validator` declared as a dependency, or schema building fails at startup.
- **Pydantic Settings:** use `SettingsConfigDict` from `pydantic_settings`, not `ConfigDict` from `pydantic`, for environment-backed settings.
