import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_interfaces_plus/src/utils.dart' show toHex;

void main() {
  test("0(10) -> ?(16)", () {
    int origin = 0;
    String result = toHex(origin);
    expect(result, "0");
  });

  test("5(10) -> ?(16)", () {
    int origin = 5;
    String result = toHex(origin);
    expect(result, "5");
  });

  test("15(10) -> ?(16)", () {
    int origin = 15;
    String result = toHex(origin);
    expect(result, "F");
  });

  test("16(10) -> ?(16)", () {
    int origin = 16;
    String result = toHex(origin);
    expect(result, "10");
  });

  test("17(10) -> ?(16)", () {
    int origin = 17;
    String result = toHex(origin);
    expect(result, "11");
  });

  test("57(10) -> ?(16)", () {
    int origin = 57;
    String result = toHex(origin);
    expect(result, "39");
  });

  test("245(10) -> ?(16)", () {
    int origin = 245;
    String result = toHex(origin);
    expect(result, "F5");
  });

  test("12345(10) -> ?(16)", () {
    int origin = 12345;
    String result = toHex(origin);
    expect(result, "3039");
  });

  test("12345678(10) -> ?(16)", () {
    int origin = 12345678;
    String result = toHex(origin);
    expect(result, "BC614E");
  });
}