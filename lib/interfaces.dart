import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show required;



class InterfaceList
{
  List<Interface> _interfaces;

  int get length => this._interfaces.length;
  bool get isEmpty => this._interfaces.isEmpty;
  int get hashCode => this._interfaces.hashCode;

  InterfaceList() {
    this._interfaces = [];
  }

  void clear() {
    this._interfaces.clear();
  }

  void add(Interface value) {
    this._interfaces.add(value);
  }

  bool remove(Interface value) {
    return this._interfaces.remove(value);
  }

  bool contains(Interface element, [allowSimilar=true]) {
    return allowSimilar 
      ? this._interfaces.any((ele) => ele == element) 
      : this._interfaces.contains(element);
  }

  void forEach(void handler(Interface element)) {
    this._interfaces.forEach(handler);
  }

  bool any(bool handler(Interface element)) {
    return this._interfaces.any(handler);
  }

  bool every(bool handler(Interface element)) {
    return this._interfaces.every(handler);
  }

  Interface operator [] (int index) => this._interfaces[index];

  bool operator == (Object other) {
    return other is InterfaceList &&
      other.length == this.length &&
      other.every((element) => this.contains(element));
  }
}


class Interface
{
  Interface({
    @required String name, 
    @required String ipv4, 
    String mask: "", 
    String bcast: "", 
    String gateway: ""
  }) {
    this._name = name;
    this._ipv4 = ipv4;
    this._mask = mask;
    this._bcast = bcast;
    this._gateway = gateway;

    if (this.mask.isNotEmpty && this.bcast.isEmpty) 
      this._bcast = this._calcBcast(this.rawIpv4, this.rawMask);
  }

  String _name;
  String _ipv4;
  String _mask;
  String _gateway;
  String _bcast;

  bool get isValid => this._check();

  String get name => this._name;
  String get ipv4 => this._ipv4;
  String get mask => this._mask;
  String get gateway => this._gateway;
  String get bcast => this._bcast;

  List<int> get rawIpv4 => this._getRaw(this.ipv4);
  List<int> get rawMask => this._getRaw(this.mask);
  List<int> get rawGateway => this._getRaw(this.gateway);
  List<int> get rawBcast => this._getRaw(this.bcast);

  int get hashCode => (this.ipv4 + this.name + this.mask + this.gateway + this.bcast).hashCode;

  bool operator == (Object other) => 
    other is Interface && 
    other.name == this.name && 
    other.ipv4 == this.ipv4 && 
    other.mask == this.mask &&
    other.gateway == this.gateway &&
    other.bcast == this.bcast;

  bool _check() {
    if (this.name.isEmpty || this.ipv4.isEmpty || this.bcast.isEmpty)
      return false;
    
    [this.rawIpv4, this.rawMask, this.rawGateway, this.rawBcast].forEach((raw) { 
      raw.forEach((seg) { 
        if (seg < 0 || seg > 255)
          return false;
      });
    });

    return true;
  }

  List<int> _getRaw(String segStr) {
    try {
      return segStr.split('.').map((seg) => int.parse(seg)).toList();
    } catch(_) {
      return [];
    }
  }

  String _calcBcast(List<int> ipv4, List<int> mask) {
    if (mask.length != 4 || ipv4.length != 4)
      return "";

    List<int> resList = [];

    for (var i = 0; i < 4; i++) {
      var ipSeg = ipv4[i].toUnsigned(8);
      var maskSeg = mask[i].toUnsigned(8);
      var inverseMaskSeg = (~maskSeg).toUnsigned(8);
      var addressSeg = (ipSeg & maskSeg | inverseMaskSeg).toUnsigned(8);

      if (addressSeg < 0)
        addressSeg = (~addressSeg | 0x80) + 1;

      resList.add(addressSeg);
    }

    var resStr = "";
    resList.forEach((seg) {resStr += seg.toString(); resStr += ".";});
    resStr = resStr.substring(0, resStr.length-1);
    return resStr;
  }
}