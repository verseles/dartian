import 'package:dartian_events/dartian_events.dart';

class MyEvent extends Event {
  final String message;
  MyEvent(this.message);
}

class MyListener extends Listener<MyEvent> {
  @override
  void handle(MyEvent event) {
    print('Received event with message: ${event.message}');
  }
}

void main() {
  final event = MyEvent('Hello, World!');
  final listener = MyListener();
  listener.handle(event);
}
