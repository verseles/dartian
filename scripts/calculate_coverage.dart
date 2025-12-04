import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart calculate_coverage.dart <path_to_lcov.info>');
    exit(1);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    print('File not found: ${args[0]}');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  var totalLines = 0;
  var coveredLines = 0;

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
  print(
    'Coverage: ${percentage.toStringAsFixed(2)}% ($coveredLines/$totalLines lines)',
  );
}
