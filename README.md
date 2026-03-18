# directprint

Directprint The plugin allows Flutter applications to raw print to 
Windows printers using the OpenPrinter/StartDocPrinter system functions,
mainly for sending raw text and control codes to POS printers.

The plugin is intended for the Windows platform only.

## Getting Started

The Directprint() class allows you to send codes directly to a Windows printer
with the help of the "print" method.

```dart
    Future<String?> print(String printer, String job, Uint8List data)
```
Call the "print" method with arguments:

    String printer - Sistem printer name 
    String job - Specifying job name in print queue
    Uint8List data - raw data bytes

The result of the call is a Future String with the following content:

    "OK" - if the call ended without error
    "ERROR:1" - Error: Opening Printer
    "ERROR:2" - Error: Opening Document
    "ERROR:3" - Error: Starting Page
    "ERROR:4" - Error: Printing Count```

## Installing

1. Add this package to your package's `pubspec.yaml` file as described
   on the installation tab

2. Import the librarie

```dart
   import 'package:directprint/directprint.dart';
```

## Example code

```dart
    import 'package:directprint/directprint.dart';
    
    Future doPrint() async {
       // ...
       final _directprintPlugin = Directprint();
   
       // ...
       String data = "Direct print plugin test ...\n\n\n\n";
       Uint8List enctxt = Uint8List.fromList(data.codeUnits);
       
       String printer = 'POS-58';
       String job = 'Invoice';
       
       String dpResult =
         await _directprintPlugin.print(printer, job, enctxt) ?? '';
   
       // ...
    }
```

---

## GitHub Copilot API

The package also provides `GitHubCopilotClient`, a Dart client for interacting
with the [GitHub Copilot](https://github.com/features/copilot) chat completions
API. This lets you use GitHub Copilot as an AI backend directly from your Dart
or Flutter application.

### Prerequisites

You need a GitHub personal access token (classic) or fine-grained token that
has access to GitHub Copilot.

### Classes

| Class | Description |
|---|---|
| `GitHubCopilotClient` | The main client. Handles token exchange and chat requests. |
| `CopilotMessage` | A single message with a `role` (`'system'`, `'user'`, or `'assistant'`) and `content`. |
| `CopilotResponse` | The API response, containing a list of `CopilotChoice` objects. |
| `CopilotChoice` | One completion choice with the model's reply `message` and `finishReason`. |
| `GitHubCopilotException` | Thrown when an API call fails, carrying an optional HTTP `statusCode`. |

### Usage

```dart
import 'package:directprint/directprint.dart';

Future<void> askCopilot() async {
  final client = GitHubCopilotClient(githubToken: 'ghp_yourGitHubToken');

  try {
    final response = await client.chat([
      const CopilotMessage(role: 'system', content: 'You are a helpful assistant.'),
      const CopilotMessage(role: 'user',   content: 'How do I print raw bytes on Windows?'),
    ]);

    print(response.choices.first.message.content);
  } on GitHubCopilotException catch (e) {
    print('Copilot error: $e');
  } finally {
    client.close();
  }
}
```

You can also specify the model:

```dart
final response = await client.chat(
  messages,
  model: 'gpt-3.5-turbo',
);
```

### How it works

1. `GitHubCopilotClient` exchanges your GitHub personal access token for a
   short-lived Copilot API token by calling
   `GET https://api.github.com/copilot_internal/v2/token`.
2. It then calls
   `POST https://api.githubcopilot.com/chat/completions`
   with an OpenAI-compatible request body.
3. The JSON response is deserialized into a `CopilotResponse` object.
