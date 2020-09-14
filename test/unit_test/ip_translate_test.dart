import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main()
{
  test("InternetAddress type test - normal ipv4", () {
    var ip = "192.168.1.1";
    var addr = InternetAddress(ip);
    expect(addr.type, equals(InternetAddressType.IPv4));
  });

  test("InternetAddress type test - normal ipv6", () {
    var ip = "fe80:0000:0000:0000:0204:61ff:fe9d:f156";
    var addr = InternetAddress(ip);
    expect(addr.type, equals(InternetAddressType.IPv6));
  });

  test("InternetAddress type test - zip ipv6", () {
    var ip = "fe80::";
    var addr = InternetAddress(ip);
    expect(addr.type, equals(InternetAddressType.IPv6));
  });

  test("InternetAddress type test - any", () {
    var ipv4 = "0.0.0.0";
    var ipv6 = "::";
    var addr4 = InternetAddress(ipv4);
    var addr6 = InternetAddress(ipv6);
    expect(addr4.type, InternetAddressType.any);
    expect(addr6.type, InternetAddressType.any);
  });

  test("IPv6 address zip test", () {
    // var raw = ["0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000"];
    // var raw = ["fe80", "0000", "0000", "0000", "0000", "0000", "0000", "0000"];
    var raw = ["0000", "0000", "0000", "0000", "0000", "0000", "0000", "0001"];
    // var raw = ["fe80", "0000", "0000", "0000", "0000", "0000", "0000", "0123"];
    // var raw = ["0000", "0000", "1234", "0000", "0000", "0000", "0000", "0002"];

    for (var i = 0; i < raw.length; i++) {
      while(raw[i].length > 1 && raw[i][0] == '0')
        raw[i] = raw[i].substring(1);
    }
    var addr = raw.join(':');
    for (var i = 8; i > 0; i--) {
      var reg = List.filled(i, '0').join(':');
      var index = -1;
      do {
        index = addr.indexOf(reg, index+1);
      } while(index > 0 && addr[index-1] != ":");

      if (index != -1) {
        addr = addr.replaceFirst(reg, "::", index).replaceAll("::::", "::").replaceAll(":::", "::");
        break;
      }
    }

    // expect(addr, "::");
    // expect(addr, "fe80::");
    expect(addr, "::1");
    // expect(addr, "fe80::123");
    // expect(addr, "0:0:1234::2");
  });

  test("InternetAddress String test - abnormal", () {
    var ip = "fafda534tnjkfsd";
    try {
      var addr = InternetAddress(ip);
      expect(addr.address, ip);
    }
    catch(e) {
      print(e);
      expect(true, false);
    }
  });

  test("InternetAddress rawAddress test - ipv4", () {
    var ipv4 = "0.0.0.0";
    var addr4 = InternetAddress(ipv4);
    expect(addr4.rawAddress, equals([0, 0, 0, 0]));
  });

  test("InternetAddress rawAddress test - ipv6", () {
    var ipv6 = "fe80::204:61ff:fe9d:f156";
    var addr6 = InternetAddress(ipv6);
    expect(addr6.rawAddress, equals([254, 128, 0, 0, 0, 0, 0, 0, 2, 4, 97, 255, 254, 157, 241, 86]));
  });

  test("InternetAddress ipv6 raw string address test", () {
    // var ipv6 = "fe80::204:61ff:fe9d:f156";
    // var ipv6 = "::";
    // var ipv6 = "fe80::";
    var ipv6 = "::1";
    var addr6 = InternetAddress(ipv6);
    var raw = ipv6.split(":");
    var length = raw.length;
    if (length < 8) {
      if (ipv6 == "::")
        raw = List.filled(8, "0", growable: false);
      else if (length >= 3 && raw[0].isEmpty && raw[1].isEmpty)
        raw = [...List.filled(8-length+2, "0"), ...raw.sublist(2)];
      else if (length >= 3 && raw[length-1].isEmpty && raw[length-2].isEmpty)
        raw = [...raw.sublist(0, length-2), ...List.filled(8-length+2, "0")];
      else {
        var index = raw.indexOf("");
        if (index != -1)
          raw = [...raw.sublist(0, index), ...List.filled(8-length+1, "0"), ...raw.sublist(index+1)];
        else
          throw "Invalid IPv6 address.";
      }
    }

    for (var i = 0; i < 8; i++) {
      if (raw[i].length < 4)
        raw[i] = '0'*(4-raw[i].length) + raw[i];
    }

    // expect(raw, equals(["fe80", "0000", "0000", "0000","0204", "61ff", "fe9d", "f156"]));
    // expect(raw, equals(["0000", "0000", "0000", "0000","0000", "0000", "0000", "0000"]));
    // expect(raw, equals(["fe80", "0000", "0000", "0000","0000", "0000", "0000", "0000"]));
    expect(raw, equals(["0000", "0000", "0000", "0000","0000", "0000", "0000", "0001"]));
  });
}