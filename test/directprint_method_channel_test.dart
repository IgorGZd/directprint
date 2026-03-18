
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:directprint/directprint_method_channel.dart';

void main() {
  MethodChannelDirectprint platform = MethodChannelDirectprint();
  const MethodChannel channel = MethodChannel('directprint');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getPrinters') {
        return ['Printer One', 'Printer Two'];
      }
      return 'OK';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('directPrint', () async {
    expect(
        await platform.print(
                'printer', 'job', Uint8List.fromList('data'.codeUnits)) ??
            '',
        'OK');
  });

  test('getPrinters', () async {
    final printers = await platform.getPrinters();
    expect(printers, ['Printer One', 'Printer Two']);
  });
}
