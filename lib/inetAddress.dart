import 'dart:io' show InternetAddress, InternetAddressType;
import 'dart:typed_data' show Uint8List;


enum InetAddressType {IPv4, IPv6}


class InetAddress
{
  /// Determines whether an IP address is within a given range.
  /// return true if [floor] <= [target] <= [ceiling]
  static bool isContains(InetAddress target, InetAddress floor, InetAddress ceiling) {
    assert(target.type == floor.type && target.type == ceiling.type);
    return InetAddress._isContains(target.toRawInt(), floor.toRawInt(), ceiling.toRawInt());
  }

  /// (private) Determines whether an IP address is within a given range.
  static bool _isContains(List<int> target, List<int> floor, List<int> ceiling) {
    assert(target.length == floor.length && target.length == ceiling.length);

    var checkFloor = true;
    var checkCeiling = true;
    for (var i = 0; i < target.length; i++) {
      if (checkFloor && target[i] < floor[i])
        return false;
      if (checkCeiling && target[i] > ceiling[i])
        return false;

      if (!checkFloor && checkCeiling && target[i] < ceiling[i])
        return true;
      if(checkFloor && !checkCeiling && target[i] > floor[i])
        return true;
      if(checkFloor && checkCeiling && target[i] > floor[i] && target[i] < ceiling[i])
        return true;

      checkFloor = checkFloor && target[i] == floor[i];
      checkCeiling = checkCeiling && target[i] == ceiling[i];
    }
    return true;
  }

  InetAddress(String address) {
    this._ip = InternetAddress(address);
    this._type = this._ip.type == InternetAddressType.IPv4 ? InetAddressType.IPv4 : InetAddressType.IPv6;
  }

  InetAddress.fromRawAddress(Uint8List rawAddress) {
    this._ip = InternetAddress.fromRawAddress(rawAddress);
    this._type = this._ip.type == InternetAddressType.IPv4 ? InetAddressType.IPv4 : InetAddressType.IPv6;
  }

  InternetAddress _ip;
  InetAddressType _type;

  InetAddressType get type => this._type;
  int get bitsLength => this._type == InetAddressType.IPv4 ? 32 : 128;

  bool get isAnyLocalAddress => this._isAnyLocalAddress();
  bool get isLoopbackAddress => this._isLoopbackAddress();
  bool get isLinkLocalAddress => this._isLinkLocalAddress();
  bool get isSiteLocalAddress => this._isSiteLocalAddress();
  bool get isMulticastAddress => this._isMulticastAddress();
  bool get isMCGlobal => this._isMCGlobal();
  bool get isMCLinkLocal => this._isMCLinkLocal();
  bool get isMCNodeLocal => this._isMCNodeLocal();
  bool get isMCOrgLocal => this._isMCOrgLocal();
  bool get isMCSiteLocal => this._isMCSiteLocal();
  bool get isMask => this._isMask();

  InternetAddress toInternetAddress() => this._ip;

  String toString() {
    if (this._type == InetAddressType.IPv4)
      return this.toRawInt().join('.');
    else {
      var raw = this.toRawStringTidy().toList();
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
      return addr;
    }
  }

  Uint8List toRawInt() => this._ip.rawAddress;

