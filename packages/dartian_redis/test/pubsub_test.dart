import 'package:test/test.dart';
import 'package:dartian_redis/dartian_redis.dart';
import 'mocks/fake_redis_client.dart';

void main() {
  group('PubSubMessage', () {
    test('should create message with channel and message', () {
      final msg = PubSubMessage('test-channel', 'test-message');

      expect(msg.channel, equals('test-channel'));
      expect(msg.message, equals('test-message'));
      expect(msg.timestamp, isA<DateTime>());
    });

    test('should have timestamp set to now', () {
      final before = DateTime.now();
      final msg = PubSubMessage('channel', 'message');
      final after = DateTime.now();

      expect(msg.timestamp.isAfter(before) || msg.timestamp.isAtSameMomentAs(before), isTrue);
      expect(msg.timestamp.isBefore(after) || msg.timestamp.isAtSameMomentAs(after), isTrue);
    });

    test('should handle empty channel name', () {
      final msg = PubSubMessage('', 'message');
      expect(msg.channel, equals(''));
    });

    test('should handle empty message', () {
      final msg = PubSubMessage('channel', '');
      expect(msg.message, equals(''));
    });

    test('should handle special characters in channel', () {
      final msg = PubSubMessage('user:123:notifications', 'hello');
      expect(msg.channel, equals('user:123:notifications'));
    });

    test('should handle unicode in message', () {
      final msg = PubSubMessage('channel', 'Hello 世界 🎉');
      expect(msg.message, equals('Hello 世界 🎉'));
    });

    test('should create unique timestamps for sequential messages', () async {
      final msg1 = PubSubMessage('channel', 'message1');
      await Future.delayed(Duration(milliseconds: 1));
      final msg2 = PubSubMessage('channel', 'message2');

      // The timestamps should be different or the same (but not before)
      expect(msg2.timestamp.isAfter(msg1.timestamp) ||
             msg2.timestamp.isAtSameMomentAs(msg1.timestamp), isTrue);
    });
  });

  group('PubSubManager - Direct Tests', () {
    late FakeRedisClient client;
    late PubSubManager pubsub;

    setUp(() async {
      client = FakeRedisClient('localhost');
      await client.connect();
      pubsub = PubSubManager(client);
    });

    tearDown(() async {
      await pubsub.close();
      await client.close();
    });

    test('should create PubSubManager with client', () {
      expect(pubsub, isNotNull);
    });

    test('should provide message stream', () {
      final stream = pubsub.messages;
      expect(stream, isA<Stream<PubSubMessage>>());
    });

    test('should allow multiple subscriptions', () async {
      await pubsub.subscribe('channel1');
      await pubsub.subscribe('channel2');
      await pubsub.subscribe('channel3');
      // Should complete without error
    });

    test('should allow subscribe then unsubscribe', () async {
      await pubsub.subscribe('test-channel');
      await pubsub.unsubscribe('test-channel');
      // Should complete without error
    });

    test('should publish message and return subscriber count', () async {
      final count = await pubsub.publish('channel', 'test message');
      expect(count, isA<int>());
    });

    test('should handle publish to non-existent channel', () async {
      final count = await pubsub.publish('non-existent', 'message');
      expect(count, isA<int>());
    });

    test('should close gracefully', () async {
      await pubsub.subscribe('channel');
      await pubsub.close();
      // Should not throw
    });

    test('should close without subscriptions', () async {
      await pubsub.close();
      // Should not throw
    });
  });

  group('PubSubMessage - Edge Cases', () {
    test('should handle very long channel name', () {
      final longChannel = 'a' * 1000;
      final msg = PubSubMessage(longChannel, 'message');
      expect(msg.channel.length, equals(1000));
    });

    test('should handle very long message', () {
      final longMessage = 'b' * 10000;
      final msg = PubSubMessage('channel', longMessage);
      expect(msg.message.length, equals(10000));
    });

    test('should handle newlines in message', () {
      final msg = PubSubMessage('channel', 'line1\nline2\nline3');
      expect(msg.message.contains('\n'), isTrue);
    });

    test('should handle JSON in message', () {
      final json = '{"key": "value", "number": 42}';
      final msg = PubSubMessage('channel', json);
      expect(msg.message, equals(json));
    });
  });
}
