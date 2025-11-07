import 'package:dartian_cli/dartian_cli.dart';
import 'package:dartian_cli/src/commands/serve_command.dart';
import 'package:dartian_cli/src/commands/new_command.dart';
import 'package:dartian_cli/src/commands/queue_work_command.dart';
import 'package:dartian_cli/src/commands/schedule_run_command.dart';
import 'package:dartian_cli/src/commands/build_command.dart';
import 'package:dartian_cli/src/commands/migrate_command.dart';
import 'package:dartian_cli/src/commands/migrate_rollback_command.dart';

void main(List<String> arguments) async {
  // Check if async commands are being used
  if (arguments.isNotEmpty) {
    switch (arguments[0]) {
      case 'serve':
        final serveArgs = arguments.sublist(1);
        final command = ServeCommand();
        await command.run(serveArgs);
        return;
      case 'new':
        final newArgs = arguments.sublist(1);
        final command = NewCommand();
        await command.run(newArgs);
        return;
      case 'queue:work':
        final queueArgs = arguments.sublist(1);
        final command = QueueWorkCommand();
        await command.run(queueArgs);
        return;
      case 'schedule:run':
        final scheduleArgs = arguments.sublist(1);
        final command = ScheduleRunCommand();
        await command.run(scheduleArgs);
        return;
      case 'build':
        final buildArgs = arguments.sublist(1);
        final command = BuildCommand();
        await command.run(buildArgs);
        return;
      case 'migrate':
        final migrateArgs = arguments.sublist(1);
        final command = MigrateCommand();
        await command.run(migrateArgs);
        return;
      case 'migrate:rollback':
        final rollbackArgs = arguments.sublist(1);
        final command = MigrateRollbackCommand();
        await command.run(rollbackArgs);
        return;
    }
  }

  // Handle synchronous commands
  final output = DartianCli.run(arguments);
  print(output);
}
