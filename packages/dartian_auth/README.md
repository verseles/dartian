# dartian_auth

Authentication and security for Dartian with session, JWT, and bcrypt password hashing.

## Features

- Session-based authentication
- JWT token support
- bcrypt password hashing
- Auth middleware
- Rate limiting

## Installation

```yaml
dependencies:
  dartian_auth: ^1.0.0
```

## Usage

```dart
import 'package:dartian_auth/dartian_auth.dart';

// Hash passwords
final hashedPassword = await HashService.hash('secret123');
final isValid = await HashService.verify('secret123', hashedPassword);

// JWT tokens
final jwt = JwtService(secret: 'your-secret-key');
final token = jwt.sign({'userId': 123});
final payload = jwt.verify(token);

// Session authentication
final session = SessionManager();
final sessionId = await session.create({'userId': 123});
final data = await session.get(sessionId);

// Auth middleware
router.use(AuthMiddleware(jwt));
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
