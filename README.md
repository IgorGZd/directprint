# directprint

DirectPrint is a Flutter plugin that allows Flutter applications to send raw data directly to Windows printers using the `OpenPrinter`/`StartDocPrinter` system functions. It is mainly used for sending raw text and ESC/POS control codes to POS (Point of Sale) receipt printers.

The plugin is intended for the **Windows platform only**.

## Capabilities

- Send raw bytes directly to any Windows printer by name
- Compatible with POS receipt printers that accept ESC/POS commands
- Send any binary data, including escape sequences and control codes
- Specify a custom print job name visible in the Windows print queue
- Receive a result indicating success or the specific error that occurred

## Limitations

- Windows platform only — not supported on Android, iOS, macOS, Linux or Web
- Does not render or format documents — raw data is sent as-is to the printer
- Does not enumerate available printers — the printer name must be provided by the caller
- Does not support printer-specific configuration (paper size, DPI, etc.) via this API

## Getting Started

The `Directprint()` class allows you to send raw data directly to a Windows printer using the `print` method:

```dart
Future<String?> print(String printer, String job, Uint8List data)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `printer` | `String` | System printer name (as shown in Windows) |
| `job` | `String` | Job name displayed in the Windows print queue |
| `data` | `Uint8List` | Raw bytes to send directly to the printer |

**Return value:**

| Result | Meaning |
|--------|---------|
| `"OK"` | Print job completed successfully |
| `"ERROR:1"` | Error opening the printer (check printer name) |
| `"ERROR:2"` | Error opening the document |
| `"ERROR:3"` | Error starting the page |
| `"ERROR:4"` | Error writing data to the printer |

## Installing

1. Add this package to your `pubspec.yaml` file as described on the installation tab.

2. Import the library:

```dart
import 'package:directprint/directprint.dart';
```

## Example code

```dart
import 'package:directprint/directprint.dart';

Future doPrint() async {
   final _directprintPlugin = Directprint();

   String data = "Direct print plugin test ...\n\n\n\n";
   Uint8List enctxt = Uint8List.fromList(data.codeUnits);

   String printer = 'POS-58';
   String job = 'Invoice';

   String dpResult =
     await _directprintPlugin.print(printer, job, enctxt) ?? '';

   if (dpResult == 'OK') {
     print('Print successful!');
   } else {
     print('Print failed: $dpResult');
   }
}
```
