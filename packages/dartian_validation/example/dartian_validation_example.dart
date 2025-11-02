import 'package:dartian_validation/dartian_validation.dart';

class RequiredRule extends Rule {
  @override
  bool passes(dynamic value) {
    return value != null && value.toString().isNotEmpty;
  }

  @override
  String message() {
    return 'The field is required.';
  }
}

void main() {
  final rule = RequiredRule();
  print('\'hello\' passes validation: ${rule.passes('hello')}');
  print('null passes validation: ${rule.passes(null)}');
}
