import '../queue.dart';
import 'driver.dart';

class SyncQueue implements QueueDriver {
  @override
  Future<void> push(Job job) async {
    await job.handle();
  }

  @override
  Future<Job?> pop(String queue) async {
    return null;
  }

  @override
  Future<void> ack(Job job) async {
    // No-op
  }
}
