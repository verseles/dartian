import 'dart:isolate';
import 'dart:async';
import '../queue.dart';
import 'driver.dart';

class IsolateJob extends Job {
  final Function(SendPort) handler;
  @override
  final SendPort sendPort;

  IsolateJob(this.handler, this.sendPort);

  @override
  Future<void> handle() async {
    handler(sendPort);
  }
}

class IsolateQueue implements QueueDriver {
  final List<Isolate> _isolates = [];

  @override
  Future<void> push(Job job) async {
    if (job is IsolateJob) {
      final isolate = await Isolate.spawn(job.handler, job.sendPort);
      _isolates.add(isolate);
    }
  }

  @override
  Future<Job?> pop(String queue) async {
    return null;
  }

  @override
  Future<void> ack(Job job) async {
    // No-op
  }

  void dispose() {
    for (final isolate in _isolates) {
      isolate.kill();
    }
  }
}
