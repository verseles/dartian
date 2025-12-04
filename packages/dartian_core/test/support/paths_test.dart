import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  test('Paths', () {
    Paths.setBasePath('/base');
    expect(base_path(), '/base');
    expect(app_path(), '/base/app');
    expect(config_path(), '/base/config');
    expect(database_path(), '/base/database');
    expect(lang_path(), '/base/lang');
    expect(public_path(), '/base/public');
    expect(resource_path(), '/base/resources');
    expect(storage_path(), '/base/storage');
  });
}
