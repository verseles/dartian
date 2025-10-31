import 'dart:async';
import 'package:cron/cron.dart';

class Scheduler {
  final Cron _cron = Cron();

  void call(FutureOr<dynamic> Function() task) {
    _lastTask = task;
  }

  void cron(String expression) {
    if (_lastTask != null) {
      _cron.schedule(Schedule.parse(expression), _lastTask!);
      _lastTask = null;
    }
  }

  void everyMinute() => cron('* * * * *');
  void hourly() => cron('0 * * * *');
  void daily() => cron('0 0 * * *');
  void weekly() => cron('0 0 * * 0');

  void start() {
    // The `cron` package handles the scheduling and execution,
    // so we don't need to do anything here.
  }

  Future<void> stop() async {
    await _cron.close();
  }

  FutureOr<dynamic> Function()? _lastTask;
}
