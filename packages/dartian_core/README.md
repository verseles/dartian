# dartian_core

Core utilities and telemetry hooks for the Dartian framework.

## Features

- Telemetry hooks for request/response monitoring
- Core helper functions
- Base interfaces and types

## Installation

```yaml
dependencies:
  dartian_core: ^1.0.0
```

## Usage

```dart
import 'package:dartian_core/dartian_core.dart';

// Register telemetry hooks
TelemetryHooks.onRequest((request) {
  print('Request: ${request.url}');
});

TelemetryHooks.onResponse((response, duration) {
  print('Response: ${response.statusCode} in ${duration.inMilliseconds}ms');
});
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework - a Laravel-inspired web framework for Dart.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
