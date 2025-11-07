import 'dart:async';
import 'queue.dart';

/// Queue worker interface
abstract class QueueWorker {
  /// Start the worker
  Future<void> start();

  /// Stop the worker
  Future<void> stop();

  /// Process a job
  Future<void> process(Job job);
}

/// Queue manager for Dartian
class QueueManager {
  final Queue _queue;
  final QueueWorker _worker;
  bool _isRunning = false;
  StreamController<Job>? _jobController;

  QueueManager(this._queue, this._worker);

  /// Start processing jobs
  Future<void> start({String? queue}) async {
    if (_isRunning) return;

    _isRunning = true;
    final workingQueue = queue ?? 'default';

    _jobController = StreamController<Job>.broadcast();
    _worker.start();

    // Process jobs in a loop
    while (_isRunning) {
      final job = await _queue.pop(workingQueue);
      if (job != null) {
        _jobController?.add(job);
        await _worker.process(job);
      } else {
        // No jobs, wait a bit
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  /// Stop processing jobs
  Future<void> stop() async {
    _isRunning = false;
    await _worker.stop();
    await _jobController?.close();
  }

  /// Stream of jobs being processed
  Stream<Job> get jobStream => _jobController?.stream ?? const Stream.empty();

  /// Push a job to the queue
  Future<String> push(String queue, String payload) {
    return _queue.push(queue, payload);
  }

  /// Get queue size
  Future<int> size(String queue) {
    return _queue.size(queue);
  }
}
