import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:directprint/directprint.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _directprintPlugin = Directprint();
  String _printStatus = 'Unknown';
  String _printerName = 'Unknown';
  String _jobName = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _directPrintText();
                    },
                    child: const Text('directPrint Test')),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      _directPrintTextWithError();
                    },
                    child: const Text('directPrint Test with error')),
                const SizedBox(height: 10),
                Text('Print status: $_printStatus'),
                const SizedBox(height: 10),
                Text('Printer: $_printerName'),
                Text('Job name: $_jobName'),
                Expanded(child: Container()),
                Container(
                  child: const Text('Check printer name ...'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _directPrintText() async {
    debugPrint('directPrint test ...');
    try {
      String data = "Direct print plugin test ...\n\n\n\n";

      // Uint8List enctxt = await CharsetConverter.encode('852', data);
      Uint8List enctxt = Uint8List.fromList(data.codeUnits);

      String printer = 'POS-58';
      String job = 'Invoice';

      String dpResult =
          await _directprintPlugin.print(printer, job, enctxt) ?? '';

      setState(() {
        _printerName = printer;
        _jobName = job;
        _printStatus = dpResult;
      });

      debugPrint('dpResult=$dpResult');
      debugPrint('test finished.');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _directPrintTextWithError() async {
    debugPrint('directPrint test ...');
    try {
      String data = "Direct print plugin test ...\n\n\n\n";

      Uint8List enctxt = Uint8List.fromList(data.codeUnits);

      String printer = 'unknown';
      String job = 'Invoice';

      String dpResult =
          await _directprintPlugin.print(printer, job, enctxt) ?? '';
      setState(() {
        _printerName = printer;
        _jobName = job;
        _printStatus = dpResult;
      });

      debugPrint('dpResult=$dpResult');
      debugPrint('test finished.');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
