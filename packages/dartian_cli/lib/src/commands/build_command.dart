import 'dart:io';
import 'package:args/args.dart';

class BuildCommand {
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory (default: build/)',
      )
      ..addOption(
        'optimization',
        abbr: 'O',
        defaultsTo: '2',
        allowed: ['0', '1', '2', '3'],
        help: 'Optimization level (0-3, default: 2)',
      )
      ..addFlag('verbose', abbr: 'v', help: 'Verbose output');

    ArgResults args;
    try {
      args = parser.parse(arguments);
    } catch (e) {
      print('Error parsing arguments: $e');
      print('\nUsage: dartian build <type> [options]');
      print('\nTypes:');
      print('  exe            Build native executable');
      print('  aot-snapshot   Build AOT snapshot');
      print('  wasm           Build WebAssembly (experimental)');
      print('\nOptions:');
      print(parser.usage);
      return;
    }

    if (args.rest.isEmpty) {
      print('Error: Build type is required');
      print('\nUsage: dartian build <type>');
      print('\nAvailable types:');
      print('  exe            Build native executable');
      print('  aot-snapshot   Build AOT snapshot');
      print('  wasm           Build WebAssembly (experimental)');
      return;
    }

    final buildType = args.rest[0];
    final outputDir = args['output'] as String? ?? 'build';
    final optimization = args['optimization'] as String;
    final verbose = args['verbose'] as bool;

    switch (buildType) {
      case 'exe':
        await _buildExecutable(outputDir, optimization, verbose);
        break;
      case 'aot-snapshot':
        await _buildAotSnapshot(outputDir, optimization, verbose);
        break;
      case 'wasm':
        await _buildWasm(outputDir, verbose);
        break;
      default:
        print('Error: Unknown build type "$buildType"');
        print('\nAvailable types: exe, aot-snapshot, wasm');
    }
  }

  Future<void> _buildExecutable(
    String outputDir,
    String optimization,
    bool verbose,
  ) async {
    print('🔨 Building Native Executable');
    print('━' * 50);
    print('🎯 Optimization: -O$optimization');
    print('📁 Output: $outputDir/');
    print('━' * 50);
    print('');

    // Check if lib/main.dart exists
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('❌ Error: lib/main.dart not found');
      print('💡 Make sure you are in the project root directory');
      return;
    }

    // Create output directory
    final output = Directory(outputDir);
    if (!output.existsSync()) {
      output.createSync(recursive: true);
    }

    print('⏳ Compiling (this may take a minute)...');
    print('');

    try {
      // Run dart compile exe
      final result = await Process.run('dart', [
        'compile',
        'exe',
        'lib/main.dart',
        '-o',
        '$outputDir/app',
        '-O$optimization',
        if (verbose) '--verbose',
      ]);

      if (verbose) {
        print(result.stdout);
      }

      if (result.exitCode != 0) {
        print('❌ Build failed:');
        print(result.stderr);
        return;
      }

      // Get file size
      final executable = File('$outputDir/app');
      final sizeInMB = executable.lengthSync() / (1024 * 1024);

      print('✅ Build completed successfully!');
      print('');
      print('📦 Executable: $outputDir/app');
      print('📊 Size: ${sizeInMB.toStringAsFixed(2)} MB');
      print('');
      print('Run your application:');
      print('  ./$outputDir/app');
    } catch (e) {
      print('❌ Build error: $e');
    }
  }

  Future<void> _buildAotSnapshot(
    String outputDir,
    String optimization,
    bool verbose,
  ) async {
    print('🔨 Building AOT Snapshot');
    print('━' * 50);
    print('🎯 Optimization: -O$optimization');
    print('📁 Output: $outputDir/');
    print('━' * 50);
    print('');

    // Check if lib/main.dart exists
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('❌ Error: lib/main.dart not found');
      print('💡 Make sure you are in the project root directory');
      return;
    }

    // Create output directory
    final output = Directory(outputDir);
    if (!output.existsSync()) {
      output.createSync(recursive: true);
    }

    print('⏳ Compiling AOT snapshot...');
    print('');

    try {
      // Run dart compile aot-snapshot
      final result = await Process.run('dart', [
        'compile',
        'aot-snapshot',
        'lib/main.dart',
        '-o',
        '$outputDir/app.aot',
        if (verbose) '--verbose',
      ]);

      if (verbose) {
        print(result.stdout);
      }

      if (result.exitCode != 0) {
        print('❌ Build failed:');
        print(result.stderr);
        return;
      }

      // Get file size
      final snapshot = File('$outputDir/app.aot');
      final sizeInMB = snapshot.lengthSync() / (1024 * 1024);

      print('✅ Build completed successfully!');
      print('');
      print('📦 Snapshot: $outputDir/app.aot');
      print('📊 Size: ${sizeInMB.toStringAsFixed(2)} MB');
      print('');
      print('Run your application:');
      print('  dartaotruntime $outputDir/app.aot');
    } catch (e) {
      print('❌ Build error: $e');
    }
  }

  Future<void> _buildWasm(String outputDir, bool verbose) async {
    print('🔨 Building WebAssembly (WASM)');
    print('━' * 50);
    print('⚠️  Experimental feature');
    print('📁 Output: $outputDir/');
    print('━' * 50);
    print('');

    // Check if lib/main.dart exists
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('❌ Error: lib/main.dart not found');
      print('💡 Make sure you are in the project root directory');
      return;
    }

    // Create output directory
    final output = Directory(outputDir);
    if (!output.existsSync()) {
      output.createSync(recursive: true);
    }

    print('⏳ Compiling to WASM...');
    print('');

    try {
      // Run dart compile wasm
      final result = await Process.run('dart', [
        'compile',
        'wasm',
        'lib/main.dart',
        '-o',
        '$outputDir/app.wasm',
        if (verbose) '--verbose',
      ]);

      if (verbose) {
        print(result.stdout);
      }

      if (result.exitCode != 0) {
        print('⚠️  WASM compilation not available or failed:');
        print(result.stderr);
        print('');
        print('💡 WASM support requires Dart SDK with WASM experimental flag');
        print(
          '💡 This is an experimental feature and may not be available yet',
        );
        return;
      }

      // Get file size
      final wasmFile = File('$outputDir/app.wasm');
      if (wasmFile.existsSync()) {
        final sizeInKB = wasmFile.lengthSync() / 1024;

        print('✅ Build completed successfully!');
        print('');
        print('📦 WASM: $outputDir/app.wasm');
        print('📊 Size: ${sizeInKB.toStringAsFixed(2)} KB');
        print('');
        print('💡 Deploy with a WASM-compatible runtime');
      }
    } catch (e) {
      print('❌ Build error: $e');
      print('💡 WASM compilation may not be available in current Dart SDK');
    }
  }
}
