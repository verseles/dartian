import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  group('Arr Extra', () {
    test('boolean', () {
      expect(Arr.boolean(true), true);
      expect(Arr.boolean(1), true);
      expect(Arr.boolean('true'), true);
      expect(Arr.boolean('on'), true);
      expect(Arr.boolean(0), false);
      expect(Arr.boolean('false'), false);
    });

    test('crossJoin', () {
      expect(
        Arr.crossJoin([
          [1, 2],
          ['a', 'b'],
        ]),
        [
          [1, 'a'],
          [1, 'b'],
          [2, 'a'],
          [2, 'b'],
        ],
      );
    });

    test('every', () {
      expect(Arr.every([1, 2, 3], (e) => e > 0), true);
      expect(Arr.every([1, 2, 0], (e) => e > 0), false);
    });

    test('float/integer/string', () {
      expect(Arr.float('1.5'), 1.5);
      expect(Arr.integer('5'), 5);
      expect(Arr.string(123), '123');
    });

    test('from', () {
      expect(Arr.from(1), [1]);
      expect(Arr.from([1, 2]), [1, 2]);
    });

    test('hasAll/hasAny', () {
      final m = {'a': 1, 'b': 2};
      expect(Arr.hasAll(m, ['a', 'b']), true);
      expect(Arr.hasAll(m, ['a', 'c']), false);
      expect(Arr.hasAny(m, ['c', 'b']), true);
    });

    test('join', () {
      expect(Arr.join(['a', 'b', 'c'], ', ', ' and '), 'a, b and c');
    });

    test('keyBy', () {
      final list = [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ];
      expect(Arr.keyBy(list, 'id'), {1: list[0], 2: list[1]});
    });

    test('map/mapSpread/mapWithKeys', () {
      // Basic checks
      expect(Arr.map([1, 2], (e) => e * 2), [2, 4]);
      // mapSpread
      expect(
        Arr.mapSpread([
          [1],
          [2, 3],
        ], (e) => e),
        [1, 2, 3],
      );
      // mapWithKeys
      expect(Arr.mapWithKeys([1, 2], (e) => MapEntry(e, e * 2)), {1: 2, 2: 4});
    });

    test('partition', () {
      final res = Arr.partition([1, 2, 3, 4], (e) => e % 2 == 0);
      expect(res[0], [2, 4]);
      expect(res[1], [1, 3]);
    });

    test('prependKeysWith', () {
      expect(Arr.prependKeysWith({'a': 1}, 'prefix.'), {'prefix.a': 1});
    });

    test('push', () {
      final l = [1];
      Arr.push(l, 2);
      expect(l, [1, 2]);
    });

    test('query', () {
      expect(Arr.query({'a': 1, 'b': 2}), 'a=1&b=2');
    });

    test('reject', () {
      expect(Arr.reject([1, 2, 3], (e) => e > 1), [1]);
    });

    test('select', () {
      expect(Arr.select({'a': 1, 'b': 2}, 'a'), {'a': 1});
    });

    test('sole', () {
      expect(Arr.sole([1]), 1);
      expect(() => Arr.sole([1, 2]), throwsException);
      expect(Arr.sole([1, 2, 3], (e) => e == 2), 2);
    });

    test('some', () {
      expect(Arr.some([1, 2, 3], (e) => e == 2), true);
      expect(Arr.some([1, 2, 3], (e) => e == 4), false);
    });

    test('sort/sortDesc', () {
      expect(Arr.sort([3, 1, 2]), [1, 2, 3]);
      expect(Arr.sortDesc([1, 2, 3]), [3, 2, 1]);
    });

    test('take', () {
      expect(Arr.take([1, 2, 3], 2), [1, 2]);
      expect(Arr.take([1, 2, 3], -2), [2, 3]);
    });

    test('toCssClasses', () {
      expect(Arr.toCssClasses(['a', 'b']), 'a b');
      expect(Arr.toCssClasses({'a': true, 'b': false}), 'a');
      expect(
        Arr.toCssClasses([
          {'a': true},
          'b',
        ]),
        'a b',
      );
    });

    test('toCssStyles', () {
      expect(Arr.toCssStyles({'color': 'red', 'display': null}), 'color: red');
    });

    test('undot', () {
      expect(Arr.undot({'a.b': 1}), {
        'a': {'b': 1},
      });
    });

    test('where/whereNotNull', () {
      expect(Arr.where([1, 2, 3], (e) => e > 1), [2, 3]);
      expect(Arr.whereNotNull([1, null, 2]), [1, 2]);
    });
  });
}
