import 'dart:async';
import '../queue.dart';

/// Synchronous queue implementation using in-memory storage
class SyncQueue implements Queue {
  final Map<String, List<Job>> _queues = {};

  @override
  Future<String> push(String queue, String payload) async {
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      queue: queue,
      payload: payload,
      createdAt: DateTime.now(),
    );

    _queues.putIfAbsent(queue, () => []).add(job);
    return job.id;
  }

  @override
  Future<Job?> pop(String queue) async {
    final jobs = _queues[queue];
    if (jobs == null || jobs.isEmpty) return null;

    return jobs.removeAt(0);
  }

  @override
  Future<int> size(String queue) async {
    return _queues[queue]?.length ?? 0;
  }

  @override
  Future<void> clear(String queue) async {
    _queues[queue]?.clear();
  }
}

/// Synchronous queue worker
class SyncQueueWorker implements QueueWorker {
  bool _isRunning = false;

  @override
  Future<void> start() async {
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
  }

  @override
  Future<void> process(Job job) async {
    // Simple synchronous processing
    // In a real implementation, you'd call a job handler
    job.status = JobStatus.completed;
  }
}
