import 'package:dartian_validation/dartian_validation.dart';
import 'package:test/test.dart';

class IsRequired implements Rule {
  @override
  bool passes(dynamic value) {
    return value != null;
  }

  @override
  String message() {
    return 'The field is required.';
  }
}

void main() {
  group('Validation', () {
    test('Rule validates a value', () {
      final rule = IsRequired();
      expect(rule.passes('foo'), isTrue);
      expect(rule.passes(null), isFalse);
    });
  });
}
