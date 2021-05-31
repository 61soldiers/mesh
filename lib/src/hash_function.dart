import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';

Future<String> getHexHashFromString(String toBeHashed) async {
  final hash = await Blake2b().hash(HEX.decode(toBeHashed));
  return HEX.encode(hash.bytes);
}

Future<String> getHexHashFromUint8List(List<int> toBeHashed) async {
  final hash = await Blake2b().hash(utf8.encode(HEX.encode(toBeHashed)));
  return HEX.encode(hash.bytes);
}
