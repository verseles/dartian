import 'package:dartian_view/dartian_view.dart';
import 'dart:io';

void main() {
  final viewEngine = ViewEngine('example');
  final output = viewEngine.render('hello', {'name': 'World'});
  print(output);

  // Clean up the dummy file
  File('example/hello.mustache').deleteSync();
}
