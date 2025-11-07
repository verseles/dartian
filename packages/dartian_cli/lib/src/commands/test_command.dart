import 'dart:io';
import 'package:args/args.dart';

class TestCommand {
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('coverage',
          help: 'Generate coverage report', negatable: false)
      ..addOption('reporter',
          abbr: 'r',
          defaultsTo: 'compact',
          allowed: ['compact', 'expanded', 'json', 'github'],
          help: 'Test reporter format')
      ..addOption('name',
          abbr: 'n',
          help: 'Filter tests by name pattern')
      ..addOption('tags',
          abbr: 't',
          help: 'Run only tests with specified tags')
      ..addOption('exclude-tags',
          abbr: 'x',
          help: 'Exclude tests with specified tags')
      ..addFlag('verbose',
          abbr: 'v',
          help: 'Verbose output', negatable: false)
      ..addFlag('fail-fast',
          help: 'Stop after first failure', negatable: false)
      ..addOption('concurrency',
          abbr: 'j',
          defaultsTo: '10',
          help: 'Number of concurrent test suites');

    ArgResults args;
    try {
      args = parser.parse(arguments);
    } catch (e) {
      print('Error parsing arguments: $e');
      print('\nUsage: dartian test [options] [files]');
      print(parser.usage);
      return;
    }

    print('🧪 Running Tests');
    print('━' * 50);

    // Build dart test command
    final testArgs = <String>[];

    // Add reporter
    testArgs.addAll(['-r', args['reporter'] as String]);

    // Add coverage if requested
    if (args['coverage'] as bool) {
      print('📊 Coverage: enabled');
      testArgs.addAll(['--coverage=coverage']);
    }

    // Add name filter
    final nameFilter = args['name'] as String?;
    if (nameFilter != null) {
      print('🔍 Filter: $nameFilter');
      testArgs.addAll(['-n', nameFilter]);
    }

    // Add tags
    final tags = args['tags'] as String?;
    if (tags != null) {
      print('🏷️  Tags: $tags');
      testArgs.addAll(['-t', tags]);
    }

    // Add exclude tags
    final excludeTags = args['exclude-tags'] as String?;
    if (excludeTags != null) {
      print('🚫 Exclude Tags: $excludeTags');
      testArgs.addAll(['-x', excludeTags]);
    }

    // Add fail-fast
    if (args['fail-fast'] as bool) {
      testArgs.add('--fail-fast');
    }

    // Add concurrency
    final concurrency = args['concurrency'] as String;
    testArgs.addAll(['-j', concurrency]);

    // Add verbose if requested
    if (args['verbose'] as bool) {
      testArgs.add('--verbose-trace');
    }

    // Add remaining arguments (test files/directories)
    testArgs.addAll(args.rest);

    print('━' * 50);
    print('');

    // Run dart test
    final result = await Process.run(
      'dart',
      ['test', ...testArgs],
      runInStdio: true,
    );

    // Check result
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }

    // Generate coverage report if requested
    if (args['coverage'] as bool) {
      print('');
      print('📊 Generating coverage report...');

      // Check if coverage directory exists
      final coverageDir = Directory('coverage');
      if (coverageDir.existsSync()) {
        // Try to generate HTML report using coverage tool
        final formatResult = await Process.run(
          'dart',
          ['pub', 'global', 'run', 'coverage:format_coverage',
           '--lcov',
           '--in=coverage',
           '--out=coverage/lcov.info',
           '--packages=.dart_tool/package_config.json',
           '--report-on=lib'],
        );

        if (formatResult.exitCode == 0) {
          print('✅ Coverage report generated: coverage/lcov.info');

          // Try to generate HTML report
          final htmlResult = await Process.run(
            'genhtml',
            ['-o', 'coverage/html', 'coverage/lcov.info'],
          );

          if (htmlResult.exitCode == 0) {
            print('✅ HTML report generated: coverage/html/index.html');
          } else {
            print('💡 Install lcov to generate HTML reports: sudo apt install lcov');
          }
        } else {
          print('💡 Install coverage tool: dart pub global activate coverage');
        }
      }
    }
  }
}

extension on Process {
  static Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    bool runInStdio = false,
  }) async {
    if (runInStdio) {
      // Run with inherited stdio for interactive output
      final process = await Process.start(
        executable,
        arguments,
        mode: ProcessStartMode.inheritStdio,
      );

      final exitCode = await process.exitCode;
      return ProcessResult(process.pid, exitCode, '', '');
    } else {
      return Process.run(executable, arguments);
    }
  }
}
