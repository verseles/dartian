import 'package:dartian_orm/dartian_orm.dart';
import 'package:dartian_orm/database.dart';

class PostModel extends Model<Post, Posts> {
  PostModel(AppDatabase database) : super(database, database.posts);
}
