import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart analyze_coverage.dart <path_to_lcov.info>');
    exit(1);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    print('File not found: ${args[0]}');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final fileStats = <String, Map<String, int>>{};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      fileStats[currentFile] = {'LF': 0, 'LH': 0};
    } else if (line.startsWith('LF:') && currentFile != null) {
      fileStats[currentFile]!['LF'] = int.parse(line.substring(3));
    } else if (line.startsWith('LH:') && currentFile != null) {
      fileStats[currentFile]!['LH'] = int.parse(line.substring(3));
    }
  }

  // Sort by coverage percentage
  final sorted = fileStats.entries.toList()
    ..sort((a, b) {
      final aPct = a.value['LF']! > 0
          ? (a.value['LH']! / a.value['LF']!) * 100
          : 0.0;
      final bPct = b.value['LF']! > 0
          ? (b.value['LH']! / b.value['LF']!) * 100
          : 0.0;
      return aPct.compareTo(bPct);
    });

  print('\nCoverage by file (sorted by percentage):\n');
  for (final entry in sorted) {
    final filename = entry.key.split('/').last;
    final lf = entry.value['LF']!;
    final lh = entry.value['LH']!;
    final pct = lf > 0 ? (lh / lf) * 100 : 0.0;

    final status = pct >= 95 ? '✅' : pct >= 80 ? '⚠️ ' : '❌';
    print('$status ${pct.toStringAsFixed(1).padLeft(5)}% ${lh.toString().padLeft(3)}/${lf.toString().padLeft(3)} $filename');
  }

  // Calculate totals
  final totalLF = fileStats.values.fold(0, (sum, v) => sum + v['LF']!);
  final totalLH = fileStats.values.fold(0, (sum, v) => sum + v['LH']!);
  final totalPct = totalLF > 0 ? (totalLH / totalLF) * 100 : 0.0;

  print('\n' + '=' * 60);
  print('Total: ${totalPct.toStringAsFixed(2)}% ($totalLH/$totalLF lines)');
  print('=' * 60);
}
