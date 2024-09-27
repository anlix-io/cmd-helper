import 'dart:io';
import 'package:logger/logger.dart';

class Result {
  final String command;
  final String message;
  final int status;

  Result({
    required this.command,
    required this.message,
    required this.status,
  });

  bool get success => status == 0;
}

class Expect {
  final String? expectedOutput;
  final int? expectedStatus;
  final String? exitWithMessage;
  final int? exitWithStatus;

  Expect({
    this.expectedOutput,
    this.expectedStatus,
    this.exitWithMessage,
    this.exitWithStatus,
  });

  static Expect? hasOcurred(Result result, List<Expect> expects) {
    for (Expect expect in expects) {
      if (
        expect.expectedOutput != null &&
        result.message.contains(expect.expectedOutput!)
      ) {
        return expect;
      } else if (
        expect.expectedStatus != null &&
        (result.status == expect.expectedStatus!)
      ) {
        return expect;
      }
    }
    return null;
  }
}

class ProcessRunner {
  static Future<void> run({
    required String command,
    required List<String> args,
    required String workingDirectory,
    List<Expect> expects = const [],
  }) async {
    Logger logger = Logger(
      printer: PrettyPrinter(
        lineLength: 80, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true,
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: ConsoleOutput(), // Add this line to enable console output
    );

    ProcessResult? pRes;
    Result? result;

    try {
      pRes = await Process.run(
        command,
        args,
        workingDirectory: workingDirectory,
      );
      result = Result(
        command: '$command ${args.join(' ')}'.trim(),
        message: (pRes.stdout ?? pRes.stderr).toString(),
        status: pRes.exitCode,
      );
    } catch (e) {
      result = Result(
        command: '$command ${args.join(' ')}'.trim(),
        message: e.toString(),
        status: 1,
      );
    }

    Expect? expect = Expect.hasOcurred(result, expects);
    int status = expect?.exitWithStatus ?? result.status;
    String message = expect?.exitWithMessage ?? result.message;

    if (status == 0) {
      logger.i(
        createMessage(
          command: result.command,
          status: status,
          message: message,
        ),
      );
    } else {
      logger.e(
        createMessage(
          command: result.command,
          status: status,
          message: message,
        ),
      );
      exit(1);
    }
  }

  static String createMessage({
    required String command,
    required int status,
    String? message,
  }) {
    return <String>[
      status == 0
        ? 'Command `$command` executed successfully.'
        : 'Command `$command` failed.',
      if (message != null) 'Message: $message',
    ].join('\n').splitMapJoin(
      RegExp(r'.{1,80}(?:\s+|$)'),
      onMatch: (m) => '${m.group(0)}',
      onNonMatch: (n) => n,
    );
  }
}
