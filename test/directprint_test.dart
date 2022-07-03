import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:directprint/directprint.dart';
import 'package:directprint/directprint_platform_interface.dart';
import 'package:directprint/directprint_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDirectprintPlatform
    with MockPlatformInterfaceMixin
    implements DirectprintPlatform {
  @override
  Future<String?> print(String printer, String job, Uint8List data) =>
      Future.value('OK');
}

void main() {
  final DirectprintPlatform initialPlatform = DirectprintPlatform.instance;

  test('$MethodChannelDirectprint is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDirectprint>());
  });

  test('directPrint', () async {
    Directprint directprintPlugin = Directprint();
    MockDirectprintPlatform fakePlatform = MockDirectprintPlatform();
    DirectprintPlatform.instance = fakePlatform;

    expect(
        await directprintPlugin.print(
            'printer', 'job', Uint8List.fromList('data'.codeUnits)),
        'OK');
  });
}
