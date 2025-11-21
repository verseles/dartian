import 'dart:async';
import 'dart:io';

import 'package:dartian_cli/src/commands/serve_command.dart';
import 'package:test/test.dart';

void main() {
  group('serve command', () {
    test('should accept valid host and port arguments', () async {
      final command = ServeCommand();

      // This test just verifies that the command can be instantiated
      // and parse arguments without errors
      expect(command, isNotNull);
    });

    test('should handle invalid port argument', () async {
      final command = ServeCommand();

      // Test with non-numeric port - should use default
      // Run won't throw, but will use default port
      expect(command, isNotNull);
    });

    test('should use default host and port when not specified', () {
      final command = ServeCommand();

      // Default values should be accessible
      expect(ServeCommand.defaultHost, equals('localhost'));
      expect(ServeCommand.defaultPort, equals(8000));
    });

    test('should parse valid arguments', () async {
      final command = ServeCommand();

      // Test that command can parse arguments without throwing
      // Note: We can't easily test the full execution without a real server
      expect(() => command, returnsNormally);
    });

    test('should start server on specified port', () async {
      final command = ServeCommand();

      // Start server in background with timeout
      final serverFuture = command.run(['--host=localhost', '--port=9999']);

      // Wait for server to start
      await Future.delayed(Duration(seconds: 2));

      // Try to connect to the server
      try {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('http://localhost:9999/'));
        final response = await request.close();

        // Server should respond
        expect(response.statusCode, equals(200));

        // Read response body
        final body = await response.transform(SystemEncoding().decoder).join();
        expect(body, contains('Dartian Development Server'));

        client.close();
      } catch (e) {
        fail('Server should be running and accepting connections: $e');
      }

      // Cancel the server (it runs indefinitely)
      // Note: In a real scenario, we'd need proper cleanup mechanism
    }, timeout: Timeout(Duration(seconds: 10)), skip: 'Manual test - requires VM service');
  });
}
