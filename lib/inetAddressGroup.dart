import 'dart:typed_data';

import 'package:flutter/foundation.dart' show required;
import 'inetAddress.dart' show InetAddress, InetAddressType;


class InetAddressGroup
{
  static InetAddress calcBroadcastAddressByMask(InetAddress ip, InetAddress mask) {
    assert(ip.type == mask.type);
    var ipRaw = ip.toRawInt();
    var maskRaw = mask.toRawInt();
    var length = ip.bitsLength~/8;
    var bRaw = List.filled(length, 0);
    for (var i = 0; i < length; i++)
      bRaw[i] = ipRaw[i] & maskRaw[i] | ~maskRaw[i];
    return InetAddress.fromRawAddress(Uint8List.fromList(bRaw));
  }

  static InetAddress calcMaskByPrefixLength(int prefixLength, InetAddressType type) {
    var maxLength = type == InetAddressType.IPv4 ? 32 : 128;
    if (prefixLength > maxLength || prefixLength < 1)
      throw RangeError.range(prefixLength, 1, maxLength);
    var raw = List.filled(maxLength~/8, 0);
    var seg = prefixLength~/8;
    var offset = prefixLength%8;
    for (var i = 0; i < raw.length; i++) {
      if (seg > i+1)
        raw[i] = 0xff;
      else if (seg == i+1) {
        raw[i] = offset == 0 ? 0xff : 0xff << 8-offset;
        break;
      }
    }
    return InetAddress.fromRawAddress(Uint8List.fromList(raw));
  }

  static int calcPrefixLengthByMask(InetAddress mask) {
    if (mask.isMask)
      throw "Invalid mask address ${mask.toString()}";
    var length = 0;
    var raw = mask.toRawInt();
    for (var i = 0; i < raw.length; i++) {
      var index = [0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff].indexOf(raw[i]);
      if (index == -1)
        break;
      else
        length += index +1;
    }
    return length;
  }

  InetAddressGroup.withMask({
    @required this.ip,
    @required InetAddress mask
  }) : assert(ip != null && mask != null && mask.isMask && ip.type == mask.type) {
    this._mask = mask;
    this._prefixLength = InetAddressGroup.calcPrefixLengthByMask(mask);
    this._broadcast = InetAddressGroup.calcBroadcastAddressByMask(this.ip, mask);
  }

  InetAddressGroup.withPrefixLength({
    @required this.ip,
    @required int prefixLength
  }) : assert(ip != null && prefixLength > 0 && prefixLength <= ip.bitsLength) {
    this._prefixLength = prefixLength;
    this._mask = InetAddressGroup.calcMaskByPrefixLength(prefixLength, this.ip.type);
    this._broadcast = InetAddressGroup.calcBroadcastAddressByMask(ip, this._mask);
  }

  final InetAddress ip;
  int _prefixLength;
  InetAddress _mask;
  InetAddress _broadcast;

  int get prefixLength => this._prefixLength;
  InetAddressType get type => this.ip.type;
  InetAddress get mask => this._mask;
  InetAddress get broadcast => this._broadcast;

  @override
  int get hashCode => this.ip.hashCode + this._mask.hashCode + this._broadcast.hashCode;

  @override
  bool operator == (Object other) => other is InetAddressGroup && other.hashCode == this.hashCode;
}