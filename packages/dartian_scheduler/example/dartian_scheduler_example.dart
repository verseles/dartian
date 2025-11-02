import 'package:dartian_scheduler/dartian_scheduler.dart';

void myTask() {
  print('MyTask is running...');
}

void main() {
  final scheduler = Scheduler();
  scheduler(myTask);
  scheduler.everyMinute();
  print('Task scheduled to run every minute!');
}
