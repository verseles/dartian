import 'package:dartian_orm/database.dart';
import 'package:faker/faker.dart';

class UserFactory {
  static UsersCompanion create() {
    return UsersCompanion.insert(
      name: faker.person.name(),
      email: faker.internet.email(),
    );
  }
}

class PostFactory {
  static PostsCompanion create(int userId) {
    return PostsCompanion.insert(
      title: faker.lorem.sentence(),
      content: faker.lorem.words(10).join(' '),
      userId: userId,
    );
  }
}

class DatabaseSeeder {
  final AppDatabase _database;

  DatabaseSeeder(this._database);

  Future<void> run() async {
    for (var i = 0; i < 10; i++) {
      final user = UserFactory.create();
      final userId = await _database.into(_database.users).insert(user);
      await _database.into(_database.posts).insert(PostFactory.create(userId));
    }
  }
}
