import 'package:dartian_events/dartian_events.dart';
import 'package:test/test.dart';

class UserLoggedIn extends Event {
  final int userId;
  UserLoggedIn(this.userId);
}

class SendWelcomeEmail implements Listener<UserLoggedIn> {
  bool handled = false;
  @override
  void handle(UserLoggedIn event) {
    handled = true;
  }
}

void main() {
  group('Events', () {
    test('Listener handles an event', () {
      final event = UserLoggedIn(1);
      final listener = SendWelcomeEmail();
      listener.handle(event);
      expect(listener.handled, isTrue);
    });
  });
}
