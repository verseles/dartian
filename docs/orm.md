# Database & ORM

Dartian's Object-Relational Mapper (ORM) provides an elegant, "Eloquent-like" API for interacting with your database. It's built on top of the powerful and type-safe [Drift](https://drift.simonbinder.eu/) library, offering a fluent interface for performing database queries.

## Configuration

Your application's database configuration is located in the `config/database.dart` file. In this file, you can define your database connections. Dartian supports SQLite out of the box.

Connection details are typically configured via your application's `.env` file.

## Defining Models

Models are the heart of the ORM. Each model corresponds to a table in your database and is used to interact with that table. Models are defined in the `app/models` directory.

Here is an example of a `User` model:

```dart
// app/models/user_model.dart
import 'package:dartian_orm/dartian_orm.dart';

part 'user_model.g.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
}

@UseRowClass(User)
class UserModel extends Model<Users, User> {
  UserModel(super.db);
}
```

After defining your model, you need to run the `build_runner` to generate the necessary data classes:

```bash
dart run build_runner build
```

## CRUD Operations

### Creating Records

To create a new record in the database, create a new model instance and call the `create()` method with a `Companion` object:

```dart
final userModel = container.resolve<UserModel>();
final newUser = await userModel.create(
  UsersCompanion.insert(
    name: 'John Doe',
    email: 'john.doe@example.com',
  ),
);
```

### Finding Records

You can retrieve a record by its primary key using the `find()` method:

```dart
final user = await userModel.find(1);
```

To retrieve all records from a table, use the `all()` method:

```dart
final users = await userModel.all();
```

### Query Constraints

The ORM provides a fluent interface for adding constraints to your queries:

```dart
final user = await userModel.select()
  ..where((tbl) => tbl.email.equals('john.doe@example.com'))
  ..getSingle();
```

### Updating Records

To update a model, you can retrieve it, change its properties, and then call the `update()` method:

```dart
final user = await userModel.find(1);
await userModel.update(user.copyWith(name: 'Jane Doe'));
```

### Deleting Records

To delete a model, you can call the `delete()` method on a model instance:

```dart
final user = await userModel.find(1);
await userModel.delete(user);
```

## Factories and Seeders

### Factories

When testing, you often need to insert a few records into your database. Instead of manually specifying the value of each column, Dartian allows you to define default sets of attributes for each of your models using model factories.

Factories are defined in `database/factories`. Here is an example `UserFactory`:

```dart
// database/factories/user_factory.dart
import 'package:dartian_orm/dartian_orm.dart';
import 'package:faker/faker.dart';

class UserFactory extends Factory<UsersCompanion> {
  @override
  UsersCompanion definition() {
    return UsersCompanion.insert(
      name: faker.person.name(),
      email: faker.internet.email(),
    );
  }
}
```

### Seeding

Seeders are classes that populate your database with test data. All seeders are stored in the `database/seeders` directory.

```dart
// database/seeders/database_seeder.dart
import 'package:dartian_orm/dartian_orm.dart';
import '../factories/user_factory.dart';

class DatabaseSeeder extends Seeder {
  @override
  Future<void> run() async {
    await UserFactory().createMany(10);
  }
}
```

You can run your seeders using the `db:seed` CLI command:

```bash
dartian db:seed
```
