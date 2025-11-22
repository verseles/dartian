# dartian_i18n

Internationalization (i18n) support for Dartian with locale management and translation helpers.

## Features

- Multiple locale support
- Translation with parameters
- Locale switching
- JSON/Map-based translations

## Installation

```yaml
dependencies:
  dartian_i18n: ^1.0.0
```

## Usage

```dart
import 'package:dartian_i18n/dartian_i18n.dart';

// Setup translations
I18n.addTranslations('en', {
  'welcome': 'Welcome, :name!',
  'items': ':count items',
});

I18n.addTranslations('pt', {
  'welcome': 'Bem-vindo, :name!',
  'items': ':count itens',
});

// Set locale
I18n.setLocale('en');

// Translate
final msg = trans('welcome', params: {'name': 'John'});
// => "Welcome, John!"

// Switch locale
I18n.setLocale('pt');
final msg2 = trans('welcome', params: {'name': 'João'});
// => "Bem-vindo, João!"
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
