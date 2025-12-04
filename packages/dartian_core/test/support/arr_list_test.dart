import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  test('Arr.get list access', () {
    final list = [
      {'name': 'A'},
      {'name': 'B'},
    ];
    expect(Arr.get(list, '0.name'), 'A');
    expect(Arr.get(list, '1.name'), 'B');
    expect(Arr.get(list, '2.name', 'default'), 'default');
  });

  test('data_get list access', () {
    final list = [
      {'name': 'A'},
    ];
    expect(data_get(list, '0.name'), 'A');
  });
}
