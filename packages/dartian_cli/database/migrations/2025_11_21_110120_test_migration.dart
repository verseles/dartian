import 'package:dartian_orm/dartian_orm.dart';

class TestMigration extends Migration {
  @override
  Future<void> up() async {
    // Run the migrations
    // Example:
    // await schema.create('table_name', (table) {
    //   table.id();
    //   table.string('name');
    //   table.timestamps();
    // });
  }

  @override
  Future<void> down() async {
    // Reverse the migrations
    // Example:
    // await schema.dropIfExists('table_name');
  }
}
