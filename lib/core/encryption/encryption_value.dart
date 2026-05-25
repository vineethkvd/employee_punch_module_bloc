import 'dart:convert';

class EncryptionValue {
  static final List<int> _keyByte =
  utf8.encode("80808080808080808080808080808080");

  static final List<int> _ivByte = utf8.encode("808080808080");
  static List<int> get keyByte => _keyByte;
  static List<int> get ivByte => _ivByte;
}