# Dartian Architecture

This document describes the technical architecture and design decisions of the Dartian framework.

## Overview

Dartian is a Laravel-inspired web framework for Dart, built as a modular monorepo with 13 specialized packages.

## Package Structure

```
dartian/
├── packages/
│   ├── dartian/             # Umbrella package (re-exports all)
│   ├── dartian_core/        # Core utilities and telemetry hooks
│   ├── dartian_http/        # HTTP kernel built on Shelf
│   ├── dartian_router/      # Fluent routing DSL
│   ├── dartian_di/          # Dependency injection with get_it
│   ├── dartian_orm/         # Drift-based ORM
│   ├── dartian_redis/       # Redis client
│   ├── dartian_queue/       # Job queue system
│   ├── dartian_scheduler/   # Cron-based task scheduling
│   ├── dartian_view/        # Mustache template engine
│   ├── dartian_i18n/        # Internationalization
│   ├── dartian_auth/        # Authentication (JWT + bcrypt)
│   └── dartian_console/     # CLI tools
└── examples/                # Example projects
```

## Dependency Graph

```
dartian_core (no deps)
    ↓
├── dartian_di (uses get_it)
├── dartian_router (uses shelf_router)
├── dartian_i18n
├── dartian_redis (uses redis)
│       ↓
│   dartian_queue
│       ↓
│   dartian_scheduler
├── dartian_orm (uses drift)
├── dartian_http (uses shelf)
│       ↓
│   dartian_view (uses mustache_template)
├── dartian_auth (uses bcrypt)
└── dartian_console (CLI, depends on http, router, i18n)
```

## Key Design Decisions

### 1. Monorepo with Independent Packages

Each package is:
- Independently publishable to pub.dev
- Has its own tests and coverage
- Can be used standalone or with the umbrella package

### 2. Shelf as HTTP Foundation

- Built on the battle-tested `shelf` package
- Middleware pipeline pattern
- Compatible with existing Shelf middleware ecosystem

### 3. Drift for ORM

- Type-safe queries with code generation
- Supports SQLite and PostgreSQL
- Migration system with versioning

### 4. Dependency Injection

- Built on `get_it` for service location
- Annotations for auto-discovery: `@Singleton`, `@Service`, `@LazySingleton`
- Circular dependency detection at registration time

### 5. Security

- Passwords hashed with bcrypt (never SHA-256)
- JWT for stateless authentication
- CSRF protection middleware
- CORS middleware with configurable origins

## Code Generation

Packages using code generation:
- `dartian_di`: Generates service registrations from annotations
- `dartian_orm`: Generates database classes from table definitions

Run with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing Strategy

- Unit tests for all packages
- Mock interfaces for external dependencies (Redis, databases)
- Integration tests tagged with `@Tag('integration')`
- Target: >= 95% coverage per package

## CI/CD

GitHub Actions workflow:
- Matrix testing: Dart 3.9.4 and stable
- Static analysis on all packages
- Code formatting verification

## Development History

For detailed implementation history, lessons learned, and technical notes from development, see [docs/PLAN-v1.0.md](docs/PLAN-v1.0.md).

## Key Technical Notes

### Dart Testing Patterns

1. **Use interfaces for mocks** - Dart doesn't support duck-typing
2. **Unique IDs in tests** - Use timestamp + counter to avoid collisions
3. **Hide Drift conflicts** - `import 'package:drift/drift.dart' hide isNull, isNotNull;`

### shelf_router Parameters

```dart
// Use <name> syntax, not :name
router.shelfRouter.get('/users/<id>', (Request request, String id) {
  return Response.ok('User: $id');
});
```

### Hot Reload

Uses `hotreloader` package with VM Service API:
```dart
final hotReloader = await HotReloader.create(
  debounceInterval: const Duration(milliseconds: 500),
);
```

## License

AGPL-3.0 with commercial dual-licensing option.
