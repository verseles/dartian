import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

/// Builder factory for dartian_di code generation
Builder dartianDiBuilder(BuilderOptions options) =>
    SharedPartBuilder([DIGenerator()], 'dartian_di');
