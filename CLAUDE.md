# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Dartian** is a Laravel-inspired web framework for Dart, designed for high-performance production deployments on Arch Linux with Podman containerization. The framework features a monorepo architecture with multiple specialized packages.

## Development Environment

- **Platform**: Arch Linux
- **Package Manager**: `paru` (use instead of pacman where applicable)
- **Container Runtime**: `podman` and `podman-compose` (NOT docker/docker-compose)
- **Dart Version**: 3.0+
- **Branch Strategy**: Work directly on `main` branch
- **CLI Tool**: `gh` (GitHub CLI) is available and authenticated

## Project Structure (Target Architecture)

```
dartian/
├── packages/
│   ├── dartian_cli/         # CLI tool with subcommands
│   ├── dartian_core/        # Core utilities and telemetry hooks
│   ├── dartian_http/        # HTTP kernel with shelf integration
│   ├── dartian_router/      # Router with fluent DSL
│   ├── dartian_di/          # Dependency injection with get_it
│   ├── dartian_orm/         # ORM with Drift (SQLite + PostgreSQL)
│   ├── dartian_redis/       # Redis cache and pub/sub
│   ├── dartian_queue/       # Job queues (sync, isolate, Redis)
│   ├── dartian_scheduler/   # Task scheduling with cron
│   ├── dartian_view/        # SSR with mustache templates
│   ├── dartian_i18n/        # Internationalization
│   └── dartian_auth/        # Session and JWT authentication
├── examples/                # Example projects
├── scripts/                 # Build and utility scripts
├── .github/workflows/       # CI/CD configuration
└── PLAN.md                  # Detailed execution plan
```

## Common Commands

### Environment Setup
```bash
# System package synchronization (always run first for each phase)
paru -Syu --noconfirm

# Install Dart SDK
paru -S --needed --noconfirm dart

# Install Podman tooling
paru -S --needed --noconfirm podman podman-compose

# Verify Dart installation
dart --version  # Should be >= 3.0
```

### Development Workflow
```bash
# Navigate to package directory
cd packages/<package_name>

# Create new package
dart create -t package .        # For library packages
dart create -t console .        # For CLI packages

# Install dependencies
dart pub get

# Run tests
dart test                       # Run all tests
dart test --coverage=coverage   # With coverage

# Static analysis
dart analyze

# Format code
dart format lib/ bin/ test/
```

### CLI Commands (dartian_cli)
```bash
# Global activation
cd packages/dartian_cli
dart pub global activate -s path .

# CLI commands (when implemented)
dartian version                          # Show version
dartian help                             # Show help
dartian new <project>                    # Create new project
dartian serve                            # Start dev server with hot reload
dartian make:controller <name>           # Generate controller
dartian make:model <name>                # Generate model
dartian make:migration <name>            # Generate migration
dartian make:request <name>              # Generate request validator
dartian make:provider <name>             # Generate service provider
dartian make:view <name>                 # Generate view template
dartian make:lang <locale>               # Generate language file
dartian make:test <name>                 # Generate test file
dartian migrate                          # Run migrations
dartian migrate:rollback                 # Rollback migration
dartian queue:work                       # Start queue worker
dartian schedule:run                     # Start scheduler
dartian build exe                        # Build AOT executable
dartian build aot-snapshot               # Build AOT snapshot
```

### Testing & Quality
```bash
# Run tests for all packages
for dir in packages/*/; do
  cd "$dir"
  dart test
  cd ../..
done

# Lint all packages
./scripts/lint.sh

# Test coverage (requires >= 95%)
./scripts/test-coverage.sh
```

### Build & Deployment
```bash
# Build AOT executable
dartian build exe
./build/dartian-aot version

# Build with Podman
podman build -t dartian:latest .
podman run --rm dartian:latest version

# Start stack with podman-compose
podman-compose up -d
podman-compose down

# Build WASM (experimental)
./scripts/build-wasi.sh
```

### Git & CI/CD Workflow
```bash
# Standard commit flow (work on main branch)
git add .
git commit -m "type: description"
git push origin main

# Monitor CI after push
sleep 30
gh run list --limit 1
gh run view

# If CI fails, investigate logs
gh run view --log-failed
```

## Architecture Guidelines

