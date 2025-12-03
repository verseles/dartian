import 'package:dartian_core/src/support/arr.dart';
import 'package:test/test.dart';

void main() {
  group('Arr', () {
    test('accessible', () {
      expect(Arr.accessible([]), isTrue);
      expect(Arr.accessible({}), isTrue);
      expect(Arr.accessible('string'), isFalse);
    });

    test('add', () {
      final map = <String, dynamic>{'name': 'Desk'};
      expect(Arr.add(map, 'price', 100), {'name': 'Desk', 'price': 100});
      expect(Arr.add(map, 'name', 'Table'), {'name': 'Desk', 'price': 100});
    });

    test('collapse', () {
      expect(Arr.collapse([[1, 2], [3, 4]]), [1, 2, 3, 4]);
    });

    test('divide', () {
      final result = Arr.divide({'name': 'Desk', 'price': 100});
      expect(result[0], ['name', 'price']);
      expect(result[1], ['Desk', 100]);
    });

    test('dot', () {
      final result = Arr.dot({'products': {'desk': {'price': 100}}});
      expect(result, {'products.desk.price': 100});
    });

    test('except', () {
      expect(Arr.except({'name': 'Desk', 'price': 100}, 'price'), {'name': 'Desk'});
      expect(Arr.except({'name': 'Desk', 'price': 100}, ['price']), {'name': 'Desk'});
    });

    test('exists', () {
      expect(Arr.exists({'name': 'Desk'}, 'name'), isTrue);
      expect(Arr.exists({'name': 'Desk'}, 'price'), isFalse);
    });

    test('first', () {
      expect(Arr.first([100, 200, 300], (e) => e >= 150), 200);
      expect(Arr.first<int>([100, 200, 300], (e) => e >= 400, 0), 0);
    });

    test('last', () {
      expect(Arr.last([100, 200, 300], (e) => e <= 250), 200);
    });

    test('flatten', () {
      expect(Arr.flatten([1, [2, 3], [4, [5, 6]]]), [1, 2, 3, 4, 5, 6]);
      expect(Arr.flatten([1, [2, 3], [4, [5, 6]]], 1), [1, 2, 3, 4, [5, 6]]);
    });

    test('get', () {
      final array = {'products': {'desk': {'price': 100}}};
      expect(Arr.get(array, 'products.desk.price'), 100);
      expect(Arr.get(array, 'products.desk.name', 'Unknown'), 'Unknown');
    });

    test('has', () {
      final array = {'products': {'desk': {'price': 100}}};
      expect(Arr.has(array, 'products.desk.price'), isTrue);
      expect(Arr.has(array, 'products.desk.name'), isFalse);
      expect(Arr.has(array, ['products.desk.price', 'products']), isTrue);
    });

    test('only', () {
      expect(Arr.only({'name': 'Desk', 'price': 100, 'orders': 10}, ['name', 'price']), {'name': 'Desk', 'price': 100});
    });

    test('pluck', () {
      final array = [
        {'developer': {'id': 1, 'name': 'Taylor'}},
        {'developer': {'id': 2, 'name': 'Abigail'}},
      ];
      expect(Arr.pluck(array, 'developer.name'), ['Taylor', 'Abigail']);
    });

    test('prepend', () {
      expect(Arr.prepend([1, 2, 3], 0), [0, 1, 2, 3]);
    });

    test('pull', () {
      final array = {'name': 'Desk', 'price': 100};
      expect(Arr.pull(array, 'name'), 'Desk');
      expect(array, {'price': 100});
    });

    test('set', () {
      final array = <String, dynamic>{'products': <String, dynamic>{'desk': <String, dynamic>{'price': 100}}};
      Arr.set(array, 'products.desk.price', 200);
      expect((array['products'] as Map)['desk']['price'], 200);

      Arr.set(array, 'products.desk.name', 'Table');
      expect((array['products'] as Map)['desk']['name'], 'Table');
    });

    test('forget', () {
      final array = <String, dynamic>{'products': <String, dynamic>{'desk': <String, dynamic>{'price': 100, 'name': 'Table'}}};
      Arr.forget(array, 'products.desk.price');
      expect(((array['products'] as Map)['desk'] as Map).containsKey('price'), isFalse);
      expect(((array['products'] as Map)['desk'] as Map).containsKey('name'), isTrue);
    });

    test('shuffle', () {
      final array = [1, 2, 3, 4, 5];
      final shuffled = Arr.shuffle(array);
      expect(shuffled.length, 5);
      expect(shuffled, containsAll([1, 2, 3, 4, 5]));
    });

    test('wrap', () {
      expect(Arr.wrap('string'), ['string']);
      expect(Arr.wrap(['string']), ['string']);
      expect(Arr.wrap(null), []);
    });
  });
}
