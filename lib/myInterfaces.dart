import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show required;


class NetworkInterfacePlus extends NetworkInterface
{
  NetworkInterfacePlus(this.index, this.name, List<AddressGroup> addressGroup) {
    this._addressGroupList = addressGroup;
  }

  final int index;
  final String name;

  List<AddressGroup> _addressGroupList = [];

  int get length => this._addressGroupList.length;
  bool get isEmpty => this._addressGroupList.isEmpty;

  List<InternetAddress> get addresses => this._addressGroupList.map((e) => e.ip).toList();
  List<InternetAddress> get broadcastAddress => this._addressGroupList.map((e) => e.bcast).toList();
  List<InternetAddress> get subnetAddress => this._addressGroupList.map((e) => e.subnet).toList();
  List<InternetAddress> get subnetMask => this._addressGroupList.map((e) => e.mask).toList();
  List<InternetAddress> get gateway => this._addressGroupList.map((e) => e.gateway).toList();

  int get hashCode => this.index + this.name.hashCode + this._addressGroupList.length + (){
    var sum = 0;
    this._addressGroupList.forEach((e) => sum += e.hashCode);
    return sum;
  }();

  void forEach(void Function(AddressGroup address) f) => this._addressGroupList.forEach(f);
  AddressGroup operator [] (int index) => this._addressGroupList[index];
  bool operator == (Object other) => other is NetworkInterfacePlus && other.hashCode == this.hashCode;

  static const MethodChannel _channel = const MethodChannel('platform_interfaces');

  static Future<List<Map<String, String>>> get _platformInterfaces async {
    final List interfaces = await _channel.invokeMethod<List>('getPlatformInterfaces');
    final List<Map<String, String>> result = [];
    interfaces.forEach((interface) => result.add(Map<String, String>.from(interface)));
    return result;
  }

  static bool get listSupported => true;
  static Future<List<NetworkInterfacePlus>> list({
    bool includeLoopback: false,
    bool includeLinkLocal: false,
    InternetAddressType type: InternetAddressType.any
  }) {

  }
}


class AddressGroup
{
  AddressGroup({
    @required InternetAddress ip,
    @required InternetAddress mask,
    InternetAddress bcast,
    InternetAddress gateway
  }) {
    assert(ip != null && mask != null);
    this._ip = ip;
    this._mask = mask;
    this._bcast = bcast;
    this._gateway = gateway;
  }

  InternetAddress _ip;
  InternetAddress _subnet;
  InternetAddress _mask;
  InternetAddress _bcast;
  InternetAddress _gateway;

  InternetAddress get ip => this._ip;
  InternetAddress get subnet => this._subnet;
  InternetAddress get mask => this._mask;
  InternetAddress get bcast => this._bcast;
  InternetAddress get gateway => this._gateway;

  @override
  int get hashCode => this._ip.hashCode + this._mask.hashCode + this._bcast.hashCode + this._gateway.hashCode;

  @override
  bool operator == (Object other) => other is AddressGroup && other.hashCode == this.hashCode;
}