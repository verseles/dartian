# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-30

### Added

-   **Initial Release of the Dartian Framework**
-   **`dartian_core`**: Core classes and utilities.
-   **`dartian_cli`**: Command-line interface for application scaffolding, code generation, and development server. Includes `new`, `serve`, `build`, and a full suite of `make:*` commands.
-   **`dartian_http`**: Shelf-based HTTP kernel with a robust middleware pipeline, `Request` and `Response` wrappers, and global error handling.
-   **`dartian_router`**: Fluent routing engine built on `shelf_router`, supporting parameters, groups, and named routes.
-   **`dartian_di`**: Dependency injection container built on `get_it`, with a service provider pattern.
-   **`dartian_orm`**: Eloquent-like ORM built on `drift`, with support for models, relationships, factories, and seeders.
-   **`dartian_redis`**: Caching abstraction with an in-memory driver.
-   **`dartian_queue`**: Job queueing system with `sync` and `isolate` drivers.
-   **`dartian_scheduler`**: Cron-based task scheduler with a fluent API.
-   **`dartian_view`**: Server-side rendering with Mustache templates, including support for partials.
-   **`dartian_i18n`**: Internationalization system with language files and a `__()` helper.
-   **Deployment**: Multi-stage `Dockerfile` for building lean, production-ready container images.
-   **WASI Support**: Experimental support for compiling to WebAssembly (WASI).
-   **Documentation**: Comprehensive `README.md` and detailed guides for all major features.
