# dartian_redis

Redis client for Dartian with caching, pub/sub, and distributed locks support.

## Features

- Redis connection management
- Cache with TTL support
- Pub/Sub messaging
- Integration with Dartian telemetry

## Installation

```yaml
dependencies:
  dartian_redis: ^1.0.0
```

## Usage

```dart
import 'package:dartian_redis/dartian_redis.dart';

// Create client
final redis = RedisClient(host: 'localhost', port: 6379);
await redis.connect();

// Cache operations
final cache = Cache(redis);
await cache.set('key', 'value', ttl: Duration(minutes: 5));
final value = await cache.get('key');

// Pub/Sub
final pubsub = PubSub(redis);
pubsub.subscribe('channel', (message) {
  print('Received: $message');
});
await pubsub.publish('channel', 'Hello!');

// Cleanup
await redis.close();
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
