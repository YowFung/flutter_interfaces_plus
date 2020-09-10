import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_interfaces_plus/flutter_interfaces_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  dynamic _platformInterfaces;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    dynamic platformInterfaces;
    try {
      platformVersion = await FlutterInterfacesPlus.platformVersion;
      platformInterfaces = await FlutterInterfacesPlus.platformInterfaces;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      platformInterfaces = "Failed to get platform interfaces.";
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _platformInterfaces = platformInterfaces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Interfaces Plus Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Interfaces: $_platformInterfaces\n')
            ],
          )
        ),
      ),
    );
  }
}
