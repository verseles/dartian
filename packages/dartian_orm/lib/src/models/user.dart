import 'package:dartian_orm/dartian_orm.dart';
import 'package:dartian_orm/database.dart';

class UserModel extends Model<User, Users> {
  UserModel(AppDatabase database) : super(database, database.users);
}
