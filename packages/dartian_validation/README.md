# dartian_validation

A simple validation system for the Dartian framework.

## Features

-   Define custom validation rules
-   Validate data against a set of rules

## Usage

Create a rule:
```dart
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
```
