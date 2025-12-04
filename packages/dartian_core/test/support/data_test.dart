import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  group('Data', () {
      test('data_get', () {
          final m = {'a': {'b': 1}};
          expect(data_get(m, 'a.b'), 1);
          expect(data_get(m, 'a.c', 2), 2);
      });

      test('data_set', () {
          final m = <String, dynamic>{};
          data_set(m, 'a.b', 1);
          expect(m['a']['b'], 1);
      });

      test('data_fill', () {
           final m = <String, dynamic>{'a': 1};
           data_fill(m, 'a', 2);
           expect(m['a'], 1); // Should not overwrite
           data_fill(m, 'b', 2);
           expect(m['b'], 2);
      });

      test('data_forget', () {
           final m = <String, dynamic>{'a': {'b': 1}};
           data_forget(m, 'a.b');
           expect((m['a'] as Map).isEmpty, isTrue);
      });

      test('head/last', () {
           expect(head([1, 2]), 1);
           expect(last([1, 2]), 2);
      });
  });
}
