# Contributing to Dartian

Thank you for your interest in contributing to Dartian! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## Getting Started

### Prerequisites

- Dart SDK >= 3.9.4
- Git
- A GitHub account

### Setup

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dartian.git
   cd dartian
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/verseles/dartian.git
   ```
4. Install dependencies for all packages:
   ```bash
   for dir in packages/*/; do
     (cd "$dir" && dart pub get)
   done
   ```

## Development Workflow

### Branch Strategy

- Work directly on `main` for small fixes
- Create feature branches for larger changes: `feature/your-feature-name`
- Create fix branches for bug fixes: `fix/issue-description`

### Making Changes

1. Sync with upstream:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. Make your changes in the appropriate package(s)

3. Run tests:
   ```bash
   cd packages/<package_name>
   dart test
   ```

4. Run analysis:
   ```bash
   dart analyze lib/
   ```

5. Format code:
   ```bash
   dart format lib/ bin/ test/
   ```

### Commit Messages

Use semantic commit messages:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

Examples:
```
feat(router): add support for route groups
fix(di): resolve circular dependency detection edge case
docs: update README with new examples
test(queue): add tests for Redis driver
```

### Pull Requests

1. Push your branch to your fork
2. Create a Pull Request against `main`
3. Fill out the PR template
4. Wait for CI to pass
5. Address any review feedback

## Code Style

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

### Key Points

- Use `dart format` before committing
- Maximum line length: 80 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Documentation

- All public classes and methods should have doc comments
- Use `///` for documentation comments
- Include examples in doc comments where helpful

```dart
/// A service that manages user authentication.
///
/// Example:
/// ```dart
/// final auth = AuthService();
/// await auth.login('user@example.com', 'password');
/// ```
class AuthService {
  /// Authenticates a user with email and password.
  ///
  /// Returns a [User] if successful, throws [AuthException] otherwise.
  Future<User> login(String email, String password) async {
    // ...
  }
}
```

## Testing

### Requirements

- All new features must have tests
- Bug fixes should include regression tests
- Maintain >= 95% test coverage

### Running Tests

```bash
# Run tests for a specific package
cd packages/dartian_di
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run all package tests
for dir in packages/*/; do
  echo "Testing $dir"
  (cd "$dir" && dart test)
done
```

### Test Structure

```dart
import 'package:test/test.dart';

void main() {
  group('ClassName', () {
    late ClassName instance;

    setUp(() {
      instance = ClassName();
    });

    tearDown(() {
      // Cleanup if needed
    });

    test('methodName does something', () {
      final result = instance.methodName();
      expect(result, equals(expectedValue));
    });
  });
}
```

## Package Structure

Each package should follow this structure:

```
packages/dartian_<name>/
├── lib/
│   ├── dartian_<name>.dart    # Main library export
│   └── src/                    # Implementation files
├── test/                       # Tests
├── pubspec.yaml               # Package manifest
└── README.md                  # Package documentation
```

## Adding a New Package

1. Create the package directory:
   ```bash
   mkdir packages/dartian_newpkg
   cd packages/dartian_newpkg
   dart create -t package .
   ```

2. Update `pubspec.yaml`:
   ```yaml
   name: dartian_newpkg
   description: Description of the package
   version: 0.0.1

   environment:
     sdk: ^3.9.4

   dependencies:
     dartian_core:
       path: ../dartian_core

   dev_dependencies:
     test: ^1.24.0
   ```

3. Create the main library file:
   ```dart
   // lib/dartian_newpkg.dart
   library dartian_newpkg;

   export 'src/main_class.dart';
   ```

4. Add tests in `test/`

5. Update the CI workflow if needed

## Reporting Issues

### Bug Reports

Include:
- Dart version (`dart --version`)
- Package version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages and stack traces

### Feature Requests

Include:
- Description of the feature
- Use case / motivation
- Proposed API (if applicable)
- Alternatives considered

## Questions?

- Open a [GitHub Discussion](https://github.com/verseles/dartian/discussions)
- Check existing issues for similar questions

## License

By contributing, you agree that your contributions will be licensed under the AGPLv3 license.
