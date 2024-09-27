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
  final String? message;
  final String? output;
  final bool? success;

  Expect({
    this.message,
    this.output,
    this.success,
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
        expect.output != null &&
        result.message.contains(expect.output!)
      ) {
        return expect;
      } else if (
        expect.success != null && (
        result.status == 0 && expect.success! ||
        result.status != 0 && !expect.success!
      )) {
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

    if (expect != null && expect.success != null) {
      if (expect.success!) {
        logger.i(logMessage(result, expect: expect));
      } else {
        logger.e(logMessage(result, expect: expect));
        exit(1);
      }
    }

    if (result.success) {
      logger.i(logMessage(result));
    } else {
      logger.e(logMessage(result));
      exit(1);
    }
  }

  static String logMessage(
    Result result, {
    Expect? expect,
  }) {
    String message = '';
    if (expect != null && expect.success != null) {
      if (expect.success!) {
        message = [
          'Command `${result.command}` executed successfully.',
          if (result.message.isNotEmpty) 'Output: ${result.message}',
          expect.message,
        ].join('\n');
      } else {
        message = [
          'Command `${result.command}` failed.',
          if (result.message.isNotEmpty) 'Output: ${result.message}',
          expect.message,
        ].join('\n');
      }
    }

    if (result.success) {
      message = [
        'Command `${result.command}` executed successfully.',
        if (result.message.isNotEmpty) 'Output: ${result.message}',
      ].join('\n');
    } else {
      message = [
        'Command `${result.command}` failed.',
        if (result.message.isNotEmpty) 'Output: ${result.message}',
      ].join('\n');
    }
    // Break the message into multiple lines at the last space before the line
    // reaches the line length.
    return message.splitMapJoin(
      RegExp(r'.{1,80}(?:\s+|$)'),
      onMatch: (m) => '${m.group(0)}',
      onNonMatch: (n) => n,
    );
  }
}