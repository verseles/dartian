# Dartian Framework

<p align="center">
  <img src="https://raw.githubusercontent.com/dartian/framework/main/logo.png" alt="Dartian Logo" width="200"/>
</p>

<p align="center">
  <strong>A powerful, opinionated, and productive server-side framework for Dart.</strong>
</p>

<p align="center">
  <a href="https://github.com/dartian/framework/actions/workflows/ci.yml"><img src="https://github.com/dartian/framework/actions/workflows/ci.yml/badge.svg" alt="Build Status"></a>
  <a href="https://opensource.org/licenses/AGPL-3.0"><img src="https://img.shields.io/badge/License-AGPL%20v3.0-blue.svg" alt="License: AGPL v3"></a>
</p>

---

## About Dartian

Dartian is a modern, backend framework for the Dart language, designed for building scalable, maintainable, and high-performance web applications, APIs, and microservices. It is heavily inspired by the elegance and productivity of frameworks like Laravel and Ruby on Rails, bringing familiar patterns and a rich feature set to the Dart ecosystem.

Our philosophy is to provide a robust, "batteries-included" experience that allows developers to focus on writing business logic instead of boilerplate. With powerful features like a service container, an elegant ORM, a fluent routing engine, and integrated support for queues, caching, and more, Dartian provides the tools you need to build amazing applications.

## Key Features

- **Fluent Routing Engine**: A simple and expressive API for defining routes and handling requests.
- **Service Container & DI**: Powerful dependency injection to manage class dependencies and write clean, testable code.
- **Elegant ORM**: A beautiful, Eloquent-like API built on top of the powerful [Drift](https://drift.simonbinder.eu/) library.
- **Integrated Queue System**: Offload long-running tasks to background jobs with support for synchronous and isolate-based drivers.
- **Caching Abstraction**: A unified API for caching with an in-memory driver.
- **Task Scheduling**: A cron-based scheduler to run recurring tasks with a fluent API.
- **Server-Side Views**: Render HTML templates with Mustache.
- **Internationalization**: A simple system for multi-language support.
- **Command-Line Interface**: `dartian_cli` for code generation, application management, and more.

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) version 3.0.0 or later.

### Installation & Project Creation

1.  **Activate the CLI:** (Coming Soon - Manual setup for now)

2.  **Create a new project:**
    ```bash
    dartian new my_awesome_project
    ```

3.  **Navigate to your project directory:**
    ```bash
    cd my_awesome_project
    ```

4.  **Install dependencies:**
    ```bash
    dart pub get
    ```

5.  **Run the development server:**
    ```bash
    dartian serve
    ```

Your application will be available at `http://localhost:8080`.

### Hello World Example

Define a route in `routes/web.dart`:

```dart
import 'package:dartian_router/dartian_router.dart';
import 'package:dartian_http/dartian_http.dart';

void register(Router router) {
  router.get('/', (DartianRequest request) {
    return DartianResponse.text('Hello, Dartian!');
  });
}
```

## Documentation

For more detailed information, please refer to our official documentation (coming soon).

- [Installation Guide](./docs/installation.md)
- [Routing](./docs/routing.md)
- [ORM & Database](./docs/orm.md)
- [Queues](./docs/queue.md)
- [Views](./docs/views.md)
- [Internationalization](./docs/i18n.md)
- [Deployment](./docs/deployment.md)

## License

The Dartian Framework is open-sourced software licensed under the [AGPLv3](https://opensource.org/licenses/AGPL-3.0).

For commercial use, please contact us for licensing options.

## Contributing

We welcome contributions from the community! Please read our [Contributing Guide](CONTRIBUTING.md) to learn how you can help.
