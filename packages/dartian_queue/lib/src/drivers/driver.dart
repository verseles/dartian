import '../queue.dart';

abstract class QueueDriver {
  Future<void> push(Job job);
  Future<Job?> pop(String queue);
  Future<void> ack(Job job);
}
