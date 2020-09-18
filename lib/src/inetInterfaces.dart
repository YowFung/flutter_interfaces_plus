import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';

import 'inetAddressGroup.dart' show InetAddressGroup;
import 'inetAddress.dart' show InetAddress, InetAddressType;
import 'utils.dart' as utils;


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


class InetInterface
{
  InetInterface._(
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
  String get macString => this.mac == null ? "" : this.mac.map((e) => utils.toHex(e)).join('-');
  List<InetAddressGroup> get addresses => this._addressGroupList;

  InetAddressGroup operator [] (int index) => this._addressGroupList[index];
  bool operator == (Object other) => other is InetInterface && other.hashCode == this.hashCode;

  int get hashCode => this.toString().hashCode;

  void forEach(void Function(InetAddressGroup address) f) => this._addressGroupList.forEach(f);

  String toString() {
    var text = "";
    text += "\nName: ${this.name}\n";
    text += "Index: ${this.index}\n";
    text += "Mac: ${this.macString}\n";
    text += "IsVirtual: ${this.isVirtual}\n";
    for (var i = 0; i < this.length; i++) {
      text += "\nAddress [$i]:\n";
      var lines = this[i].toString().split('\n');
      for(var j = 0; j < lines.length; j++)
        lines[j] = "    " + lines[j] + "\n";
      text += lines.join();
    }
    return text;
  }

  _NetworkInterface toNetworkInterface() {
    return _NetworkInterface(
      index: this.index,
      name: this.name,
      addresses: this.addresses.map((e) => e.ip.toInternetAddress()).toList(growable: false)
    );
  }

  static const MethodChannel _channel = const MethodChannel('flutter_interfaces_plus');

  static Future<List<InetInterface>> list({
    bool includeLoopback: false,
    bool includeLinkLocal: false,
    bool includeIPv4: true,
    bool includeIPv6: true,
    void Function(dynamic errMsg) onError
  }) async {
    List<InetInterface> cards = [];
    List msg = await InetInterface._channel.invokeMethod('getPlatformInterfaces');
    try {
      msg.forEach((c) {
        Map<String, Object> card = Map.from(c);
        String name = card['name'];
        int index = card['index'];
        bool isVirtual = card['isVirtual'];
        Uint8List mac = card['mac'];

        List addresses = card['addresses'];
        List<InetAddressGroup> addressesGroup = [];
        addresses.forEach((addr) {
          String ipStr = addr['address'];
          var i = ipStr.indexOf('%');
          if (i != -1)
            ipStr = ipStr.substring(0, i);
          var ip = InetAddress(ipStr);
          if (!(ip.isLinkLocalAddress && !includeLinkLocal
              || ip.isLoopbackAddress && !includeLoopback
              || ip.type == InetAddressType.IPv4 && !includeIPv4
              || ip.type == InetAddressType.IPv6 && !includeIPv6)
          ) {
            int prefix = int.parse(addr['prefix']);
            var group = InetAddressGroup.byPrefixLength(ip: ip, prefixLength: prefix);
            addressesGroup.add(group);
          }
        });
        if (addressesGroup.isNotEmpty)
          cards.add(InetInterface._(index, name, mac, isVirtual, addressesGroup));
      });
    }
    catch(e) {
      if (onError != null)
        onError(e);
    }
    return cards.toList(growable: false);
  }
}