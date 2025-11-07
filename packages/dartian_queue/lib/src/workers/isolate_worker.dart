import 'dart:async';
import 'dart:isolate';
import '../queue.dart';
import '../queue_manager.dart';
import 'sync_worker.dart';

/// Isolate-based queue implementation
class IsolateQueue implements Queue {
  final SyncQueue _syncQueue = SyncQueue();

  @override
  Future<String> push(String queue, String payload) async {
    return _syncQueue.push(queue, payload);
  }

  @override
  Future<Job?> pop(String queue) async {
    return _syncQueue.pop(queue);
  }

  @override
  Future<int> size(String queue) async {
    return _syncQueue.size(queue);
  }

  @override
  Future<void> clear(String queue) async {
    return _syncQueue.clear(queue);
  }
}

/// Isolate queue worker that processes jobs in a separate isolate
class IsolateQueueWorker implements QueueWorker {
  final SendPort _sendPort;
  late final ReceivePort _receivePort;
  late final StreamController<Job> _jobController;
  bool _isRunning = false;

  IsolateQueueWorker(this._sendPort);

  @override
  Future<void> start() async {
    if (_isRunning) return;

    _isRunning = true;
    _receivePort = ReceivePort();
    _jobController = StreamController<Job>.broadcast();
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _receivePort.close();
    await _jobController.close();
  }

  @override
  Future<void> process(Job job) async {
    // Send job to isolate for processing
    _sendPort.send(job.toJson());

    // Listen for result
    final result = await _receivePort.first;
    if (result is Map<String, dynamic>) {
      final processedJob = Job.fromJson(result);
      job.status = processedJob.status;
      job.error = processedJob.error;
    }
  }
}

/// Spawn an isolate worker
Future<IsolateQueueWorker> spawnIsolateWorker() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateWorker, receivePort.sendPort);
  return IsolateQueueWorker(receivePort.sendPort);
}

/// Isolate worker function
void _isolateWorker(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((message) {
    if (message is Map<String, dynamic>) {
      final job = Job.fromJson(message);

      // Process job in isolate
      try {
        // Simulate job processing
        job.status = JobStatus.completed;
        sendPort.send(job.toJson());
      } catch (e) {
        job.status = JobStatus.failed;
        job.error = e.toString();
        sendPort.send(job.toJson());
      }
    }
  });
}
