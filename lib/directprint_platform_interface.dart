import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'directprint_method_channel.dart';

abstract class DirectprintPlatform extends PlatformInterface {
  /// Constructs a DirectprintPlatform.
  DirectprintPlatform() : super(token: _token);

  static final Object _token = Object();

  static DirectprintPlatform _instance = MethodChannelDirectprint();

  /// The default instance of [DirectprintPlatform] to use.
  ///
  /// Defaults to [MethodChannelDirectprint].
  static DirectprintPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DirectprintPlatform] when
  /// they register themselves.
  static set instance(DirectprintPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> print(String printer, String job, Uint8List data) {
    throw UnimplementedError('directPrint has not been implemented.');
  }
}
