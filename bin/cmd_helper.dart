import 'dart:convert';
import 'dart:io';

import 'package:cmd_helper/cmd_helper.dart';

// Main function parses the arguments and runs the command.
// The input must be a JSON string with the following structure:
// {
//   "command": "command",
//   "args": ["arg1", "arg2"],
//   "workingDirectory": "path",
//   "expects": [
//     {
//       "message": "message",
//       "output": "output",
//       "success": true
//     }
//   ]
// }
void main(List<String> args) {
  Map<String, dynamic> json = {};

  try {
    json = jsonDecode(args.join(' '));
  } catch (e) {
    print('Invalid JSON: $e');
    print('Usage: dart cmd_helper.dart <json>');
    exit(1);
  }

  String command = json['command'];
  List<String> argsList = List<String>.from(json['args']);
  String workingDirectory = json['workingDirectory'] ?? '.';
  List<Expect> expects = [];

  if (json.containsKey('expects')) {
    for (Map<String, dynamic> expect in json['expects']) {
      expects.add(Expect(
        message: expect['message'],
        output: expect['output'],
        success: expect['success'],
      ));
    }
  }

  ProcessRunner.run(
    command: command,
    args: argsList,
    workingDirectory: workingDirectory,
    expects: expects,
  );
}