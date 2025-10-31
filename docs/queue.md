# Queues

During a web request, some tasks, like sending an email or processing an uploaded file, can take a long time. Offloading these time-consuming tasks to a separate process is a common pattern to ensure your application's HTTP responses are fast.

Dartian's queue system provides a unified API across a variety of different queue backends, allowing you to defer the processing of a time-consuming task until a later time.

## Creating Jobs

A job is a class that represents a task to be executed on the queue. All jobs are stored in the `app/jobs` directory. You can generate a new job using the `make:job` CLI command:

```bash
dartian make:job ProcessPodcast
```

This will create a new `ProcessPodcast.dart` file in `app/jobs`. A job class is simple: it must have a `handle()` method that will be called when the job is processed by the queue worker.

```dart
// app/jobs/process_podcast.dart
import 'package:dartian_queue/dartian_queue.dart';

class ProcessPodcast extends Job {
  final int podcastId;

  ProcessPodcast(this.podcastId);

  @override
  Future<void> handle() async {
    // Logic to process the podcast...
    print('Processing podcast $podcastId');
  }
}
```

## Dispatching Jobs

You can dispatch a job from anywhere in your application. The easiest way is to use the `dispatch` helper function.

```dart
import 'package:dartian_queue/dartian_queue.dart';
import 'app/jobs/process_podcast.dart';

// In a controller...
Future<DartianResponse> process(DartianRequest request) async {
  final int podcastId = 123;
  await dispatch(ProcessPodcast(podcastId));

  return DartianResponse.text('Podcast is being processed!');
}
```

The job will be sent to your configured queue driver to be processed by a worker.

## Queue Drivers

Dartian supports multiple queue drivers:

- **`sync`**: Jobs are executed immediately in the current process. This is useful for local development and testing.
- **`isolate`**: Jobs are executed in a separate Dart isolate, preventing them from blocking the main thread.

The queue driver is configured in the `config/queue.dart` file and can be set via the `QUEUE_DRIVER` environment variable in your `.env` file.

## Running the Queue Worker

To process jobs that have been dispatched to the queue, you need to run the queue worker. The worker will listen for new jobs and execute them as they become available.

You can start the queue worker using the `queue:work` CLI command:

```bash
dartian queue:work
```

The worker will continue to run and process jobs until you manually stop it.
