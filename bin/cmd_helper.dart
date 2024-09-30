import 'dart:convert';
import 'dart:io';

import 'package:cmd_helper/cmd_helper.dart';

// Main function parses the arguments and runs the command.
// The input must be a JSON file with the following structure:
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
  List<Map<String, dynamic>> jsonList = [];

  try {
    String filepath = File(args[0]).readAsStringSync();
    Map<String, dynamic> json = jsonDecode(filepath);
    if (json.containsKey('list')) {
      jsonList = List<Map<String, dynamic>>.from(json['list']);
    } else if (!json.containsKey('command') || !json.containsKey('args')) {
      print('Invalid JSON: missing command or args');
      print('Usage: dart cmd_helper.dart <json file>');
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
          expectedOutput: expect['expectedOutput'],
          expectedStatus: expect['expectedStatus'],
          exitWithMessage: expect['exitWithMessage'],
          exitWithStatus: expect['exitWithStatus'],
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
}
