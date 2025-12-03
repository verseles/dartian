import 'package:dartian_core/src/support/number.dart';
import 'package:test/test.dart';

void main() {
  group('Number', () {
    test('abbreviate', () {
      expect(Number.abbreviate(100), '100');
      expect(Number.abbreviate(1000), '1K');
      expect(Number.abbreviate(1500), '1.5K');
      expect(Number.abbreviate(1000000), '1M');
      expect(Number.abbreviate(1500000), '1.5M');
      expect(
        Number.abbreviate(1500000, precision: 0),
        '2M',
      ); // toStringAsFixed rounds
    });

    test('clamp', () {
      expect(Number.clamp(10, 5, 15), 10);
      expect(Number.clamp(20, 5, 15), 15);
      expect(Number.clamp(0, 5, 15), 5);
    });

    test('fileSize', () {
      expect(Number.fileSize(100), '100 B');
      expect(Number.fileSize(1024), '1 KB');
      expect(Number.fileSize(1536), '1.5 KB');
      expect(Number.fileSize(1048576), '1 MB');
    });

    test('forHumans', () {
      expect(Number.forHumans(1000), '1K');
    });

    test('percentage', () {
      expect(Number.percentage(10), '10%');
      expect(Number.percentage(10.5, precision: 1), '10.5%');
    });

    test('ordinal', () {
      expect(Number.ordinal(1), '1st');
      expect(Number.ordinal(2), '2nd');
      expect(Number.ordinal(3), '3rd');
      expect(Number.ordinal(4), '4th');
      expect(Number.ordinal(11), '11th');
      expect(Number.ordinal(21), '21st');
    });
  });
}
