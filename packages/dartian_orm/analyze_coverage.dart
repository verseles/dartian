import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');

  if (!file.existsSync()) {
    print('Error: coverage/lcov.info not found');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final fileStats = <String, Map<String, int>>{};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).split('/').last; // Get just the filename
    } else if (line.startsWith('LF:') && currentFile != null) {
      final total = int.parse(line.substring(3));
      fileStats.putIfAbsent(currentFile, () => {'total': 0, 'covered': 0});
      fileStats[currentFile]!['total'] = total;
    } else if (line.startsWith('LH:') && currentFile != null) {
      final covered = int.parse(line.substring(3));
      fileStats[currentFile]!['covered'] = covered;
    }
  }

  print('==========================================');
  print('DARTIAN_ORM COVERAGE BY FILE');
  print('==========================================\n');

  final sortedFiles = fileStats.entries.toList()
    ..sort((a, b) {
      final aPercent =
          (a.value['covered']! / a.value['total']!) * 100;
      final bPercent =
          (b.value['covered']! / b.value['total']!) * 100;
      return aPercent.compareTo(bPercent);
    });

  for (final entry in sortedFiles) {
    final fileName = entry.key;
    final total = entry.value['total']!;
    final covered = entry.value['covered']!;
    final percent = (covered / total) * 100;

    final status = percent >= 95 ? '✅' : percent >= 80 ? '🟡' : '🔴';
    print(
        '$status ${fileName.padRight(30)} ${percent.toStringAsFixed(1).padLeft(5)}%  ($covered/$total)');
  }

  print('\n==========================================');
  print('Legend: ✅ >= 95%  🟡 >= 80%  🔴 < 80%');
  print('==========================================');
}
