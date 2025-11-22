import 'dart:io';

void main() {
  final lcov = File('coverage/lcov.info').readAsStringSync();
  final lines = lcov.split('\n');

  final Map<String, Map<String, int>> fileStats = {};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      if (currentFile.contains('lib/')) {
        final shortName = currentFile.split('lib/').last;
        fileStats[shortName] = {'covered': 0, 'total': 0};
      }
    } else if (currentFile != null && line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      final execCount = int.parse(parts[1]);
      final shortName = currentFile.split('lib/').last;

      if (fileStats.containsKey(shortName)) {
        fileStats[shortName]!['total'] = fileStats[shortName]!['total']! + 1;
        if (execCount > 0) {
          fileStats[shortName]!['covered'] =
              fileStats[shortName]!['covered']! + 1;
        }
      }
    }
  }

  print('=' * 50);
  print('DARTIAN_CLI COVERAGE BY FILE');
  print('=' * 50);
  print('');

  final sortedFiles = fileStats.entries.toList()
    ..sort((a, b) {
      final aPct = (a.value['covered']! / a.value['total']!) * 100;
      final bPct = (b.value['covered']! / b.value['total']!) * 100;
      return aPct.compareTo(bPct);
    });

  int totalLines = 0;
  int coveredLines = 0;

  for (final entry in sortedFiles) {
    final covered = entry.value['covered']!;
    final total = entry.value['total']!;
    final pct = (covered / total) * 100;

    totalLines += total;
    coveredLines += covered;

    final emoji = pct >= 95
        ? '✅'
        : pct >= 80
        ? '🟡'
        : '🔴';
    print(
      '$emoji ${entry.key.padRight(35)} ${pct.toStringAsFixed(1).padLeft(5)}%  ($covered/$total)',
    );
  }

  print('');
  print('=' * 50);
  final totalPct = (coveredLines / totalLines) * 100;
  print('TOTAL: ${totalPct.toStringAsFixed(1)}% ($coveredLines/$totalLines)');
  print('=' * 50);
}
