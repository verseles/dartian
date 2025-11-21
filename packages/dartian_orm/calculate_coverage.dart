import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');

  if (!file.existsSync()) {
    print('Error: coverage/lcov.info not found');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  int totalLines = 0;
  int coveredLines = 0;

  for (final line in lines) {
    if (line.startsWith('LF:')) {
      totalLines += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      coveredLines += int.parse(line.substring(3));
    }
  }

  if (totalLines == 0) {
    print('No coverage data found');
    exit(1);
  }

  final percentage = (coveredLines / totalLines) * 100;

  print('==========================================');
  print('DARTIAN_ORM COVERAGE REPORT');
  print('==========================================');
  print('Total lines:    $totalLines');
  print('Covered lines:  $coveredLines');
  print('Coverage:       ${percentage.toStringAsFixed(2)}%');
  print('==========================================');

  if (percentage >= 95.0) {
    print('✅ Coverage goal achieved (>= 95%)');
    exit(0);
  } else {
    print('⚠️  Coverage below 95% (${(95.0 - percentage).toStringAsFixed(2)}% to go)');
    exit(1);
  }
}
