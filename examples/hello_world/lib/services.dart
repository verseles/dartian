/// Example services demonstrating dependency injection patterns.
library;

/// A singleton service that provides greetings.
class GreetingService {
  final List<String> _greetings = [
    'Hello',
    'Hi',
    'Welcome',
    'Greetings',
    'Hey there',
  ];

  int _index = 0;

  /// Returns a greeting message.
  String greet(String name) {
    final greeting = _greetings[_index];
    _index = (_index + 1) % _greetings.length;
    return '$greeting, $name!';
  }

  /// Returns a simple hello message.
  String hello() => 'Hello from Dartian!';
}

/// A factory service that provides time-related functionality.
/// Each request gets a new instance.
class TimeService {
  final DateTime _createdAt = DateTime.now();

  /// Returns the current time formatted as a string.
  String currentTime() {
    final now = DateTime.now();
    return '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';
  }

  /// Returns the current date formatted as a string.
  String currentDate() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  /// Returns when this service instance was created.
  DateTime get createdAt => _createdAt;

  String _pad(int n) => n.toString().padLeft(2, '0');
}
