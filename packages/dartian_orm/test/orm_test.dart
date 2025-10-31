import 'package:dartian_orm/dartian_orm.dart';
import 'package:test/test.dart';

void main() {
  group('ORM', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.connect(inMemory: true);
    });

    tearDown(() async {
      await database.close();
    });

    test('can connect to in-memory database', () {
      expect(database, isA<AppDatabase>());
    });

    test('can run migrations', () async {
      // The migration is run automatically on creation.
      // We can test this by inserting a user with an email.
      final companion = UsersCompanion.insert(name: 'test', email: 'test@test.com');
      final id = await database.into(database.users).insert(companion);
      expect(id, isA<int>());
    });

    test('UserModel can create and find a user', () async {
      final userModel = UserModel(database);
      final companion = UsersCompanion.insert(name: 'test', email: 'test@test.com');
      final id = await userModel.create(companion);
      final user = await userModel.find(id);
      expect(user, isNotNull);
      expect(user!.name, 'test');
    });

    test('UserFactory creates a valid user', () {
      final user = UserFactory.create();
      expect(user, isA<UsersCompanion>());
    });

    test('DatabaseSeeder populates the database', () async {
      final seeder = DatabaseSeeder(database);
      await seeder.run();
      final userModel = UserModel(database);
      final users = await userModel.all();
      expect(users.length, 10);
    });
  });
}
