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

    test('env', () {
      expect(env<String>('NON_EXISTENT_KEY', 'default'), 'default');
    });

    test('throwIf', () {
      expect(() => throwIf(true, Exception('error')), throwsException);
      expect(() => throwIf(false, Exception('error')), returnsNormally);
    });

    test('throwUnless', () {
      expect(() => throwUnless(false, Exception('error')), throwsException);
      expect(() => throwUnless(true, Exception('error')), returnsNormally);
    });

    test('dataGet', () {
      final data = {
        'products': {
          'desk': {'price': 100},
        },
      };
      expect(dataGet(data, 'products.desk.price'), 100);
    });

    test('dataSet', () {
      final data = <String, dynamic>{
        'products': <String, dynamic>{
          'desk': <String, dynamic>{'price': 100},
        },
      };
      dataSet(data, 'products.desk.price', 200);
      expect(dataGet(data, 'products.desk.price'), 200);
    });

    test('dataFill', () {
      final data = <String, dynamic>{
        'products': <String, dynamic>{
          'desk': <String, dynamic>{'price': 100},
        },
      };
      dataFill(data, 'products.desk.price', 200);
      expect(dataGet(data, 'products.desk.price'), 100); // Should not overwrite

      dataFill(data, 'products.desk.name', 'Table');
      expect(dataGet(data, 'products.desk.name'), 'Table');
    });

    test('head', () {
      expect(head([1, 2, 3]), 1);
      expect(head([]), isNull);
    });

    test('last', () {
      expect(last([1, 2, 3]), 3);
      expect(last([]), isNull);
    });
  });
}
