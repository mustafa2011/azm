import 'dart:convert';
import 'package:sprintf/sprintf.dart';

class Tag {
  final int tag;
  final String value;

  Tag(this.tag, this.value){
    if (value.isEmpty){
      throw Exception("Value cannot be null or empty");
    }
  }

  int getTag() => tag;

  String getValue() => value;

  int getLength() {
    List<int> bytes = utf8.encode(value);
    return bytes.length;
  }

  String toHex(int value) {
    String hex = sprintf("%02X", [value]).toString();
    String input = hex.length % 2 == 0 ? hex : "${hex}0";
    final output = StringBuffer();
    for (int i = 0; i < input.length; i += 2) {
      String str = input.substring(i, i + 2);
      var charRadix16 = int.tryParse(str, radix: 16);
      output.writeCharCode(charRadix16!);
    }
    // return output.toString();
    return output.toString();
  }

  @override
  String toString() {
    return toHex(getTag()) + toHex(getLength()) + getValue();
  }
}
