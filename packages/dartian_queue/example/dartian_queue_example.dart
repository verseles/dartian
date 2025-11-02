import 'package:dartian_queue/dartian_queue.dart';

class MyJob extends Job {
  @override
  Future<void> handle() async {
    print('MyJob is handling...');
  }
}

void main() async {
  final queue = Queue(SyncQueue());
  await queue.push(MyJob());
  print('Job pushed to queue!');
}
