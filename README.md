# Flutter Interfaces Plus
Enhanced Flutter network interface plug-in for multiple platforms.



------

### Platforms will be supported
- [x] Android

- [ ] iOS *(developing)*

- [ ] Windows *(developing)*

- [ ] Linux *(developing)*

- [ ] MacOS *(developing)*



------

### Features will be provided
- [x] Lists all network card interfaces for the platform.
- [x] Get the interface name, index and MAC address.
- [x] Get the IP address, prefix length, mask and broadcast address.
- [x] Support IPv4 and IPv6.
- [x] Output full, compressed or raw address.
- [x] Can determine the network card type and address type such as `isVirtual`, `isLookBack` etc.
- [x] Can determines whether the address is within a range.
- [x] Can be converted to the object of DART library.



------

### APP Demo 

![image-20200915102802657](assets/image-20200915102802657.png)



------

### How to use

**Installing:** 

​	see https://pub.dev/packages/flutter_interfaces_plus/install



**Lists network card interfaces:**

```dart
import 'flutter_interfaces_plus/flutter_interfaces_plus';

InetInterface.list(
  includeLoopback: true,
  includeLinkLocal: true,
  includeIPv4: true,
  includeIPv6: true
).then((interfaces) {                // interfaces is List<InetInterface>
  interfaces.forEach((interface) {
    // Print network card information:
    print(interface.name);
    print(interface.index);
    print(interface.macString);
    print(interface.length);
    print(interface.isEmpty);
    print(interface.isVirtual);
    
    // Print information of each address of this interface:
    interface.forEach((address) {    // Equal to [interface.addresses.forEach(...)]
      print(address.ip);
      print(address.type);
      print(address.mask);
      print(address.broadcast);
      print(address.prefixLength);
    });
    
    // Print information of specified address:
    var address = interface[0];       // Equal to [interface.addresses[0]]
    print(address.toString());
    
    // Or you can use the [toString] method to print all informations about this interface:
    print(interface.toString());
  });
});
```



**Create `InetAddress` object:**

```dart
// Create IPv4 address
String ipv4 = "192.168.1.1";
InetAddress address1 = InetAddress(ipv4);

// Create IPv6 address
String ipv6 = "fe80::1234:5678:ABCD:1";
InetAddress address2 = InetAddress(ipv6);

// Create it by raw address
List<int> rawIpv4 = [192, 168, 1, 1];
InetAddress address3 = InetAddress.fromRawAddress(rawIpv4);
```



**Create `InetAddressGroup` object:**

```dart
// Create object by mask:
InetAddress ip = InetAddress("192.168.1.1");
InetAddress mask = InetAddress("255.255.255.0");
InetAddressGroup group = InetAddressGroup.byMask(ip: ip, mask: mask);

// Create object by prefix length:
InetAddress ip = InetAddress("192.168.1.1");
int prefix = 24
InetAddressGroup group = InetAddressGroup.byPrefixLength(ip: ip, prefixLength: prefix);
```



------

### Class Interfaces

**Properties and methods of `InetInterfaces`:**

```dart
/** Instance properties **/
int index;
String name;
Uint8List mac;      // eg. [228, 253, 161, 71, 158, 121]
String macString;   // eg. "E4-FD-A1-47-9E-79"
bool isVirtual;     // Determine if it's a virtual network card.
bool isEmpty;       // Has no address(es).
int length;         // count of addresses.
List<InetAddressGroup> addresses;


/** Instance methods **/
// Formatted output information
String toString();

// Convert to [InternetAddress] of DART library.
NetworkInterface toNetworkInterface();

// Iterate over all the elements of [addresses] property.
void forEach(void Function(InetAddressGroup address) f);

// Equal to "[]" operator of [addresses] property. 
InetAddressGroup operator [] (int index);


/** Static methods **/
// Lists all the filtered network card interfaces.
static Future<List<InetInterface>> list({
  bool includeLoopback: false,
  bool includeLinkLocal: false,
  bool includeIPv4: true,
  bool includeIPv6: true
});
```



**Properties and methods of `InetAddress`:**

```dart
/** Instance properties **/
InetAddressType type;       // IPv4 or IPv6
int bitsLength;             // 32 if IPv4 else 128
bool isAnyLocalAddress;
bool isLoopbackAddress;
bool isLinkLocalAddress;
bool isSiteLocalAddress;
bool isMulticastAddress;
bool isMCGlobal;
bool isMCLinkLocal;
bool isMCNodeLocal;
bool isMCOrgLocal;
bool isMCSiteLocal;
bool isMask;

/** Instance methods **/
// Convert to [InternetAddress] of DART library.
InternetAddress toInternetAddress();

// Concise form.  eg. "192.168.1.1" or "::1"
String toString();

// raw int.       eg. [192, 168, 1, 1]
List<int> toRawInt();

// raw string.    eg. ["192", "168", "1", "1"] or ["FE80", "0", ..., "FD1"]
List<String> toRawString();

// Tidy form.     eg. ["192", "168", "001", "001"] or ["FE80", "0000", ..., "0FD1"]
List<String> toRawStringTidy();


/** Static methods **/
// Determines whether an IP address is within a given range.
static bool isContains(InetAddress target, InetAddress floor, InetAddress ceiling);
```



**Properties and methods of `InetAddressGroup`:**

```dart
/** Instance properties **/
InetAddress ip;         // IP address
InetAddress mask;       // subnet mask
InetAddress broadcast;  // broadcast address
InetAddressType type;   // IPv4 or IPv6
int prefixLength;

/** Instace methods **/
String toString();      // Formatted output information

/** Static methods **/
static InetAddress InetAddressGroup.calcBroadcastAddressByMask(InetAddress ip, InetAddress mask);
static InetAddress InetAddressGroup.calcMaskByPrefixLength(int length, InetAddressType type);
static int InetAddressGroup.calcPrefixLengthByMask(InetAddress mask);
```

