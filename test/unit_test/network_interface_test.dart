import 'package:flutter_test/flutter_test.dart';
import 'dart:io';


void main() {
  test("NetworkInterface index test", () async {
    var list = await NetworkInterface.list(includeLinkLocal: true, includeLoopback: true);
    list.forEach((element) {
      print(element.name);
      print(element.addresses);
      print(element.index);
      print('--------------');
    });
  });
}
