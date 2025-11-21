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
  final ReceivePort _responsePort;
  StreamSubscription? _responseSubscription;
  final Map<String, Completer<Map<String, dynamic>>> _pendingJobs = {};
  bool _isRunning = false;

  IsolateQueueWorker(this._sendPort) : _responsePort = ReceivePort();

  @override
  Future<void> start() async {
    if (_isRunning) return;

    _isRunning = true;

    // Listen to responses from isolate
    _responseSubscription = _responsePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final jobId = message['id'] as String?;
        if (jobId != null && _pendingJobs.containsKey(jobId)) {
          _pendingJobs[jobId]!.complete(message);
          _pendingJobs.remove(jobId);
        }
      }
    });
  }

  @override
  Future<void> stop() async {
    if (!_isRunning) return;

    _isRunning = false;
    await _responseSubscription?.cancel();
    _responseSubscription = null;
    _responsePort.close();

    // Complete any pending jobs with error
    for (final completer in _pendingJobs.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Worker stopped'));
      }
    }
    _pendingJobs.clear();
  }

  @override
  Future<void> process(Job job) async {
    if (!_isRunning) {
      throw StateError('Worker not started. Call start() first.');
    }

    final completer = Completer<Map<String, dynamic>>();
    _pendingJobs[job.id] = completer;

    // Send job to isolate for processing with response port
    _sendPort.send({
      'type': 'job',
      'data': job.toJson(),
      'responsePort': _responsePort.sendPort,
    });

    // Wait for result
    final result = await completer.future;
    final processedJob = Job.fromJson(result);
    job.status = processedJob.status;
    job.error = processedJob.error;
  }
}

/// Spawn an isolate worker
Future<IsolateQueueWorker> spawnIsolateWorker() async {
  final commandPort = ReceivePort();
  await Isolate.spawn(_isolateWorker, commandPort.sendPort);

  // Wait for isolate to send its SendPort
  final isolateSendPort = await commandPort.first as SendPort;
  commandPort.close();

  return IsolateQueueWorker(isolateSendPort);
}

/// Isolate worker function
void _isolateWorker(SendPort mainSendPort) {
  final receivePort = ReceivePort();

  // Send this isolate's SendPort back to main isolate
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final type = message['type'] as String?;

      if (type == 'job') {
        final jobData = message['data'] as Map<String, dynamic>;
        final responseSendPort = message['responsePort'] as SendPort;
        final job = Job.fromJson(jobData);

        // Process job in isolate
        try {
          // Simulate job processing
          job.status = JobStatus.completed;
          responseSendPort.send(job.toJson());
        } catch (e) {
          job.status = JobStatus.failed;
          job.error = e.toString();
          responseSendPort.send(job.toJson());
        }
      }
    }
  });
}
