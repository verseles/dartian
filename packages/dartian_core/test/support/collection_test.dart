import 'package:dartian_core/src/support/collection.dart';
import 'package:test/test.dart';

void main() {
  group('Collection', () {
    test('all', () {
      expect(collect([1, 2, 3]).all(), [1, 2, 3]);
    });

    test('avg', () {
      expect(collect([1, 2, 3, 4]).avg(), 2.5);
      expect(
        collect([
          {'id': 1, 'price': 100},
          {'id': 2, 'price': 200},
        ]).avg('price'),
        150,
      );
    });

    test('chunk', () {
      final chunks = collect([1, 2, 3, 4, 5, 6, 7]).chunk(4);
      expect(chunks.length, 2);
      expect(chunks[0].all(), [1, 2, 3, 4]);
      expect(chunks[1].all(), [5, 6, 7]);
    });

    test('collapse', () {
      final collection = collect([
        [1, 2],
        [3, 4],
      ]);
      expect(collection.collapse().all(), [1, 2, 3, 4]);
    });

    test('contains', () {
      final collection = collect([1, 2, 3]);
      expect(collection.contains(1), isTrue);
      expect(collection.contains(4), isFalse);
    });

    test('count', () {
      expect(collect([1, 2, 3]).count(), 3);
    });

    test('filter', () {
      final collection = collect([1, 2, 3, 4]);
      final filtered = collection.filter((item) => item > 2);
      expect(filtered.all(), [3, 4]);
    });

    test('first', () {
      expect(collect([1, 2, 3]).first, 1);
    });

    test('flatten', () {
      final collection = collect([
        1,
        [2, 3],
        [
          4,
          [5, 6],
        ],
      ]);
      expect(collection.flatten().all(), [1, 2, 3, 4, 5, 6]);
    });

    test('groupBy', () {
      final collection = collect([
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
        {'id': 3, 'name': 'A'},
      ]);
      final grouped = collection.groupBy('name');
      expect(grouped.length, 2);
      expect(grouped.first.value.count(), 2); // 'A'
      expect(grouped.last.value.count(), 1); // 'B'
    });

    test('implode', () {
      final collection = collect([
        {'account': 'a', 'product': 'Desk'},
        {'account': 'b', 'product': 'Chair'},
      ]);
      expect(collection.implode(', ', 'product'), 'Desk, Chair');
      expect(collect([1, 2, 3]).implode('-'), '1-2-3');
    });

    test('keyBy', () {
      final collection = collect([
        {'id': 'a', 'product': 'Desk'},
        {'id': 'b', 'product': 'Chair'},
      ]);
      final keyed = collection.keyBy('id');
      expect(keyed['a'], {'id': 'a', 'product': 'Desk'});
      expect(keyed['b'], {'id': 'b', 'product': 'Chair'});
    });

    test('map', () {
      final collection = collect([1, 2, 3]);
      final mapped = collection.map((item) => item * 2);
      expect(mapped.all(), [2, 4, 6]);
    });

    test('merge', () {
      final collection = collect([1, 2, 3]);
      final merged = collection.merge([4, 5, 6]);
      expect(merged.all(), [1, 2, 3, 4, 5, 6]);
    });

    test('pluck', () {
      final collection = collect([
        {'id': 1, 'name': 'Desk'},
        {'id': 2, 'name': 'Chair'},
      ]);
      expect(collection.pluck('name').all(), ['Desk', 'Chair']);
    });

    test('pop', () {
      final collection = collect([1, 2, 3]);
      expect(collection.pop(), 3);
      expect(collection.all(), [1, 2]);
    });

    test('push', () {
      final collection = collect([1, 2, 3]);
      collection.push(4);
      expect(collection.all(), [1, 2, 3, 4]);
    });

    test('reduce', () {
      final collection = collect([1, 2, 3]);
      expect(collection.reduceCarry(0, (curr, next) => curr + next), 6);
    });

    test('reverse', () {
      expect(collect([1, 2, 3]).reverse().all(), [3, 2, 1]);
    });

    test('sort', () {
      expect(collect([3, 1, 2]).sort().all(), [1, 2, 3]);
    });

    test('sortBy', () {
      final collection = collect([
        {'name': 'Desk', 'price': 200},
        {'name': 'Chair', 'price': 100},
        {'name': 'Bookcase', 'price': 150},
      ]);
      final sorted = collection.sortBy('price');
      expect(sorted.first['name'], 'Chair');
      expect(sorted.last['name'], 'Desk');
    });

    test('take', () {
      expect(collect([0, 1, 2, 3, 4, 5]).take(3).all(), [0, 1, 2]);
      expect(collect([0, 1, 2, 3, 4, 5]).take(-2).all(), [4, 5]);
    });

    test('transform', () {
      final collection = collect([1, 2, 3]);
      collection.transform((item) => item * 2);
      expect(collection.all(), [2, 4, 6]);
    });

    test('unique', () {
      expect(collect([1, 1, 2, 2, 3, 4, 2]).unique().all(), [1, 2, 3, 4]);
    });

    test('whereKey', () {
      final collection = collect([
        {'product': 'Desk', 'price': 200},
        {'product': 'Chair', 'price': 100},
        {'product': 'Bookcase', 'price': 150},
        {'product': 'Door', 'price': 100},
      ]);
      final filtered = collection.whereKey('price', 100);
      expect(filtered.all(), [
        {'product': 'Chair', 'price': 100},
        {'product': 'Door', 'price': 100},
      ]);
    });

    test('toJson', () {
      expect(collect([1, 2, 3]).toJson(), '[1,2,3]');
    });
  });
}
