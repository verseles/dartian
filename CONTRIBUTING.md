# Contributing to the Dartian Framework

First off, thank you for considering contributing to Dartian! It's people like you that make the open-source community such a great place. We welcome any form of contribution, from reporting bugs and submitting feedback to writing code and improving documentation.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please open an issue on our GitHub repository. When you are creating a bug report, please include as many details as possible:

-   A clear and descriptive title.
-   A description of the problem, including the steps to reproduce it.
-   The expected behavior and what happened instead.
-   Your Dart version and operating system.
-   Any relevant code snippets or logs.

### Submitting Feature Requests

If you have an idea for a new feature, we'd love to hear it! Open an issue with a clear description of the feature, why you think it would be valuable, and any implementation ideas you might have.

### Pull Requests

We are happy to accept pull requests! If you'd like to contribute code, please follow these steps:

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** to your local machine.
3.  **Create a new branch** for your feature or bug fix: `git checkout -b feature/my-new-feature` or `git checkout -b fix/my-bug-fix`.
4.  **Make your changes.** Please ensure your code adheres to the project's coding standards.
5.  **Run the tests** to ensure everything is still working correctly: `dart test`.
6.  **Commit your changes** with a descriptive commit message. We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
7.  **Push your branch** to your fork on GitHub.
8.  **Open a pull request** to the `main` branch of the official Dartian repository.

## Development Setup

To get started with local development:

1.  Fork and clone the repository.
2.  Navigate to the root of the project.
3.  Install all dependencies for the monorepo workspace:
    ```bash
    dart pub get
    ```

## Running Tests

To run the entire test suite for the framework, you can run the following command from the root of the project for each package:

```bash
dart test packages/<package_name>
```

For example:
```bash
dart test packages/dartian_http
```

Please ensure that all tests are passing before submitting a pull request.

## Coding Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style). To ensure your code is formatted correctly, you can run the Dart formatter:

```bash
dart format .
```

We also use `dart analyze` to check for any static analysis issues. Please make sure there are no analysis errors before submitting your code.
