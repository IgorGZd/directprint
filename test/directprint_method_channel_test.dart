
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:directprint/directprint_method_channel.dart';

void main() {
  MethodChannelDirectprint platform = MethodChannelDirectprint();
  const MethodChannel channel = MethodChannel('directprint');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
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
}
