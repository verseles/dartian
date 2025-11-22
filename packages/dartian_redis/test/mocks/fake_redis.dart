import 'dart:async';

/// In-memory fake Redis implementation for testing
class FakeRedis {
  final Map<String, String> _data = {};
  final Map<String, DateTime> _expirations = {};
  final List<String> _subscribedChannels = [];
  final StreamController<PubSubEvent> _pubsubController =
      StreamController<PubSubEvent>.broadcast();

  /// Get the pub/sub stream
  Stream<PubSubEvent> get pubsubStream => _pubsubController.stream;

  /// Execute a Redis command
  Future<dynamic> sendCommand(List<dynamic> command) async {
    if (command.isEmpty) {
      throw ArgumentError('Command cannot be empty');
    }

    final cmd = command[0].toString().toUpperCase();

    switch (cmd) {
      case 'SET':
        if (command.length < 3) {
          throw ArgumentError('SET requires at least 2 arguments');
        }
        final key = command[1].toString();
        final value = command[2].toString();
        _data[key] = value;
        _expirations.remove(key);
        return 'OK';

      case 'SETEX':
        if (command.length < 4) {
          throw ArgumentError('SETEX requires 3 arguments');
        }
        final key = command[1].toString();
        final seconds = int.parse(command[2].toString());
        final value = command[3].toString();
        _data[key] = value;
        _expirations[key] = DateTime.now().add(Duration(seconds: seconds));
        return 'OK';

      case 'GET':
        if (command.length < 2) {
          throw ArgumentError('GET requires 1 argument');
        }
        final key = command[1].toString();
        _checkExpiration(key);
        return _data[key];

      case 'DEL':
        if (command.length < 2) {
          throw ArgumentError('DEL requires at least 1 argument');
        }
        int count = 0;
        for (int i = 1; i < command.length; i++) {
          final key = command[i].toString();
          if (_data.remove(key) != null) {
            _expirations.remove(key);
            count++;
          }
        }
        return count;

      case 'EXISTS':
        if (command.length < 2) {
          throw ArgumentError('EXISTS requires 1 argument');
        }
        final key = command[1].toString();
        _checkExpiration(key);
        return _data.containsKey(key) ? 1 : 0;

      case 'EXPIRE':
        if (command.length < 3) {
          throw ArgumentError('EXPIRE requires 2 arguments');
        }
        final key = command[1].toString();
        final seconds = int.parse(command[2].toString());
        if (!_data.containsKey(key)) {
          return 0;
        }
        _expirations[key] = DateTime.now().add(Duration(seconds: seconds));
        return 1;

      case 'TTL':
        if (command.length < 2) {
          throw ArgumentError('TTL requires 1 argument');
        }
        final key = command[1].toString();
        if (!_data.containsKey(key)) {
          return -2; // Key doesn't exist
        }
        if (!_expirations.containsKey(key)) {
          return -1; // No expiration set
        }
        _checkExpiration(key);
        if (!_data.containsKey(key)) {
          return -2; // Just expired
        }
        final remaining = _expirations[key]!
            .difference(DateTime.now())
            .inSeconds;
        return remaining > 0 ? remaining : -2;

      case 'INCR':
        if (command.length < 2) {
          throw ArgumentError('INCR requires 1 argument');
        }
        final key = command[1].toString();
        final current = int.tryParse(_data[key] ?? '0') ?? 0;
        final newValue = current + 1;
        _data[key] = newValue.toString();
        return newValue;

      case 'DECR':
        if (command.length < 2) {
          throw ArgumentError('DECR requires 1 argument');
        }
        final key = command[1].toString();
        final current = int.tryParse(_data[key] ?? '0') ?? 0;
        final newValue = current - 1;
        _data[key] = newValue.toString();
        return newValue;

      case 'INCRBY':
        if (command.length < 3) {
          throw ArgumentError('INCRBY requires 2 arguments');
        }
        final key = command[1].toString();
        final increment = int.parse(command[2].toString());
        final current = int.tryParse(_data[key] ?? '0') ?? 0;
        final newValue = current + increment;
        _data[key] = newValue.toString();
        return newValue;

      case 'DECRBY':
        if (command.length < 3) {
          throw ArgumentError('DECRBY requires 2 arguments');
        }
        final key = command[1].toString();
        final decrement = int.parse(command[2].toString());
        final current = int.tryParse(_data[key] ?? '0') ?? 0;
        final newValue = current - decrement;
        _data[key] = newValue.toString();
        return newValue;

      case 'FLUSHDB':
        _data.clear();
        _expirations.clear();
        return 'OK';

      case 'SUBSCRIBE':
        if (command.length < 2) {
          throw ArgumentError('SUBSCRIBE requires at least 1 argument');
        }
        for (int i = 1; i < command.length; i++) {
          final channel = command[i].toString();
          if (!_subscribedChannels.contains(channel)) {
            _subscribedChannels.add(channel);
          }
        }
        return 'OK';

      case 'UNSUBSCRIBE':
        if (command.length < 2) {
          throw ArgumentError('UNSUBSCRIBE requires at least 1 argument');
        }
        for (int i = 1; i < command.length; i++) {
          final channel = command[i].toString();
          _subscribedChannels.remove(channel);
        }
        return 'OK';

      case 'PUBLISH':
        if (command.length < 3) {
          throw ArgumentError('PUBLISH requires 2 arguments');
        }
        final channel = command[1].toString();
        final message = command[2].toString();
        _pubsubController.add(PubSubEvent(channel, message));
        return _subscribedChannels.contains(channel) ? 1 : 0;

      case 'AUTH':
        // Always succeed for testing
        return 'OK';

      case 'SELECT':
        // Always succeed for testing
        return 'OK';

      default:
        throw UnsupportedError('Command $cmd not implemented in fake Redis');
    }
  }

  /// Check and remove expired keys
  void _checkExpiration(String key) {
    final expiration = _expirations[key];
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      _data.remove(key);
      _expirations.remove(key);
    }
  }

  /// Clear all data
  void clear() {
    _data.clear();
    _expirations.clear();
    _subscribedChannels.clear();
  }

  /// Close the fake Redis
  Future<void> close() async {
    await _pubsubController.close();
  }
}

/// Pub/Sub event
class PubSubEvent {
  final String channel;
  final String message;
  final DateTime timestamp;

  PubSubEvent(this.channel, this.message) : timestamp = DateTime.now();
}
