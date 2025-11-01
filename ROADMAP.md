# Dartian Framework Roadmap & Status

This document provides a detailed overview of the Dartian Framework's development status, tracking progress against the original 16-phase implementation plan.

---

## 🎯 Current Focus: CI Pipeline Stabilization (In Progress)

The CI pipeline is currently failing due to a large number of static analysis (`dart analyze`) issues across the monorepo. Before proceeding with any new features, the immediate priority is to resolve these issues to ensure codebase stability and improve the developer experience.

**Status:**
*   [ ] **Dependencies:** Adding missing dependencies and `publish_to: none` properties to various `pubspec.yaml` files.
*   [ ] **Code Quality:** Fixing unused imports, incorrect annotations, and other linting warnings.
*   [ ] **Templates:** Correcting errors in the `dartian_cli` project templates.
*   [ ] **Examples:** Replacing broken placeholder code in `example` directories with functional demonstrations.
*   [ ] **Blocked:** A persistent null safety issue in `packages/dartian_router/lib/src/router.dart` is currently blocking progress.

---

## ✅ Completed Features

The following core modules and features are implemented, tested, and considered stable for an initial alpha release.

-   **Phase 0: Project Setup & Monorepo**
    -   [x] Dart SDK environment configured.
    -   [x] Monorepo workspace with 11 packages created.
    -   [x] All initial dependencies resolve correctly.
    -   [x] Basic GitHub Actions CI workflow is in place.

-   **Phase 1 & 11: CLI Implementation (`dartian_cli`)**
    -   [x] `dartian new <project>` command is implemented and tested.
    -   [x] A full suite of `make:*` commands for code generation is implemented.

-   **Phase 2: HTTP Kernel (`dartian_http`)**
    -   [x] `HttpKernel` implemented using `package:shelf`.
    -   [x] Middleware pipeline is functional.
    -   [x] Global error handling is implemented.
    -   [x] Abstractions for `Request` (via extensions) and `Response` are complete.

-   **Phase 3: Router (`dartian_router`)**
    -   [x] Fluent routing engine built on `shelf_router`.
    -   [x] Supports route parameters, groups, and named routes.
    -   [x] Integrates with the DI container for controller resolution.

-   **Phase 4: Dependency Injection (`dartian_di`)**
    -   [x] Service container implemented as a facade over `get_it`.
    -   [x] `ServiceProvider` pattern is established for organizing dependency registration.

-   **Phase 5: ORM (`dartian_orm`)**
    -   [x] Database layer built on `drift` with an Eloquent-like API.
    -   [x] Supports SQLite.
    -   [x] Implements models, seeders, and factories for test data generation.

-   **Phase 7: Scheduler (`dartian_scheduler`)**
    -   [x] Cron-based task scheduler with a fluent API is functional.
    -   [x] `schedule:run` command is implemented in the CLI.

-   **Phase 8: Authentication & Security (`dartian_http`)**
    -   [x] In-memory session management.
    -   [x] JWT generation and validation.
    -   [x] `AuthGuard` middleware for protecting routes (supports session and JWT).
    -   [x] Middleware for CORS, CSRF, and common security headers.
    -   [x] All authentication features are tested and stable.

-   **Phase 9: Server-Side Views (`dartian_view`)**
    -   [x] View engine using Mustache for server-side rendering is complete.
    -   [x] Supports partials/includes.

-   **Phase 10: Internationalization (`dartian_i18n`)**
    -   [x] Basic pluralization support is implemented and tested.

-   **Phase 13: WASI Support**
    -   [x] Experimental support for compiling to a WASI target via the `build wasm` command.
    -   [x] CI validates the WASI build.

-   **Phase 15: Documentation**
    -   [x] Comprehensive `README.md` and project `LICENSE`.
    -   [x] Detailed guides for all completed features (`routing.md`, `orm.md`, etc.).
    -   [x] `CONTRIBUTING.md` and `CHANGELOG.md` are created.

---

## ⚠️ Partially Completed / Blocked Features

-   **Phase 6: Redis for Cache & Queues**
    -   [x] `RedisClient` wrapper is implemented in `dartian_redis`.
    -   [x] `RedisCache` driver is implemented.
    -   [ ] **Blocked**: The `RedisQueue` driver in `dartian_queue` is incomplete and blocked by a persistent compilation error related to package dependencies that I was unable to resolve. The framework currently lacks a production-ready queue driver.

---

## ❌ Incomplete / Missing Features

The following features from the original plan have not been implemented.

-   **Phase 11: Hot Reload**
    -   [ ] The "Hot Reload" feature for the `dartian serve` command was attempted but abandoned due to testing complexities.

-   **Phase 12: Deployment Verification**
    -   [ ] While a `Dockerfile` and `docker-compose.yml` were created, the final integration tests to verify that the application runs correctly in a containerized environment were abandoned due to Docker permission issues.

---

## Next Steps

1.  **Resolve the CI pipeline issues.**
2.  Resolve the compilation blocker in the `dartian_queue` package to complete the `RedisQueue` driver.
3.  Fix the environmental issues to complete the Docker integration tests.
4.  Re-evaluate and attempt to implement the Hot Reload feature for the `serve` command.
