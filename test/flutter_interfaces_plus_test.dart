import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_interfaces_plus/flutter_interfaces_plus.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_interfaces_plus');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterInterfacesPlus.platformVersion, '42');
  });
}
