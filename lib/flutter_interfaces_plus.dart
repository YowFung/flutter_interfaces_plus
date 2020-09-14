export 'inetAddress.dart';
export 'inetAddressGroup.dart';
export 'inetInterfaces.dart';

import 'dart:async';
import 'package:flutter/services.dart';


class FlutterInterfacesPlus {
  static const MethodChannel _channel = const MethodChannel('flutter_interfaces_plus');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
