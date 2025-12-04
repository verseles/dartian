import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  group('Number', () {
    test('abbreviate', () {
      expect(Number.abbreviate(1000), '1K');
      expect(Number.abbreviate(1500), '1.5K');
      expect(Number.abbreviate(1000000), '1M');
      expect(Number.abbreviate(1000000000), '1B');
    });

    test('clamp', () {
      expect(Number.clamp(10, min: 5, max: 15), 10);
      expect(Number.clamp(2, min: 5, max: 15), 5);
      expect(Number.clamp(20, min: 5, max: 15), 15);
    });

    test('currency', () {
      // Depending on locale, might be $1,000.00 or 1.000,00 $
      // We set locale to en_US for test
      Number.useLocale('en_US');
      expect(Number.currency(1000), '\$1,000.00');
      expect(Number.currency(1000, inCurrency: 'EUR'), '€1,000.00');
    });

    test('fileSize', () {
      expect(Number.fileSize(1024), '1 KB');
      expect(Number.fileSize(1024 * 1024), '1 MB');
      expect(Number.fileSize(500), '500 B');
    });

    test('forHumans', () {
      expect(Number.forHumans(1000), '1,000');
      expect(Number.forHumans(1000, units: true), '1K');
    });

    test('format', () {
      Number.useLocale('en_US');
      expect(Number.format(1234.56), '1,234.56');
      expect(Number.format(1234.56, precision: 1), '1,234.6');
      expect(Number.format(1234.56, maxPrecision: 1), '1,234.6');
    });

    test('ordinal', () {
      expect(Number.ordinal(1), '1st');
      expect(Number.ordinal(2), '2nd');
      expect(Number.ordinal(3), '3rd');
      expect(Number.ordinal(4), '4th');
      expect(Number.ordinal(11), '11th');
      expect(Number.ordinal(21), '21st');
    });

    test('percentage', () {
      Number.useLocale('en_US');
      expect(Number.percentage(10), '10%');
      expect(Number.percentage(10.5, precision: 2), '10.50%');
    });

    test('spell', () {
      expect(Number.spell(10), 'ten');
      expect(Number.spell(21), 'twenty-one');
      expect(Number.spell(105), 'one hundred and five');
    });

    test('trim', () {
      expect(Number.trim(12.00), '12');
      expect(Number.trim(12.50), '12.5');
    });
  });
}
