# dartian_events

A simple event system for the Dartian framework.

## Features

-   Define events and listeners
-   Dispatch events to be handled by listeners

## Usage

Create an event:
```dart
class UserLoggedIn extends Event {
  final int userId;
  UserLoggedIn(this.userId);
}
```

Create a listener:
```dart
class SendWelcomeEmail implements Listener<UserLoggedIn> {
  @override
  void handle(UserLoggedIn event) {
    // Send a welcome email
  }
}
```
