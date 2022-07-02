# directprint

Directprint The plugin allows Flutter applications to raw print to 
Windows printers using the OpenPrinter/StartDocPrinter system functions,
mainly for sending raw text and control codes to POS printers.

The plugin is intended for the Windows platform.

## Getting Started

The Directprint() class allows you to send codes directly to a Windows printer
with the help of the "print" method.

```dart
    Future<String?> print(String printer, String job, Uint8List data)
```
Call the "print" method with arguments:

    String printer - Sistem printr nae 
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
       
       String printer = 'unknown';
       String job = 'Invoice';
       
       String dpResult =
         await _directprintPlugin.print(printer, job, enctxt) ?? '';
   
       // ...
    }
```




