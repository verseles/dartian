import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart';

void main() {
  group('QueryBuilder', () {
    late QueryDatabase db;
    late QueryBuilder queryBuilder;

    setUp(() {
      db = DatabaseManager.instance.inMemoryDatabase();
      db.execute(
        'CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, category TEXT)',
        [],
      );

      // Insert test data
      db.execute(
        'INSERT INTO products (name, price, category) VALUES (?, ?, ?)',
        ['Laptop', 999.99, 'Electronics'],
      );
      db.execute(
        'INSERT INTO products (name, price, category) VALUES (?, ?, ?)',
        ['Mouse', 29.99, 'Electronics'],
      );
      db.execute(
        'INSERT INTO products (name, price, category) VALUES (?, ?, ?)',
        ['Desk', 299.99, 'Furniture'],
      );

      queryBuilder = QueryBuilder(db, 'products');
    });

    tearDown(() {
      db.close();
    });

    group('SelectQuery', () {
      test('should select all columns', () {
        final results = queryBuilder.select([]).get();

        expect(results, isNotEmpty);
        expect(results.length, 3);
        expect(results.first.containsKey('name'), isTrue);
        expect(results.first.containsKey('price'), isTrue);
        expect(results.first.containsKey('category'), isTrue);
      });

      test('should select specific columns', () {
        final results = queryBuilder.select(['name', 'price']).get();

        expect(results, isNotEmpty);
        expect(results.first.containsKey('name'), isTrue);
        expect(results.first.containsKey('price'), isTrue);
        expect(results.first.containsKey('category'), isFalse);
      });

      test('should add WHERE condition', () {
        final results = queryBuilder
            .select(['name', 'category'])
            .where('category = ?', ['Electronics'])
            .get();

        expect(results, isNotEmpty);
        expect(results.length, 2);
        for (final result in results) {
          expect(result['category'], 'Electronics');
        }
      });

      test('should chain multiple WHERE conditions with AND', () {
        final results = queryBuilder
            .select(['name', 'price'])
            .where('category = ?', ['Electronics'])
            .where('price > ?', [50.0])
            .get();

        expect(results, isNotEmpty);
        expect(results.length, 1);
        expect(results.first['name'], 'Laptop');
      });

      test('should add ORDER BY clause', () {
        final results = queryBuilder
            .select(['name', 'price'])
            .orderBy('price', descending: true)
            .get();

        expect(results, isNotEmpty);
        expect(results.first['price'], 999.99);
        expect(results.last['price'], 29.99);
      });

      test('should add LIMIT', () {
        final results = queryBuilder.select(['name']).limit(2).get();

        expect(results.length, 2);
      });

      test('should add OFFSET', () {
        final results = queryBuilder
            .select(['name'])
            .orderBy('id')
            .offset(1)
            .get();

        expect(results.length, 2);
      });

      test('should combine LIMIT and OFFSET', () {
        final results = queryBuilder
            .select(['name'])
            .orderBy('id')
            .limit(1)
            .offset(1)
            .get();

        expect(results.length, 1);
        expect(results.first['name'], 'Mouse');
      });
    });

    group('InsertQuery', () {
      test('should insert data', () {
        final data = {
          'name': 'Keyboard',
          'price': 79.99,
          'category': 'Electronics',
        };

        final result = queryBuilder.insert(data).execute();

        expect(result, greaterThan(0));

        // Verify the insert
        final products = queryBuilder.select(['name']).where('name = ?', ['Keyboard']).get();
        expect(products, isNotEmpty);
        expect(products.first['name'], 'Keyboard');
      });
    });

    group('UpdateQuery', () {
      test('should update data', () {
        // Get a product ID
        final products = db.query('SELECT id FROM products WHERE name = ?', ['Mouse']);
        final productId = products.first['id'] as int;

        final data = {
          'name': 'Wireless Mouse',
          'price': 39.99,
        };

        final result = queryBuilder
            .update(data)
            .where('id = ?', [productId])
            .execute();

        expect(result, greaterThan(0));

        // Verify the update
        final updated = db.query(
          'SELECT * FROM products WHERE id = ?',
          [productId],
        );
        expect(updated.first['name'], 'Wireless Mouse');
        expect(updated.first['price'], 39.99);
      });

      test('should update with multiple WHERE conditions', () {
        final data = {'price': 199.99};

        final result = queryBuilder
            .update(data)
            .where('category = ?', ['Furniture'])
            .where('name = ?', ['Desk'])
            .execute();

        expect(result, greaterThan(0));

        // Verify
        final updated = db.query('SELECT * FROM products WHERE name = ?', ['Desk']);
        expect(updated.first['price'], 199.99);
      });
    });

    group('DeleteQuery', () {
      test('should delete data', () {
        // Get a product ID
        final products = db.query('SELECT id FROM products WHERE name = ?', ['Mouse']);
        final productId = products.first['id'] as int;

        final result = queryBuilder.delete().where('id = ?', [productId]).execute();

        expect(result, greaterThan(0));

        // Verify deletion
        final deleted = db.query('SELECT * FROM products WHERE id = ?', [productId]);
        expect(deleted, isEmpty);
      });

      test('should delete with WHERE condition', () {
        final result = queryBuilder
            .delete()
            .where('category = ?', ['Furniture'])
            .execute();

        expect(result, equals(1));

        // Verify all furniture is deleted
        final remaining = db.query('SELECT * FROM products WHERE category = ?', ['Furniture']);
        expect(remaining, isEmpty);
      });
    });
  });
}
