import 'dart:io';
import 'package:logger/logger.dart';

class Result {
  final String message;
  final int status;

  Result({
    required this.message,
    required this.status,
  });

  bool get success => status == 0;
}

class Expect {
  final String? message;
  final String? output;
  final bool success;

  Expect({
    this.message,
    this.output,
    this.success = true,
  });

  Expect.success({
    this.message,
    this.output,
  }) : success = true;


  Expect.failure({
    this.message,
    this.output,
  }) : success = false;

  static Expect? hasOcurred(Result result, List<Expect> expects) {
    for (Expect expect in expects) {
      if (
        result.status == 0 && expect.success ||
        result.status != 0 && !expect.success
      ) {
        return expect;
      } else if (
        expect.output != null &&
        result.message.contains(expect.output!)
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
        lineLength: stdout.terminalColumns, // Width of the output
        colors: stdout.supportsAnsiEscapes, // Colorful log messages
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
        message: (pRes.stdout ?? pRes.stderr).toString(),
        status: pRes.exitCode,
      );
    } catch (e) {
      result = Result(
        message: e.toString(),
        status: 1,
      );
    }

    Expect? expect = Expect.hasOcurred(result, expects);

    if (expect != null) {
      if (expect.success) {
        logger.i(logMessage(result, expect: expect));
        exit(0);
      } else {
        logger.i(logMessage(result, expect: expect));
        exit(1);
      }
    }

    if (result.success) {
      logMessage(result);
      exit(0);
    } else {
      logMessage(result);
      exit(1);
    }
  }

  static String logMessage(
    Result result, {
    Expect? expect,
  }) {
    if (expect != null) {
      if (expect.success) {
        return 'Command executed successfully.';
      } else {
        return [
          'Command failed.',
          if (result.message.isNotEmpty) 'Output: ${result.message}',
          expect.message,
        ].join('\n');
      }
    }

    if (result.success) {
      return 'Command executed successfully.';
    } else {
      return [
        'Command failed.',
        if (result.message.isNotEmpty) 'Output: ${result.message}',
      ].join('\n');
    }
  }
}