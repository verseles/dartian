# dartian_cli

Command-line interface for Dartian framework with code generators and dev server.

## Features

- Project scaffolding
- Development server with hot reload
- Code generators (controllers, models, views, etc.)
- Database migration runner
- AOT build support

## Installation

```bash
dart pub global activate dartian_cli
```

## Usage

```bash
# Create new project
dartian new my_app
cd my_app

# Start development server
dartian serve

# Generate files
dartian make:controller UserController
dartian make:model User
dartian make:migration create_users_table
dartian make:view home

# Run migrations
dartian migrate
dartian migrate:rollback

# Build for production
dartian build exe
```

## Commands

| Command | Description |
|---------|-------------|
| `dartian new <name>` | Create new project |
| `dartian serve` | Start dev server |
| `dartian make:controller` | Generate controller |
| `dartian make:model` | Generate model |
| `dartian make:migration` | Generate migration |
| `dartian make:view` | Generate view |
| `dartian migrate` | Run migrations |
| `dartian build` | Build executable |

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
