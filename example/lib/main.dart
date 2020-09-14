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
  List<InetNetworkInterface> interfaces;
  String platformVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterInterfacesPlus.platformVersion.then((value) => this.setState(() => this.platformVersion = value));
      InetNetworkInterface.list().then((value) => this.setState(() => this.interfaces = value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Interfaces Plus Demo'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Text('Running on: ${this.platformVersion ?? "Unknown"}\n', style: TextStyle(color: Colors.green)),
            Text('Interfaces: ${this.interfaces == null ? 'Unknown' : this.interfaces.length}\n', style: TextStyle(color: Colors.green)),
            this.interfaces == null ? Text("none!") : Expanded(
                child: SingleChildScrollView(child: Text(this.interfaces.join("\n\n\n")))
              )
            ],
        )
      ),
    );
  }
}
