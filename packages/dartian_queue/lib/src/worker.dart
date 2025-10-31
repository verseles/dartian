import 'dart:async';
import 'drivers/driver.dart';
import 'queue.dart';

class Worker {
  final QueueDriver _driver;
  bool _running = false;

  Worker(this._driver);

  Future<void> run({String queue = 'default'}) async {
    _running = true;
    while (_running) {
      final job = await _driver.pop(queue);
      if (job != null) {
        try {
          await job.handle();
          await _driver.ack(job);
        } catch (e) {
          // Handle failed job
        }
      }
    }
  }

  void stop() {
    _running = false;
  }
}
