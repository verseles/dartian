# dartian_queue

Job queue system for Dartian with sync, isolate, and Redis-backed drivers.

## Features

- Multiple queue drivers (sync, isolate, Redis)
- Job retry mechanism
- Failure handling
- Queue priorities
- Delayed jobs

## Installation

```yaml
dependencies:
  dartian_queue: ^1.0.0
```

## Usage

```dart
import 'package:dartian_queue/dartian_queue.dart';

// Create queue manager
final queue = QueueManager();

// Register a job handler
queue.register<SendEmailJob>((job) async {
  await sendEmail(job.email, job.subject, job.body);
});

// Dispatch a job
await queue.dispatch(SendEmailJob(
  email: 'user@example.com',
  subject: 'Welcome!',
  body: 'Hello World',
));

// With delay
await queue.dispatch(job, delay: Duration(minutes: 5));

// Start worker
await queue.work();
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
