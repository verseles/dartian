import 'package:dartian_core/src/support/global.dart';
import 'package:test/test.dart';

void main() {
  group('Global Helpers', () {
    test('tap', () {
      int value = 1;
      final result = tap(value, (int v) {
        value = v + 1;
      });
      expect(result, 1);
      expect(value, 2);
    });

    test('value', () {
      expect(value('foo'), 'foo');
      expect(value(() => 'foo'), 'foo');
    });

    test('blank', () {
      expect(blank(null), isTrue);
      expect(blank(''), isTrue);
      expect(blank('   '), isTrue);
      expect(blank([]), isTrue);
      expect(blank({}), isTrue);
      expect(blank(0), isFalse);
      expect(blank(false), isFalse);
      expect(blank('foo'), isFalse);
    });

    test('filled', () {
      expect(filled(null), isFalse);
      expect(filled(''), isFalse);
      expect(filled('foo'), isTrue);
    });

    test('retry', () async {
      int attempts = 0;
      try {
        await retry(3, () async {
          attempts++;
          throw Exception('fail');
        }, delay: Duration(milliseconds: 10));
      } catch (e) {
        // expected
      }
      expect(attempts, 3);

      attempts = 0;
      final result = await retry(3, () async {
        attempts++;
        if (attempts < 2) throw Exception('fail');
        return 'success';
      }, delay: Duration(milliseconds: 10));
      expect(result, 'success');
      expect(attempts, 2);
    });
  });
}
