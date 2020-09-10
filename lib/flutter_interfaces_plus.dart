
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterInterfacesPlus {
  static const MethodChannel _channel = const MethodChannel('flutter_interfaces_plus');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<Map<String, String>>> get platformInterfaces async {
    final List interfaces = await _channel.invokeMethod<List>('getPlatformInterfaces');
    final List<Map<String, String>> result = [];
    interfaces.forEach((interface) => result.add(Map<String, String>.from(interface)));
    return result;
  }
}
