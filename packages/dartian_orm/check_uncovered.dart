import 'dart:io';

void main() {
  final lcov = File('coverage/lcov.info').readAsStringSync();

  // Find relationships.dart section
  final lines = lcov.split('\n');
  bool inFile = false;
  final uncoveredLines = <int>[];

  for (final line in lines) {
    if (line.startsWith('SF:') && line.contains('relationships.dart')) {
      inFile = true;
      print('Found relationships.dart in lcov.info');
    } else if (inFile && line.startsWith('SF:')) {
      // Next file, stop
      break;
    } else if (inFile && line.startsWith('DA:')) {
      // DA:line_number,execution_count
      final parts = line.substring(3).split(',');
      final lineNum = int.parse(parts[0]);
      final execCount = int.parse(parts[1]);

      if (execCount == 0) {
        uncoveredLines.add(lineNum);
      }
    }
  }

  if (uncoveredLines.isEmpty) {
    print('No uncovered lines found or file not in report');
  } else {
    print('\nUncovered lines in relationships.dart:');
    print(uncoveredLines.join(', '));
    print('\nTotal uncovered: ${uncoveredLines.length}');
  }
}
