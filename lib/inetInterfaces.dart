import 'dart:io';
import 'dart:convert' show json, utf8;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';

import 'inetAddressGroup.dart' show InetAddressGroup;
import 'inetAddress.dart' show InetAddress;


class _NetworkInterface extends NetworkInterface
{
  _NetworkInterface({
    this.index,
    this.name,
    this.addresses,
  });

  final int index;
  final String name;
  final List<InternetAddress> addresses;
}


class InetNetworkInterface
{
  InetNetworkInterface._(
      this.index,
      this.name,
      this.mac,
      this.isVirtual,
      List<InetAddressGroup> addresses
  ) {
    this._addressGroupList = addresses;
  }

  final int index;
  final String name;
  final Uint8List mac;
  final bool isVirtual;

  List<InetAddressGroup> _addressGroupList = [];

  int get length => this._addressGroupList.length;
  bool get isEmpty => this._addressGroupList.isEmpty;

  List<InetAddressGroup> get addresses => this._addressGroupList;

  int get hashCode => this.index + this.name.hashCode + this._addressGroupList.length + (){
    var sum = 0;
    this._addressGroupList.forEach((e) => sum += e.hashCode);
    return sum;
  }();

  void forEach(void Function(InetAddressGroup address) f) => this._addressGroupList.forEach(f);

  String toString() {
    var text = "."*100;
    text += "\nName: ${this.name}\n";
    text += "Index: ${this.index}\n";
    text += "Mac: ${this.mac}\n";
    text += "IsVirtual: ${this.isVirtual}\n";
    for (var i = 0; i < this.addresses.length; i++) {
      text += "\nAddress [$i]:\n";
      text += "    Address: \t${this.addresses[i].ip}\n";
      text += "    Type: \t${this.addresses[i].type}\n";
      text += "    Prefix: \t${this.addresses[i].prefixLength}\n";
      text += "    Mask: \t${this.addresses[i].mask}\n";
      text += "    Broadcast: \t${this.addresses[i].broadcast}\n";
    }
    text += "."*100;
    return text;
  }

  _NetworkInterface toNetworkInterface() {
    return _NetworkInterface(
      index: this.index,
      name: this.name,
      addresses: this.addresses.map((e) => e.ip.toInternetAddress()).toList(growable: false)
    );
  }

  InetAddressGroup operator [] (int index) => this._addressGroupList[index];
  bool operator == (Object other) => other is InetNetworkInterface && other.hashCode == this.hashCode;

  static const MethodChannel _channel = const MethodChannel('flutter_interfaces_plus');

  static Future<List<InetNetworkInterface>> list({
    bool includeLoopback: false,
    bool includeLinkLocal: false,
    InternetAddressType type: InternetAddressType.any
  }) async {
    var message = await InetNetworkInterface._channel.invokeMethod('getPlatformInterfaces');
    List jsonObj = json.decode(message);
    print('+++++++++++++++++++++++++++++++');
    print(jsonObj);
    print('+++++++++++++++++++++++++++++++');
    // try {
      List<InetNetworkInterface> cards = [];
      jsonObj.forEach((c) {
        Map<String, Object> card = c;
        String name = card['name'];
        int index = card['index'];
        bool isVirtual = card['isVirtual'];
        Uint8List mac = Uint8List.fromList(utf8.encode(card['mac'].toString()));

        List addresses = card['addresses'];
        List<InetAddressGroup> addressesGroup = [];
        addresses.forEach((addr) {
          String ip = addr['address'];
          var i = ip.indexOf('%');
          if (i != -1)
            ip = ip.substring(0, i);
          addressesGroup.add(InetAddressGroup.withPrefixLength(
              ip: InetAddress(ip),
              prefixLength: int.parse(addr['prefix']))
          );
        });
        cards.add(InetNetworkInterface._(index, name, mac, isVirtual, addressesGroup));
      });
      return cards.toList(growable: false);
    // }
    // catch(e) {
    //   print("InetNetworkInterfaceParseError: $e");
    //   return List.empty();
    // }
  }
}