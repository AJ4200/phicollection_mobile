import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

String getHash(String value)
{
  var bytes = utf8.encode(value); // data being hashed

  return sha256.convert(bytes).toString();
}