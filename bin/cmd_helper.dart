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
void main(List<String> args) async {
  List<Map<String, dynamic>> jsonList = [];

  try {
    Map<String, dynamic> json = jsonDecode(args.join(' '));
    if (json.containsKey('list')) {
      jsonList = List<Map<String, dynamic>>.from(json['list']);
    } else if (!json.containsKey('command') || !json.containsKey('args')) {
      print('Invalid JSON: missing command or args');
      print('Usage: dart cmd_helper.dart <json>');
      exit(1);
    } else {
      jsonList.add(json);
    }
  } catch (e) {
    print('Invalid JSON: $e');
    print('Usage: dart cmd_helper.dart <json>');
    exit(1);
  }

  for (Map<String, dynamic> json in jsonList) {
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

    await ProcessRunner.run(
      command: command,
      args: argsList,
      workingDirectory: workingDirectory,
      expects: expects,
    );
  }
}