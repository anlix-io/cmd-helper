import 'dart:convert';
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

  @override
  String toString() {
    return 'Result(${{
      'command': command,
      'message': message,
      'status': status,
    }})';
  }
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

  @override
  String toString() {
    return 'Expected(${{
      'expectedOutput': expectedOutput,
      'expectedStatus': expectedStatus,
      'exitWithMessage': exitWithMessage,
      'exitWithStatus': exitWithStatus,
    }})';
  }

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
  static void run({
    required String command,
    required List<String> args,
    required String workingDirectory,
    List<Expect> expects = const [],
  }) {
    Logger logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        lineLength: 80, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true,
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
    );

    ProcessResult? pRes;
    Result? result;

    try {
      pRes = Process.runSync(
        command,
        args,
        workingDirectory: workingDirectory,
        stderrEncoding: Encoding.getByName('utf-8'),
        stdoutEncoding: Encoding.getByName('utf-8'),
      );

      result = Result(
        command: '$command ${args.join(' ')}'.trim(),
        message: pRes.exitCode == 0
          ? pRes.stdout.toString()
          : pRes.stderr.toString(),
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

    if (status == 0) {
      logger.i(
        createMessage(
          command: result.command,
          status: status,
          result: result.message,
          message: expect?.exitWithMessage,
        ),
      );
    } else {
      logger.e(
        createMessage(
          command: result.command,
          status: status,
          result: result.message,
          message: expect?.exitWithMessage,
        ),
      );
      exit(1);
    }
  }

  static String createMessage({
    required String command,
    required int status,
    String? result,
    String? message,
  }) {
    return <String>[
      status == 0
        ? 'Command `$command` executed successfully.'
        : 'Command `$command` failed.',
      if (result != null) 'Result: $result',
      if (message != null) 'Message: $message',
    ].join('\n').splitMapJoin(
      RegExp(r'.{1,64}(?:\s+|$)'),
      onMatch: (m) => '${m.group(0)}',
      onNonMatch: (n) => n,
    );
  }
}