### Monorepo Dependencies
- Use path dependencies for internal packages in `pubspec.yaml`:
  ```yaml
  dependencies:
    dartian_core:
      path: ../dartian_core
  ```

### Testing Requirements
- **100% test coverage** required for each module
- Use `@Tag('integration')` for tests requiring external services (PostgreSQL, Redis)
- Mark WASM tests with `@Tag('wasm')` for conditional execution

### Error Handling Strategy
1. Capture complete stack trace
2. Search web with generic terms first (e.g., "dart shelf middleware error")
3. Progress to specific terms if needed
4. Fetch official documentation when available
5. Test proposed solutions before committing
6. If 3 approaches fail, brainstorm alternatives

### Code Generation
- Use `build_runner` for compile-time code generation
- Auto-discovery patterns for services and providers
- Run generation: `dart run build_runner build`

### Security Considerations
- Never commit secrets (.env files, credentials)
- Implement CORS with production allowlists
- Use CSRF tokens for state-changing operations
- Hash passwords with argon2 or bcrypt
- Validate JWT tokens properly
- Escape HTML in templates by default

## Development Principles

### Autonomous Development Flow
For each implementation phase:

1. **Preparation**: Create todo list, research (generic → specific), fetch documentation
2. **Synchronization**: `paru -Syu --noconfirm`
3. **Implementation**: Code, install dependencies via paru
4. **Validation**:
   - `dart test` (if fails: investigate, research, fix, repeat)
   - `dart analyze` (if fails: fix, repeat)
5. **Commit**: When both pass
6. **CI Monitoring**:
   - `sleep 30 && gh run list --limit 1 && gh run view`
   - If running: wait and check again
   - If failed: investigate logs, research, fix, repeat from step 4
7. **Completion**: Proceed to next task

### Research Tools Available
- **brave-search** or **WebSearch**: Web research (use generic → specific approach)
- **WebFetch**: Download official documentation
- **context7**: Specialized documentation search

### Commit Conventions
- Use semantic commit types: `init:`, `feat:`, `fix:`, `test:`, `docs:`, `chore:`, `ci:`
- Never add co-authors to commits (including Claude)
- Commit frequently after successful validation
- Push directly to main after tests pass

### Adaptation Philosophy
You have full autonomy to adapt as needed for project success. Before significant architectural changes:
1. Brainstorm alternatives
2. Weigh pros/cons
3. Document decision in commit message

## Key Dependencies (When Implemented)

### HTTP Layer
- `shelf: ^1.4.1` - HTTP server foundation
- `shelf_router: ^1.2.0` - Routing

### Data Layer
- `drift: ^2.14.0` - SQL ORM
- `sqlite3: ^3.2.0` - SQLite driver
- `postgres: ^3.0.0` - PostgreSQL driver

### Dependency Injection
- `get_it: ^8.0.0` - Service locator
- `build_runner: ^2.4.0` - Code generation
- `source_gen: ^1.4.0` - Code generation utilities

### Background Processing
- `redis: ^4.8.0` - Redis client
- `cron: ^0.7.0` - Scheduler

### Utilities
- `args: ^2.4.0` - CLI argument parsing
- `watcher: ^1.1.0` - File watching for hot reload
- `mustache_template: ^2.0.0` - Template engine
- `crypto: ^3.0.0` - Cryptographic functions

### Development
- `test: ^1.24.0` - Testing framework
- `coverage` - Code coverage (dart pub global activate)

## Compilation Targets

1. **Development**: JIT with hot reload (`dartian serve`)
2. **Production AOT**: Native executable (`dart compile exe -O2`)
3. **Container**: Podman multi-stage build with AOT binary
4. **WASM/WASI**: Experimental support (`dart compile wasm`)

## CI/CD Pipeline

GitHub Actions workflow on main branch:
- Matrix testing (Dart 3.0 and latest)
- Run tests with coverage for all packages
- Lint with `dart analyze`
- Aggregate coverage reports
- Fail if coverage < 95%

## Important Notes

- This is a **greenfield project** - implementation follows PLAN.md phased approach
- Work directly on `main` branch (no feature branches in initial implementation)
- Use `podman` instead of `docker` everywhere
- Always research errors using web search before attempting fixes
- Maintain test coverage >= 95% at all times
- Each package should be independently testable
- Integration tests should be tagged appropriately

## License

AGPLv3 with commercial dual-licensing option
