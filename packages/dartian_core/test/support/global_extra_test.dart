import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  test('blank/filled', () {
    expect(blank(''), true);
    expect(filled('a'), true);
  });

  test('collect', () {
    expect(collect([1]).isNotEmpty, true);
  });

  test('tap', () {
    int val = 0;
    final res = tap(1, (n) => val = n);
    expect(res, 1);
    expect(val, 1);
  });

  test('value', () {
    expect(value(1), 1);
    expect(value(() => 1), 1);
  });

  test('withValue', () {
    expect(withValue(1), 1);
    int val = 0;
    expect(withValue(1, (n) => val = n), 1);
    expect(val, 1);
  });

  test('retry', () async {
    int count = 0;
    await retry(3, () async {
      count++;
      if (count < 2) throw Exception('fail');
      return true;
    });
    expect(count, 2);
  });
}
