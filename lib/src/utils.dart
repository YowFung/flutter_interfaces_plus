
/// convert int to hex string.
String toHex(int num, [int minLength = 0]) {
  var set = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
  var result = <String>[];
  while (num > 15) {
    var m = num % 16;
    result.insert(0, set[m]);
    num = num ~/ 16;
  }
  result.insert(0, set[num]);
  while (result.length < minLength)
    result.insert(0, '0');
  return result.join();
}