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
  for (final entry in fileStats.entries) {
    final covered = entry.value['covered']!;
    final total = entry.value['total']!;
    final pct = (covered / total) * 100;
    final emoji = pct >= 95
        ? '✅'
        : pct >= 80
        ? '🟡'
        : '🔴';
    print(
      '$emoji ${entry.key.padRight(30)} ${pct.toStringAsFixed(1).padLeft(5)}% ($covered/$total)',
    );
  }
}
