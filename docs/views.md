# Views & Server-Side Rendering

While Dartian is well-suited for building JSON APIs, it also provides a simple way to render server-side views using the [Mustache](https://mustache.github.io/) templating language.

## Creating Views

Views are stored in the `resources/views` directory. A view is simply a file containing HTML and Mustache tags. You can create a new view file with the `.mustache` extension. You can also generate a new view file using the `make:view` CLI command:

```bash
dartian make:view welcome
```

This will create a `resources/views/welcome.mustache` file.

## Writing Templates

Mustache templates consist of standard HTML mixed with "tags" that are used for interpolating data, looping over collections, and conditional logic.

A basic example might look like this:

```html
<!-- resources/views/welcome.mustache -->
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
</head>
<body>
    <h1>Hello, {{ name }}!</h1>
</body>
</html>
```

## Rendering Views

You can render a view from a controller and return it as an HTTP response using the `DartianResponse.view()` helper.

```dart
// In a controller...
import 'package:dartian_http/dartian_http.dart';

class WelcomeController {
  Future<DartianResponse> show(DartianRequest request) async {
    return DartianResponse.view('welcome', {
      'title': 'Welcome Page',
      'name': 'Dartian User',
    });
  }
}
```

The first argument to `view()` is the name of the template file (without the `.mustache` extension). The second argument is a `Map<String, dynamic>` of data to be made available to the template.

## Partials (Includes)

Mustache allows you to include one template inside another, which is useful for reusing common layout elements like headers and footers. These are called "partials".

Partials are typically stored in the `resources/views/partials` directory.

For example, you could have a `header.mustache`:

```html
<!-- resources/views/partials/header.mustache -->
<header>
    <h1>My Awesome Application</h1>
</header>
```

And then include it in your main view:

```html
<!-- resources/views/welcome.mustache -->
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
</head>
<body>
    {{> partials/header }}

    <h1>Hello, {{ name }}!</h1>
</body>
</html>
```

The `{{> ... }}` tag is used to include a partial. The path is relative to the `resources/views` directory.
