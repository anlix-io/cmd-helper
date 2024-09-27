# CMD Helper

CMD Helper is a Dart-based command-line utility that parses JSON input to run specified commands with arguments and expected outputs.

## Description

This project allows you to run commands with specified arguments and working directories, and it checks the output against expected results. The input is provided as a JSON string.

## Installation

To use CMD Helper, you need to have Dart installed on your machine. You can install Dart from [here](https://dart.dev/get-dart).

Clone the repository and navigate to the project directory:

```sh
git clone https://github.com/yourusername/cmd_helper.git
cd cmd_helper
```

## Usage

To use CMD Helper, run the main function with a JSON string as input. The JSON should have the following structure:

```json
{
  "command": "command",
  "args": ["arg1", "arg2"],
  "workingDirectory": "path",
  "expects": [
    {
      "message": "message",
      "output": "output",
      "success": true
    }
  ]
}
```

## Example

Here is an example of how to run CMD Helper:

```
dart run bin/cmd_helper.dart '{"command": "echo", "args": ["Hello, World!"], "workingDirectory": ".", "expects": [{"message": "Check output", "output": "Hello, World!", "success": true}]}'
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

Fork the repository
Create a new branch (`git checkout -b feature-branch`)
Commit your changes (`git commit -am 'Add new feature'`)
Push to the branch (`git push origin feature-branch`)
Create a new Pull Request


## License

This project is licensed under the MIT License - see the LICENSE file for details.