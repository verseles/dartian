import 'dart:async';
import 'drivers/driver.dart';

abstract class Job {
  Future<void> handle();
}

class Queue {
  final QueueDriver driver;

  Queue(this.driver);

  Future<void> push(Job job) async {
    await driver.push(job);
  }
}
