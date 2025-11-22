# dartian_scheduler

Task scheduling for Dartian with cron expressions and timezone support.

## Features

- Cron expression support
- Fluent scheduling API
- Integration with job queues
- Timezone support
- Overlap prevention

## Installation

```yaml
dependencies:
  dartian_scheduler: ^1.0.0
```

## Usage

```dart
import 'package:dartian_scheduler/dartian_scheduler.dart';

// Create scheduler
final scheduler = Scheduler();

// Schedule tasks with fluent API
scheduler.call(() => print('Hello!')).everyMinute();

scheduler.call(cleanupTask).hourly();

scheduler.call(backupTask).dailyAt('03:00');

scheduler.call(reportTask).weekly();

// Schedule with cron expression
scheduler.cron('0 0 * * 1', () => print('Every Monday'));

// Start scheduler
await scheduler.start();
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