  List<String> toRawString() {
    if (this._type == InetAddressType.IPv4)
      return this._ip.address.split('.').toList(growable: false);
    else {
      var raw = this._ip.address.split(':');
      var length = raw.length;
      if (length < 8) {
        if (length == 3 && raw.every((e) => e.isEmpty))
          raw = List.filled(8, "0");
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
      return raw.toList(growable: false);
    }
  }

  List<String> toRawStringTidy() {
    return this.toRawString().map(
      (e) => '0'*((this._type == InetAddressType.IPv4 ? 3 : 4) - e.length) + e
    ).toList();
  }

  bool _isAnyLocalAddress() {
    return (this._type == InetAddressType.IPv4 && this.toString() == '0.0.0.0')
        || (this._type == InetAddressType.IPv6 && this.toString() == '::');
  }

  bool _isLoopbackAddress() {
    return (this._type == InetAddressType.IPv4 && InetAddress._isContains(this.toRawInt(), [127, 0, 0, 0], [127, 255, 255, 255]))
        || (this._type == InetAddressType.IPv6 && this.toString() == '::1');
  }

  bool _isLinkLocalAddress() {
    if (this._type == InetAddressType.IPv4)
      return InetAddress._isContains(this.toRawInt(), [169, 254, 0, 0], [169, 254, 255, 255]);
    else if (this._type == InetAddressType.IPv6) {
      var raw = this.toRawInt();
      return raw[0] == 0xfe && raw[1] & 0x80 >> 4 == 0x08;
    }
    return false;
  }

  bool _isSiteLocalAddress() {
    if (this._type == InetAddressType.IPv4) {
      return InetAddress._isContains(this.toRawInt(), [10, 0, 0, 0], [10, 255, 255, 255])
          || InetAddress._isContains(this.toRawInt(), [172, 16, 0, 0], [172, 31, 255, 255])
          || InetAddress._isContains(this.toRawInt(), [192, 168, 0, 0], [192, 168, 255, 255]);
    }
    else if (this._type == InetAddressType.IPv4)
      return this.toRawInt()[0] == 0xfe && this.toRawInt()[1] & 0xc0 >> 4 == 0x0c;
    return false;
  }

  bool _isMulticastAddress() {
    if (this._type == InetAddressType.IPv4)
      return InetAddress._isContains(this.toRawInt(), [224, 0, 0, 0], [239, 255, 255, 255]);
    else if (this._type == InetAddressType.IPv4)
      return this.toRawInt()[0] == 0xff;
    return false;
  }

  bool _isMCGlobal() {
    if (this._type == InetAddressType.IPv4)
      return InetAddress._isContains(this.toRawInt(), [224, 0, 0, 1], [238, 255, 255, 255]);
    else if (this._type == InetAddressType.IPv4) {
      var raw = this.toRawInt();
      return raw[0] == 0xff && raw[1] >= 0x0e && raw[1] <= 0xfe;
    }
    return false;
  }

  bool _isMCLinkLocal() {
    if (this._type == InetAddressType.IPv4)
      return InetAddress._isContains(this.toRawInt(), [224, 0, 0, 0], [224, 0, 0, 255]);
    else if (this._type == InetAddressType.IPv6) {
      var raw = this.toRawInt();
      return raw[0] == 0xff && raw[1] >= 0x02 && raw[1] <= 0xf2;
    }
    return false;
  }

  bool _isMCNodeLocal() {
    if (this._type == InetAddressType.IPv6) {
      var raw = this.toRawInt();
      return raw[0] == 0xff && raw[1] >= 0x01 && raw[1] <= 0xf1;
    }
    return false;
  }

  bool _isMCOrgLocal() {
    if (this._type == InetAddressType.IPv4) {
      var raw = this.toRawInt();
      return raw[0] == 239 && raw[1] >= 192 && raw[2] <= 195;
    }
    else if (this._type == InetAddressType.IPv6) {
      var raw = this.toRawInt();
      return raw[0] == 0xff && raw[1] >= 0x08 && raw[1] <= 0xf8;
    }
    return false;
  }

  bool _isMCSiteLocal() {
    if (this._type == InetAddressType.IPv4)
      return InetAddress._isContains(this.toRawInt(), [239, 255, 0, 0], [239, 255, 255, 255]);
    else if (this._type == InetAddressType.IPv6) {
      var raw = this.toRawInt();
      return raw[0] == 0xff && raw[1] >= 0x05 && raw[1] <= 0xf5;
    }
    return false;
  }

  bool _isMask() {
    var checkZero = false;
    var raw = this.toRawInt();
    for (var i = 0; i < raw.length; i++) {
      if (checkZero && raw[i] != 0x00)
        return false;
      else if (raw[i] == 0xff)
        continue;
      else if ([0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe].contains(raw[i]))
        checkZero = true;
      else
        return false;
    }
    return false;
  }
}