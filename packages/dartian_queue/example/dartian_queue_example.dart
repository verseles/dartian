import 'package:dartian_queue/dartian_queue.dart';

// A simple job for demonstration purposes.
class ExampleJob extends Job {
  final String message;

  ExampleJob(this.message);

  @override
  Future<void> handle() async {
    print('Processing job: $message');
  }
}

void main() async {
  // 1. Create a queue instance.
  final queue = SyncQueue();

  // 2. Create a job.
  final job = ExampleJob('Hello, Dartian!');

  // 3. Push the job to the queue.
  await queue.push(job);

  // 4. In a real application, a worker would pop and process the job.
  // For this example, we can simulate it.
  final poppedJob = await queue.pop('default');
  if (poppedJob != null) {
    await poppedJob.handle();
    await queue.ack(poppedJob);
  }
}
