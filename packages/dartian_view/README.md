# dartian_view

Server-side rendering (SSR) views for Dartian using Mustache templates with i18n support.

## Features

- Mustache template engine
- Layouts and partials
- i18n integration
- Auto-escaping for security

## Installation

```yaml
dependencies:
  dartian_view: ^1.0.0
```

## Usage

```dart
import 'package:dartian_view/dartian_view.dart';

// Create view engine
final engine = ViewEngine(
  viewsPath: 'resources/views',
);

// Render a template
final html = await engine.render('welcome', {
  'name': 'John',
  'items': ['Apple', 'Banana', 'Orange'],
});

// With layout
final page = await engine.render('home', data, layout: 'layouts/main');
```

### Template Syntax

```mustache
<!-- resources/views/welcome.mustache -->
<h1>Welcome, {{name}}!</h1>
<ul>
  {{#items}}
    <li>{{.}}</li>
  {{/items}}
</ul>
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
