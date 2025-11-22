import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// Generator for @Singleton annotated classes
class SingletonGenerator extends GeneratorForAnnotation<Singleton> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Singleton can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final name = annotation.peek('name')?.stringValue;
    final async = annotation.peek('async')?.boolValue ?? false;

    final nameParam = name != null ? ", instanceName: '$name'" : '';
    final registerMethod = async
        ? 'registerSingletonAsync'
        : 'registerSingleton';
    final factoryCall = async
        ? '() async => $className()'
        : '() => $className()';

    return '''
// Registration for $className
void _register$className(DIContainer container) {
  container.$registerMethod<$className>($factoryCall$nameParam);
}
''';
  }
}

/// Generator for @Service annotated classes
class ServiceGenerator extends GeneratorForAnnotation<Service> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Service can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final name = annotation.peek('name')?.stringValue;

    final nameParam = name != null ? ", instanceName: '$name'" : '';

    return '''
// Registration for $className
void _register$className(DIContainer container) {
  container.registerFactory<$className>(() => $className()$nameParam);
}
''';
  }
}

/// Generator for @LazySingleton annotated classes
class LazySingletonGenerator extends GeneratorForAnnotation<LazySingleton> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@LazySingleton can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final name = annotation.peek('name')?.stringValue;

    final nameParam = name != null ? ", instanceName: '$name'" : '';

    return '''
// Registration for $className (lazy)
void _register$className(DIContainer container) {
  container.registerLazySingleton<$className>(() => $className()$nameParam);
}
''';
  }
}

/// Combined generator that processes all DI annotations
class DIGenerator extends Generator {
  final _singletonGenerator = SingletonGenerator();
  final _serviceGenerator = ServiceGenerator();
  final _lazySingletonGenerator = LazySingletonGenerator();

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();
    final registrations = <String>[];

    // Process all annotated classes
    for (final element in library.allElements) {
      if (element is ClassElement) {
        // Check for @Singleton
        final singletonAnnotation = _getAnnotation(element, Singleton);
        if (singletonAnnotation != null) {
          buffer.writeln(
            _singletonGenerator.generateForAnnotatedElement(
              element,
              ConstantReader(singletonAnnotation),
              buildStep,
            ),
          );
          registrations.add('_register${element.name}');
        }

        // Check for @Service
        final serviceAnnotation = _getAnnotation(element, Service);
        if (serviceAnnotation != null) {
          buffer.writeln(
            _serviceGenerator.generateForAnnotatedElement(
              element,
              ConstantReader(serviceAnnotation),
              buildStep,
            ),
          );
          registrations.add('_register${element.name}');
        }

        // Check for @LazySingleton
        final lazyAnnotation = _getAnnotation(element, LazySingleton);
        if (lazyAnnotation != null) {
          buffer.writeln(
            _lazySingletonGenerator.generateForAnnotatedElement(
              element,
              ConstantReader(lazyAnnotation),
              buildStep,
            ),
          );
          registrations.add('_register${element.name}');
        }
      }
    }

    if (registrations.isEmpty) {
      return null;
    }

    // Generate the registerAll function
    buffer.writeln('''
/// Registers all annotated services in this file
void registerAllServices(DIContainer container) {
${registrations.map((r) => '  $r(container);').join('\n')}
}
''');

    return buffer.toString();
  }

  dynamic _getAnnotation(ClassElement element, Type annotationType) {
    for (final annotation in element.metadata.annotations) {
      final value = annotation.computeConstantValue();
      if (value?.type?.element?.name == annotationType.toString()) {
        return value;
      }
    }
    return null;
  }
}
