import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';

class QueueWorkCommand {
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('queue', defaultsTo: 'default', help: 'The queue to process')
      ..addOption(
        'driver',
        defaultsTo: 'sync',
        allowed: ['sync', 'redis'],
        help: 'Queue driver (sync or redis)',
      )
      ..addOption(
        'sleep',
        defaultsTo: '3',
        help: 'Seconds to sleep when no jobs are available',
      )
      ..addOption(
        'max-jobs',
        defaultsTo: '0',
        help: 'Maximum jobs to process (0 = unlimited)',
      )
      ..addOption(
        'memory',
        defaultsTo: '128',
        help: 'Memory limit in MB (0 = unlimited)',
      )
      ..addFlag('daemon', defaultsTo: true, help: 'Run as daemon')
      ..addFlag('once', defaultsTo: false, help: 'Process one job and exit');

    ArgResults args;
    try {
      args = parser.parse(arguments);
    } catch (e) {
      print('Error parsing arguments: $e');
      print('\nUsage: dartian queue:work [options]');
      print(parser.usage);
      return;
    }

    final queue = args['queue'] as String;
    final driver = args['driver'] as String;
    final sleep = int.tryParse(args['sleep'] as String) ?? 3;
    final maxJobs = int.tryParse(args['max-jobs'] as String) ?? 0;
    final memoryLimit = int.tryParse(args['memory'] as String) ?? 128;
    final daemon = args['daemon'] as bool;
    final once = args['once'] as bool;

    print('🚀 Queue Worker Starting');
    print('━' * 50);
    print('📦 Queue: $queue');
    print('🔧 Driver: $driver');
    print('⏱️  Sleep: ${sleep}s');
    if (maxJobs > 0) print('🎯 Max Jobs: $maxJobs');
    if (memoryLimit > 0) print('💾 Memory Limit: ${memoryLimit}MB');
    print(
      '🔄 Mode: ${once
          ? "once"
          : daemon
          ? "daemon"
          : "single"}',
    );
    print('━' * 50);
    print('');

    if (once) {
      await _processOnce(queue, driver);
    } else if (daemon) {
      await _processDaemon(queue, driver, sleep, maxJobs, memoryLimit);
    }
  }

  Future<void> _processOnce(String queue, String driver) async {
    print('⏳ Processing one job from queue "$queue"...');

    // Simulate job processing
    await Future.delayed(const Duration(milliseconds: 500));

    print('✅ Processed 1 job');
    print('👋 Worker stopped');
  }

  Future<void> _processDaemon(
    String queue,
    String driver,
    int sleep,
    int maxJobs,
    int memoryLimit,
  ) async {
    print('💪 Worker started successfully');
    print('👀 Listening for jobs on queue "$queue"...');
    print('');

    int processedJobs = 0;
    bool shouldStop = false;

    // Handle Ctrl+C gracefully
    ProcessSignal.sigint.watch().listen((_) {
      print('\n\n🛑 Stopping worker gracefully...');
      shouldStop = true;
    });

    while (!shouldStop) {
      // Check memory limit
      if (memoryLimit > 0) {
        final currentMemory = ProcessInfo.currentRss ~/ (1024 * 1024);
        if (currentMemory > memoryLimit) {
          print(
            '⚠️  Memory limit exceeded ($currentMemory MB > $memoryLimit MB)',
          );
          print('🛑 Worker stopping due to memory limit');
          break;
        }
      }

      // Check max jobs limit
      if (maxJobs > 0 && processedJobs >= maxJobs) {
        print('✅ Processed $processedJobs jobs (limit reached)');
        print('🛑 Worker stopping');
        break;
      }

      // Simulate job checking and processing
      final hasJob = await _checkForJob(queue, driver);

      if (hasJob) {
        try {
          await _processJob(queue, driver, processedJobs + 1);
          processedJobs++;
        } catch (e) {
          print('❌ Job failed: $e');
        }
      } else {
        // No jobs available, sleep
        await Future.delayed(Duration(seconds: sleep));
      }
    }

    print('');
    print('📊 Summary:');
    print('  Total jobs processed: $processedJobs');
    print('');
    print('👋 Worker stopped');
  }

  Future<bool> _checkForJob(String queue, String driver) async {
    // Simulate checking for jobs (10% chance of having a job)
    await Future.delayed(const Duration(milliseconds: 100));

    // In real implementation, this would check the actual queue
    // For now, simulate occasionally finding jobs
    return DateTime.now().second % 10 == 0;
  }

  Future<void> _processJob(String queue, String driver, int jobNumber) async {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] Processing job #$jobNumber from "$queue"...');

    // Simulate job processing time
    await Future.delayed(Duration(milliseconds: 200 + (jobNumber % 5) * 100));

    print('[$timestamp] ✅ Job #$jobNumber completed');
  }
}
