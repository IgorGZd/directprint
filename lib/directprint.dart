import 'package:flutter/foundation.dart';
import 'directprint_platform_interface.dart';

export 'src/github_copilot_client.dart';

class Directprint {
  Future<String?> print(String printer, String job, Uint8List data) {
    return DirectprintPlatform.instance.print(printer, job, data);
  }
}
