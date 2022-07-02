import 'dart:typed_data';

import 'directprint_platform_interface.dart';

class Directprint {

  Future<String?> print(String printer, String job, Uint8List data) {
    return DirectprintPlatform.instance.print(printer, job, data);
  }
}
