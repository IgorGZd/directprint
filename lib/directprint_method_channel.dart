import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'directprint_platform_interface.dart';

/// An implementation of [DirectprintPlatform] that uses method channels.
class MethodChannelDirectprint extends DirectprintPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('directprint');

  @override
  Future<String?> print(String printer, String job, Uint8List data) async {
    final version = await methodChannel.invokeMethod<String>(
        'directPrint', {'printer': printer, 'job': job, 'data': data});
    return version;
  }
}
