import 'dart:io' show Platform;
import 'package:flutter/material.dart';

import 'package:flutter_interfaces_plus/flutter_interfaces_plus.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  List<InetInterface> interfaces;
  bool includeLookBack = true;
  bool includeLinkLocal = true;
  bool includeIPv4 = true;
  bool includeIPv6 = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.updateInterfaces();
    });
  }

  void updateInterfaces() {
    InetInterface.list(
      includeLoopback: this.includeLookBack,
      includeLinkLocal: this.includeLinkLocal,
      includeIPv4: this.includeIPv4,
      includeIPv6: this.includeIPv6
    ).then((value) {
      this.setState(() => this.interfaces = value);
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
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running on: ${Platform.operatingSystem} | ${Platform.operatingSystemVersion}\n',
                    style: TextStyle(color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Interfaces Count: ${this.interfaces == null ? 'Unknown' : this.interfaces.length}',
                    style: TextStyle(color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            this.interfaces == null
                ? Expanded(child: Text("none!"))
                : Expanded(child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Text(this.interfaces.join("\n\n"))
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey),
                      )
                    ),
                  )),
            Container(
              color: Colors.blueAccent.withOpacity(0.3),
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton.icon(
                    onPressed: () => this.updateInterfaces(),
                    icon: Icon(Icons.sync),
                    label: Text("Refresh"),
                  ),
                  OutlineButton.icon(
                    textColor: this.includeLookBack ? Colors.green : null,
                    onPressed: () {
                      this.setState(() => this.includeLookBack = !this.includeLookBack);
                      this.updateInterfaces();
                    },
                    icon: Icon(Icons.settings_backup_restore_rounded),
                    label: Text("LookBack"),
                  ),
                  OutlineButton.icon(
                    textColor: this.includeLinkLocal ? Colors.green : null,
                    onPressed: () {
                      this.setState(() => this.includeLinkLocal = !this.includeLinkLocal);
                      this.updateInterfaces();
                    },
                    icon: Icon(Icons.link),
                    label: Text("LinkLocal"),
                  ),
                  OutlineButton.icon(
                    textColor: this.includeIPv4 ? Colors.green : null,
                    onPressed: () {
                      this.setState(() => this.includeIPv4 = !this.includeIPv4);
                      this.updateInterfaces();
                    },
                    icon: Icon(Icons.filter_4_outlined),
                    label: Text("IPv4"),
                  ),
                  OutlineButton.icon(
                    textColor: this.includeIPv6 ? Colors.green : null,
                    onPressed: () {
                      this.setState(() => this.includeIPv6 = !this.includeIPv6);
                      this.updateInterfaces();
                    },
                    icon: Icon(Icons.filter_6_outlined),
                    label: Text("IPv6"),
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}
